AddCSLuaFile()

if CLIENT then
  language.Add("weapon_hadescannon", "Hades Cannon")
  language.Add("electromissile", "Rhino Missile")
end

SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Hades Cannon"
SWEP.Author = "Archemyde"
SWEP.Contact = ""
SWEP.Purpose = "Vaporise your enemies with this epic cannon"
SWEP.Instructions = "Primary Fire: HADES Cannon, Secondary fire: IronSights"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 74
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 60
SWEP.CSMuzzleFlashes = true
SWEP.Slot = 3
SWEP.SlotPos = 11
SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.HoldType = "rpg"
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.Primary.Sound = Sound("NPC_Strider.FireMinigun")
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.11
SWEP.Primary.Cone = 0.016
SWEP.Primary.Recoil = 2
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 500
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Cannon = {}
SWEP.Cannon.ShootSound = Sound("npc/strider/fire.wav")
SWEP.Cannon.ChargeSound = Sound("npc/strider/charging.wav")
SWEP.Cannon.BoomSound = Sound("weapons/mortar/mortar_explode2.wav")
SWEP.Cannon.Damage = 300
SWEP.Cannon.Radius = 500
SWEP.Cannon.Delay = 1.5
SWEP.Cannon.Recoil = 6
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 50
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "AR2AltFire"

SWEP.VElements = {
  ["some_unique_name3+"] = {
    type = "Model",
    model = "models/props_lab/labpart.mdl",
    bone = "base",
    rel = "",
    pos = Vector(2.618, -0.306, 4.631),
    angle = Angle(0, -21.831, 90.88),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 0, 0, 255),
    surpresslightning = true,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name4"] = {
    type = "Model",
    model = "models/props_combine/combine_fence01a.mdl",
    bone = "base",
    rel = "",
    pos = Vector(5.282, -3.145, 25.305),
    angle = Angle(-95, 0, 0),
    size = Vector(0.079, 0.079, 0.05),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name5"] = {
    type = "Sprite",
    sprite = "models/weapons/V_smg1/texture5",
    bone = "base",
    rel = "",
    pos = Vector(9.105, -0.625, 23.031),
    size = {
      x = 2,
      y = 2
    },
    color = Color(2550, 2550, 2550, 255),
    nocull = true,
    additive = true,
    vertexalpha = true,
    vertexcolor = false,
    ignorez = false
  },
  ["some_unique_name2"] = {
    type = "Model",
    model = "models/props_lab/incubatorplug.mdl",
    bone = "base",
    rel = "",
    pos = Vector(4.169, -0.382, 22.555),
    angle = Angle(0, 180, 92.025),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name3++"] = {
    type = "Model",
    model = "models/props_lab/labpart.mdl",
    bone = "base",
    rel = "",
    pos = Vector(2.618, -0.306, -1.507),
    angle = Angle(0, -21.831, 90.88),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 0, 0, 255),
    surpresslightning = true,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name3"] = {
    type = "Model",
    model = "models/props_lab/labpart.mdl",
    bone = "base",
    rel = "",
    pos = Vector(2.618, -0.306, 11.3),
    angle = Angle(0, -21.837, 90.88),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 0, 0, 255),
    surpresslightning = true,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name"] = {
    type = "Model",
    model = "models/props_lab/LabTurret.mdl",
    bone = "base",
    rel = "",
    pos = Vector(-1.231, -8.263, 11.274),
    angle = Angle(0, 1.549, 88.212),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name4+"] = {
    type = "Model",
    model = "models/props_combine/combine_fence01a.mdl",
    bone = "base",
    rel = "",
    pos = Vector(5.282, 2.336, 25.305),
    angle = Angle(95, 180, 0),
    size = Vector(0.079, 0.079, 0.05),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  }
}

