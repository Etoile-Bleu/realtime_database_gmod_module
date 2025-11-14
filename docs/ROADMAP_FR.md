# Feuille de Route - Module Realtime GMod

**État**: Phase POC ✅ → Phase Production 🚀

## Contexte du Projet
- **Portée**: Un seul serveur GMod + Redis local/distant
- **Objectif**: Streaming d'événements temps réel sans polling
- **Standards**: C++17 moderne, RAII, thread-safe, production-ready

---

## Phase 1: Architecture de Base (CRITIQUE) 🔴

### 1.1 Refactorisation: Séparer les Responsabilités
**Pourquoi**: Le code actuel est dans un seul fichier. Les instructions exigent scalabilité & testabilité.

**Tâches**:
- [ ] Créer `src/core/redis_client.h` - Interface abstraite `IBackend`
- [ ] Créer `src/backend/redis_backend.cpp` - Implémentation Redis
- [ ] Créer `src/core/message_queue.h` - Queue thread-safe (template)
- [ ] Créer `src/core/lua_bindings.h` - Wrapper API Lua
- [ ] Déplacer `Lua_Connect`, `Lua_Publish`, etc. dans un fichier séparé
- [ ] Supprimer la variable globale `g_redis` → utiliser l'injection de dépendances

**Structure attendue**:
```
src/
├── core/
│   ├── redis_client.h         (Interface IBackend)
│   ├── message_queue.h        (ThreadSafeQueue<T>)
│   └── lua_callback.h         (Wrapper RAII pour Lua)
├── backend/
│   ├── redis_backend.h
│   └── redis_backend.cpp
├── lua/
│   ├── module_entry.cpp       (GMOD_MODULE_OPEN/CLOSE)
│   └── lua_api.cpp            (Wrappers Lua)
└── main.cpp                   (minimal)
```

**Vérification**: Peux-tu ajouter un backend PostgreSQL sans toucher le code Redis ? Si oui, c'est bon ✅

---

### 1.2 Implémenter une Queue Thread-Safe
**Pourquoi**: Les instructions exigent du threading sans mutex bruts. Besoin d'une queue RAII pour communication worker thread → thread principal.

**Implémentation**:
```cpp
template<typename T>
class ThreadSafeQueue {
    // Per instructions: std::mutex + std::lock_guard + std::condition_variable
    // Méthodes: Push(), TryPop(), WaitAndPop(timeout), Shutdown()
};
```

**Tâches**:
- [ ] Créer `src/core/message_queue.h` avec implémentation complète
- [ ] Ajouter tests unitaires: `tests/unit/test_message_queue.cpp`
- [ ] Vérifier: Pas de deadlocks, pas de race conditions (utiliser clang-tidy)

---

### 1.3 Implémenter la Gestion des Références Lua (RAII)
**Pourquoi**: Les instructions montrent un wrapper `LuaCallback`. Critique pour ne pas perdre les références registry.

**Implémentation**:
```cpp
class LuaCallback {
    lua_State* L;
    int ref;  // Référence LUA_REGISTRYINDEX
public:
    LuaCallback(lua_State* L, int stack_idx);   // Push et ref
    ~LuaCallback();                              // Unref automatiquement
    LuaCallback(const LuaCallback&) = delete;   // Pas de copie
    LuaCallback(LuaCallback&&) noexcept;        // Move autorisé
    void Call(std::string_view channel, std::string_view msg);
};
```

**Tâches**:
- [ ] Créer `src/core/lua_callback.h` avec wrapper RAII complet
- [ ] Ajouter tests unitaires: `tests/unit/test_lua_callback.cpp`
- [ ] Vérifier: Pas de fuites registry après 1000+ callbacks

---

## Phase 2: Architecture Asynchrone (BLOQUANT) 🔴

### 2.1 Implémenter Subscribe Asynchrone avec Worker Thread
**Pourquoi**: Le subscribe actuel est synchrone. Besoin d'un thread de fond gérant le flux Redis.

