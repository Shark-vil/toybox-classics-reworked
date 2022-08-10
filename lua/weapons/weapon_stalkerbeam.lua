AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Stalker Beam"
SWEP.Author = "Jvs"
SWEP.Slot = 3
SWEP.SlotPos = 5
SWEP.Weight = 5
SWEP.ViewModel = "models/effects/teleporttrail_alyx.mdl"
SWEP.WorldModel = "models/effects/teleporttrail_alyx.mdl"
SWEP.MinRange = 64 * 12
SWEP.Range = 3600 * 12

SWEP.BeamDamage = {1, 3, 10}

SWEP.DamageDelay = 0.1
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = false
SWEP.Primary.Automatic = true
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = true
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

if CLIENT then
	language.Add("weapon_stalkerbeam", "Stalker Beam")
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
	SWEP.ViewModelFOV = 54
	SWEP.SwayScale = 0 -- The scale of the viewmodel sway
	SWEP.BobScale = 0 -- The scale of the viewmodel bob
	SWEP.Contact = "jvs_34@yahoo.it"
	SWEP.Purpose = "Damage anything! Stalker...style?"
	SWEP.Instructions = "Primary: Stalker Beam. Secondary:Upgrade"
	SWEP.RenderGroup = RENDERGROUP_TRANSLUCENT

	local laser = CreateMaterial("sprites/laserbeamnew", "UnlitGeneric", {
		['$basetexture'] = "sprites/laser",
		['$additive'] = "1",
		['$vertexcolor'] = "1",
		['$vertexalpha'] = "1",
	})

	local colbeam = {Color(255, 0, 0, 255), Color(255, 50, 0, 255), Color(255, 150, 0, 255)}

	local sprite = {
		CreateMaterial("sprites/redglow1stalker", "UnlitGeneric", {
			['$basetexture'] = "sprites/redglow1",
			['$additive'] = "1",
			['$vertexcolor'] = "1",
			['$vertexalpha'] = "1",
		}),
		CreateMaterial("sprites/orangeglow1stalker", "UnlitGeneric", {
			['$basetexture'] = "sprites/orangeglow1",
			['$additive'] = "1",
			['$vertexcolor'] = "1",
			['$vertexalpha'] = "1",
		}),
		CreateMaterial("sprites/yellowglow1stalker", "UnlitGeneric", {
			['$basetexture'] = "sprites/yellowglow1",
			['$additive'] = "1",
			['$vertexcolor'] = "1",
			['$vertexalpha'] = "1",
		})
	}

	function SWEP:CalculateOffset(pos, ang, off)
		local selfangle = ang
		local selfpos = pos
		local offset = selfangle:Right() * off.x + selfangle:Forward() * off.y + selfangle:Up() * off.z
		local pos = selfpos + offset

		return pos
	end

	function SWEP:ViewModelDrawn()
		if not self.dt.attacking then return end
		local Owner = self:GetOwner()
		if not IsValid(Owner) then return end
		--i know,this viewmodel sprite rendering code sucks,i wrote it quickly,and it show the sprite when looking up and the beam when
		--looking down,i really should rotate it with the Owner:EyeAngles()
		local traceres = util.QuickTrace(Owner:EyePos(), Owner:EyeAngles():Forward() * (3600 * 12), Owner)
		local offzet = Vector(0, 0, 3)
		local StartPos = self:CalculateOffset(Owner:EyePos(), Owner:EyeAngles(), offzet)
		render.SetMaterial(laser)
		render.DrawBeam(StartPos, traceres.HitPos, 2, 0, 0, colbeam[self.dt.power])
		render.SetMaterial(sprite[self.dt.power])
		render.DrawSprite(StartPos, 76.8, 76.8, Color(255, 200, 200, 255))
		render.DrawSprite(traceres.HitPos, 10, 10, Color(255, 255, 255, 255))
		self:CreateLight(StartPos, 100, 0)
		self:CreateLight(traceres.HitPos, 50, 1)
	end

	function SWEP:DrawWorldModelTranslucent()
		self:DrawWMBeam()
	end

	function SWEP:CreateLight(pos, size, numb)
		local dlight = DynamicLight(self:EntIndex() + numb)

		if dlight then
			dlight.r = colbeam[self.dt.power].r
			dlight.g = colbeam[self.dt.power].g
			dlight.b = colbeam[self.dt.power].b
			dlight.Pos = pos
			dlight.Brightness = 4
			dlight.Size = size
			dlight.Decay = size
			dlight.DieTime = CurTime() + 0.1
		end
	end

	function SWEP:DrawWorldModel()
		self:DrawWMBeam()
	end

	function SWEP:DrawWMBeam()
		if not self.dt.attacking then return end
		local Owner = self:GetOwner()
		if not IsValid(Owner) then return end
		local traceres = util.QuickTrace(Owner:EyePos(), Owner:GetAimVector() * (3600 * 12), Owner)
		local StartPos = Owner:GetAttachment(Owner:LookupAttachment("eyes")).Pos + Vector(0, 0, 3)
		render.SetMaterial(laser)
		render.DrawBeam(StartPos, traceres.HitPos, 2, 0, 0, colbeam[self.dt.power])
		render.SetMaterial(sprite[self.dt.power])
		render.DrawSprite(StartPos, 76.8, 76.8, Color(255, 200, 200, 255))
		render.DrawSprite(StartPos, 16, 16, Color(255, 200, 200, 255))
		render.DrawSprite(traceres.HitPos, 10, 10, Color(255, 255, 255, 255))
		self:CreateLight(Owner:EyePos(), 100, 0)
		self:CreateLight(traceres.HitPos, 50, 1)
	end
