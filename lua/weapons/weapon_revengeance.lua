AddCSLuaFile()
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Toybox Classics"
SWEP.PrintName = "MGR: Revengeance"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.ViewModel = "models/weapons/v_models/v_fist_heavy.mdl"
SWEP.WorldModel = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Side = 0
SWEP.Special = 0
SWEP.SoundFullPath = Sound("music_mgr_revengeance_full.wav")
SWEP.SoundLoopPath = Sound("music_mgr_revengeance_short_loop.wav")
SWEP.SoundFullVolume = 0
SWEP.SoundLoopVolume = 0
SWEP.PrimaryAttackDelay = 0

SWEP.SwingMiss = {"weapons/boxing_gloves_swing1.wav", "weapons/boxing_gloves_swing2.wav", "weapons/boxing_gloves_swing4.wav"}

SWEP.SwingHit = {"weapons/fist_hit_world1.wav", "weapons/fist_hit_world2.wav"}

function SWEP:Initialize()
	self:SetHoldType("fist")
	self.SoundFullObject = CreateSound(self.Weapon, self.SoundFullPath)
	self.SoundLoopObject = CreateSound(self.Weapon, self.SoundLoopPath)

	hook.Add("EntityTakeDamage", self, function(_, target, dmginfo)
		if dmginfo:GetAttacker() == self:GetOwner() and target == self.CurrentTarget then
			return false
		end
	end)
end

--[[---------------------------------------------------------
		Reload does nothing
---------------------------------------------------------]]
function SWEP:Reload() end

function SWEP:OnRemove()
	hook.Remove("EntityTakeDamage", self)
	if self.SoundLoopObject then self.SoundLoopObject:Stop() end
	if self.SoundFullObject then self.SoundFullObject:Stop() end
end

--[[---------------------------------------------------------
	 Think does nothing
---------------------------------------------------------]]
function SWEP:Think()
	local tr = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))
	if tr.HitPos:Distance(self:GetOwner():GetShootPos()) < 70 then
		self.CurrentTarget = tr.Entity
	else
		self.CurrentTarget = NULL
	end

	if CLIENT then return end

	self.LastFrame = self.LastFrame or CurTime()

	if self:GetOwner():KeyDown(IN_ATTACK) then
		self:PlayLoopSound()
	elseif self:GetOwner():KeyDown(IN_ATTACK2) then
		self:PlayFullSound()
	else
		self:StopSounds(true, true)
	end

	self.LastFrame = CurTime()
end

function SWEP:PlayFullSound()
	if not self.SoundFullObject:IsPlaying() then self.SoundFullObject:Play() end
	self.SoundFullVolume = math.Clamp(self.SoundFullVolume + CurTime() - self.LastFrame, 0, 1)
	self.SoundFullObject:ChangeVolume(self.SoundFullVolume)
	self:StopSounds(false, true)
end

function SWEP:PlayLoopSound()
	if not self.SoundLoopObject:IsPlaying() then self.SoundLoopObject:Play() end
	self.SoundLoopVolume = math.Clamp(self.SoundLoopVolume + CurTime() - self.LastFrame, 0, 1)
	self.SoundLoopObject:ChangeVolume(self.SoundLoopVolume)
	self:StopSounds(true, false)
end

function SWEP:StopSounds(fullSound, loopSound)
	if fullSound then
		self.SoundFullVolume = math.Clamp(self.SoundFullVolume - CurTime() + self.LastFrame, 0, 1)
		if self.SoundFullVolume  == 0 then
			self.SoundFullObject:Stop()
		else
			self.SoundFullObject:ChangeVolume(self.SoundFullVolume)
		end
	end

	if loopSound then
		self.SoundLoopVolume = math.Clamp(self.SoundLoopVolume - CurTime() + self.LastFrame, 0, 1)
		if self.SoundLoopVolume  == 0 then
			self.SoundLoopObject:Stop()
			self.PrimaryAttackDelay = 0
		else
			self.SoundLoopObject:ChangeVolume(self.SoundLoopVolume)
		end
	end
end

function SWEP:CanPrimaryAttack()
	if self.PrimaryAttackDelay > CurTime() then
		return false
	end
end

--[[---------------------------------------------------------
		PrimaryAttack
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
	self:GetOwner():DoAttackEvent()

	if self.PrimaryAttackDelay == 0 then
		self.PrimaryAttackDelay = CurTime() + 3
		return
	elseif self.PrimaryAttackDelay > CurTime() then
		return
	end

	if self.Side == 0 then
		self.Side = 1
		self.Weapon:SendWeaponAnim(ACT_VM_HITLEFT)
	else
		self.Side = 0
		self.Weapon:SendWeaponAnim(ACT_VM_HITRIGHT)
	end

	if IsValid(self.CurrentTarget) then
		self:EmitSound(tostring(table.Random(self.SwingHit)), 40, 100, 1, CHAN_AUTO)
		self:ShootBullet(0, 1, 0, nil, 0, 0)
	else
		self:EmitSound(tostring(table.Random(self.SwingMiss)))
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.05)
end

--[[---------------------------------------------------------
		SecondaryAttack
---------------------------------------------------------]]
function SWEP:SecondaryAttack() end

--[[---------------------------------------------------------
	 Name: ShouldDropOnDie
	 Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------]]
function SWEP:ShouldDropOnDie()
	return false
end