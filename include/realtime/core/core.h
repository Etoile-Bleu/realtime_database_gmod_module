#pragma once

// ============================================================================
// realtime/core - Core Infrastructure Components
// ============================================================================
//
// Thread-safe utilities and templates for the realtime module.
// No external dependencies (no Redis, no Lua beyond lua.h, no GMod).
// Fully testable in isolation.
//

#include "realtime/core/message_queue.h"
#include "realtime/core/lua_callback.h"

namespace realtime::core {
    // All exports via includes above
}  // namespace realtime::core
