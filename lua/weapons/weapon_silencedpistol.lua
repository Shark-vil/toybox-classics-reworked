AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Silenced Pistol"
SWEP.Slot = 2
SWEP.SlotPos = 5
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/weapons/v_gistol.mdl"
SWEP.WorldModel = "models/weapons/v_gistol.mdl"
SWEP.ReloadSound = "weapons/pistol/gistol_reload1.wav"
SWEP.HoldType = "pistol"
SWEP.UseHands = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Author = "II HitmanJack x"
SWEP.Contact = "Just msg me on steam"
SWEP.Instructions = "Left Click to fire"
SWEP.Primary.Sound = "weapons/usp/usp1.wav"
SWEP.Primary.Damage = 31
SWEP.Primary.NumShots = 1
SWEP.Primary.Recoil = 0
SWEP.Primary.Cone = 0.03
SWEP.Primary.Delay = 0.01
SWEP.Primary.ClipSize = 13
SWEP.Primary.DefaultClip = 26
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.Secondary.Ammo = false

function SWEP:Initialize()
  self:SetHoldType("pistol")
end

function SWEP:PrimaryAttack()
  if not self:CanPrimaryAttack() then return end
  local bullet = {}
  bullet.Num = self.Primary.NumShots
  bullet.Src = self:GetOwner():GetShootPos()
  bullet.Dir = self:GetOwner():GetAimVector()
  bullet.Spread = Vector(self.Primary.Cone / 90, self.Primary.Cone / 90, 0)
  bullet.Tracer = self.Primary.Tracer
  bullet.Force = self.Primary.Force
  bullet.Damage = self.Primary.Damage
  bullet.AmmoType = self.Primary.Ammo
  self:GetOwner():FireBullets(bullet)
  self:GetOwner():MuzzleFlash()
  self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self:GetOwner():SetAnimation(PLAYER_ATTACK1)
  self.Weapon:EmitSound(Sound(self.Primary.Sound))
  self:GetOwner():ViewPunch(Angle(-self.Primary.Recoil, 0, 0))

  if self.Primary.TakeAmmoPerBullet then
    self:TakePrimaryAmmo(self.Primary.NumShots)
  else
    self:TakePrimaryAmmo(1)
  end

  self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
end

function SWEP:Holster()
  self:SetSubMaterial(0, "")
  self:SetSubMaterial(1, "")

  if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetViewModel()) then
    local vm = self:GetOwner():GetViewModel()
    vm:SetSubMaterial(0, "")
    vm:SetSubMaterial(1, "")
  end

  return true
end

function SWEP:OnRemove()
  self:Holster()
end

function SWEP:Reload()
  if self:DefaultReload(ACT_VM_RELOAD) then
    self:EmitSound(self.ReloadSound)
  end

  return true
end

function SWEP:DrawWorldModel()
  -- remove hev
  if self:GetSubMaterial(0) ~= "color" then
    self:SetSubMaterial(0, "color")
  end

  -- hexed pistol skin
  if self:GetSubMaterial(1) ~= "models/weapons/v_pistol/v_gistol_sheet" then
    self:SetSubMaterial(1, "models/weapons/v_pistol/v_gistol_sheet")
  end

  -- remove laser
  if self:GetSubMaterial(4) ~= "color" then
    self:SetSubMaterial(4, "color")
  end

  self:DrawModel()
end

function SWEP:PostDrawViewModel(vm)
  -- remove hev
  if vm:GetSubMaterial(0) ~= "color" then
    vm:SetSubMaterial(0, "color")
  end

  -- hexed pistol skin
  if vm:GetSubMaterial(1) ~= "models/weapons/v_pistol/v_gistol_sheet" then
    vm:SetSubMaterial(1, "models/weapons/v_pistol/v_gistol_sheet")
  end
end