**Design**:
```cpp
class RedisBackend final : public IBackend {
    std::thread subscriber_thread;      // Gère SUBSCRIBE
    ThreadSafeQueue<Event> event_queue; // Worker → Thread principal
    std::atomic<bool> connected{false};
    
    void SubscriberLoop();                              // Thread worker: lit Redis, queue events
    void ProcessEventQueue(lua_State* L);              // Thread principal: déclenche callbacks
};
```

**Tâches**:
- [ ] Implémenter `RedisBackend::SubscriberLoop()` - gère Redis SUBSCRIBE
- [ ] Implémenter routage des événements vers callbacks Lua (à partir de la queue)
- [ ] Ajouter timeout & gestion d'erreurs (perte de connexion, crash Redis)
- [ ] Thread-safe callback registry (`std::unordered_map<std::string, LuaCallback>`)

**CRITIQUE**: Le worker thread ne doit JAMAIS appeler Lua directement. Uniquement queuer les événements. Le thread principal déclenche.

---

### 2.2 Implémenter les Hooks de Cycle de Vie du Module
**Pourquoi**: Besoin d'une initialisation/désactivation correcte, cleanup des ressources gracieux.

**Tâches**:
- [ ] `GMOD_MODULE_OPEN()` → Initialiser le backend, démarrer worker thread
- [ ] `GMOD_MODULE_CLOSE()` → Arrêter worker thread, fermer connexions
- [ ] Lua: `realtime.ProcessEvents()` → Appeler depuis hook `Think` pour vider queue
- [ ] Gestion d'erreurs: Fallback gracieux si Redis indisponible

---

## Phase 3: Implémentation Production-Ready 🟡

### 3.1 Gestion d'Erreurs & Gestion des Connexions
**Pourquoi**: L'implémentation actuelle suppose que Redis fonctionne toujours. Besoin de résilience.

**Tâches**:
- [ ] Implémenter pattern `Result<T, E>` (per instructions)
- [ ] Gérer les échecs de connexion Redis (reconnection logic avec backoff)
- [ ] Implémenter timeout configurable
- [ ] Ajouter logging: `[Redis]`, `[Error]`, `[Warn]` avec préfixes
- [ ] Tester: Comportement quand Redis s'arrête en plein traitement

**Cas d'erreur**:
```cpp
// ❌ Actuel: Retourne bool, silences d'erreur
LUA->PushBool(false);  // Pourquoi a échoué?

// ✅ Mieux: Type Result
Result<void> Connect(...);  // Peux vérifier IsErr() et Error()
```

---

### 3.2 Étendre les Fonctions POC - Événements Production
**Pourquoi**: Le POC actuel a tracking véhicule basique. Besoin d'événements plus réalistes.

**Ajouter Fonctions**:
- [ ] `realtime.PlayerSpawn(player_name, team, pos)`
- [ ] `realtime.PlayerDeath(victim_name, attacker_name, weapon)`
- [ ] `realtime.ChatMessage(player_name, message)`
- [ ] `realtime.PlayerTakeDamage(victim_name, damage, attacker_name)`
- [ ] `realtime.RoundStart(gamemode, map)`
- [ ] `realtime.RoundEnd(winner_team, score)`

**Chaque fonction**:
- Publie sur le canal approprié (`player:spawn`, `chat:message`, etc.)
- Format JSON avec timestamp
- Gestion d'erreurs per pattern Result<T>

---

### 3.3 Système de Configuration
**Pourquoi**: Hardcoder `127.0.0.1:6379` ne fonctionnera pas. Besoin de variables env ou fichier config.

**Tâches**:
- [ ] Ajouter config Lua: `realtime.Config(host, port, password, timeout)`
- [ ] Support variables d'environnement: `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`
- [ ] Parsing fichier `.env` (optionnel)
- [ ] Valider configuration avant connexion

