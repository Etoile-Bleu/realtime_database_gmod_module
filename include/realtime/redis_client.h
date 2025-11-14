#pragma once

#include <hiredis/hiredis.h>
#include <memory>
#include <optional>
#include <string>

namespace realtime {

class RedisClient {
public:
    RedisClient();
    ~RedisClient();

    // Try to connect to host:port. Returns true on success
    bool Connect(std::string_view host, int port) noexcept;

    // Publish a message to a channel. Returns true on success
    bool Publish(std::string_view channel, std::string_view message) noexcept;

    // Disconnects and frees resources
    void Disconnect() noexcept;

    bool IsConnected() const noexcept;

private:
    struct RedisContextDeleter {
        void operator()(redisContext* ctx) const;
    };

    std::unique_ptr<redisContext, RedisContextDeleter> ctx_{};
};

} // namespace realtime