SWEP.WElements = {
  ["some_unique_name4+"] = {
    type = "Model",
    model = "models/props_combine/combine_fence01a.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(17.049, 7.618, -7.369),
    angle = Angle(0, 0, 95),
    size = Vector(0.079, 0.079, 0.05),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name3+"] = {
    type = "Model",
    model = "models/props_lab/labpart.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(3.65, 4.446, -7.488),
    angle = Angle(0, -88, -7.7),
    size = Vector(0.3, 0.3, 0.3),
    color = Color(255, 0, 0, 255),
    surpresslightning = true,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name3"] = {
    type = "Model",
    model = "models/props_lab/labpart.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(7.212, 4.489, -8),
    angle = Angle(0, -88, -7.7),
    size = Vector(0.3, 0.3, 0.3),
    color = Color(255, 0, 0, 255),
    surpresslightning = true,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name4"] = {
    type = "Model",
    model = "models/props_combine/combine_fence01a.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(16.062, 7.3, -11.877),
    angle = Angle(32.536, -180, -90.2),
    size = Vector(0.079, 0.079, 0.05),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name"] = {
    type = "Model",
    model = "models/props_lab/LabTurret.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(5.993, 0.787, -12.763),
    angle = Angle(0, -87.082, -6.151),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name3++"] = {
    type = "Model",
    model = "models/props_lab/labpart.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(10.487, 4.493, -8.337),
    angle = Angle(0, -88.056, -7.782),
    size = Vector(0.3, 0.3, 0.3),
    color = Color(255, 0, 0, 255),
    surpresslightning = true,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["some_unique_name2"] = {
    type = "Model",
    model = "models/props_lab/incubatorplug.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(15.118, 6.212, -9.344),
    angle = Angle(0, 81.031, 9.355),
    size = Vector(0.3, 0.3, 0.3),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  }
}

local PHASE_NONE = 0
local PHASE_WARMUP = 1
local PHASE_FIRE = 2
local PHASE_COOLDOWN = 3
local WarmupLength = 1.5964626073837
local CooldownLength = 1.3695101737976
SWEP.IronSightsPos = Vector(-6.98, -15.247, 1.619)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:Initialize()
  self:SetHoldType("rpg")
  self:InstallDataTable()
  self:DTVar("Int", 0, "Phase")
  self.Weapon:SetNetworkedBool("Ironsights", false)

  if SERVER then
    self:SetWeaponHoldType(self.HoldType)
    self.dt.Phase = PHASE_NONE
    self.FirstTimeFired = true
    self.NextAmmoRegen = CurTime()
    self.NextIdle = CurTime()
  end

  if CLIENT then
    -- great.. StopSound doesnt work
    self.ChargeFrac = 0
    self.ChargeSpeed = 0
    self.LastPhase = PHASE_NONE
    self.HudAlphaFrac = 0.5
    self.VMOffset = 0
    self.NextHitEffect = CurTime()
  end

  self.ChargeFrac = 0
  self.ChargeSpeed = 0
  self.LastPhase = PHASE_NONE
  self.Charging = false

  if CLIENT then
    -- Create a new table for every weapon instance
    self.VElements = table.FullCopy(self.VElements)
    self.WElements = table.FullCopy(self.WElements)
    self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)
    self:CreateModels(self.VElements) -- create viewmodels
    self:CreateModels(self.WElements) -- create worldmodels

    -- init view model bone build function
    if IsValid(self:GetOwner()) then
      local vm = self:GetOwner():GetViewModel()

      if IsValid(vm) then
        self:ResetBonePositions(vm)

        -- Init viewmodel visibility
        if self.ShowViewModel == nil or self.ShowViewModel then
          vm:SetColor(Color(255, 255, 255, 255))
        else
          -- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
          vm:SetColor(Color(255, 255, 255, 1))
          -- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
          -- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
          vm:SetMaterial("Debug/hsv")
        end
      end
    end
  end
end

function SWEP:OnRemove()
  -- other onremove code goes here
  if CLIENT then
    self:RemoveModels()
  end
end

function SWEP:Deploy()
  self.dt.Phase = PHASE_NONE

  return true
end

function SWEP:DoWarmup()
  self:SetNextPrimaryFire(CurTime() + WarmupLength)
  self.dt.Phase = PHASE_WARMUP
  self.FirstTimeFired = false
  self.NextAmmoRegen = -1
end

------------------------------------------------------------------------------------------------------
--	Purpose: do cooldown actions
------------------------------------------------------------------------------------------------------
function SWEP:DoCooldown()
  self:SetNextPrimaryFire(CurTime() + CooldownLength)
  self.dt.Phase = PHASE_COOLDOWN
  self.FirstTimeFired = true
  self.NextAmmoRegen = CurTime() + CooldownLength
end

function SWEP:ProcessEffects()
  -- the phase has shifted
  if self.dt.Phase ~= self.LastPhase then
    if self.dt.Phase == PHASE_WARMUP then
      --  self.WarmupSound:Play()
      self.ChargeSpeed = 1 / WarmupLength
      -- self.Emitter = ParticleEmitter( self:GetPos() )
      -- set the bounds here incase the weapon is off-screen
      -- local tr = self:GetOwner():GetEyeTraceNoCursor()
      -- self:SetRenderBoundsWS( tr.StartPos, tr.HitPos )
    elseif self.dt.Phase == PHASE_COOLDOWN then
      --self.WarmupSound:Stop()
      -- self.FiringSound:Stop()
      -- self:EmitSound( CooldownSound )
      self.ChargeSpeed = -1 / CooldownLength
    elseif self.dt.Phase == PHASE_FIRE then
    end

    --self.Emitter:Finish()
    -- self.Emitter = nil
    -- self.WarmupSound:Stop()
    -- self.FiringSound:Play()
    self.LastPhase = self.dt.Phase
  end

  self.ChargeFrac = math.Clamp(self.ChargeFrac + self.ChargeSpeed * FrameTime(), 0, 1)
end

