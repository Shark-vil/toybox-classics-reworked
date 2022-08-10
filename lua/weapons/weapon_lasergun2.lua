AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.UseHands = true
SWEP.Author = "victormeriqui"
SWEP.Purpose = "do stuff"
SWEP.Instructions = "!!!"
SWEP.PrintName = "Laser Gun"
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.Primary.ClipSize = 100
SWEP.Primary.Force = 50
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Secondary.Delay = 300
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Force = 50
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "Pistol"

if CLIENT then
	surface.CreateFont("TextFont", {
		font = "Segoe Print",
		size = 20,
		weight = 550
	})
end

function SWEP:ViewModelDrawn()
	local me = self:GetOwner()
	local isfiring
	local color = Color(0, 0, 0, 255)
	local spin
	local hit
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if tr.Hit and tr.HitNonWorld and (tr.Entity:IsNPC() or (tr.Entity:IsPlayer() and tr.Entity:Alive())) and self.Weapon:Clip1() > 2 then
		hit = tr.Entity:GetClass():sub(5, -1)
		color = Color(0, 255, 0, 255)
		spin = SysTime() * 700
		isfiring = Material("icon16/star.png")
	else
		hit = "NONE"
		color = Color(255, 0, 0, 255)
		spin = 90
		isfiring = Material("icon16/emoticon_smile.png")
	end

	local clipcol = Color(0, 0, 0, 255)
	local clip2col = Color(0, 0, 0, 255)

	if self.Weapon:Clip1() < 20 then
		clipcol = Color(255, 0, 0, 255)
	elseif self.Weapon:Clip1() < 60 then
		clipcol = Color(255, 255, 0, 255)
	elseif self.Weapon:Clip1() > 59 then
		clipcol = Color(0, 255, 0, 255)
	end

	if self.Weapon:Clip2() == 0 then
		clip2col = Color(255, 0, 0, 255)
	elseif self.Weapon:Clip2() == 1 then
		clip2col = Color(0, 255, 0, 255)
	end

	local muzzle = me:GetViewModel():GetAttachment(me:GetViewModel():LookupAttachment("muzzle"))

	if self:GetOwner():KeyDown(IN_ATTACK) and self.Weapon:Clip1() > 2 then
		color = Color(150, 0, 255, 255)
		spin = SysTime() * 2000
		isfiring = Material("icon16/exclamation.png")

		if self.Weapon:Clip1() > 2 then
			render.SetMaterial(Material("sprites/bluelaser1"))
			render.DrawBeam(muzzle.Pos, self:GetOwner():GetEyeTrace().HitPos, 5, 0, 0, Color(100, 0, 255, 255))
		end
	end

	local muzzleang = muzzle.Ang
	muzzleang:RotateAroundAxis(muzzleang:Right(), 90)
	cam.Start3D2D(muzzle.Pos - me:GetAimVector(), muzzleang, 0.05)
	cam.IgnoreZ(true)
	--ammo panel
	draw.RoundedBox(6, -320, 0, 320, 50, Color(11, 11, 11, 100))
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(-320, 0, 321, 51)
	draw.RoundedBox(0, -180, 17, 106, 16, Color(0, 0, 0, 255))
	draw.RoundedBox(0, -177, 20, self.Weapon:Clip1(), 10, clipcol)
	--circle taget
	surface.DrawCircle(-220, 25, 23, color)
	surface.SetDrawColor(color)
	surface.SetTexture(surface.GetTextureID("debug/debugportals"))
	surface.DrawTexturedRectRotated(-220, 25, 1, 34, spin)
	surface.DrawTexturedRectRotated(-220, 25, 34, 1, spin)
	--projectile color box next to ammo panel
	draw.RoundedBox(2, -320, -30, 21, 110, Color(160, 160, 160, 255))
	draw.RoundedBox(0, -317, 75, 15, -self.Weapon:Clip2() * 100, clip2col)
	--distance panel    
	draw.RoundedBox(0, -170, -200, 200, 100, Color(11, 11, 11, 100))
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(-170, -200, 201, 101)
	--box target
	surface.SetDrawColor(color)
	surface.DrawOutlinedRect(-100, -180, 50, 50)
	surface.SetTexture(surface.GetTextureID("debug/debugportals"))
	surface.DrawTexturedRectRotated(-75, -155, 1, 34, spin)
	surface.DrawTexturedRectRotated(-75, -155, 34, 1, spin)
	--box around crosshair
	surface.DrawOutlinedRect(-155, -137, 10, 10)
	--distance
	draw.SimpleText("Distance: " .. math.floor(self:GetOwner():GetEyeTrace().HitPos:Distance(self:GetOwner():GetPos())), "ScoreboardText", -165, -120, Color(0, 0, 0, 255))
	draw.SimpleText("Target: " .. hit, "ScoreboardText", -120, -200, Color(255, 255, 255, 255))
	surface.SetMaterial(isfiring)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(-280, 20, 15, 15)
	--text
	draw.SimpleText("The Shittiest", "TextFont", 0, -100, Color(255, 0, 0, 255))
	draw.SimpleText("SWEP In Town.", "TextFont", 15, -80, Color(255, 0, 0, 255))
	cam.IgnoreZ(false)
	cam.End3D2D()
