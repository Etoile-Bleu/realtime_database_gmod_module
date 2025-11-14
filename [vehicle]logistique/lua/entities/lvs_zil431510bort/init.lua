AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(-50.5,28,46.5), Angle(0,-95,-8) )
	local PassengerSeat = self:AddPassengerSeat( Vector(-31.5,-5,49.5), Angle(0,-85,15) )
	local PassengerSeat1 = self:AddPassengerSeat( Vector(-31.5,-27,49.5), Angle(0,-90,15) )

	local DoorHandler = self:AddDoorHandler( "left_door", Vector(-25,60,50), Angle(0,0,0), Vector(-10,-3,-12), Vector(20,6,12), Vector(-10,-15,-12), Vector(20,30,12) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( DriverSeat )

	local DoorHandler = self:AddDoorHandler( "right_door", Vector(-25,-60,50), Angle(0,180,0), Vector(-10,-3,-12), Vector(20,6,12), Vector(-10,-15,-12), Vector(20,30,12) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( PassengerSeat1 )

        local DoorHandler = self:AddDoorHandler( "bortd", Vector(-270,0,50), Angle(0,180,0), Vector(-10,-3,-12), Vector(20,6,12), Vector(-10,-15,-12), Vector(20,30,12) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_door_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_door_close.wav" )




	self:AddEngine( Vector(35,2,66) )

	local FuelTank = self:AddFuelTank( Vector(-80,54,27), Angle(0,0,0), 1200, LVS.FUELTYPE_PETROL )

	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_FRONT,
			SteerAngle = 35,
			TorqueFactor = 0,
			BrakeFactor = 1,
		},
		Wheels = {
			self:AddWheel( {
				pos = Vector(25.15,50,15.1),
				mdl = "models/models/lvs_zil431510/wheel1.mdl",
				mdl_ang = Angle(0,-90,0),
			} ),
			self:AddWheel( {
				pos = Vector(25.15,-45,15.1),
				mdl = "models/models/lvs_zil431510/wheel1.mdl",
				mdl_ang = Angle(0,90,0),
			} ),
		},
		Suspension = {
			Height = 5,
			MaxTravel = 7,
			ControlArmLength = 25,
			SpringConstant = 50000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )

	local RearAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_NONE,
			TorqueFactor = 3,
			BrakeFactor = 1,
			UseHandbrake = true,
		},
		Wheels = {
			self:AddWheel( {
				pos = Vector(-181,45,13.3),
				mdl = "models/models/lvs_zil431510/wheel2.mdl",
				mdl_ang = Angle(0,-90,0),
			} ),
			self:AddWheel( {
				pos = Vector(-181,-40,13.3),
				mdl = "models/models/lvs_zil431510/wheel2.mdl",
				mdl_ang = Angle(0,90,0),
			} ),
		},
		Suspension = {
			Height = 2,
			MaxTravel = 7,
			ControlArmLength = 25,
			SpringConstant = 50000,
			SpringDamping = 1000,
			SpringRelativeDamping = 1000,
		},
	} )

	self:AddTrailerHitch( Vector(-265,2,27), LVS.HITCHTYPE_MALE )
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/zil431510/zil_start.wav" )
	else
		self:EmitSound( "lvs/zil431510/zil_stop.wav" )
	end
end


