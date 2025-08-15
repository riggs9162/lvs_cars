
function ENT:CalcViewOverride( ply, pos, angles, fov, pod )
	return pos, angles, fov
end

function ENT:CalcViewDirectInput( ply, pos, angles, fov, pod )
	return LVS:CalcView( self, ply, pos, angles,  fov, pod )
end

function ENT:CalcViewMouseAim( ply, pos, angles, fov, pod )
	return LVS:CalcView( self, ply, pos, angles,  fov, pod )
end

function ENT:CalcViewDriver( ply, pos, angles, fov, pod )
	pos = pos + pod:GetUp() * 7 - pod:GetRight() * 11

	if ply:lvsMouseAim() then
		angles = ply:EyeAngles()

		return self:CalcViewMouseAim( ply, pos, angles,  fov, pod )
	else
		return self:CalcViewDirectInput( ply, pos, angles,  fov, pod )
	end
end

function ENT:CalcViewPassenger( ply, pos, angles, fov, pod )
	return LVS:CalcView( self, ply, pos, angles, fov, pod )
end

function ENT:LVSCalcView( ply, original_pos, original_angles, original_fov, pod )
	local pos, angles, fov = self:CalcViewOverride( ply, original_pos, original_angles, original_fov, pod )

	if self:GetDriverSeat() == pod then
		return self:CalcViewDriver( ply, pos, angles, fov, pod )
	else
		return self:CalcViewPassenger( ply, pos, angles, fov, pod )
	end
end

function ENT:SuppressViewPunch( time )
	self._viewpunch_supressed_time = CurTime() + (time or 0.2)
end

function ENT:IsViewPunchSuppressed()
	return (self._viewpunch_supressed_time or 0) > CurTime()
end