#include "realtime/redis_client.h"
#include <hiredis/hiredis.h>
#include <iostream>

namespace realtime {

void RedisClient::RedisContextDeleter::operator()(redisContext* ctx) const {
    if (ctx) redisFree(ctx);
}

RedisClient::RedisClient() = default;

RedisClient::~RedisClient() {
    Disconnect();
}

bool RedisClient::Connect(std::string_view host, int port) noexcept {
    ctx_.reset(redisConnect(host.data(), port));
    if (!ctx_ || ctx_->err) {
        std::cerr << "[Redis] Connection failed: " << (ctx_ ? ctx_->errstr : "Unknown") << std::endl;
        ctx_.reset();
        return false;
    }
    std::cerr << "[Redis] Connected to " << host << ":" << port << std::endl;
    return true;
}

bool RedisClient::Publish(std::string_view channel, std::string_view message) noexcept {
    if (!ctx_) return false;

    void* r = redisCommand(ctx_.get(), "PUBLISH %b %b",
        channel.data(), static_cast<size_t>(channel.size()),
        message.data(), static_cast<size_t>(message.size()));

    if (!r) return false;

    freeReplyObject(r);
    return true;
}

void RedisClient::Disconnect() noexcept {
    ctx_.reset();
}

bool RedisClient::IsConnected() const noexcept {
    return static_cast<bool>(ctx_);
}

} // namespace realtime