**Exemple**:
```lua
-- Au démarrage Lua
realtime.Config("redis.example.com", 6379, "monmotdepasse", 5)
realtime.Connect()  -- Utilise la config
```

---

## Phase 4: Tests & Validation 🟡

### 4.1 Tests Unitaires (Pas de Dépendances)
**Pourquoi**: Les instructions exigent du code testable. Tests unitaires sans Redis/GMod.

**Fichiers de Test**:
- [ ] `tests/unit/test_message_queue.cpp` - Push/pop/shutdown de queue
- [ ] `tests/unit/test_lua_callback.cpp` - Wrapper RAII + registry
- [ ] `tests/unit/test_result_type.cpp` - Pattern gestion d'erreurs
- [ ] `tests/unit/test_config.cpp` - Parsing configuration

**CMake**:
```cmake
add_executable(unit_tests
    tests/unit/test_message_queue.cpp
    tests/unit/test_lua_callback.cpp
)
target_link_libraries(unit_tests PRIVATE realtime_core)
```

**Exécution**: `ctest` → doit être <1 seconde, pas de dépendances externes

---

### 4.2 Tests d'Intégration (Avec Redis)
**Pourquoi**: Vérifier que la communication Redis réelle fonctionne.

**Fichiers de Test**:
- [ ] `tests/integration/test_redis_connect.cpp` - Connexion/déconnexion
- [ ] `tests/integration/test_redis_publish.cpp` - Publier message
- [ ] `tests/integration/test_redis_subscribe.cpp` - Subscribe + recevoir
- [ ] `tests/integration/test_redis_threading.cpp` - Worker thread + events

**Requisit**: Redis actif localement (skip si indisponible)

**CMake**:
```cmake
add_executable(integration_tests
    tests/integration/test_redis_publish.cpp
)
target_link_libraries(integration_tests PRIVATE gmsv_realtime hiredis)
```

**Exécution**: `ctest --label-regex integration` (si Redis disponible)

---

### 4.3 Tests Manuels (Intégration GMod)
**Pourquoi**: Vérifier que le module charge dans GMod réel, pas de crashes.

**Checklist**:
- [ ] Module charge: `require("realtime")` fonctionne
- [ ] Connexion fonctionne: `realtime.Connect("127.0.0.1", 6379)` retourne true
- [ ] Publish fonctionne: `realtime.Publish("test", "hello")` envoie message
- [ ] Subscribe fonctionne: Messages arrivent dans callback (zéro lag)
- [ ] Déchargement sans crash: `GMOD_MODULE_CLOSE()`
- [ ] 1000+ événements: Pas de fuites mémoire (profil avec Valgrind)

---

## Phase 5: Documentation & Polish 🟢

### 5.1 Documentation API
**Tâches**:
- [ ] Créer `docs/API.md` - Toutes les fonctions Lua avec exemples
- [ ] Créer `docs/ARCHITECTURE.md` - Décisions de design, modèle threading
- [ ] Créer `docs/BUILD.md` - Guide build Windows (MSVC) + Linux (GCC)
- [ ] Créer `docs/TROUBLESHOOTING.md` - Problèmes courants & solutions

---

### 5.2 Qualité Code
**Tâches**:
- [ ] Exécuter `clang-format` - Style cohérent
- [ ] Exécuter `clang-tidy` - Analyse statique (catch bugs)
- [ ] Exécuter `cppcheck` - Vérifications additionnelles
- [ ] Vérifier: Zéro warnings compilateur avec `/W4 /WX` (MSVC) et `-Wall -Wextra -Werror` (GCC)

---

### 5.3 Profiling Performance
**Pourquoi**: Vérifier que la latence atteint les exigences temps-réel.

**Tâches**:
- [ ] Mesurer latence: PUBLISH → Callback déclenché (cible: <5ms)
- [ ] Mesurer mémoire: 10,000 événements en vol (cible: <10MB)
- [ ] Mesurer CPU: 100 callbacks concurrents (cible: <5% CPU)
- [ ] Tester: Charge soutenue (1000 événements/sec pendant 1 heure)

