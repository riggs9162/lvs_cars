include("shared.lua")

local lerp_to_ragdoll = 0
local freezeangles = Angle(0,0,0)

function ENT:StartCommand( client, cmd )
	local LocalSpeed = self:WorldToLocal( self:GetPos() + self:GetVelocity() )

	client:SetAbsVelocity( LocalSpeed )
end

function ENT:CalcViewOverride( client, pos, angles, fov, pod )
	if client:GetNWBool( "lvs_camera_follow_ragdoll", false ) then
		local ragdoll = client:GetRagdollEntity()

		if IsValid( ragdoll ) then
			lerp_to_ragdoll = math.min( lerp_to_ragdoll + FrameTime() * 2, 1 )

			local eyeang = client:EyeAngles() - Angle(0,90,0)

			local newpos = LerpVector( lerp_to_ragdoll, pos, ragdoll:GetPos() )
			local newang = LerpAngle( lerp_to_ragdoll, freezeangles, freezeangles + eyeang )

			return newpos, newang, fov
		end
	end

	lerp_to_ragdoll = 0
	freezeangles = angles

	return pos, angles, fov
end

function ENT:CalcViewDirectInput( client, pos, angles, fov, pod )
	local roll = angles.r

	angles.r = math.max( math.abs( roll ) - 30, 0 ) * (angles.r > 0 and 1.5 or -1.5)
	return LVS:CalcView( self, client, pos, angles,  fov, pod )
end

function ENT:CalcViewPassenger( client, pos, angles, fov, pod )
	local roll = angles.r

	angles.r = math.max( math.abs( roll ) - 30, 0 ) * (angles.r > 0 and 1.5 or -1.5)
	return LVS:CalcView( self, client, pos, angles,  fov, pod )
end

local angle_zero = Angle(0,0,0)

function ENT:GetPlayerBoneManipulation( client, PodID )
	if PodID != 1 then return self.PlayerBoneManipulate[ PodID ] or {} end

	local TargetValue = self:ShouldPutFootDown() and 1 or 0

	local Rate = math.min( FrameTime() * 4, 1 )

	client._smlvsBikerFoot = client._smlvsBikerFoot and (client._smlvsBikerFoot + (TargetValue - client._smlvsBikerFoot) * Rate) or 0

	local CurValue = client._smlvsBikerFoot ^ 2

	local Pose = table.Copy( self.PlayerBoneManipulate[ PodID ] or {} )

	local BoneManip = self:GetEngineActive() and self.DriverBoneManipulateIdle or self.DriverBoneManipulateParked

	for bone, EndAngle in pairs( BoneManip or {} ) do
		local StartAngle = Pose[ bone ] or angle_zero

		Pose[ bone ] = LerpAngle( CurValue, StartAngle, EndAngle )
	end

	if self.DriverBoneManipulateKickStart and client._KickStartValue then
		client._KickStartValue = math.max( client._KickStartValue - Rate, 0 )

		local Start = self.DriverBoneManipulateKickStart.Start
		local End = self.DriverBoneManipulateKickStart.End

		for bone, EndAngle in pairs( End ) do
			local StartAngle = Start[ bone ] or angle_zero

			Pose[ bone ] = LerpAngle( client._KickStartValue, StartAngle, EndAngle )
		end

		if client._KickStartValue == 0 then client._KickStartValue = nil end
	end

	return Pose or {}
end

function ENT:GetKickStarter()
	local Driver = self:GetDriver()

	if not IsValid( Driver ) then return 0 end

	return math.sin( (Driver._KickStartValue or 0) * math.pi ) ^ 2
end

net.Receive( "lvs_kickstart_network" , function( len )
	local client = net.ReadEntity()

	if not IsValid( client ) then return end

	client._KickStartValue = 1
end )