AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName = "Gas Station"
ENT.Author = "Luna"
ENT.Information = "Refills fuel tanks"
ENT.Category = "[LVS]"

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.Editable = true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "User" )
	self:NetworkVar( "Int",0, "FuelType", { KeyName = "fueltype", Edit = { type = "Int", order = 1,min = 0, max = #LVS.FUELTYPES, category = "Settings"} } )

	if SERVER then
		self:SetFuelType( LVS.FUELTYPE_PETROL )
	end
end

if SERVER then
	function ENT:SpawnFunction( client, tr, ClassName )
		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal )
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:OnTakeDamage( dmginfo )
	end

	function ENT:Initialize()
		self:SetModel( "models/props_wasteland/gaspump001a.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		local PhysObj = self:GetPhysicsObject()

		if not IsValid( PhysObj ) then return end

		PhysObj:EnableMotion( false )
	end

	function ENT:giveSWEP( client )
		self:EmitSound("common/wpn_select.wav")

		client:SetSuppressPickupNotices( true )
		client:Give( "weapon_lvsfuelfiller" )
		client:SetSuppressPickupNotices( false )

		client:SelectWeapon( "weapon_lvsfuelfiller" )
		self:SetUser( client )

		local SWEP = client:GetWeapon( "weapon_lvsfuelfiller" )

		if not IsValid( SWEP ) then return end

		SWEP:SetFuelType( self:GetFuelType() )
		SWEP:SetCallbackTarget( self )
	end

	function ENT:removeSWEP( client )
		if client:HasWeapon( "weapon_lvsfuelfiller" ) then
			client:StripWeapon( "weapon_lvsfuelfiller" )
			client:SwitchToDefaultWeapon()
		end
		self:SetUser( NULL )
	end

	function ENT:checkSWEP( client )
		if not client:Alive() or client:InVehicle() then

			self:removeSWEP( client )

			return
		end

		local weapon = client:GetActiveWeapon()

		if not IsValid( weapon ) or weapon:GetClass() != "weapon_lvsfuelfiller" then
			self:removeSWEP( client )

			return
		end

		if (client:GetPos() - self:GetPos()):LengthSqr() < 150000 then return end

		self:removeSWEP( client )
	end

	function ENT:Think()
		local client = self:GetUser()
		local T = CurTime()

		if IsValid( client ) then
			self:checkSWEP( client )

			self:NextThink( T )
		else
			self:NextThink( T + 0.5 )
		end

		return true
	end

	function ENT:Use( client )
		if not IsValid( client ) or not client:IsPlayer() then return end

		local User = self:GetUser()

		if IsValid( User ) then
			if User == client then
				self:removeSWEP( client )
			end
		else
			if client:HasWeapon("weapon_lvsfuelfiller") then return end

			self:giveSWEP( client )
		end
	end

	function ENT:OnRemove()
		local User = self:GetUser()

		if not IsValid( User ) then return end

		self:removeSWEP( User )
	end
end

if CLIENT then
	function ENT:CreatePumpEnt()
		if IsValid( self.PumpEnt ) then return self.PumpEnt end

		self.PumpEnt = ents.CreateClientProp()
		self.PumpEnt:SetModel( "models/props_equipment/gas_pump_p13.mdl" )
		self.PumpEnt:SetPos( self:LocalToWorld( Vector(-0.2,-14.6,45.7) ) )
		self.PumpEnt:SetAngles( self:LocalToWorldAngles( Angle(-0.3,92.3,-0.1) ) )
		self.PumpEnt:Spawn()
		self.PumpEnt:Activate()
		self.PumpEnt:SetParent( self )

		return self.PumpEnt
	end

	function ENT:RemovePumpEnt()
		if not IsValid( self.PumpEnt ) then return end

		self.PumpEnt:Remove()
	end

	function ENT:Think()
		local PumpEnt = self:CreatePumpEnt()

		local ShouldDraw = IsValid( self:GetUser() )
		local Draw = PumpEnt:GetNoDraw()

		if Draw != ShouldDraw then
			PumpEnt:SetNoDraw( ShouldDraw )
		end
	end

	local cable = Material( "cable/cable2" )
	local function bezier(p0, p1, p2, p3, t)
		local e = p0 + t * (p1 - p0)
		local f = p1 + t * (p2 - p1)
		local g = p2 + t * (p3 - p2)

		local h = e + t * (f - e)
		local i = f + t * (g - f)

		local p = h + t * (i - h)

		return p
	end

	ENT.FrameMat = Material( "lvs/3d2dmats/frame.png" )
	ENT.RefuelMat = Material( "lvs/3d2dmats/refuel.png" )

	function ENT:Draw()
		self:DrawModel()
		self:DrawCable()

		local client = LocalPlayer()
		local Pos = self:GetPos()

		if not IsValid( client ) then return end

		if (client:GetPos() - Pos):LengthSqr() > 5000000 then return end

		local data = LVS.FUELTYPES[ self:GetFuelType() ]
		local Text = data.name
		local IconColor = Color( data.color.x, data.color.y, data.color.z, 255 )

		cam.Start3D2D( self:LocalToWorld( Vector(10,0,45) ), self:LocalToWorldAngles( Angle(0,90,90) ), 0.1 )
			draw.NoTexture()
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( -150, -120, 300, 240 )

			surface.SetDrawColor( IconColor )

			surface.SetMaterial( self.FrameMat )
			surface.DrawTexturedRect( -50, -50, 100, 100 )

			surface.SetMaterial( self.RefuelMat )
			surface.DrawTexturedRect( -50, -50, 100, 100 )

			draw.SimpleText( Text, "LVS_FONT", 0, 75, IconColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end

	function ENT:DrawCable()
		local plyL = LocalPlayer()

		if not IsValid( plyL ) then return end

		if plyL:GetPos():DistToSqr( self:GetPos() ) > 350000 then return end

		local pos = self:LocalToWorld( Vector(10,0,45) )
		local ang = self:LocalToWorldAngles( Angle(0,90,90) )
		local client = self:GetUser()

		local startPos = self:LocalToWorld( Vector(0.06,-17.77,55.48) )
		local p2 = self:LocalToWorld( Vector(8,-17.77,30) )
		local p3
		local endPos

		if IsValid( client ) then
			local id = client:LookupAttachment("anim_attachment_rh")
			local attachment = client:GetAttachment( id )

			if not attachment then return end

			endPos = (attachment.Pos + attachment.Ang:Forward() * -3 + attachment.Ang:Right() * 2 + attachment.Ang:Up() * -3.5)
			p3 = endPos + attachment.Ang:Right() * 5 - attachment.Ang:Up() * 20
		else
			p3 = self:LocalToWorld( Vector(0,-20,30) )
			endPos = self:LocalToWorld( Vector(0.06,-20.3,37) )
		end

		render.StartBeam( 15 )
		render.SetMaterial( cable )

		for i = 0,15 do
			local pos = bezier(startPos, p2, p3, endPos, i / 14)

			local Col = (render.GetLightColor( pos ) * 0.8 + Vector(0.2,0.2,0.2)) * 255

			render.AddBeam( pos, 1, 0, Color(Col.r,Col.g,Col.b,255) )
		end

		render.EndBeam()
	end

	function ENT:OnRemove()
		self:RemovePumpEnt()
	end
end