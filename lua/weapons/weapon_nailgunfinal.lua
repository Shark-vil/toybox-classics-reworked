AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "nailgun"
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "pistol"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "figure it out if you haven't already"
SWEP.ViewModel = "models/advancedweaponiser/nailgun/v_nailgun.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ShootSound = "weapons/nailgun_shoot.wav"
SWEP.DELAY = .1

function SWEP:Initialize()
  self:SetHoldType("pistol")
end

function SWEP:Deploy()
  self:SendWeaponAnim(ACT_VM_DRAW)

  return true
end

function SWEP:PrimaryAttack()
  if self:Clip1() <= 0 then
    self:Reload()

    return
  end

  if self.DELAY > CurTime(.1) then return end
  self.DELAY = CurTime(.1)
  self:TakePrimaryAmmo(1)
  self:EmitSound(self.ShootSound)
  self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

  if SERVER then
    local needle = ents.Create("scout_nail")
    local pos = self:GetAttachment(self:LookupAttachment("muzzle"))["Pos"]
    pos.z = pos.z + self:GetOwner():WorldToLocal(self:GetOwner():GetShootPos()).z
    needle:SetPos(self:GetOwner():GetShootPos())
    needle:SetAngles(self:GetOwner():EyeAngles())
    needle.owner = self
    needle:Spawn()
    needle:Activate()
    needle:SetOwner(self:GetOwner())
    local phys = needle:GetPhysicsObject()

    if phys:IsValid() then
      phys:SetVelocity((self:GetOwner():GetForward() + Vector(0, math.Rand(-0.009, 0.009), math.Rand(-0.009, 0.009))) * 1900)
    end
  end

  self:SetNextSecondaryFire(CurTime() + .1)
  self:SetNextPrimaryFire(CurTime() + .1)
end

function SWEP:SecondaryAttack()
end

function SWEP:ShouldDropOnDie()
  return true
end