function SWEP:PrimaryAttack()
  if self:Ammo2() <= 0 then
    self.Weapon:EmitSound("Weapon_Pistol.Empty")
    self.Weapon:SetNextSecondaryFire(CurTime() + 0.2)
    self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)

    return
  end

  self.Weapon:SetNextSecondaryFire(CurTime() + 1.35 + self.Cannon.Delay)
  self.Weapon:SetNextPrimaryFire(CurTime() + 1.35 + self.Cannon.Delay)
  self:DoWarmup()
  local fx = EffectData()
  fx:SetEntity(self:GetOwner())
  fx:SetAttachment(1)
  util.Effect("stridcan_charge", fx)
  self.Charging = true
  if CLIENT then return end
  self:GetOwner():EmitSound(self.Cannon.ChargeSound, 85)

  timer.Simple(1.35, function()
    if IsValid(self) then
      self:ShootCannon()
    end
  end)
end

function SWEP:SetIronsights(b)
  self.Weapon:SetNetworkedBool("Ironsights", b)
end

SWEP.NextSecondaryAttack = 0

function SWEP:SecondaryAttack()
  if not self.IronSightsPos then return end
  if self.NextSecondaryAttack > CurTime() then return end
  bIronsights = not self.Weapon:GetNetworkedBool("Ironsights", false)
  self:SetIronsights(bIronsights)
  self.NextSecondaryAttack = CurTime() + 0.3
end

function SWEP:DoDischarge()
  self.dt.Phase = PHASE_FIRE
end

function SWEP:ShootCannon()
  if SERVER then
    if not IsValid(self) then return end
    if not self.Charging then return end
    if not IsValid(self) then return end
    if not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return end
  end

  local PlayerPos = self:GetOwner():GetShootPos()
  local tr = self:GetOwner():GetEyeTrace()
  local dist = (tr.HitPos - PlayerPos):Length()
  local delay = dist / 8000
  self:DoDischarge()
  self:TakeSecondaryAmmo(1)
  self:GetOwner():EmitSound(self.Cannon.ShootSound, 85)
  local fx = EffectData()
  fx:SetEntity(self:GetOwner())
  fx:SetOrigin(tr.HitPos)
  fx:SetAttachment(1)
  util.Effect("stridcan_fire", fx)
  util.Effect("stridcan_mzzlflash", fx)
  --play animations
  self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self:GetOwner():MuzzleFlash()
  self:GetOwner():SetAnimation(PLAYER_ATTACK1)
  --apply recoil
  self:GetOwner():ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Cannon.Recoil, math.Rand(-0.1, 0.1) * self.Cannon.Recoil, 0))

  timer.Simple(delay, function()
    print("!?!")
    self:CannonDisintegrate(tr)
  end)

  self.Charging = false
  self:DoCooldown()
end

-- main one
function SWEP:CannonDisintegrate(tr)
  if SERVER then
    local splodepos = tr.HitPos + 3 * tr.HitNormal
    local damageinform = DamageInfo()
    damageinform:SetDamage(self.Cannon.Damage)
    damageinform:SetAttacker(self:GetOwner())
    damageinform:SetInflictor(self)
    damageinform:SetDamageType(DMG_DISSOLVE)
    util.BlastDamageInfo(damageinform, splodepos, self.Cannon.Radius)

    timer.Simple(0.01, function()
      if IsValid(self) then
        self:DissolveEnts(splodepos, self.Cannon.Radius)
      end
    end)
  end

  local fx = EffectData()
  fx:SetOrigin(tr.HitPos)
  fx:SetNormal(tr.HitNormal)
  util.Effect("stridcan_expld", fx)
end

function SWEP:Think()
  if CLIENT then
    self:ProcessEffects()

    return
  end

  if CurTime() > self.NextIdle then
    self:SendWeaponAnim(ACT_VM_IDLE)
    self.NextIdle = CurTime() + self:SequenceDuration()
  end
end

local StriderBulletCallback = function(attacker, tr, dmginfo)
  local fx = EffectData()
  fx:SetOrigin(tr.HitPos)
  fx:SetNormal(tr.HitNormal)
  fx:SetScale(20)
  util.Effect("cball_bounce", fx)
  util.Effect("AR2Impact", fx)

  return true
end

function SWEP:DissolveEnts(pos, radius)
  if not IsValid(self) then return end
  if not SERVER then return end

  local targname = "dissolveme" .. self:EntIndex()

  for k, ent in ipairs(ents.FindInSphere(pos, radius)) do
    if ent:GetMoveType() == 6 then
      ent:SetKeyValue("targetname", targname)
      local numbones = ent:GetPhysicsObjectCount()

      for bone = 0, numbones - 1 do
        local PhysObj = ent:GetPhysicsObjectNum(bone)

        if PhysObj:IsValid() then
          PhysObj:SetVelocity(PhysObj:GetVelocity() * 0.04)
          PhysObj:EnableGravity(false)
        end
      end
    end
  end

  local dissolver = ents.Create("env_entity_dissolver")
  dissolver:SetKeyValue("dissolvetype", 0)
  dissolver:SetKeyValue("magnitude", 0)
  dissolver:SetPos(pos)
  dissolver:SetKeyValue("target", targname)
  dissolver:Spawn()
  dissolver:SetOwner(self:GetOwner())
  dissolver:Fire("Dissolve", targname, 0)
  dissolver:Fire("kill", "", 0.1)
  dissolver:EmitSound(self.Cannon.BoomSound, 85)
