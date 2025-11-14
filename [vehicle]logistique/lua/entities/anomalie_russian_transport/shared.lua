ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "Russian ZIL (AMMO)"
ENT.Author = "Weier"
ENT.Information = ""
ENT.Category = "Anomalies"

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Military"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/models/lvs_zil431510/zil431510bort.mdl"

-- Configuration par défaut
ENT.DefaultSkin = 0
ENT.DefaultBodyGroups = {
	[0] = 1, -- "Add roof"
	[1] = 1  -- "Extra Bort"
}

-- Variables pour le système de munitions
ENT.MaxAmmoCaches = 10
ENT.DeployCooldown = 2
ENT.DeployDistance = 400
ENT.SpawnOffset = {
    base = 250,
    random = {
        x = {min = -50, max = 50},
        y = {min = -25, max = 25}
    },
    height = 50
}

-- Fonction pour empêcher la modification des paramètres
function ENT:SetSkin(skin)
	return self.DefaultSkin
end

function ENT:GetSkin()
	return self.DefaultSkin
end

function ENT:SetBodygroup(id, value)
	return self.DefaultBodyGroups[id] or 0
end

function ENT:Initialize()
    self.BaseClass.Initialize(self)
end

ENT.AITEAM = 2

ENT.MaxVelocity = 800

ENT.EngineTorque = 65
ENT.EngineCurve = 0.25
ENT.EngineIdleRPM = 2200
ENT.EngineMaxRPM = 3000
ENT.MaxHealth = 700

ENT.TransGears = 5
ENT.TransGearsReverse = 1

ENT.HornSound = "lvs/horn3.wav"
ENT.HornPos = Vector(40,0,35)

ENT.EngineSounds = {
	{
		sound = "lvs/zil431510/zil_idle.wav",
		Volume = 4.4,
		Pitch = 90,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/zil431510/zil_heavy.wav",
		Volume = 5,
		Pitch = 70,
		PitchMul = 70,
		SoundLevel = 95,
		UseDoppler = true,
	},
}

ENT.Lights = {
	{
		Trigger = "main",
		Sprites = {
			{ pos = Vector(-265,45,36), colorG = 0, colorB = 0, colorA = 150 },
			{ pos = Vector(-265,-40,36), colorG = 0, colorB = 0, colorA = 150 },
		},
		ProjectedTextures = {
			{ pos = Vector(63,-37,40), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			{ pos = Vector(63,41.5,40), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
		},
	},
	{
		Trigger = "high",
		ProjectedTextures = {
			{ pos = Vector(63,-37,40), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			{ pos = Vector(63,41.5,40), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
		},
	},
	{
		Trigger = "main+high",
		SubMaterialID = 1,
		Sprites = {
			{ pos = Vector(63,-37,40), colorB = 200, colorA = 150 },
			{ pos = Vector(63,41.5,40), colorB = 200, colorA = 150 },
		},
	},
	{
		Trigger = "brake",
		SubMaterialID = 2,
		Sprites = {
			{ pos = Vector(-265,45,36), colorG = 0, colorB = 0, colorA = 150 },
			{ pos = Vector(-265,-40,36), colorG = 0, colorB = 0, colorA = 150 },
		}
	},
	{
		Trigger = "fog",
		SubMaterialID = 3,
		Sprites = {
			{ pos = Vector(33.15,-25.63,48.61), colorB = 200, colorA = 150 },
		},

		Trigger = "turnright",
		Sprites = {
			{ pos = Vector(63,-37,50), colorG = 150, colorB = 0, colorA = 150 },
			{ pos = Vector(51,-49.5,54), colorG = 150, colorB = 0, colorA = 150 },
			{ pos = Vector(-265,-47,36), colorG = 150, colorB = 0, colorA = 150 },
		},
	},
	{
		Trigger = "turnleft",
		Sprites = {
			{ pos = Vector(63,41.5,50), colorG = 150, colorB = 0, colorA = 150 },
			{ pos = Vector(51,54,54), colorG = 150, colorB = 0, colorA = 150 },
			{ pos = Vector(-265,51,36), colorG = 150, colorB = 0, colorA = 150 },
		},
	},
}

ENT.ExhaustPositions = {
	{
		pos = Vector(-108.9,16,17),
		ang = Angle(0,110,0),
	},
}