---

## Phase 6: Features Avancées (Nice-to-Have) 🟢

### 6.1 Stockage Persistant de Messages
**Pourquoi**: S'assurer qu'aucun événement n'est perdu, même si subscriber temporairement indisponible.

**Options d'Implémentation**:
- [ ] Utiliser Redis `XREAD` (streams) au lieu de `SUBSCRIBE`
- [ ] Ajouter queue SQLite local en backup
- [ ] Implémenter: Fallback disque si Redis down

---

### 6.2 Filtrage Multi-Canal
**Pourquoi**: Permettre à Lua de subscribe à des patterns, pas seulement canaux exacts.

**Tâches**:
- [ ] Implémenter support `PSUBSCRIBE` (Redis pattern subscribe)
- [ ] API Lua: `realtime.SubscribePattern("player:*")`

---

### 6.3 Métriques & Monitoring
**Pourquoi**: Tracker la santé du module en production.

**Tâches**:
- [ ] Exposer compteurs: `realtime.GetStats()` → {published, received, dropped}
- [ ] Ajouter commande redis: `INFO gmod:realtime` (commande Redis custom ?)
- [ ] Ajouter métriques Lua: Événements par seconde, profondeur queue, etc.

---

## Ordre d'Implémentation (Priorité)

**Semaine 1-2 (Chemin Critique)**:
1. Phase 1.1 - Refactorisation en modules (architecture)
2. Phase 1.2 - Queue thread-safe + tests
3. Phase 2.1 - Subscribe asynchrone avec worker thread
4. Phase 2.2 - Hooks cycle de vie module

**Semaine 3 (Production)**:
5. Phase 3.1 - Gestion d'erreurs (Result<T>)
6. Phase 3.2 - Plus de types d'événements
7. Phase 4.1 - Tests unitaires

**Semaine 4 (Polish)**:
8. Phase 3.3 - Système de configuration
9. Phase 4.2 - Tests d'intégration
10. Phase 5.1 - Documentation

---

## Critères de Réussite ✅

### Pour Chaque Feature:
- [ ] Code suit les instructions (C++17, RAII, pas de raw pointers, thread-safe)
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent (si applicable)
- [ ] Zéro warnings compilateur
- [ ] Clang-tidy clean
- [ ] Checklist code review satisfaite
- [ ] Documentation à jour

### Pour Release Complète:
- [ ] Phases 1-5 complètes
- [ ] 0 fuite mémoire (Valgrind)
- [ ] Latence <5ms provée (benchmark)
- [ ] Gère 1000+ événements concurrents
- [ ] Arrêt gracieux
- [ ] README + docs API complètes
- [ ] Scripts d'exemple pour usages courants

---

## Cleanup Debt Technique

**Supprimer à vue** (per instructions):
- [ ] Enlever `std::cout` → Utiliser framework logging correct
- [ ] Enlever nombres magiques → `constexpr kMaxQueueSize = 10000;`
- [ ] Enlever vieilles fonctions POC une fois nouvelles actives
- [ ] Supprimer code commenté immédiatement
- [ ] Pas de `TODO`/`FIXME` plus vieux que la session actuelle

---

## Notes

- **Portée Serveur Unique**: Pas d'arbitration multi-serveur nécessaire (simplifie design)
- **Redis = Source de Vérité**: Tous les événements passent par pub/sub Redis
- **Lua est Lent**: Garder opérations lourdes en C++ (réseau, threading, parsing JSON)
- **Restrictions GMod**: Peut seulement appeler Lua du thread principal → worker thread doit queuer
- **Pas de Polling**: C'est le point entier. Les événements circulent, pas de polling

---

## Références

- Voir `module_realtime_gmod.instructions.md` pour standards de code
- Voir `ARCHITECTURE.md` (à créer) pour détails design
- Voir dossier `tests/` pour exemples de tests
