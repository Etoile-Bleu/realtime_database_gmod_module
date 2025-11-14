#pragma once

#include <queue>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <optional>
#include <chrono>

namespace realtime::core {

// ============================================================================
// ThreadSafeQueue<T> - RAII Thread-Safe Message Queue
// ============================================================================
//
// Production-grade queue for inter-thread communication.
// Per instructions: Modern C++ (C++17), RAII, std::mutex, std::lock_guard,
// std::condition_variable, zero manual resource management.
//
// Guarantees:
// - Thread-safe Push() / TryPop() / WaitAndPop()
// - No deadlocks (uses std::lock_guard, not manual lock/unlock)
// - Exception-safe RAII design
// - Graceful Shutdown() to wake all waiters
//
// Usage:
//   ThreadSafeQueue<Message> queue;
//   
//   // Producer thread:
//   queue.Push({channel, data});
//   
//   // Consumer thread:
//   while (auto msg = queue.WaitAndPop(timeout)) {
//       ProcessMessage(*msg);
//   }
//   
//   // Shutdown (from any thread):
//   queue.Shutdown();
//
// ============================================================================

template<typename T>
class ThreadSafeQueue {
private:
    mutable std::mutex mtx_;
    std::queue<T> queue_;
    std::condition_variable cv_;
    std::atomic<bool> shutdown_{false};

public:
    ThreadSafeQueue() = default;
    
    // Delete copy (not thread-safe to copy)
    ThreadSafeQueue(const ThreadSafeQueue&) = delete;
    ThreadSafeQueue& operator=(const ThreadSafeQueue&) = delete;
    
    // Allow move (empty source after move)
    ThreadSafeQueue(ThreadSafeQueue&& other) noexcept
        : shutdown_(other.shutdown_.load()) {
        std::lock_guard lock(other.mtx_);
        queue_ = std::move(other.queue_);
        other.shutdown_ = true;  // Mark source as shutdown
    }
    
    ThreadSafeQueue& operator=(ThreadSafeQueue&& other) noexcept {
        if (this != &other) {
            std::lock_guard lock(mtx_);
            std::lock_guard other_lock(other.mtx_);
            queue_ = std::move(other.queue_);
            shutdown_ = other.shutdown_.load();
            other.shutdown_ = true;
        }
        return *this;
    }
    
    // ========================================================================
    // Push() - Add element to queue (thread-safe)
    // ========================================================================
    // Precondition: Called from any thread
    // Postcondition: Element added, one waiter notified
    // Thread-safe: Yes (via std::lock_guard)
    // Blocks: Never
    // Returns: Nothing (void)
    //
    void Push(T value) {
        {
            std::lock_guard lock(mtx_);
            if (shutdown_) return;  // Silently drop if shutdown
            queue_.push(std::move(value));
        }
        cv_.notify_one();  // Wake one waiter
    }
    
    // ========================================================================
    // TryPop() - Non-blocking pop (thread-safe)
    // ========================================================================
    // Returns: std::optional<T>
    //   - Has value if element was in queue
    //   - Empty if queue is empty (doesn't wait)
    // Thread-safe: Yes
    // Blocks: Never
    //
    [[nodiscard]] std::optional<T> TryPop() {
        std::lock_guard lock(mtx_);
        if (queue_.empty()) {
            return std::nullopt;
        }
        T value = std::move(queue_.front());
        queue_.pop();
        return value;
    }
    
    // ========================================================================
    // WaitAndPop() - Blocking pop with timeout (thread-safe)
    // ========================================================================
    // Parameters:
    //   timeout - Max wait time (default: infinite)
    // Returns: std::optional<T>
    //   - Has value if element retrieved
    //   - Empty if timeout or shutdown
    // Thread-safe: Yes
    // Blocks: Up to timeout milliseconds (or until element available)
    // Exceptions: None (noexcept)
    //
    [[nodiscard]] std::optional<T> WaitAndPop(
        std::chrono::milliseconds timeout = std::chrono::milliseconds::max()
    ) noexcept {
        std::unique_lock lock(mtx_);
        
        // Wait for element or shutdown
        if (!cv_.wait_for(lock, timeout, [this] {
            return !queue_.empty() || shutdown_;
        })) {
            return std::nullopt;  // Timeout
        }
        
        // Check if we're shutting down with empty queue
        if (shutdown_ && queue_.empty()) {
            return std::nullopt;
        }
        
        // Pop element
        T value = std::move(queue_.front());
        queue_.pop();
        return value;
    }
    
    // ========================================================================
    // Shutdown() - Signal all threads to wake up
    // ========================================================================
    // Precondition: Called from any thread (usually main thread)
    // Postcondition: All waiters unblocked, queue refuses new items
    // Thread-safe: Yes
    // Blocks: Never
    //
    void Shutdown() noexcept {
        {
            std::lock_guard lock(mtx_);
            shutdown_ = true;
        }
        cv_.notify_all();  // Wake all waiters
    }
    
    // ========================================================================
    // IsShutdown() - Check if queue is shutting down
    // ========================================================================
    [[nodiscard]] bool IsShutdown() const noexcept {
        return shutdown_.load();
    }
    
    // ========================================================================
    // Size() - Get current queue depth (snapshot)
    // ========================================================================
    // Note: Size changes immediately after return, so only use for stats
    [[nodiscard]] size_t Size() const {
        std::lock_guard lock(mtx_);
        return queue_.size();
    }
    
    // ========================================================================
    // Empty() - Check if queue is empty (snapshot)
    // ========================================================================
    [[nodiscard]] bool Empty() const {
        std::lock_guard lock(mtx_);
        return queue_.empty();
    }

private:
    // No other methods
};

}  // namespace realtime::core
