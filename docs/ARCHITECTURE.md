# Architecture - GMod Realtime Module

## Structure des Dossiers

```
src/
├── module_entry.cpp          # Entry point GMOD_MODULE_OPEN/CLOSE (épuré)
├── core/
│   ├── message_queue.h       # ThreadSafeQueue<T> template
│   ├── lua_callback.h        # LuaCallback RAII wrapper
│   ├── redis_client.h        # IBackend interface abstraite
│   ├── realtime_module.h     # Gestionnaire principal du module
│   └── realtime_module.cpp   # Implémentation
├── backend/
│   └── redis_backend.h       # RedisBackend implémentation
└── lua/
    ├── lua_api.h             # Déclarations des fonctions Lua
    └── lua_api.cpp           # Implémentations des bindings
```

## Principes Directeurs

### 1. **Séparation des Responsabilités**
- `core/` : Logique C++ pure, abstractions
- `backend/` : Implémentations Redis (extensible)
- `lua/` : Interface Lua seulement
- `module_entry.cpp` : Point d'entrée minimaliste

### 2. **Standards Modernes C++17**
- ✅ `std::unique_ptr` avec custom deleters (RAII)
- ✅ `std::optional` pour les valeurs optionnelles
- ✅ Templates pour la réutilisabilité
- ✅ `std::lock_guard` pour thread-safety
- ✅ AUCUN raw pointer sauf aux limites API

### 3. **Thread Safety (CRITIQUE)**
```
Worker Thread (Redis)        Main Thread (Lua)
    ↓                            ↓
  Read Redis      Queue      Process Callbacks
  Queue Events  ←────→  Call Lua Functions
  (pas de Lua)
```

### 4. **Extensibilité (Open/Closed)**
Ajouter PostgreSQL = créer `src/backend/postgres_backend.h` sans toucher Redis

## Flux d'Exécution

### Initialisation
```
GMOD_MODULE_OPEN()
  → RealtimeModule::Get().Initialize()
    → RedisBackend::Connect()
      → StartSubscriberThread() (worker thread démarre)
    → Register Lua functions
```

### Événements Temps-Réel
```
Redis SUBSCRIBE (worker thread)
  → redisGetReply() (blocking)
  → ProcessReply() (parse)
  → event_queue.Push() (RAII queue)
    ↓
Lua: realtime.ProcessEvents() (Think hook)
  → ProcessEventQueue() (main thread)
  → LuaCallback::Call() (déclenche callback Lua)
```

### Shutdown
```
GMOD_MODULE_CLOSE()
  → RealtimeModule::Get().Shutdown()
    → backend->Disconnect()
    → event_queue.Shutdown()
    → subscriber_thread.join()
    → Clear callbacks
```

## Règles Strictes

### Mémoire
- ✅ `std::unique_ptr` pour ownership
- ✅ `std::lock_guard` (RAII locks, exception-safe)
- ❌ `new`/`delete` ou `malloc`/`free`
- ❌ Raw pointers sauf API boundaries

### Thread Safety
- ✅ Worker thread JAMAIS appelle Lua
- ✅ Worker thread QUE queue les événements
- ✅ Main thread SEULE traite callbacks Lua
- ❌ Pas de mutable globals
- ❌ Pas de mutex.lock/unlock() (use lock_guard)

### Erreurs
- ✅ `Result<T, E>` pour erreurs hors hot-path
- ✅ Exceptions pour erreurs critiques
- ❌ `bool` silencieux (return true/false)
- ❌ Codes d'erreur magiques

## Exemple: Ajouter un Backend PostgreSQL

### 1. Créer le fichier
```cpp
// src/backend/postgres_backend.h
class PostgresBackend final : public IBackend {
public:
    Result<void> Connect(...) override;
    Result<void> Publish(...) override;
    Result<void> Subscribe(...) override;
    // ... etc
};
```

### 2. Updater le factory (dans `realtime_module.cpp`)
```cpp
auto backend = CreateBackend(BackendType::PostgreSQL);
```

### 3. RIEN d'autre à toucher!
Redis backend reste 100% inchangé ✅

## Testing Strategy

```
Unit Tests (fast, no Redis):
  ├─ test_message_queue.cpp
  ├─ test_lua_callback.cpp
  └─ test_result_type.cpp

Integration Tests (with Redis):
  ├─ test_redis_connect.cpp
  ├─ test_redis_publish.cpp
  └─ test_redis_subscribe.cpp

Manual Tests (GMod):
  └─ Véhicules, kills, chat events
```

## Performance Targets

- **Latency**: PUBLISH → Callback < 5ms
- **Memory**: 10,000 events in-flight < 10MB
- **CPU**: 100 concurrent callbacks < 5%
- **Sustained**: 1000 events/sec pour 1h

## Code Review Checklist

- [ ] Zéro warnings compilateur (-Wall -Wextra)
- [ ] Pas de raw pointers (sauf API)
- [ ] Toutes ressources RAII
- [ ] Thread-safe ou documenté single-threaded
- [ ] Pas imports inutilisés
- [ ] Tous error paths explicites
- [ ] Pas nombres magiques
- [ ] Pas TODO/FIXME old
- [ ] Extensible sans modifications?
- [ ] Testable isolé?

## Notes

- **Single Server**: Pas d'arbitration multi-serveur
- **Redis = Source de Vérité**: Events perdus = acceptable (pub/sub nature)
- **Lua Calls = Main Thread Only**: CRITICAL pour éviter crashes GMod
- **Zero Polling from Lua**: Events driven par worker thread
