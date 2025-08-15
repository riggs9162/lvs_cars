
include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")

function ENT:TankViewOverride( client, pos, angles, fov, pod )
	if client == self:GetDriver() and not pod:GetThirdPersonMode() then
		local vieworigin, found = self:GetTurretViewOrigin()

		if found then pos = vieworigin end
	end

	return pos, angles, fov
end
