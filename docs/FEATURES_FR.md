# Fonctionnalités Essentielles - Ce qui rend le module UTILE

**Question**: "Pourquoi je ferais un event custom si je peux déjà faire du SQL ?"

**Réponse**: Ce document montre comment transformer ce POC en système d'événements temps-réel qui vaut le coup.

---

## 🎯 Vision: Un Système d'Événements pour GMod

### Actuellement (Hypothétique)
```lua
-- Serveur GMod classique
local events = {}
-- Les données restent LOCALES, INACCESSIBLES de l'extérieur
hook.Add("PlayerDeath", "MyHook", function(victim, inflictor, attacker)
    -- Log en DB ? HTTP call ? Lent et compliqué
end)
```

### Avec notre module (Futur)
```lua
-- Serveur GMod avec Realtime
hook.Add("PlayerDeath", "RealtimeKill", function(victim, inflictor, attacker)
    realtime.Emit("player:kill", {
        killer = attacker:Nick(),
        victim = victim:Nick(),
        weapon = attacker:GetActiveWeapon():GetClass(),
        timestamp = os.time()
    })
end)
```

**Résultat**: 
- ✅ Dashboard externe montre les kills en DIRECT
- ✅ Webhook Discord pour chaque kill
- ✅ Analytics Python consomme les événements
- ✅ Autre serveur GMod reçoit les mêmes events
- ✅ Zéro latence (<5ms), zéro polling

---

## 📦 Feature Set Minimum (MVP)

### 1. **Événements Personnalisés - `realtime.Emit(channel, data)`** 🔴 CRITICAL

**Concept**: Permettre à n'importe quel script Lua d'envoyer des événements Redis. La DLL gère TOUT en C++.

**API Lua**:
```lua
-- Format simple: channel + JSON
realtime.Emit("player:death", {
    killer = "John",
    victim = "Alice",
    weapon = "crowbar"
})

-- Retour: true si succès, false si erreur
local ok = realtime.Emit("custom:event", data)
```

**Pourquoi c'est essentiel**:
- ✅ Les scripters GMod créent leurs propres événements
- ✅ Pas limité au module (vehicle spawn, kill, chat, custom)
- ✅ Extensible infiniment

**Implémentation C++** (DLL gère tout):
```cpp
// Lua_Emit: Prend channel (string) et table Lua
// 1. Sérialise la table Lua → JSON (en C++, pas Python!)
// 2. Publie sur Redis
// 3. Retourne ok/error
// La DLL est COMPLÈTE et AUTONOME
```

**Cas d'Usage**:
```lua
-- Événement custom depuis n'importe quel addon
hook.Add("HumanCityChat", "RealtimeCityChat", function(ply, msg)
    realtime.Emit("city:message", {
        player = ply:Nick(),
        message = msg,
        job = ply:getJob and ply:getJob() or "Unknown"
    })
end)
```

---

### 2. **Listen à des Événements - `realtime.On(channel, callback)`** 🔴 CRITICAL

**Concept**: S'abonner à un channel et recevoir les événements via callback.

**API Lua**:
```lua
-- Écouter un channel
realtime.On("player:death", function(data)
    print("Kill: " .. data.killer .. " killed " .. data.victim)
    -- Faire quelque chose avec data
end)

-- Écouter pattern
realtime.On("player:*", function(data)
    -- Reçoit player:death, player:spawn, player:chat, etc.
end)

-- Unsubscribe
realtime.Off("player:death")
```

**Pourquoi c'est essentiel**:
- ✅ Réagir à des événements autres serveurs
- ✅ Zéro polling (event-driven)
- ✅ Code Lua réactif et lisible

**Implémentation C++**:
- Worker thread subscribe à Redis SUBSCRIBE
- Events arrivent → queue thread-safe
- Chaque tick, traiter queue → déclencher callbacks Lua

---

### 3. **Stockage Clés-Valeurs - `realtime.Set/Get(key, value)`** 🟡 IMPORTANT

**Concept**: Redis est aussi une key-value store. Pourquoi pas l'utiliser ?

**API Lua**:
```lua
-- Stocker données globales (accessibles par tous les serveurs)
realtime.Set("server:playercount", 32)
realtime.Set("server:map", "rp_downtown_v4c_v2")

-- Récupérer données
local player_count = realtime.Get("server:playercount")
local map = realtime.Get("server:map")

-- Avec TTL (expiration auto)
realtime.SetEx("daily:topkiller", "John", 86400)  -- Expire demain
```

