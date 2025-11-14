#pragma once

#include <hiredis/hiredis.h>
#include <memory>
#include <string_view>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <unordered_map>
#include <unordered_set>
#include <queue>
#include <functional>
#include <optional>
#include <chrono>

// Forward declaration - we don't use Lua C API directly anymore
struct lua_State;

namespace realtime {

// Event representing a Redis message
struct Event {
    std::string channel;
    std::string message;
    std::chrono::high_resolution_clock::time_point timestamp = std::chrono::high_resolution_clock::now();
};

// Thread-safe queue for inter-thread communication
template<typename T>
class ThreadSafeQueue {
public:
    void Push(T value) {
        {
            std::lock_guard<std::mutex> lock(mtx_);
            if (shutdown_) return;
            queue_.push(std::move(value));
        }
        cv_.notify_one();
    }

    std::optional<T> TryPop() {
        std::lock_guard<std::mutex> lock(mtx_);
        if (queue_.empty()) return std::nullopt;
        T value = std::move(queue_.front());
        queue_.pop();
        return value;
    }

    std::optional<T> WaitAndPop(
        std::chrono::milliseconds timeout = std::chrono::milliseconds(100)
    ) {
        std::unique_lock<std::mutex> lock(mtx_);
        if (!cv_.wait_for(lock, timeout, [this]{ return !queue_.empty() || shutdown_; })) {
            return std::nullopt;
        }
        if (shutdown_ && queue_.empty()) return std::nullopt;
        T value = std::move(queue_.front());
        queue_.pop();
        return value;
    }

    void Shutdown() {
        {
            std::lock_guard<std::mutex> lock(mtx_);
            shutdown_ = true;
        }
        cv_.notify_all();
    }

    bool IsShutdown() const {
        std::lock_guard<std::mutex> lock(mtx_);
        return shutdown_;
    }

private:
    mutable std::mutex mtx_;
    std::condition_variable cv_;
    std::queue<T> queue_;
    std::atomic<bool> shutdown_{false};
};

// Callback function type
using MessageCallback = std::function<void(std::string_view channel, std::string_view message)>;

// RAII wrapper for Lua callback stored in registry
class LuaCallback {
public:
    LuaCallback() noexcept = default;
    ~LuaCallback() noexcept = default;

    // Delete copy, allow move
    LuaCallback(const LuaCallback&) = delete;
    LuaCallback& operator=(const LuaCallback&) = delete;

    LuaCallback(LuaCallback&& other) noexcept = default;
    LuaCallback& operator=(LuaCallback&& other) noexcept = default;

    // Store as empty - we'll use table-based dispatch in Lua instead
    bool IsValid() const noexcept { return true; }
};

// Manages Redis subscriptions with background thread
class SubscriptionManager {
public:
    SubscriptionManager() noexcept;
    ~SubscriptionManager() noexcept;

    // Delete copy, allow move
    SubscriptionManager(const SubscriptionManager&) = delete;
    SubscriptionManager& operator=(const SubscriptionManager&) = delete;

    // Start subscription to a channel
    // Returns true on success
    bool Subscribe(std::string_view channel) noexcept;

    // Stop subscription to a channel
    bool Unsubscribe(std::string_view channel) noexcept;

    // Process one event from the queue (called from main thread)
    // Returns the event if one was available, std::nullopt if queue empty
    std::optional<Event> ProcessEvent() noexcept;

    // Stop all subscriptions and shut down background thread
    void Shutdown() noexcept;

    bool IsRunning() const noexcept { return running_; }

private:
    // Background thread that reads Redis SUBSCRIBE messages
    void SubscriberLoop() noexcept;

    // RAII wrapper for subscription context
    struct RedisContextDeleter {
        void operator()(redisContext* ctx) const noexcept {
            if (ctx) redisFree(ctx);
        }
    };

    // State: subscriber context, event queue
    std::unique_ptr<redisContext, RedisContextDeleter> subscriber_ctx_;
    std::unordered_set<std::string> subscribed_channels_;
    ThreadSafeQueue<Event> event_queue_;

    // Threading
    std::thread subscriber_thread_;
    std::atomic<bool> running_{false};
    mutable std::mutex callbacks_mtx_;
};

} // namespace realtime
