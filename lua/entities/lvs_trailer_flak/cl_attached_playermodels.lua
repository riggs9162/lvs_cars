
include("entities/lvs_tank_wheeldrive/modules/cl_attachable_playermodels.lua")

function ENT:DrawDriver()
	local pod = self:GetDriverSeat()

	if not IsValid( pod ) then self:RemovePlayerModel( "driver" ) return end

	local plyL = LocalPlayer()
	local client = pod:GetDriver()

	if not IsValid( client ) or (client == plyL and not pod:GetThirdPersonMode()) then self:RemovePlayerModel( "driver" ) return end

	local ID = self:LookupAttachment( "seat" )
	local Att = self:GetAttachment( ID )

	if not Att then self:RemovePlayerModel( "driver" ) return end

	local Pos,Ang = LocalToWorld( Vector(0,0,0), Angle(180,-20,-90), Att.Pos, Att.Ang )

	local model = self:CreatePlayerModel( client, "driver" )

	model:SetSequence( "drive_airboat" )
	model:SetRenderOrigin( Pos )
	model:SetRenderAngles( Ang )
	model:DrawModel()
end

function ENT:PreDraw()
	self:DrawDriver()

	return true
end
