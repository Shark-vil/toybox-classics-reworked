AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Boosted Artillery Cannon"
SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true
-- Settings
SWEP.HoldType = "rpg"
SWEP.Weight = 5 -- 
SWEP.AutoSwitchTo = true -- 
SWEP.AutoSwitchFrom = false -- 
SWEP.Spawnable = true -- 
SWEP.AdminSpawnable = true --		
SWEP.ObjectForce = 2500
SWEP.Counter = 1
SWEP.DoBoost = true
-- Weapon info
SWEP.Author = "Ramificate" -- 
SWEP.Contact = "Indian tech support" -- 
SWEP.Purpose = "Artillery" -- 
SWEP.Instructions = "Left click to fire artillery right click to toggle mid air boost" -- 
game.AddParticles("particles/building_explosion.pcf")
game.AddParticles("particles/cinefx.pcf")
game.AddParticles("particles/choreo_dog_v_strider.pcf")
game.AddParticles("particles/skybox_smoke.pcf")
game.AddParticles("particles/rockettrail.pcf")
game.AddParticles("particles/explosion.pcf")
game.AddParticles("particles/door_explosion.pcf")
PrecacheParticleSystem("cinefx_goldrush")
PrecacheParticleSystem("building_explosion")
PrecacheParticleSystem("smoke_dark_plume_1")
PrecacheParticleSystem("citadel_shockwave_06")
PrecacheParticleSystem("citadel_shockwave_l")
PrecacheParticleSystem("rockettrail_waterbubbles")
PrecacheParticleSystem("door_explosion_flash")
PrecacheParticleSystem("Explosion_2_FireSmoke")
-- Primary fire settings
SWEP.Primary.Sound = "/weapons/grenade_launcher1.wav" --	
SWEP.Primary.Damage = -1 -- 
SWEP.Primary.NumShots = 0 -- 
SWEP.Primary.Recoil = 0.6 -- 
SWEP.Primary.Cone = 0 -- 
SWEP.Primary.Delay = 1 -- 
SWEP.Primary.ClipSize = 100 -- 
SWEP.Primary.DefaultClip = 500 -- 
SWEP.Primary.Tracer = 0 -- 
SWEP.Primary.Force = 100 -- 
SWEP.Primary.TakeAmmoPerBullet = true -- 
SWEP.Primary.Automatic = false -- 
SWEP.Primary.Ammo = "smg1" --			 --

function SWEP:Initialize()
	self:SetHoldType("rpg")
end

-- 
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end -- 
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- 
	self:GetOwner():MuzzleFlash() -- 
	self:GetOwner():SetAnimation(PLAYER_ATTACK1) -- 
	self.Weapon:EmitSound(Sound(self.Primary.Sound)) -- 
	self:GetOwner():ViewPunch(Angle(-self.Primary.Recoil, 0, 0))

	if SERVER then
		object = ents.Create("prop_physics")
		object:SetKeyValue("explodedamage", "25")
		object:SetKeyValue("health", "1")
		object:SetKeyValue("exploderadius", "150")
		object:SetKeyValue("physdamagescale", "1500")
		object:SetName("hrefaha")
		object:SetKeyValue("physdamagescale", "500")
		object:SetModel("models/hunter/misc/sphere025x025.mdl")
		object:SetColor(Color(0, 0, 0, 255))
		object:SetOwner(self:GetOwner())
		object:SetPos(self:GetOwner():GetShootPos())
		object:SetAngles(Vector(math.random(-180, 181), math.random(-180, 181), math.random(-180, 181)):Angle())
		object:Spawn()
		physobj = object:GetPhysicsObject()
		local force = self.ObjectForce * physobj:GetMass()
		physobj:SetVelocity(self:GetOwner():GetAimVector() * force)
		ParticleEffectAttach("Rocket_Smoke", PATTACH_ABSORIGIN_FOLLOW, object, 0)

		if self.DoBoost then
			timer.Simple(0.7, function()
				if object:IsValid() then
					ParticleEffectAttach("door_explosion_flash", PATTACH_ABSORIGIN_FOLLOW, object, 0)
					ParticleEffectAttach("Explosion_2_FireSmoke", PATTACH_ABSORIGIN_FOLLOW, object, 0)
					ParticleEffectAttach("rockettrail", PATTACH_ABSORIGIN_FOLLOW, object, 0)
					physobj:EnableDrag(false)
					physobj:SetInertia(Vector(5000, 5000, 5000))
					physobj:SetVelocity(physobj:GetVelocity() * 100)
					object:EmitSound("/weapons/stinger_fire1.wav", 100, 100)
				end
			end)
		end
	end

	if SERVER then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	end
end

function Check(ent, inflictor, attacker, amount)
	if ent:GetName() == "hrefaha" and ent:IsValid() == true and ent.Bool == nil then
		ent.Bool = true

		if ent:WaterLevel() ~= 3 then
			ParticleEffectAttach("cinefx_goldrush", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
			ParticleEffectAttach("building_explosion", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
			ParticleEffectAttach("smoke_dark_plume_1", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
			ParticleEffectAttach("citadel_shockwave_06", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
			ParticleEffectAttach("citadel_shockwave_l", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
		else
			ParticleEffectAttach("rockettrail_waterbubbles", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
		end

		local boom = ents.Create("env_explosion")
		boom:SetOwner(ent:GetOwner())
		boom:SetPos(ent:GetPos())
		boom:SetKeyValue("iMagnitude", "155")
		boom:Spawn()
		boom:Activate()
		boom:Fire("Explode", "", 0)

		timer.Simple(0.05, function()
			ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
			ent:Remove()
		end)
	end
end

hook.Add("EntityTakeDamage", "Check damage", Check)

function SWEP:SecondaryAttack()
	if self.DoBoost == true then
		self.DoBoost = false
		self:GetOwner():PrintMessage(HUD_PRINTCENTER, "BOOST IS OFF")
	elseif self.DoBoost == false then
		self.DoBoost = true
		self:GetOwner():PrintMessage(HUD_PRINTCENTER, "BOOST IS ON")
	end
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

	return true
end