**Pourquoi c'est important**:
- ✅ Leaderboards, statistiques globales
- ✅ Stocker l'état (quelle map ?, combien de players ?)
- ✅ Cache distribué entre serveurs

**Cas d'Usage**:
```lua
-- Top kills du jour
hook.Add("PlayerDeath", "StatsUpdate", function(victim, inflictor, attacker)
    if attacker:IsPlayer() then
        local key = "kills:daily:" .. attacker:Nick()
        local current = tonumber(realtime.Get(key) or 0)
        realtime.SetEx(key, current + 1, 86400)  -- Expire demain
    end
end)

-- Voir le top
local topkiller = realtime.Get("topkiller:daily")
```

---

### 4. **Data Persistence - Sauvegarder sans Polling** 🟡 IMPORTANT

**Concept**: Les événements disparaissent naturellement, mais on peut les logger.

**Problem**: "Et si je veux archiver les kills ?"

**Solution 1 - Batch Write** (recommandé):
```lua
-- Accumule en mémoire, écrit toutes les 5 min
local kills_batch = {}

hook.Add("PlayerDeath", "KillsBatch", function(victim, inflictor, attacker)
    if attacker:IsPlayer() then
        table.insert(kills_batch, {
            killer = attacker:Nick(),
            victim = victim:Nick(),
            time = os.time()
        })
    end
end)

timer.Create("BatchWriteKills", 300, 0, function()
    if #kills_batch > 0 then
        -- Écrire batch en DB (une seule query)
        local json = util.TableToJSON(kills_batch)
        realtime.Emit("archive:kills", json)
        kills_batch = {}
    end
end)
```

**Solution 2 - Service Backend** (meilleur):
```
Redis Pub/Sub (notre module)
    ↓ (Subscribe depuis Python/Node.js)
Backend Service
    ↓ (Traite les événements)
PostgreSQL (Archive)
```

**Avantage**: Découplage complet, peut ajouter backends sans toucher GMod

---

### 5. **Hooks d'Intégration Standard** 🟢 OPTIONAL

**Concept**: Automatiser les cas courants (player events, etc.)

**Ajouter des Hooks Lua Natifs**:
```lua
-- Ces events sont AUTOMATIQUEMENT envoyés par le module
-- player:spawn
-- player:disconnect  
-- player:death
-- chat:message
-- vehicle:spawn
-- vehicle:removed
```

**Implémentation**:
```lua
-- Dans test_realtime.lua
hook.Add("PlayerConnect", "RealtimePlayerSpawn", function(name, ip)
    realtime.Emit("player:spawn", {
        name = name,
        ip = ip,
        time = os.time()
    })
end)

hook.Add("PlayerDisconnected", "RealtimePlayerDisconnect", function(name, uid)
    realtime.Emit("player:disconnect", {
        name = name,
        uid = uid,
        time = os.time()
    })
end)
```

---

## 🏗️ La DLL Fait TOUT (Autonome & Complète)

**Pas de Python. Pas de Node.js. La DLL C++ gère tout.**

### Concept: Event Hooks & Actions Intégrées

La DLL écoute les événements Redis ET peut déclencher des actions :

```cpp
// DANS LA DLL C++
class RealtimeModule {
    // Listen Redis events
    void OnRedisMessage(const std::string& channel, const std::string& data);
    
    // Exécute les actions:
    void ProcessAction(const Event& event);
};
```

---

### Exemple 1: Discord Webhook (Intégré dans la DLL)

**Configuration**:
```lua
-- Dans Lua, tu dis à la DLL: "Quand tu reçois un event, envoie à Discord"
realtime.AddHook("player:death", {
    type = "discord",
    webhook_url = "https://discord.com/api/webhooks/...",
    format = "**{killer}** tué **{victim}** avec {weapon}"
})
```

**La DLL fait**:
```cpp
// C++ dans la DLL
// 1. Reçoit event "player:death" de Redis
// 2. Parse le JSON
// 3. Formate le message
// 4. Envoie HTTP POST au webhook Discord (fait en C++!)
// 5. Log résultat
```

**Résultat**: Discord notifié EN DIRECT, zéro lag, sans Python/Node.js ✅

---

### Exemple 2: Webhooks HTTP Personnalisés

```lua
-- Envoyer à n'importe quel endpoint HTTP
realtime.AddHook("player:death", {
    type = "http",
    method = "POST",
    url = "http://monsite.com/api/kill",
    headers = {["Authorization"] = "Bearer TOKEN"},
    format = "json"  -- La DLL sérialise en JSON automatiquement
})
```

