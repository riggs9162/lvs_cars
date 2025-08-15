
ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "[LVS] Wheeldrive Bike"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] - Cars"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.MaxVelocity = 1250
ENT.MaxVelocityReverse = 100

ENT.EngineCurve = 0.4
ENT.EngineTorque = 250

ENT.TransGears = 4
ENT.TransGearsReverse = 1

ENT.PhysicsMass = 250
ENT.PhysicsWeightScale = 0.5
ENT.PhysicsInertia = Vector(400,400,200)

ENT.ForceAngleMultiplier = 0.5

ENT.PhysicsDampingSpeed = 500
ENT.PhysicsDampingForward = true
ENT.PhysicsDampingReverse = false

ENT.PhysicsRollMul = 1
ENT.PhysicsDampingRollMul = 1
ENT.PhysicsWheelGyroMul = 1
ENT.PhysicsWheelGyroSpeed = 400

ENT.WheelPhysicsMass = 250
ENT.WheelPhysicsInertia = Vector(5,4,5)

ENT.WheelSideForce = 800
ENT.WheelDownForce = 1000

ENT.KickStarter = true
ENT.KickStarterSound = "lvs/vehicles/bmw_r75/moped_crank.wav"
ENT.KickStarterMinAttempts = 2
ENT.KickStarterMaxAttempts = 4
ENT.KickStarterAttemptsInSeconds = 5
ENT.KickStarterMinDelay = 0.5

ENT.FastSteerAngleClamp = 15

function ENT:ShouldPutFootDown()
	return self:GetNWHandBrake() or self:GetVelocity():Length() < 20
end

function ENT:CalcMainActivity( client )
	if client != self:GetDriver() then return self:CalcMainActivityPassenger( client ) end

	if client.m_bWasNoclipping then
		client.m_bWasNoclipping = nil
		client:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )

		if CLIENT then
			client:SetIK( true )
		end
	end

	client.CalcIdeal = ACT_STAND
	client.CalcSeqOverride = client:LookupSequence( "drive_airboat" )

	return client.CalcIdeal, client.CalcSeqOverride
end

function ENT:GetWheelUp()
	return self:GetUp() * math.Clamp( 1 + math.abs( self:GetSteer() / 10 ), 1, 1.5 )
end

function ENT:GetVehicleType()
	return "bike"
end

function ENT:GravGunPickupAllowed( client )
	return false
end
