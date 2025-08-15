
include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")

function ENT:TankViewOverride( client, pos, angles, fov, pod )
	if client == self:GetDriver() and not pod:GetThirdPersonMode() then
		local ID = self:LookupAttachment( "seat1" )

		local Muzzle = self:GetAttachment( ID )

		if Muzzle then
			pos =  Muzzle.Pos - Muzzle.Ang:Right() * 25
		end
	end

	return pos, angles, fov
end

function ENT:CalcViewPassenger( client, pos, angles, fov, pod )
	if pod == self:GetGunnerSeat() and not pod:GetThirdPersonMode() then
		local ID = self:LookupAttachment( "seat2" )

		local Muzzle = self:GetAttachment( ID )

		if Muzzle then
			pos =  Muzzle.Pos - Muzzle.Ang:Right() * 25
		end
	end

	return LVS:CalcView( self, client, pos, angles, fov, pod )
end