**La DLL**:
```cpp
// C++ HTTP client integré (ou curl)
// Pour chaque event:
// 1. Formate JSON
// 2. POST à l'URL
// 3. Retry si erreur
// 4. Log timeout/failures
```

---

### Exemple 3: Logging Binaire (Persistance)

```lua
-- Logger les events sur disque (binaire, rapide)
realtime.AddHook("player:death", {
    type = "file",
    path = "logs/events/deaths.log",
    format = "binary"  -- Compact, rapide
})

-- Plus tard, lire les logs
local events = realtime.ReadEventLog("logs/events/deaths.log", {
    start_time = os.time() - 86400,  -- Dernières 24h
    limit = 1000
})
```

**La DLL**:
```cpp
// C++ Binary Logger
// 1. Reçoit event
// 2. Écrit en binaire compacte (très rapide)
// 3. Index par timestamp
// 4. Rotation automatique des fichiers (max 100MB)
```

---

### Exemple 4: Stockage en Cache Distribué

```lua
-- Leaderboard temps-réel (dans Redis, partagé entre serveurs)
realtime.AddHook("player:kill", {
    type = "counter",
    key = "kills:{killer}:daily",
    action = "incr",
    ttl = 86400  -- Expire demain
})

-- Récupérer le leaderboard
local top10 = realtime.GetLeaderboard("kills:*:daily", 10)
-- Returns: {["John"] = 50, ["Alice"] = 45, ...}
```

**La DLL**:
```cpp
// C++ Redis Client
// 1. INCR kills:John:daily
// 2. EXPIRE key 86400
// 3. Leaderboard accessible en temps-réel
// 4. Pattern matching intégré (kills:*)
```

---

### Exemple 5: Alertes Conditionnelles

```lua
-- Déclencher action si condition match
realtime.AddHook("player:death", {
    type = "conditional",
    condition = function(data)
        return data.weapon == "weapon_crossbow" and data.victim_hp < 20
    end,
    actions = {
        {
            type = "discord",
            webhook = "https://...",
            message = "AWESOME SHOT: {killer} killed {victim}"
        },
        {
            type = "counter",
            key = "crossbow_kills:daily",
            action = "incr"
        }
    }
})
```

**La DLL exécute**:
```cpp
// Pour chaque event player:death:
// 1. Parse JSON
// 2. Exécute condition Lua (appel depuis worker thread → queue → main thread)
// 3. Si true, déclenche toutes les actions
// 4. Discord + Counter mis à jour en parallèle
```

---

### Exemple 6: Réagrégation d'Événements

```lua
-- "Chaque minute, aggreg les kills et log en fichier"
realtime.AddAggregator("player:death", {
    interval = 60,  -- Chaque minute
    aggregate = function(events)
        -- events = tous les kills de cette minute
        local data = {
            total_kills = #events,
            unique_killers = {},
            top_weapon = {},
            timestamp = os.time()
        }
        
        -- La DLL appelle cette fonction Lua toutes les minutes
        return data
    end,
    actions = {
        {type = "file", path = "logs/hourly_stats.log"}
    }
})
```

**La DLL**:
```cpp
// 1. Accumule tous les events player:death pendant 60s
// 2. Appelle fonction Lua aggregate
// 3. Reçoit données agrégées
// 4. Sauvegarde en fichier
// 5. Réinitialise buffer
```

---

## 📋 Ordre d'Implémentation (Phases)

### Phase A: **MVP Complet** (2 semaines) 🔴
```
✅ Emit() - Envoyer événements
✅ On() - Écouter événements
✅ Off() - Unsubscribe
✅ Tests unitaires
✅ Architecture modulaire (Phase 1.1)
✅ Worker thread asynchrone (Phase 2.1)
```

**Résultat**: Système d'événements temps-réel fonctionnel

---

### Phase B: **Stockage** (1 semaine) 🟡
```
✅ Set/Get pour key-value
✅ SetEx pour TTL
✅ Incr pour compteurs
✅ Integration tests
```

**Résultat**: Leaderboards, statistiques globales

---

### Phase C: **Production Polish** (2 semaines) 🟡
```
✅ Error handling (Result<T>)
✅ Configuration system
✅ Reconnection logic
✅ Logging proper
✅ Performance profiling
```

**Résultat**: Module production-ready

---

### Phase D: **Intégrations** (ongoing) 🟢
```
✅ Hooks GMod standard (player spawn, death, etc)
✅ Documentation exemples (Discord, Dashboard, etc)
✅ Advanced features (persistence, patterns)
```

