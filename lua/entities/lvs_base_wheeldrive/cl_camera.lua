
-- Car camera alignment cvars (client)
local cvar_car_align_enable = CreateClientConVar("lvs_car_align_enable", "1", true, false)
local cvar_car_align_factor = CreateClientConVar("lvs_car_align_factor", "0.4", true, false)
local cvar_car_align_roll   = CreateClientConVar("lvs_car_align_roll", "0", true, false)
local cvar_car_align_rate   = CreateClientConVar("lvs_car_align_rate", "8", true, false)

-- Bias camera angles toward vehicle orientation with smoothing
function ENT:ApplyCameraAlignCar( angles, ply )
	if not cvar_car_align_enable:GetBool() then return angles end
	if IsValid(ply) and ply.lvsKeyDown and ply:lvsKeyDown("FREELOOK") then return angles end

	local vehAng = self:GetAngles()
	if not cvar_car_align_roll:GetBool() then
		vehAng = Angle(vehAng.p, vehAng.y, 0)
	end

	self._carCamAlignAng = self._carCamAlignAng or Angle(vehAng.p, vehAng.y, vehAng.r)
	local rate = math.max(cvar_car_align_rate:GetFloat(), 0)
	local step = math.Clamp(RealFrameTime() * rate, 0, 1)
	self._carCamAlignAng = LerpAngle(step, self._carCamAlignAng, vehAng)

	local fac = math.Clamp(cvar_car_align_factor:GetFloat(), 0, 1)
	if fac <= 0 then return angles end

	return LerpAngle(fac, angles, self._carCamAlignAng)
end

function ENT:CalcViewOverride( ply, pos, angles, fov, pod )
	if pod:GetThirdPersonMode() then
		pos = self:WorldSpaceCenter()
	end

	return pos, angles, fov
end

function ENT:CalcViewDirectInput( ply, pos, angles, fov, pod )
	angles = self:ApplyCameraAlignCar( angles, ply )
	return LVS:CalcView( self, ply, pos, angles,  fov, pod )
end

function ENT:CalcViewMouseAim( ply, pos, angles, fov, pod )
	angles = self:ApplyCameraAlignCar( angles, ply )
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