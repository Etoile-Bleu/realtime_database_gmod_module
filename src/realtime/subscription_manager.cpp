#include "realtime/subscription_manager.h"
#include <iostream>

namespace realtime {

// ============================================================================
// LuaCallback Implementation (Empty - we use Lua table dispatch instead)
// ============================================================================

// LuaCallback is now just an empty placeholder.
// Callbacks will be dispatched through a Lua table from ProcessEvent().

// ============================================================================
// SubscriptionManager Implementation
// ============================================================================

SubscriptionManager::SubscriptionManager() noexcept = default;

SubscriptionManager::~SubscriptionManager() noexcept {
    Shutdown();
}

bool SubscriptionManager::Subscribe(std::string_view channel) noexcept {
    if (channel.empty()) {
        return false;
    }

    // First subscription: create subscriber context
    if (!subscriber_ctx_) {
        // Create dedicated Redis connection for subscribing
        subscriber_ctx_.reset(redisConnect("127.0.0.1", 6379));
        
        if (!subscriber_ctx_) {
            std::cerr << "[Redis] Failed to create subscriber context" << std::endl;
            return false;
        }
        if (subscriber_ctx_->err) {
            std::cerr << "[Redis] Subscriber context error: " << subscriber_ctx_->errstr << std::endl;
            subscriber_ctx_.reset();
            return false;
        }
    }

    // Store the channel name - callbacks are looked up in Lua at runtime
    bool is_new_subscription = false;
    {
        std::lock_guard<std::mutex> lock(callbacks_mtx_);
        if (subscribed_channels_.count(std::string(channel)) == 0) {
            subscribed_channels_.insert(std::string(channel));
            is_new_subscription = true;
        }
    }

    // Start reader thread only once (before first SUBSCRIBE)
    // This prevents race conditions when sending commands
    if (!running_) {
        running_ = true;
        subscriber_thread_ = std::thread([this]() { SubscriberLoop(); });
    }

    // Only send SUBSCRIBE if this is a new channel (idempotent)
    // Multiple Lua callbacks can subscribe to the same Redis channel
    if (is_new_subscription) {
        // Send SUBSCRIBE command asynchronously (append, don't block)
        int status = redisAppendCommand(subscriber_ctx_.get(), "SUBSCRIBE %b",
            channel.data(), static_cast<size_t>(channel.size()));

        if (status != REDIS_OK) {
            std::cerr << "[Redis] Failed to send SUBSCRIBE command" << std::endl;
            {
                std::lock_guard<std::mutex> lock(callbacks_mtx_);
                subscribed_channels_.erase(std::string(channel));
            }
            return false;
        }

        // Flush the write buffer to ensure command is sent immediately
        int done = 0;
        if (redisBufferWrite(subscriber_ctx_.get(), &done) == -1) {
            std::cerr << "[Redis] Failed to flush SUBSCRIBE command" << std::endl;
            {
                std::lock_guard<std::mutex> lock(callbacks_mtx_);
                subscribed_channels_.erase(std::string(channel));
            }
            return false;
        }
    }

    std::cerr << "[Redis] Subscribed to: " << channel << std::endl;
    return true;
}

bool SubscriptionManager::Unsubscribe(std::string_view channel) noexcept {
    if (!subscriber_ctx_ || channel.empty()) {
        return false;
    }

    {
        std::lock_guard<std::mutex> lock(callbacks_mtx_);
        if (!subscribed_channels_.count(std::string(channel))) {
            return false;
        }
        subscribed_channels_.erase(std::string(channel));
    }

    void* reply = redisCommand(subscriber_ctx_.get(), "UNSUBSCRIBE %b",
        channel.data(), static_cast<size_t>(channel.size()));

    if (!reply) {
        return false;
    }

    freeReplyObject(reply);
    return true;
}

std::optional<Event> SubscriptionManager::ProcessEvent() noexcept {
    return event_queue_.TryPop();
}


void SubscriptionManager::Shutdown() noexcept {
    if (!running_) return;

    running_ = false;
    event_queue_.Shutdown();

    if (subscriber_thread_.joinable()) {
        subscriber_thread_.join();
    }

    {
        std::lock_guard<std::mutex> lock(callbacks_mtx_);
        subscribed_channels_.clear();
    }

    subscriber_ctx_.reset();
}

void SubscriptionManager::SubscriberLoop() noexcept {
    if (!subscriber_ctx_) return;

    while (running_) {
        redisReply* reply = nullptr;

        // Use redisGetReply to fetch messages (with timeout)
        // This allows us to receive SUBSCRIBE/MESSAGE/PSUBSCRIBE replies
        int ret = redisGetReply(subscriber_ctx_.get(), reinterpret_cast<void**>(&reply));

        if (ret != REDIS_OK || !reply) {
            if (running_) {
                std::cerr << "[Redis] Subscriber connection lost" << std::endl;
            }
            break;
        }

        // Handle MESSAGE reply (SUBSCRIBE generates: [message, channel, data])
        if (reply->type == REDIS_REPLY_ARRAY && reply->elements >= 3) {
            if (reply->element[0]->type == REDIS_REPLY_STRING) {
                std::string type(reply->element[0]->str, reply->element[0]->len);

                if (type == "message" && reply->elements == 3) {
                    std::string channel(reply->element[1]->str, reply->element[1]->len);
                    std::string message(reply->element[2]->str, reply->element[2]->len);

                    // Queue the event for main thread
                    event_queue_.Push({std::move(channel), std::move(message)});
                }
            }
        }

        freeReplyObject(reply);
    }

    std::cerr << "[Redis] Subscriber thread exiting" << std::endl;
}

} // namespace realtime