---

## 🎁 Cas d'Usages Concrets

### Cas 1: Serveur Roleplay
```lua
-- Quand un joueur reçoit un salaire
hook.Add("PayPlayerSalary", "PaymentEvent", function(ply, amount)
    realtime.Emit("economy:payment", {
        player = ply:Nick(),
        amount = amount,
        time = os.time()
    })
end)

-- Backend Python: Log dans analytics
-- Discord webhook: Affiche les gros paiements (>100k)
-- Dashboard: Graph des paiements/heure
```

### Cas 2: Tournoi RP
```lua
-- Track tous les frags du tournoi
hook.Add("TournamentKill", "TrackKill", function(killer, victim, weapon)
    realtime.Emit("tournament:kill", {
        killer = killer:Nick(),
        victim = victim:Nick(),
        weapon = weapon
    })
    
    -- Update leaderboard en temps réel
    local current = tonumber(realtime.Get("tournament:frags:" .. killer:Nick()) or 0)
    realtime.Set("tournament:frags:" .. killer:Nick(), current + 1)
end)

-- Spectateurs voient le leaderboard LIVE sans refresh
```

### Cas 3: Anti-Cheat Analytics
```lua
-- Envoyer données suspectes
realtime.Emit("anticheat:suspicious", {
    player = ply:Nick(),
    reason = "Trop de kills trop vite",
    kills_per_sec = 5.2,
    time = os.time()
})

-- Backend Python: Analyseur ML
-- Dashboard: Admin voit players suspects en direct
```

### Cas 4: Multi-Serveurs Synchronisé
```lua
-- Serveur 1 & 2
hook.Add("PlayerDeath", "SyncKills", function(victim, inflictor, attacker)
    realtime.Emit("network:kill", {
        server = "server_name",
        killer = attacker:Nick(),
        victim = victim:Nick()
    })
end)

-- Tous les serveurs écoutent
realtime.On("network:kill", function(data)
    print("[" .. data.server .. "] " .. data.killer .. " tué " .. data.victim)
    -- Leaderboard GLOBAL des 2 serveurs
end)
```

---

## ✨ Résumé: C'EST UTILE QUAND...

✅ Tu veux des **événements temps-réel** entre GMod et l'extérieur
✅ Tu as besoin d'un **leaderboard global** sans DB polling
✅ Tu veux un **dashboard live** des événements serveur
✅ Tu as besoin de **webhooks Discord** instantanés
✅ Tu gères **plusieurs serveurs** et veux les synchroniser
✅ Tu veux du **tracking/analytics** sans charger la DB
✅ Tu veux construire un **système distribué** scalable

---

## 🚀 Priorités MVP

**Must Have** (Phase A):
1. `realtime.Emit(channel, table)` - Envoyer events
2. `realtime.On(channel, callback)` - Écouter events
3. Worker thread asynchrone (pas de lag)
4. Tests + doc

**Should Have** (Phase B):
1. `realtime.Set/Get()` - Key-value store
2. Configuration (host, port, password)
3. Error handling décent

**Nice to Have** (Phase C+):
1. Hooks GMod standards (auto-emit)
2. Pattern subscribe
3. Persistence/streams
4. Metrics/monitoring

---

## 🎯 TL;DR

**Sans ce module**: 
- Events = données locales, inaccessibles
- Intégrations = Python/Node.js externe = compliqué, lent, lourd

**Avec ce module (DLL C++ autonome)**: 
- Events = Redis pub/sub, instantané
- Intégrations = **TOUT DANS LA DLL**:
  - ✅ Discord webhooks
  - ✅ HTTP custom endpoints
  - ✅ Logging binaire
  - ✅ Leaderboards Redis
  - ✅ Alertes conditionnelles
  - ✅ Agrégation d'événements
  - ✅ Tout en temps-réel, zéro lag

**LA DLL EST COMPLÈTE - ZERO DÉPENDANCES EXTERNES**

---

## 🚀 Architecture Finale

```
GMod Server (Lua)
     ↓
DLL C++ (TOUT FAIRE)
├─ Emit() - Envoyer events
├─ On() - Écouter events
├─ Hooks (Discord, HTTP, File, Redis)
├─ Leaderboards (temps-réel)
├─ Logging (binaire)
├─ Agrégation (batch processing)
└─ Alertes (conditionnel)
     ↓
Redis (stockage des events)
     ↓
N'importe quoi (Discord, HTTP, fichiers, leaderboards)

**SANS PYTHON. SANS NODE.JS. AUTONOME.**
```
