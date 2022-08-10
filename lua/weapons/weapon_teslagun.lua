AddCSLuaFile()
game.AddParticles("particles/electrical_fx.pcf")
PrecacheParticleSystem("electrical_arc_01")
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Toybox Classics"
SWEP.HoldType = "ar2"
SWEP.PrintName = "Tesla Gun"
SWEP.Author = "Azaz3l"
SWEP.Slot = 5
SWEP.SlotPos = 7
SWEP.Description = "Hyper Powerfull Tesla Gun"
SWEP.Purpose = "KIll EVERYONE!"
SWEP.Instructions = "Left click to shoot."
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/c_iRifle.mdl"
SWEP.WorldModel = "models/weapons/w_iRifle.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 80
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Automatic = false

function SWEP:SetupDataTables()
  self:NetworkVar("String", 0, "mode")
end

function SWEP:Initialize()
  self.v = 0
  self.charging = 0
  self.ChoseTarget = false
  self:Setmode("normal")
  self:SetHoldType("ar2")
end

function SWEP:SecondaryAttack()
  self:GetOwner():EmitSound("weapons/ar2/ar2_reload_push.wav")
  if not IsFirstTimePredicted() then return end

  if self:Getmode() == "autoaim" then
    self:Setmode("normal")
    self:GetOwner():PrintMessage(HUD_PRINTTALK, "Switched to Normal")
  else
    self:Setmode("autoaim")
    self:GetOwner():PrintMessage(HUD_PRINTTALK, "Switched to AutoAim")
  end
end

function SWEP:PrimaryAttack()
  local tr = self:GetOwner():GetEyeTrace()

  if self.charging == 0 then
    self.ChoseTarget = false
    ChargeSnd = Sound("npc/strider/charging.wav")
    Snd = CreateSound(self.Weapon, ChargeSnd)
    Snd:Play()
    self.charging = 1
  end

  if self:GetOwner():KeyDown(IN_ATTACK) then
    self.v = self.v + .1
  end

  if self.v > 5 then
    self.v = 0
    self.charging = 0
    Snd:Stop()

    if self:Getmode() == "autoaim" then
      self:AutoAimShot()
    else
      self:NormalShot()
    end

    ChargeSnd = Sound("npc/strider/charging.wav")
    Snd = CreateSound(self.Weapon, ChargeSnd)
    Snd:Play()
  end
end

function SWEP:Reload()
end

function SWEP:Think()
  if self:GetOwner():KeyReleased(IN_ATTACK) then
    self.charging = 0
    self.v = 0

    if Snd then
      Snd:Stop()
    end
  end
end

function SWEP:ShootBeam(pos)
  self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self.Weapon:EmitSound("beams/beamstart5.wav")
  ParticleEffect("electrical_arc_01_system", pos, Angle(0, 0, 0), nil)
  local effectdata = EffectData()
  effectdata:SetOrigin(pos)
  effectdata:SetStart(self:GetOwner():GetShootPos())
  effectdata:SetAttachment(1)
  effectdata:SetEntity(self.Weapon)
  util.Effect("ToolTracer", effectdata)
  local effectdata2 = EffectData()
  effectdata2:SetOrigin(pos)
  effectdata2:SetMagnitude(5)
  effectdata2:SetScale(1)
  effectdata2:SetRadius(5)
  util.Effect("Sparks", effectdata2)
end

function SWEP:DrawHUD()
  surface.DrawCircle(ScrW() / 2, ScrH() / 2, 7, Color(200, 200, 200))
end

function SWEP:AutoAimShot()
  for k, v in ipairs(ents.FindInSphere(self:GetOwner():GetPos() + self:GetOwner():GetForward() * 300, 350)) do
    if (v:IsPlayer() or v:IsNPC()) and v ~= self:GetOwner() and self.ChoseTarget == false and (v:Health() ~= 0 or v:GetClass() == "npc_rollermine") then
      self.ChoseTarget = true
      local dmginfo = DamageInfo()
      dmginfo:SetDamage(500)
      dmginfo:SetDamageType(DMG_DISSOLVE)
      dmginfo:SetAttacker(self:GetOwner())

      if SERVER then
        v:TakeDamageInfo(dmginfo)
      end

      if v:GetClass() == "npc_headcrab" or v:GetClass() == "npc_headcrab_fast" or v:GetClass() == "npc_headcrab_black" or v:GetClass() == "npc_rollermine" then
        self:ShootBeam(v:GetPos())
      else
        self:ShootBeam(v:GetPos() + Vector(0, 0, 50))
      end
    end
  end
end

function SWEP:NormalShot()
  local tr = self:GetOwner():GetEyeTrace()

  if self:GetOwner():GetPos():Distance(tr.HitPos) > 500 then
    pos = self:GetOwner():GetPos() + self:GetOwner():GetAimVector() * 500 + Vector(0, 0, 60)
  else
    pos = tr.HitPos
  end

  if SERVER then
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(500)
    dmginfo:SetDamageType(DMG_DISSOLVE)
    dmginfo:SetAttacker(self:GetOwner())
    util.BlastDamageInfo(dmginfo, pos, 100)
  end

  self:ShootBeam(pos)
end

function SWEP:CustomAmmoDisplay()
  self.AmmoDisplay = self.AmmoDisplay or {}
  self.AmmoDisplay.Draw = false

  return self.AmmoDisplay
end