end

function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw = true
	self.AmmoDisplay.PrimaryClip = self:Clip1()
	self.AmmoDisplay.PrimaryAmmo = 0
	self.AmmoDisplay.SecondaryAmmo = self:Clip2()

	return self.AmmoDisplay
end

function SWEP:DrawHUD()
	local me = self:GetOwner()
	local x = ScrW() / 2
	local y = ScrH() / 2
	surface.DrawCircle(x, y, 1, Color(255, 255, 255, 255))
end

function SWEP:PrimaryAttack()
	local me = self:GetOwner()
	local tr = self:GetOwner():GetEyeTraceNoCursor()
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(math.Rand(10, 50))
	dmginfo:SetDamageForce(Vector(10, 0, 0))

	if dmginfo:GetDamage() > 30 then
		dmginfo:SetDamageType(DMG_DISSOLVE)
	else
		dmginfo:SetDamageType(DMG_BULLET)
	end

	if self.Weapon:Clip1() > 2 then
		dmginfo:SetAttacker(me)

		if SERVER and IsValid(tr.Entity) then
			tr.Entity:TakeDamageInfo(dmginfo)
		end

		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:EmitSound("npc/stalker/laser_flesh.wav")
		self.Weapon:SetClip1(self.Weapon:Clip1() - 1)

		timer.Create("ToyBox_WeaponLaser2StopSoundPrimaryAttack", .2, 1, function()
			if not IsValid(self) then return end
			self:StopSound("npc/stalker/laser_flesh.wav")
		end)
	end
	--yes bitch, i do it like this. Problem?
end