end

function SWEP:Initialize()
	self.AttackTime = CurTime()
	self:SetHoldType("normal")
	self:InstallDataTable()
	self:DTVar("Bool", 0, "attacking")
	self:DTVar("Int", 0, "power")
	self.dt.power = 1
	self.dt.attacking = false
	self.NextScream = CurTime()
end

function SWEP:Shoot()
	local owner = self:GetOwner()
	if not owner then return end
	--so you cant just snipe with the long range of 16384 game units
	local traceres

	if IsValid(self.BeamEnd) then
		traceres = util.QuickTrace(owner:EyePos(), owner:GetAimVector() * self.Range, {owner, self.BeamEnd})
	else
		traceres = util.QuickTrace(owner:EyePos(), owner:GetAimVector() * self.Range, owner)
	end

	--[[
	if traceres.HitWorld && !traceres.HitSky then
		local Pos1 = traceres.HitPos + traceres.HitNormal
		local Pos2 = traceres.HitPos - traceres.HitNormal
		util.Decal("FadingScorch" ,Pos1,Pos2)
		util.Decal("RedGlowFade",Pos1,Pos2)
	end
	]]
	if SERVER and IsValid(traceres.Entity) then
		local DMG = DamageInfo()
		DMG:SetDamageType(DMG_SHOCK)
		DMG:SetDamage(self.BeamDamage[self.dt.power])
		DMG:SetAttacker(self:GetOwner())
		DMG:SetInflictor(self)
		DMG:SetDamagePosition(traceres.HitPos)
		DMG:SetDamageForce(pPlayer:GetAimVector() * (10000 * self.dt.power))
		traceres.Entity:TakeDamageInfo(DMG)
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
	if self.NextScream < CurTime() and self:CanUpgrade() then
		if SERVER then
			self:Upgrade()
			self:UpgradeAmmo()
		end

		self.NextScream = CurTime() + SoundDuration("d3_citadel.stalker_shriek1")
		self:GetOwner():EmitSound("d3_citadel.stalker_shriek1")
	end
end

function SWEP:Reload()
end

function SWEP:Holster(wep)
	if SERVER then
		self:DestroyEndPos()
	end

	return true
end

function SWEP:OnRemove()
	if not SERVER then return end
	self:DestroyEndPos()
end

function SWEP:Deploy()
	self.m_WeaponDeploySpeed = 1
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

	return true
end

function SWEP:Beam(bool)
	if not self.dt.attacking and bool then
		self.Weapon:EmitSound("npc/stalker/laser_flesh.wav")
	end

	if bool ~= self.dt.attacking then
		self.dt.attacking = bool
	end
end

