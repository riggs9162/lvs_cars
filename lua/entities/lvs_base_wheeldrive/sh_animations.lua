
function ENT:CalcMainActivityPassenger( client )
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
	client.CalcSeqOverride = client:LookupSequence( "drive_jeep" )

	return client.CalcIdeal, client.CalcSeqOverride
end

function ENT:UpdateAnimation( client, velocity, maxseqgroundspeed )
	client:SetPlaybackRate( 1 )

	if CLIENT then
		if client == self:GetDriver() then
			client:SetPoseParameter( "vehicle_steer", self:GetSteer() /  self:GetMaxSteerAngle() )
			client:InvalidateBoneCache()
		end

		GAMEMODE:GrabEarAnimation( client )
		GAMEMODE:MouthMoveAnimation( client )
	end

	return false
end
