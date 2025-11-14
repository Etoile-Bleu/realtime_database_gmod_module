
ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "[LVS] ZIL-431510"
ENT.Author = "ǤAŞ₱A℟ĬN"
ENT.Information = ""
ENT.Category = "[LVS] - ǤAŞ₱A℟ĬN"

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Military"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/models/lvs_zil431510/zil431510.mdl"

ENT.AITEAM = 2

ENT.MaxVelocity = 850

ENT.EngineTorque = 67
ENT.EngineCurve = 0.25
ENT.EngineIdleRPM = 2200
ENT.EngineMaxRPM = 3000
ENT.MaxHealth = 600

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


		Trigger = "turnright",
		Sprites = {
			{ pos = Vector(63,-37,50), colorG = 150, colorB = 0, colorA = 150 },
			{ pos = Vector(51,-49.5,54), colorG = 150, colorB = 0, colorA = 150 },
		},
	},
	{
		Trigger = "turnleft",
		Sprites = {
			{ pos = Vector(63,41.5,50), colorG = 150, colorB = 0, colorA = 150 },
			{ pos = Vector(51,54,54), colorG = 150, colorB = 0, colorA = 150 },
		},
	},
}

ENT.ExhaustPositions = {
	{
		pos = Vector(-108.9,16,17),
		ang = Angle(0,110,0),
	},
}

ENT.RandomColor = {
	{
		Skin = 0,
		Color = Color(255,255,255),
			Wheels = {
			Skin = 1,
			Color = Color(255,255,255),
		}
	},
	{
		Skin = 1,
		Color = Color(255,255,255),
			Wheels = {
			Skin = 1,
			Color = Color(255,255,255),
		}
	},
	{
		Skin = 2,
		Color = Color(255,255,255),
			Wheels = {
			Skin = 1,
			Color = Color(255,255,255),
		}
	},
	
}