end

function SWEP:Reload()
  self.Weapon:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:ShootStriderBullet(dmg, recoil, numbul, cone)
  --send the bullet
  local bullet = {}
  bullet.Num = numbul
  bullet.Src = self:GetOwner():GetShootPos()
  bullet.Dir = self:GetOwner():GetAimVector()
  bullet.Spread = Vector(cone, cone, 0)
  bullet.Tracer = 1
  bullet.TracerName = "AirboatGunTracer"
  bullet.Force = 0.5 * dmg
  bullet.Damage = dmg
  bullet.Callback = StriderBulletCallback
  self:GetOwner():FireBullets(bullet)
  --play animations
  self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self:GetOwner():MuzzleFlash()
  self:GetOwner():SetAnimation(PLAYER_ATTACK1)
  --apply recoil
  self:GetOwner():ViewPunch(Angle(math.Rand(-0.2, 0.1) * recoil, math.Rand(-0.1, 0.1) * recoil, 0))
end

function SWEP:StopCharging()
  self:StopSound(self.Cannon.ChargeSound)
  self.Charging = false
end

function SWEP:Holster(wep)
  self:StopCharging()

  if CLIENT and IsValid(self:GetOwner()) then
    local vm = self:GetOwner():GetViewModel()

    if IsValid(vm) then
      self:ResetBonePositions(vm)
    end
  end

  return true
end

function SWEP:Equip(NewOwner)
  self:StopCharging()

  return true
end

function SWEP:OnRemove()
  self:StopCharging()

  return true
end

function SWEP:OnDrop()
  self:StopCharging()

  return true
end

function SWEP:OwnerChanged()
  self:StopCharging()

  return true
end

function SWEP:CustomAmmoDisplay()
  self.AmmoDisplay = self.AmmoDisplay or {}
  self.AmmoDisplay.PrimaryClip = self:Ammo2()

  return self.AmmoDisplay
end

local IRONSIGHT_TIME = 0.25

function SWEP:GetViewModelPosition(pos, ang)
  local targetOffset = 0
  local wiggle = VectorRand()
  wiggle:Mul(self.ChargeFrac * 0.5)

  if self.dt.Phase == PHASE_FIRE then
    wiggle:Mul(0.5)
    targetOffset = 5
  end

  if self.dt.Phase == PHASE_COOLDOWN or self.dt.Phase == PHASE_NONE then
    wiggle = vector_origin
  end

  self.VMOffset = Lerp(FrameTime() * 20, self.VMOffset, targetOffset)
  local offset = ang:Forward()
  offset:Mul(self.VMOffset)
  offset:Add(wiggle)
  pos:Sub(offset)
  if not self.IronSightsPos then return pos, ang end
  local bIron = self.Weapon:GetNetworkedBool("Ironsights")

  if bIron ~= self.bLastIron then
    self.bLastIron = bIron
    self.fIronTime = CurTime()

    if bIron then
      self.SwayScale = 0.3
      self.BobScale = 0.1
    else
      self.SwayScale = 1.0
      self.BobScale = 1.0
    end
  end

  local fIronTime = self.fIronTime or 0
  if not bIron and fIronTime < CurTime() - IRONSIGHT_TIME then return pos, ang end
  local Mul = 1.0

  if fIronTime > CurTime() - IRONSIGHT_TIME then
    Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

    if not bIron then
      Mul = 1 - Mul
    end
  end

  local Offset = self.IronSightsPos

  if self.IronSightsAng then
    ang = ang * 1
    ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * Mul)
    ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * Mul)
    ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
  end

  local Right = ang:Right()
  local Up = ang:Up()
  local Forward = ang:Forward()
  pos = pos + Offset.x * Right * Mul
  pos = pos + Offset.y * Forward * Mul
  pos = pos + Offset.z * Up * Mul

  return pos, ang
end

if CLIENT then
  matPinch = Material("Effects/strider_pinch_dudv")
  matBlueFlash = Material("Effects/blueblackflash")
  matBlueBeam = Material("Effects/blueblacklargebeam")
  matBulge = Material("Effects/strider_bulge_dudv")
  matBlueMuzzle = Material("Effects/bluemuzzle")
  matBlueMuzzle:SetInt("$spriterendermode", 9)
end

local EFF1 = {}

function EFF1:Init(data)
  self.Shooter = data:GetEntity()
  self.Attachment = data:GetAttachment()
  self.WeaponEnt = self.Shooter:GetActiveWeapon()
  self.KillTime = 0
  self.ShouldRender = false
  self.Owner = self.Shooter

  if GetViewEntity() == self.Shooter then
    self.plr = self.Shooter:GetViewModel()
    self.RefractScale = 0.06
    self.RefractSize = 100
    self.SpriteSize = 110
    self.BeamWidth = 16
  else
    self.plr = self.WeaponEnt
    self.RefractScale = 0.16
    self.SizeScale = 2
    self.RefractSize = 100
    self.SpriteSize = 110
    self.BeamWidth = 16
  end

  if not self.plr:IsValid() then return end
  local Muzzle = self.plr:GetAttachment(self.Attachment)
  local hitpos = self.Shooter:GetEyeTrace().HitPos
  self:SetRenderBoundsWS(Muzzle.Pos + Vector() * self.RefractSize, hitpos - Vector() * self.RefractSize)
  self.KillTime = CurTime() + 1.35
  self.ShouldRender = true