function SWEP:SecondaryAttack()
	if self.Weapon:Clip2() > 0 then
		self:EmitSound("ambient/energy/zap6.wav", 100, 100)
		self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self.Weapon:SetClip2(self.Weapon:Clip2() - 1)
		if not SERVER then return end
		local ang = self:GetOwner():GetAimVector():GetNormalized()
		local pos = self:GetOwner():EyePos() + (self:GetOwner():GetAimVector() * 32)

		proj = MakeLight(self:GetOwner(), 0, 255, 255, 1, 80, 1, 1, {
			Pos = pos,
			Angle = ang
		})

		proj:SetPos(pos)
		proj:SetAngles(ang:Angle())
		print(ang)
		local trail = util.SpriteTrail(proj, 0, Color(0, 0, 255, 255), false, 5, 1, 0.4, 1 / 6 * 0.5, "trails/electric.vmt")
		local phys = proj:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:ApplyForceCenter(self:GetOwner():GetAimVector() * 1000)

		function proj:PhysicsCollide(data, phys)
			data.HitObject:GetEntity():TakeDamage(100)
			data.HitObject:ApplyForceCenter(self:GetPhysicsObject():GetVelocity() * 40)
			data.HitObject:GetEntity():Ignite(10, 1)
			local vPoint = self:GetPos()
			local eff = EffectData()
			eff:SetStart(vPoint)
			eff:SetOrigin(vPoint)
			eff:SetScale(1)
			util.Effect("Sparks", eff)
			--these were from hl2dm shit back when i used to mess around with the console
			--flash
			local fade = ents.Create("env_fade")
			fade:SetPos(vPoint)
			fade:SetKeyValue("duration", 1)
			fade:SetKeyValue("renderamt", 255)
			fade:SetKeyValue("rendercolor", "249 249 249")
			fade:Spawn()
			fade:Fire("fade", 0, 0)
			--the explosion, no effects
			local explode = ents.Create("env_explosion")
			explode:SetPos(vPoint + Vector(0, 0, 500))
			explode:SetOwner(self:GetOwner())
			explode:Spawn()
			explode:SetKeyValue("iMagnitude", 1200)
			explode:SetKeyValue("fireballsprite", "sprites/light_glow03.vmt")
			explode:Fire("Explode", 0, 0)
			--effects
			--cloud 
			local middle = ents.Create("env_ar2explosion")
			middle:SetPos(vPoint + Vector(0, 0, 2000))
			middle:SetOwner(self:GetOwner())
			middle:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			middle:Spawn()
			middle:Fire("Explode", 0, 0)
			--right
			local right = ents.Create("env_ar2explosion")
			right:SetPos(vPoint + Vector(0, 500, 2000))
			right:SetOwner(self:GetOwner())
			right:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			right:Spawn()
			right:Fire("Explode", 0, 0)
			local right2 = ents.Create("env_ar2explosion")
			right2:SetPos(vPoint + Vector(0, 1000, 2000))
			right2:SetOwner(self:GetOwner())
			right2:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			right2:Spawn()
			right2:Fire("Explode", 0, 0)
			local diagonalr = ents.Create("env_ar2explosion")
			diagonalr:SetPos(vPoint + Vector(500, 500, 2000))
			diagonalr:SetOwner(self:GetOwner())
			diagonalr:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			diagonalr:Spawn()
			diagonalr:Fire("Explode", 0, 0)
			--left
			local left = ents.Create("env_ar2explosion")
			left:SetPos(vPoint + Vector(0, -500, 2000))
			left:SetOwner(self:GetOwner())
			left:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			left:Spawn()
			left:Fire("Explode", 0, 0)
			local left2 = ents.Create("env_ar2explosion")
			left2:SetPos(vPoint + Vector(0, -1000, 2000))
			left2:SetOwner(self:GetOwner())
			left2:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			left2:Spawn()
			left2:Fire("Explode", 0, 0)
			local diagonall = ents.Create("env_ar2explosion")
			diagonall:SetPos(vPoint + Vector(-500, -500, 2000))
			diagonall:SetOwner(self:GetOwner())
			diagonall:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			diagonall:Spawn()
			diagonall:Fire("Explode", 0, 0)
			local diagonall2 = ents.Create("env_ar2explosion")
			diagonall2:SetPos(vPoint + Vector(-1000, -1000, 2000))
			diagonall2:SetOwner(self:GetOwner())
			diagonall2:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			diagonall2:Spawn()
			diagonall2:Fire("Explode", 0, 0)
			--down
			local down = ents.Create("env_ar2explosion")
			down:SetPos(vPoint + Vector(500, 0, 2000))
			down:SetOwner(self:GetOwner())
			down:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			down:Spawn()
			down:Fire("Explode", 0, 0)
			local down2 = ents.Create("env_ar2explosion")
			down2:SetPos(vPoint + Vector(1000, 0, 2000))
			down2:SetOwner(self:GetOwner())
			down2:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			down2:Spawn()
			down2:Fire("Explode", 0, 0)
			local diagonald = ents.Create("env_ar2explosion")
			diagonald:SetPos(vPoint + Vector(-500, 500, 2000))
			diagonald:SetOwner(self:GetOwner())
			diagonald:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			diagonald:Spawn()
			diagonald:Fire("Explode", 0, 0)
			local diagonald2 = ents.Create("env_ar2explosion")
			diagonald2:SetPos(vPoint + Vector(-1000, 1000, 2000))
			diagonald2:SetOwner(self:GetOwner())
			diagonald2:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			diagonald2:Spawn()
			diagonald2:Fire("Explode", 0, 0)
			--up
			local up = ents.Create("env_ar2explosion")
			up:SetPos(vPoint + Vector(-500, 0, 2000))
			up:SetOwner(self:GetOwner())
			up:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			up:Spawn()
			up:Fire("Explode", 0, 0)
			local up2 = ents.Create("env_ar2explosion")
			up2:SetPos(vPoint + Vector(-1000, 0, 2000))
			up2:SetOwner(self:GetOwner())
			up2:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			up2:Spawn()
			up2:Fire("Explode", 0, 0)
			local diagonalu = ents.Create("env_ar2explosion")
			diagonalu:SetPos(vPoint + Vector(500, -500, 2000))
			diagonalu:SetOwner(self:GetOwner())
			diagonalu:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			diagonalu:Spawn()
			diagonalu:Fire("Explode", 0, 0)
			local diagonalu2 = ents.Create("env_ar2explosion")
			diagonalu2:SetPos(vPoint + Vector(1000, -1000, 2000))
			diagonalu2:SetOwner(self:GetOwner())
			diagonalu2:SetKeyValue("material", "particle/particle_smokegrenade.vmt")
			diagonalu2:Spawn()
			diagonalu2:Fire("Explode", 0, 0)
			--body
			local body = ents.Create("env_ar2explosion")
			body:SetPos(vPoint + Vector(0, 0, 300))
			body:SetOwner(self:GetOwner())
			body:SetKeyValue("material", "Effects/fire_cloud1.vmt")
			body:Spawn()
			body:Fire("Explode", 0, 0)
			local body2 = ents.Create("env_ar2explosion")
			body2:SetPos(vPoint + Vector(0, 0, 600))
			body2:SetOwner(self:GetOwner())
			body2:SetKeyValue("material", "Effects/fire_cloud1.vmt")
			body2:Spawn()
			body2:Fire("Explode", 0, 0)
			local body3 = ents.Create("env_ar2explosion")
			body3:SetPos(vPoint + Vector(0, 0, 1200))
			body3:SetOwner(self:GetOwner())
			body3:SetKeyValue("material", "Effects/fire_cloud1.vmt")
			body3:Spawn()
			body3:Fire("Explode", 0, 0)
			local body4 = ents.Create("env_ar2explosion")
			body4:SetPos(vPoint + Vector(0, 0, 1800))
			body4:SetOwner(self:GetOwner())
			body4:SetKeyValue("material", "Effects/fire_cloud1.vmt")
			body4:Spawn()
			body4:Fire("Explode", 0, 0)
			--feet
			local foot = ents.Create("env_ar2explosion")
			foot:SetPos(vPoint + Vector(0, 0, 100))
			foot:SetOwner(self:GetOwner())
			foot:SetKeyValue("material", "sprites/orangecore1.vmt")
			foot:Spawn()
			foot:Fire("Explode", 0, 0)
			--the thing that hurts you
			local rad = ents.Create("point_hurt")
			rad:SetPos(vPoint)
			rad:SetOwner(self:GetOwner())
			rad:Spawn()
			rad:SetKeyValue("damage", 50)
			rad:SetKeyValue("damageradius", 3000)
			rad:Fire("turnon", "", 0)
			rad:Fire("kill", "", 5.1)
			self:EmitSound("physics/plastic/plastic_box_impact_hard3.wav", 100, 100)
			self:EmitSound("ambient/explosions/explode_1.wav", 100, 100)
			self:Remove()
		end
	end
end

--that was hard :\
function SWEP:Reload()
	if self:GetOwner():KeyDown(IN_RELOAD) then
		if self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():KeyDown(IN_ATTACK2) then
			return
		else
			local NextThink = 0

			if (CurTime() >= NextThink) and (self:Clip1() < 100) and (self:Clip1() > 1) then
				self:SetClip1(self:Clip1() + 1)
				NextThink = CurTime() + 0.1
			end

			if (CurTime() >= NextThink) and (self:Clip2() < 1) and (self:Clip2() > -1) then
				self:SetClip2(self:Clip2() + 1)
				NextThink = CurTime() + 10
			end

			if NextThink > 0 then
				self:EmitSound("ambient/machines/combine_shield_loop3.wav")
	
				timer.Create("ToyBox_WeaponLaser2StopSoundReload", .2, 1, function()
					if not IsValid(self) then return end
					self:StopSound("ambient/machines/combine_shield_loop3.wav")
				end)
			end
		end
	end
end

function SWEP:Deploy()
	self:EmitSound("ambient/voices/f_scream1.wav", 100, 100)
end