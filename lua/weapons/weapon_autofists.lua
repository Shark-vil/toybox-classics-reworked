AddCSLuaFile()
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Toybox Classics"
SWEP.PrintName = "Autofists"
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

SWEP.SwingMiss = {"weapons/boxing_gloves_swing1.wav", "weapons/boxing_gloves_swing2.wav", "weapons/boxing_gloves_swing4.wav"}

SWEP.SwingHit = {"weapons/fist_hit_world1.wav", "weapons/fist_hit_world2.wav"}

function SWEP:Initialize()
  self:SetHoldType("fist")
end

--[[---------------------------------------------------------
    Reload does nothing
---------------------------------------------------------]]
function SWEP:Reload()
end

--[[---------------------------------------------------------
   Think does nothing
---------------------------------------------------------]]
function SWEP:Think()
end

--[[---------------------------------------------------------
    PrimaryAttack
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
  --if (!SERVER) then return end
  self:GetOwner():DoAttackEvent()

  if self.Side == 0 then
    self.Side = 1
    self.Weapon:SendWeaponAnim(ACT_VM_HITLEFT)
  else
    self.Side = 0
    self.Weapon:SendWeaponAnim(ACT_VM_HITRIGHT)
  end

  local tr = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))

  if tr.HitPos:Distance(self:GetOwner():GetShootPos()) < 70 then
    self:GetOwner():LagCompensation(true)

    if self.Special == 1 then
      self:FireBullets({
        Num = 1,
        Src = self:GetOwner():GetShootPos(),
        Dir = self:GetOwner():GetAimVector(),
        Spread = vector_origin,
        Tracer = 0,
        Force = 10000000,
        Damage = 1000,
        Attacker = self:GetOwner(),
        Callback = function()
          self:EmitSound(tostring(table.Random(self.SwingHit)))
        end
      })
    else
      self:FireBullets({
        Num = 1,
        Src = self:GetOwner():GetShootPos(),
        Dir = self:GetOwner():GetAimVector(),
        Spread = vector_origin,
        Tracer = 0,
        Force = 10,
        Damage = 40,
        Attacker = self:GetOwner(),
        Callback = function()
          self:EmitSound(tostring(table.Random(self.SwingHit)))
        end
      })
    end

    self:GetOwner():LagCompensation(false)
  else
    self:EmitSound(tostring(table.Random(self.SwingMiss)))
  end

  self.Weapon:SetNextPrimaryFire(CurTime() + 0.05)
end

--[[---------------------------------------------------------
    SecondaryAttack
---------------------------------------------------------]]
function SWEP:SecondaryAttack()
  if self.Special == 0 then
    self.Special = 1
  else
    self.Special = 0
  end
end

--[[---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------]]
function SWEP:ShouldDropOnDie()
  return false
end