end

function EFF1:Think()
  if CurTime() > self.KillTime then return false end
  if not self.Shooter then return false end
  if self.WeaponEnt ~= self.Shooter:GetActiveWeapon() then return false end
  if not self.plr:IsValid() then return false end

  return true
end

function EFF1:Render()
  if not self.ShouldRender then return end
  local Muzzle = self.plr:GetAttachment(self.Attachment)
  if not Muzzle then return end
  local MuzzleAng = self.Shooter:GetAimVector()
  local RenderPos = Muzzle.Pos
  local hitpos = self.Shooter:GetEyeTrace().HitPos
  self:SetRenderBoundsWS(RenderPos + Vector() * self.RefractSize, hitpos - Vector() * self.RefractSize)
  local invintrplt = (self.KillTime - CurTime()) / 1.35
  local intrplt = 1 - invintrplt
  render.SetMaterial(matBlueBeam)
  render.DrawBeam(RenderPos, hitpos, intrplt * self.BeamWidth, 0, 0, Color(255, 0, 0, intrplt * 100))
  matPinch:SetFloat("$refractamount", math.sin(0.5 * intrplt * math.pi) * self.RefractScale)
  render.SetMaterial(matPinch)
  render.UpdateRefractTexture()
  render.DrawSprite(RenderPos, self.RefractSize, self.RefractSize, Color(255, 0, 0, 150))
  render.SetMaterial(matBlueFlash)

  if intrplt < 0.5 then
    local size = 2 * self.SpriteSize * intrplt
    render.DrawSprite(RenderPos, size, size, Color(255, 0, 0, 100))
  else
    local clr = 255 * (2 * intrplt - 1)
    render.DrawSprite(RenderPos, self.SpriteSize, self.SpriteSize, Color(clr, 0, 0, 100))
  end
end

local EFF2 = {}

function EFF2:Init(data)
  self.Position = data:GetOrigin()
  self.Normal = data:GetNormal()
  self.KillTime = CurTime() + 0.65
  self:SetRenderBoundsWS(self.Position + Vector() * 280, self.Position - Vector() * 280)
  local ang = self.Normal:Angle():Right():Angle() -- D :
  local emitter = ParticleEmitter(self.Position)

  for i = 1, 7 do
    local vec = (self.Normal + 1.2 * VectorRand()):GetNormalized()
    local particle = emitter:Add("Effects/bluespark", self.Position + math.Rand(3, 30) * vec)
    particle:SetVelocity(math.Rand(700, 800) * vec)
    particle:SetDieTime(math.Rand(0.8, 1))
    particle:SetStartAlpha(150)
    particle:SetStartSize(math.Rand(3, 4))
    particle:SetEndSize(0)
    particle:SetStartLength(math.Rand(30, 40))
    particle:SetEndLength(0)
    particle:SetColor(255, 0, 0)
    particle:SetGravity(Vector(0, 0, -400))
    particle:SetAirResistance(5)
    particle:SetCollide(true)
    particle:SetBounce(0.9)
  end

  for i = 1, 15 do
    ang:RotateAroundAxis(self.Normal, math.Rand(0, 360))
    local vec = ang:Forward()
    local particle = emitter:Add("particle/particle_smokegrenade", self.Position + math.Rand(5, 20) * vec)
    particle:SetVelocity(math.Rand(600, 1200) * vec)
    particle:SetDieTime(math.Rand(2.5, 3))
    particle:SetStartAlpha(math.Rand(16, 25))
    particle:SetStartSize(math.Rand(40, 50))
    particle:SetEndSize(math.Rand(70, 80))
    particle:SetColor(255, 0, 0)
    particle:SetAirResistance(600)
  end

  for i = 1, 10 do
    local vec = (self.Normal + 0.6 * VectorRand()):GetNormalized()
    local particle = emitter:Add("particle/particle_smokegrenade", self.Position + math.Rand(5, 20) * vec)
    particle:SetVelocity(math.Rand(1000, 1500) * vec)
    particle:SetDieTime(math.Rand(2.5, 3))
    particle:SetStartAlpha(math.Rand(16, 25))
    particle:SetStartSize(math.Rand(40, 60))
    particle:SetEndSize(math.Rand(80, 90))
    particle:SetColor(255, 0, 0)
    particle:SetGravity(Vector(0, 0, 100))
    particle:SetAirResistance(500)
  end

  emitter:Finish()
  local dlight = DynamicLight(math.random(2048, 4096)) --This works for some reason.  Don't ask.
  dlight.Pos = self.Position
  dlight.Size = 500
  dlight.DieTime = CurTime() + 0.2
  dlight.r = 255
  dlight.g = 0
  dlight.b = 0
  dlight.Brightness = 1
  dlight.Decay = 1000
