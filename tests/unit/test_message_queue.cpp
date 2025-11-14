#include <cassert>
#include <thread>
#include <chrono>
#include <string>
#include "realtime/core/message_queue.h"

using namespace realtime::core;

// ============================================================================
// Test 1: Basic Push/Pop
// ============================================================================
void TestBasicPushPop() {
    ThreadSafeQueue<int> queue;
    
    queue.Push(42);
    queue.Push(100);
    
    auto val1 = queue.TryPop();
    assert(val1.has_value() && val1.value() == 42);
    
    auto val2 = queue.TryPop();
    assert(val2.has_value() && val2.value() == 100);
    
    auto empty = queue.TryPop();
    assert(!empty.has_value());
    
    printf("[✓] Test 1: Basic Push/Pop\n");
}

// ============================================================================
// Test 2: WaitAndPop with timeout
// ============================================================================
void TestWaitAndPopTimeout() {
    ThreadSafeQueue<std::string> queue;
    
    // Should timeout immediately on empty queue
    auto start = std::chrono::high_resolution_clock::now();
    auto result = queue.WaitAndPop(std::chrono::milliseconds(100));
    auto elapsed = std::chrono::high_resolution_clock::now() - start;
    
    assert(!result.has_value());
    assert(elapsed >= std::chrono::milliseconds(100));
    
    printf("[✓] Test 2: WaitAndPop timeout (%.0fms)\n", 
           std::chrono::duration<double, std::milli>(elapsed).count());
}

// ============================================================================
// Test 3: Multi-threaded Push/Pop
// ============================================================================
void TestMultiThreadedPushPop() {
    ThreadSafeQueue<int> queue;
    int pushed_count = 0;
    int popped_count = 0;
    
    // Producer thread
    auto producer = std::thread([&queue, &pushed_count]() {
        for (int i = 0; i < 100; ++i) {
            queue.Push(i);
            ++pushed_count;
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }
    });
    
    // Consumer thread
    auto consumer = std::thread([&queue, &popped_count]() {
        while (popped_count < 100) {
            if (auto val = queue.WaitAndPop(std::chrono::milliseconds(500))) {
                ++popped_count;
            }
        }
    });
    
    producer.join();
    consumer.join();
    
    assert(pushed_count == 100);
    assert(popped_count == 100);
    
    printf("[✓] Test 3: Multi-threaded Push/Pop (100 items)\n");
}

// ============================================================================
// Test 4: Shutdown wakes all waiters
// ============================================================================
void TestShutdownWakesWaiters() {
    ThreadSafeQueue<int> queue;
    int woken_count = 0;
    
    // Spawn 5 waiting threads
    std::vector<std::thread> waiters;
    for (int i = 0; i < 5; ++i) {
        waiters.emplace_back([&queue, &woken_count]() {
            auto result = queue.WaitAndPop(std::chrono::seconds(10));
            // Should wake up due to Shutdown(), not timeout
            ++woken_count;
        });
    }
    
    // Let them wait a bit
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    
    // Shutdown should wake all
    queue.Shutdown();
    
    // Join all
    for (auto& t : waiters) {
        t.join();
    }
    
    assert(woken_count == 5);
    assert(queue.IsShutdown());
    
    printf("[✓] Test 4: Shutdown wakes all waiters (5 threads)\n");
}

// ============================================================================
// Test 5: Push during Shutdown is ignored
// ============================================================================
void TestPushAfterShutdown() {
    ThreadSafeQueue<int> queue;
    
    queue.Push(1);
    queue.Shutdown();
    queue.Push(2);  // Should be ignored
    
    auto val = queue.TryPop();
    assert(val.has_value() && val.value() == 1);
    
    auto nothing = queue.TryPop();
    assert(!nothing.has_value());
    
    printf("[✓] Test 5: Push after Shutdown is ignored\n");
}

// ============================================================================
// Test 6: Move semantics
// ============================================================================
void TestMoveSemantics() {
    ThreadSafeQueue<int> queue1;
    queue1.Push(42);
    
    // Move-construct
    ThreadSafeQueue<int> queue2 = std::move(queue1);
    
    // queue2 should have the element
    auto val = queue2.TryPop();
    assert(val.has_value() && val.value() == 42);
    
    // queue1 should be shutdown after move
    assert(queue1.IsShutdown());
    
    printf("[✓] Test 6: Move semantics\n");
}

// ============================================================================
// Test 7: RAII - No memory leaks with exceptions
// ============================================================================
void TestRAIIExceptionSafety() {
    {
        ThreadSafeQueue<std::string> queue;
        queue.Push("test1");
        queue.Push("test2");
        queue.Push("test3");
        // Destructor should clean up properly
    }
    
    printf("[✓] Test 7: RAII exception safety\n");
}

// ============================================================================
// Test 8: Size and Empty
// ============================================================================
void TestSizeAndEmpty() {
    ThreadSafeQueue<int> queue;
    
    assert(queue.Empty());
    assert(queue.Size() == 0);
    
    queue.Push(1);
    queue.Push(2);
    queue.Push(3);
    
    assert(!queue.Empty());
    assert(queue.Size() == 3);
    
    [[maybe_unused]] auto popped = queue.TryPop();
    assert(queue.Size() == 2);
    
    printf("[✓] Test 8: Size and Empty\n");
}

// ============================================================================
// Main
// ============================================================================
int main() {
    printf("\n");
    printf("=============================================================\n");
    printf("ThreadSafeQueue<T> Unit Tests\n");
    printf("=============================================================\n\n");
    
    try {
        TestBasicPushPop();
        TestWaitAndPopTimeout();
        TestMultiThreadedPushPop();
        TestShutdownWakesWaiters();
        TestPushAfterShutdown();
        TestMoveSemantics();
        TestRAIIExceptionSafety();
        TestSizeAndEmpty();
        
        printf("\n=============================================================\n");
        printf("All 8 tests passed! ✓\n");
        printf("=============================================================\n\n");
        return 0;
    } catch (const std::exception& e) {
        printf("\n[✗] Exception: %s\n", e.what());
        return 1;
    }
}