function SWEP:CreateEndPos()
	if (not self.BeamEnd or not IsValid(self.BeamEnd)) and SERVER then
		self.BeamEnd = ents.Create("base_anim")
		self.BeamEnd:SetModel(self.WorldModel)
		self.BeamEnd:SetNoDraw(true)
		self.BeamEnd:SetPos(Vector(0, 0, 0))
		self.BeamEnd:Spawn()
		self:CreateSounds(self.BeamEnd)
	end
end

function SWEP:DestroyEndPos()
	if self.BeamEnd and IsValid(self.BeamEnd) then
		self.BeamEnd.WallSound:Stop()
		self.BeamEnd.FleshSound:Stop()
		self.BeamEnd:Remove()
		self.BeamEnd = NULL
	end
end

function SWEP:CreateSounds(ent)
	if not ent.WallSound then
		ent.WallSound = CreateSound(ent, "NPC_Stalker.BurnWall")
	end

	if not ent.FleshSound then
		ent.FleshSound = CreateSound(ent, "NPC_Stalker.BurnFlesh")
	end
end

function SWEP:UpdateSoundPos()
	self:CreateEndPos()

	if SERVER then
		local owner = self:GetOwner()
		local traceres = util.QuickTrace(owner:EyePos(), owner:GetAimVector() * self.Range, {owner, self.BeamEnd})

		self.BeamEnd:SetPos(traceres.HitPos)

		if traceres.HitWorld then
			if not self.BeamEnd.PlayWallSound then
				self.BeamEnd.WallSound:Play()
				self.BeamEnd.PlayWallSound = true
			end

			if self.BeamEnd.PlayFleshSound then
				self.BeamEnd.FleshSound:Stop()
				self.BeamEnd.PlayFleshSound = false
			end

			if self.BeamEnd.PlayWallSound then
				self.BeamEnd.WallSound:ChangePitch(100 + (10 * (self.dt.power - 1)))
			end
		else
			if not self.BeamEnd.PlayFleshSound then
				self.BeamEnd.FleshSound:Play()
				self.BeamEnd.PlayFleshSound = true
			end

			if self.BeamEnd.PlayWallSound then
				self.BeamEnd.WallSound:Stop()
				self.BeamEnd.PlayWallSound = false
			end
		end
	end
end

function SWEP:Upgrade()
	if self.dt.power < 3 then
		self.dt.power = self.dt.power + 1
	else
		self.dt.power = 1
	end
end

function SWEP:BeamDecal()
	local owner = self:GetOwner()
	if not owner then return end
	--so you cant just snipe with the long range of 16384 game units
	local traceres

	if IsValid(self.BeamEnd) then
		traceres = util.QuickTrace(owner:EyePos(), owner:GetAimVector() * self.Range, {owner, self.BeamEnd})
	else
		traceres = util.QuickTrace(owner:EyePos(), owner:GetAimVector() * self.Range, owner)
	end

	if traceres.HitWorld and not traceres.HitSky then
		local Pos1 = traceres.HitPos + traceres.HitNormal
		local Pos2 = traceres.HitPos - traceres.HitNormal
		util.Decal("FadingScorch", Pos1, Pos2)
		util.Decal("RedGlowFade", Pos1, Pos2)
	end
end

function SWEP:Think()
	local owner = self:GetOwner()

	if owner:KeyDown(IN_ATTACK) and not owner:KeyDown(IN_ZOOM) and self:HasPrimaryAmmo() then
		self:Beam(true)
		self:UpdateSoundPos()
		self:BeamDecal()

		if self.AttackTime < CurTime() then
			self:Shoot()
			self:EatAmmo()
			self.AttackTime = CurTime() + self.DamageDelay
		end

		timer.Create("ToyBox_WeaponStalkerBeamStopSound", .2, 1, function()
			if not IsValid(self) then return end
			self.Weapon:StopSound("npc/stalker/laser_flesh.wav")
		end)
	else
		self:DestroyEndPos()
		self:Beam(false)
	end
end

function SWEP:HasPrimaryAmmo()
	return true --we will always return true on this side,the other weapon will return true if it has enough ammo
end

function SWEP:EatAmmo()
end

--self:TakePrimaryAmmo(1);
function SWEP:CanUpgrade()
	return true --we will always return true on this side,the other weapon will return true if it has enough ammo
end

function SWEP:UpgradeAmmo()
end