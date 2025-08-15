if SERVER then return end

function ENT:GetPlayerModel( name )
	if not istable( self._PlayerModels ) then return end

	return self._PlayerModels[ name ]
end

function ENT:RemovePlayerModel( name )
	if not istable( self._PlayerModels ) then return end

	for id, model in pairs( self._PlayerModels ) do
		if name and id != name then continue end

		if not IsValid( model ) then continue end

		model:Remove()
	end
end

function ENT:CreatePlayerModel( client, name )
	if not isstring( name ) then return end

	if not istable( self._PlayerModels ) then
		self._PlayerModels  = {}
	end

	if IsValid( self._PlayerModels[ name ] ) then return self._PlayerModels[ name ] end

	local model = ClientsideModel( client:GetModel() )
	model:SetNoDraw( true )

	model.GetPlayerColor = function() return client:GetPlayerColor() end
	model:SetSkin( client:GetSkin() )

	self._PlayerModels[ name ] = model

	return model
end

function ENT:OnRemoved()
	self:RemovePlayerModel()
end