
ENT.Base = "lvs_base_wheeldrive_trailer"

ENT.PrintName = "PaK 40"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS]"

ENT.VehicleCategory = "Artillery"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/blu/pak40.mdl"

ENT.AITEAM = 1

ENT.WheelPhysicsMass = 350
ENT.WheelPhysicsInertia = Vector(10,8,10)
ENT.WheelPhysicsTireHeight = 0 -- tire height 0 = doesnt use tires

ENT.CannonArmorPenetration = 14500

-- ballistics
ENT.ProjectileVelocityHighExplosive = 13000
ENT.ProjectileVelocityArmorPiercing = 16000

ENT.lvsShowInSpawner = false

ENT.MaxHealth = 800

ENT.DSArmorIgnoreForce = 1000

ENT.GibModels = {
	"models/blu/pak_d1.mdl",
	"models/blu/pak_d2.mdl",
	"models/blu/pak_d3.mdl",
	"models/blu/pak_d4.mdl",
	"models/blu/pak_d5.mdl",
	"models/blu/pak_d6.mdl",
	"models/blu/pak40_wheel.mdl",
	"models/blu/pak40_wheel.mdl",
	"models/gibs/manhack_gib01.mdl",
	"models/gibs/manhack_gib02.mdl",
	"models/gibs/manhack_gib03.mdl",
	"models/gibs/manhack_gib04.mdl",
}

function ENT:OnSetupDataTables()
	self:AddDT( "Bool", "Prongs" )
	self:AddDT( "Bool", "UseHighExplosive" )
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

	client.CalcIdeal = ACT_CROUCHIDLE
	client.CalcSeqOverride = client:LookupSequence( "cidle_knife" )

	return client.CalcIdeal, client.CalcSeqOverride
end

function ENT:InitWeapons()
	local COLOR_WHITE = Color(255,255,255,255)

	local weapon = {}
	weapon.Icon = true
	weapon.Ammo = 100
	weapon.Delay = 3
	weapon.HeatRateUp = 1
	weapon.HeatRateDown = 0.3
	weapon.OnThink = function( ent )
		local client = ent:GetDriver()

		if not IsValid( client ) then return end

		local SwitchType = client:lvsKeyDown( "CAR_SWAP_AMMO" )

		if ent._oldSwitchType != SwitchType then
			ent._oldSwitchType = SwitchType

			if SwitchType then
				ent:SetUseHighExplosive( not ent:GetUseHighExplosive() )
				ent:DoReloadSequence( 0 )
				ent:SetHeat( 1 )
				ent:SetOverheated( true )

				if ent:GetUseHighExplosive() then
					ent:TurretUpdateBallistics( ent.ProjectileVelocityHighExplosive )
				else
					ent:TurretUpdateBallistics( ent.ProjectileVelocityArmorPiercing )
				end
			end
		end
	end
	weapon.Attack = function( ent )
		local ID = ent:LookupAttachment( "muzzle" )

		local Muzzle = ent:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= Muzzle.Ang:Forward()
		bullet.Spread = Vector(0,0,0)
		bullet.EnableBallistics = true

		if ent:GetUseHighExplosive() then
			bullet.Force	= 500
			bullet.HullSize 	= 15
			bullet.Damage	= 250
			bullet.SplashDamage = 750
			bullet.SplashDamageRadius = 200
			bullet.SplashDamageEffect = "lvs_bullet_impact_explosive"
			bullet.SplashDamageType = DMG_BLAST
			bullet.Velocity = ent.ProjectileVelocityHighExplosive
		else
			bullet.Force	= ent.CannonArmorPenetration
			bullet.HullSize 	= 0
			bullet.Damage	= 1000
			bullet.Velocity = ent.ProjectileVelocityArmorPiercing
		end

		bullet.TracerName = "lvs_tracer_cannon"
		bullet.Attacker 	= ent:GetDriver()
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		ent:TakeAmmo( 1 )

		ent:DoAttackSequence()
	end
	weapon.HudPaint = function( ent, X, Y, client )
		local ID = ent:LookupAttachment(  "muzzle" )

		local Muzzle = ent:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos,
				endpos = Muzzle.Pos + Muzzle.Ang:Forward() * 50000,
				filter = ent:GetCrosshairFilterEnts()
			} )

			local MuzzlePos2D = traceTurret.HitPos:ToScreen()

			if ent:GetUseHighExplosive() then
				ent:PaintCrosshairSquare( MuzzlePos2D, COLOR_WHITE )
			else
				ent:PaintCrosshairOuter( MuzzlePos2D, COLOR_WHITE )
			end

			ent:LVSPaintHitMarker( MuzzlePos2D )
		end
	end
	self:AddWeapon( weapon )
end