end

function EFF2:Think()
  if CurTime() > self.KillTime then return false end

  return true
end

function EFF2:Render()
  local invintrplt = (self.KillTime - CurTime()) / 0.65
  local intrplt = 1 - invintrplt
  local size = 280 + 200 * intrplt
  self:SetRenderBoundsWS(self.Position + Vector() * size, self.Position - Vector() * size)
  matBulge:SetFloat("$refractamount", math.sin(0.5 * invintrplt * math.pi) * 0.16)
  render.SetMaterial(matBulge)
  render.UpdateRefractTexture()
  render.DrawSprite(self.Position, size, size, Color(255, 0, 0, 150 * invintrplt))
end

local EFF3 = {}

function EFF3:Init(data)
  self.Shooter = data:GetEntity()
  self.EndPos = data:GetOrigin()
  self.Attachment = data:GetAttachment()
  self.WeaponEnt = self.Shooter:GetActiveWeapon()
  self.KillTime = 0
  self.ShouldRender = false
  self.Owner = self.Shooter
  if not self.Shooter or not self.Shooter:IsValid() then return end
  if not self.WeaponEnt or not self.WeaponEnt:IsValid() then return end

  if GetViewEntity() == self.Shooter then
    self.plr = self.Shooter:GetViewModel()
    self.Owner = self.Shooter
    self.BeamWidth = 20
  else
    self.plr = self.WeaponEnt
    self.BeamWidth = 25
  end

  if not self.plr:IsValid() then return end
  local Muzzle = self.plr:GetAttachment(self.Attachment)
  self.RenderAng = Muzzle.Pos - self.EndPos
  self.RenderDist = self.RenderAng:Length()
  self.RenderAng = self.RenderAng / self.RenderDist
  self.Duration = self.RenderDist / 8000
  self.KillTime = CurTime() + self.Duration
  self:SetRenderBoundsWS(Muzzle.Pos + Vector() * 280, self.EndPos - Vector() * 280)
  self.ShouldRender = true
end

function EFF3:Think()
  if CurTime() > self.KillTime then return false end

  return true
end

function EFF3:Render()
  if not self.ShouldRender then return end
  local invintrplt = (self.KillTime - CurTime()) / self.Duration
  local intrplt = 1 - invintrplt
  local RenderPos = self.EndPos + self.RenderAng * (self.RenderDist * invintrplt)
  self:SetRenderBoundsWS(RenderPos + Vector() * 280, self.EndPos - Vector() * 280)
  matBulge:SetFloat("$refractamount", 0.16)
  render.SetMaterial(matBulge)
  render.UpdateRefractTexture()
  render.DrawSprite(RenderPos, 280, 280, Color(255, 0, 0, 150))
  render.SetMaterial(matBlueBeam)
  render.DrawBeam(RenderPos, self.EndPos, self.BeamWidth, 0, 0, Color(255, 0, 0, 160))
end

local EFF4 = {}

function EFF4:Init(data)
  self.Shooter = data:GetEntity()
  self.Attachment = data:GetAttachment()
  self.WeaponEnt = self.Shooter:GetActiveWeapon()
  self.KillTime = 0
  self.ShouldRender = false
  self.Owner = self.Shooter

  if GetViewEntity() == self.Shooter then
    self.plr = self.Shooter:GetViewModel()
    self.SpriteSize = 30
    self.FlashSize = 30
  else
    self.plr = self.WeaponEnt
    self.SpriteSize = 110
    self.FlashSize = 110
  end

  if not self.plr:IsValid() then return end
  local Muzzle = self.plr:GetAttachment(self.Attachment)
  self:SetRenderBoundsWS(Muzzle.Pos + Vector() * self.SpriteSize, Muzzle.Pos - Vector() * self.SpriteSize)
  self.KillTime = CurTime() + 2
  self.ShouldRender = true
end

function EFF4:Think()
  if CurTime() > self.KillTime then return false end
  if not self.Shooter then return false end
  if self.WeaponEnt ~= self.Shooter:GetActiveWeapon() then return false end
  if not self.plr:IsValid() then return false end

  return true
end

function EFF4:Render()
  if not self.ShouldRender then return end
  local Muzzle = self.plr:GetAttachment(self.Attachment)
  if not Muzzle then return end
  local RenderPos = Muzzle.Pos
  self:SetRenderBoundsWS(RenderPos + Vector() * self.SpriteSize, RenderPos - Vector() * self.SpriteSize)
  local invintrplt = (self.KillTime - CurTime()) / 2
  local intrplt = 1 - invintrplt
  local size

  if invintrplt > 0.8 then
    render.SetMaterial(matBlueMuzzle)
    size = 2 * self.FlashSize * (invintrplt - 0.5)
    local alpha = 1275 * (invintrplt - 0.8)
    render.DrawSprite(RenderPos, size, size, Color(255, 0, 0, alpha))
  end

  render.SetMaterial(matBlueFlash)
  size = self.SpriteSize * invintrplt
  render.DrawSprite(RenderPos, size, size, Color(255, 0, 0, 100 * invintrplt))
end

if CLIENT then
  SWEP.vRenderOrder = nil

  function SWEP:ViewModelDrawn()
    local vm = self:GetOwner():GetViewModel()
    if not IsValid(vm) then return end
    if not self.VElements then return end
    self:UpdateBonePositions(vm)

    if not self.vRenderOrder then
      -- we build a render order because sprites need to be drawn after models
      self.vRenderOrder = {}

      for k, v in pairs(self.VElements) do
        if v.type == "Model" then
          table.insert(self.vRenderOrder, 1, k)
        elseif v.type == "Sprite" or v.type == "Quad" then
          table.insert(self.vRenderOrder, k)
        end
      end
    end

    for k, name in ipairs(self.vRenderOrder) do
      local v = self.VElements[name]

      if not v then
        self.vRenderOrder = nil
        break
      end

      if v.hide then continue end
      local model = v.modelEnt
      local sprite = v.spriteMaterial
      if not v.bone then continue end
      local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
      if not pos then continue end

      if v.type == "Model" and IsValid(model) then
        model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        model:SetAngles(ang)
        --model:SetModelScale(v.size)
        local matrix = Matrix()
        matrix:Scale(v.size)
        model:EnableMatrix("RenderMultiply", matrix)

        if v.material == "" then
          model:SetMaterial("")
        elseif model:GetMaterial() ~= v.material then
          model:SetMaterial(v.material)
        end

        if v.skin and v.skin ~= model:GetSkin() then
          model:SetSkin(v.skin)
        end

        if v.bodygroup then
          for k, v in pairs(v.bodygroup) do
            if model:GetBodygroup(k) ~= v then
              model:SetBodygroup(k, v)
            end
          end
        end

        if v.surpresslightning then
          render.SuppressEngineLighting(true)
        end

        render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
        render.SetBlend(v.color.a / 255)
        model:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)

        if v.surpresslightning then
          render.SuppressEngineLighting(false)
        end
      elseif v.type == "Sprite" and sprite then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        render.SetMaterial(sprite)
        render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
      elseif v.type == "Quad" and v.draw_func then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        cam.Start3D2D(drawpos, ang, v.size)
        v.draw_func(self)
        cam.End3D2D()
      end
    end
  end

  SWEP.wRenderOrder = nil

  function SWEP:DrawWorldModel()
    if self.ShowWorldModel == nil or self.ShowWorldModel then
      self:DrawModel()
    end

    if not self.WElements then return end

    if not self.wRenderOrder then
      self.wRenderOrder = {}

      for k, v in pairs(self.WElements) do
        if v.type == "Model" then
          table.insert(self.wRenderOrder, 1, k)
        elseif v.type == "Sprite" or v.type == "Quad" then
          table.insert(self.wRenderOrder, k)
        end
      end
    end

    if IsValid(self:GetOwner()) then
      bone_ent = self:GetOwner()
    else
      -- when the weapon is dropped
      bone_ent = self
    end

    for k, name in ipairs(self.wRenderOrder) do
      local v = self.WElements[name]

      if not v then
        self.wRenderOrder = nil
        break
      end

      if v.hide then continue end
      local pos, ang

      if v.bone then
        pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
      else
        pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
      end

      if not pos then continue end
      local model = v.modelEnt
      local sprite = v.spriteMaterial

      if v.type == "Model" and IsValid(model) then
        model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        model:SetAngles(ang)
        --model:SetModelScale(v.size)
        local matrix = Matrix()
        matrix:Scale(v.size)
        model:EnableMatrix("RenderMultiply", matrix)

        if v.material == "" then
          model:SetMaterial("")
        elseif model:GetMaterial() ~= v.material then
          model:SetMaterial(v.material)
        end

        if v.skin and v.skin ~= model:GetSkin() then
          model:SetSkin(v.skin)
        end

        if v.bodygroup then
          for k, v in pairs(v.bodygroup) do
            if model:GetBodygroup(k) ~= v then
              model:SetBodygroup(k, v)
            end
          end
        end

        if v.surpresslightning then
          render.SuppressEngineLighting(true)
        end

        render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
        render.SetBlend(v.color.a / 255)
        model:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)

        if v.surpresslightning then
          render.SuppressEngineLighting(false)
        end
      elseif v.type == "Sprite" and sprite then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        render.SetMaterial(sprite)
        render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
      elseif v.type == "Quad" and v.draw_func then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        cam.Start3D2D(drawpos, ang, v.size)
        v.draw_func(self)
        cam.End3D2D()
      end
    end
  end

  function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
    local bone, pos, ang

    if tab.rel and tab.rel ~= "" then
      local v = basetab[tab.rel]
      if not v then return end
      -- Technically, if there exists an element with the same name as a bone
      -- you can get in an infinite loop. Let's just hope nobody's that stupid.
      pos, ang = self:GetBoneOrientation(basetab, v, ent)
      if not pos then return end
      pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
      ang:RotateAroundAxis(ang:Up(), v.angle.y)
      ang:RotateAroundAxis(ang:Right(), v.angle.p)
      ang:RotateAroundAxis(ang:Forward(), v.angle.r)
    else
      bone = ent:LookupBone(bone_override or tab.bone)
      if not bone then return end
      pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
      local m = ent:GetBoneMatrix(bone)

      if m then
        pos, ang = m:GetTranslation(), m:GetAngles()
      end

      if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and ent == self:GetOwner():GetViewModel() and self.ViewModelFlip then
        ang.r = -ang.r -- Fixes mirrored models
      end
    end

    return pos, ang
  end

  function SWEP:CreateModels(tab)
    if not tab then return end

    -- Create the clientside models here because Garry says we can't do it in the render hook
    for k, v in pairs(tab) do
      if v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and string.find(v.model, ".mdl") and file.Exists(v.model, "GAME") then
        v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)

        if IsValid(v.modelEnt) then
          v.modelEnt:SetPos(self:GetPos())
          v.modelEnt:SetAngles(self:GetAngles())
          v.modelEnt:SetParent(self)
          v.modelEnt:SetNoDraw(true)
          v.createdModel = v.model
        else
          v.modelEnt = nil
        end
      elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists("materials/" .. v.sprite .. ".vmt", "GAME") then
        local name = v.sprite .. "-"

        local params = {
          ["$basetexture"] = v.sprite
        }

        -- make sure we create a unique name based on the selected options
        local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}

        for i, j in pairs(tocheck) do
          if v[j] then
            params["$" .. j] = 1
            name = name .. "1"
          else
            name = name .. "0"
          end
        end

        v.createdSprite = v.sprite
        v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
      end
    end
  end

  local allbones
  local hasGarryFixedBoneScalingYet = false

  function SWEP:UpdateBonePositions(vm)
    if self.ViewModelBoneMods then
      if not vm:GetBoneCount() then return end
      -- !! WORKAROUND !! //
      -- We need to check all model names :/
      local loopthrough = self.ViewModelBoneMods

      if not hasGarryFixedBoneScalingYet then
        allbones = {}

        for i = 0, vm:GetBoneCount() do
          local bonename = vm:GetBoneName(i)

          if self.ViewModelBoneMods[bonename] then
            allbones[bonename] = self.ViewModelBoneMods[bonename]
          else
            allbones[bonename] = {
              scale = Vector(1, 1, 1),
              pos = Vector(0, 0, 0),
              angle = Angle(0, 0, 0)
            }
          end
        end

        loopthrough = allbones
      end

      -- !! ----------- !! //
      for k, v in pairs(loopthrough) do
        local bone = vm:LookupBone(k)
        if not bone then continue end
        -- !! WORKAROUND !! //
        local s = Vector(v.scale.x, v.scale.y, v.scale.z)
        local p = Vector(v.pos.x, v.pos.y, v.pos.z)
        local ms = Vector(1, 1, 1)

        if not hasGarryFixedBoneScalingYet then
          local cur = vm:GetBoneParent(bone)

          while cur >= 0 do
            local pscale = loopthrough[vm:GetBoneName(cur)].scale
            ms = ms * pscale
            cur = vm:GetBoneParent(cur)
          end
        end

        s = s * ms

        -- !! ----------- !! //
        if vm:GetManipulateBoneScale(bone) ~= s then
          vm:ManipulateBoneScale(bone, s)
        end

        if vm:GetManipulateBoneAngles(bone) ~= v.angle then
          vm:ManipulateBoneAngles(bone, v.angle)
        end

        if vm:GetManipulateBonePosition(bone) ~= p then
          vm:ManipulateBonePosition(bone, p)
        end
      end
    else
      self:ResetBonePositions(vm)
    end
  end

  function SWEP:ResetBonePositions(vm)
    if not vm:GetBoneCount() then return end

    for i = 0, vm:GetBoneCount() do
      vm:ManipulateBoneScale(i, Vector(1, 1, 1))
      vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
      vm:ManipulateBonePosition(i, Vector(0, 0, 0))
    end
  end

  --[[*************************
		Global utility code
	*************************]]
  -- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
  -- Does not copy entities of course, only copies their reference.
  -- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
  function table.FullCopy(tab)
    if not tab then return nil end
    local res = {}

    for k, v in pairs(tab) do
      if type(v) == "table" then
        res[k] = table.FullCopy(v) -- recursion ho!
      elseif type(v) == "Vector" then
        res[k] = Vector(v.x, v.y, v.z)
      elseif type(v) == "Angle" then
        res[k] = Angle(v.p, v.y, v.r)
      else
        res[k] = v
      end
    end

    return res
  end
end

if CLIENT then
  effects.Register(EFF1, "stridcan_charge")
  effects.Register(EFF2, "stridcan_expld")
  effects.Register(EFF3, "stridcan_fire")
  effects.Register(EFF4, "stridcan_mzzlflash")
end