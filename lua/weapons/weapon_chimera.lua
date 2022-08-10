AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Chimera" -- pronounced "kye-meer-uh" (not "chim-uh-ruh", "chim-ae-ruh" or "kye-mehr-uh", you 'tard)
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.Slot = 1
SWEP.SlotPos = 5
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "PRIMARY: Fire\nSECONDARY: Ironsights\n\nYou can still fire if you're out of ammo, but the shots will be weak and have no effects."
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.ViewModelBonescales = {
  ["Cylinder"] = Vector(0.01, 0.01, 0.01)
}

SWEP.VElements = {
  ["barrel"] = {
    type = "Model",
    model = "models/props_c17/oildrum001.mdl",
    bone = "Python",
    pos = Vector(0, 0.2, 1.442),
    angle = Angle(0, 0, 0),
    size = Vector(0.041, 0.041, 0.144),
    color = Color(100, 90, 90, 255),
    surpresslightning = false,
    material = "phoenix_storms/grey_steel",
    skin = 0,
    bodygroup = {}
  },
  ["bullet1"] = {
    type = "Model",
    model = "models/props_phx/smallwheel.mdl",
    bone = "Cylinder",
    pos = Vector(0, -0.689, -1.295),
    angle = Angle(0, 0, 0),
    size = Vector(0.05, 0.05, 0.699),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["bullet2"] = {
    type = "Model",
    model = "models/props_phx/smallwheel.mdl",
    bone = "Cylinder",
    pos = Vector(0.606, -0.369, -1.295),
    angle = Angle(0, -120, 0),
    size = Vector(0.05, 0.05, 0.699),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["bullet3"] = {
    type = "Model",
    model = "models/props_phx/smallwheel.mdl",
    bone = "Cylinder",
    pos = Vector(0.606, 0.368, -1.295),
    angle = Angle(0, -240, 0),
    size = Vector(0.05, 0.05, 0.699),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["bullet4"] = {
    type = "Model",
    model = "models/props_phx/smallwheel.mdl",
    bone = "Cylinder",
    pos = Vector(0, 0.688, -1.295),
    angle = Angle(0, 180, 0),
    size = Vector(0.05, 0.05, 0.699),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["bullet5"] = {
    type = "Model",
    model = "models/props_phx/smallwheel.mdl",
    bone = "Cylinder",
    pos = Vector(-0.607, 0.368, -1.295),
    angle = Angle(0, -120, 0),
    size = Vector(0.05, 0.05, 0.699),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["bullet6"] = {
    type = "Model",
    model = "models/props_phx/smallwheel.mdl",
    bone = "Cylinder",
    pos = Vector(-0.607, -0.369, -1.295),
    angle = Angle(0, -240, 0),
    size = Vector(0.05, 0.05, 0.699),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["cylinder"] = {
    type = "Model",
    model = "models/Mechanics/wheels/wheel_rounded_36.mdl",
    bone = "Cylinder",
    pos = Vector(0, 0, -0.187),
    angle = Angle(0, 0, 0),
    size = Vector(0.043, 0.043, 0.059),
    color = Color(100, 90, 90, 255),
    surpresslightning = false,
    material = "phoenix_storms/grey_steel",
    skin = 0,
    bodygroup = {}
  },
  ["cylinderback1"] = {
    type = "Model",
    model = "models/Mechanics/wheels/wheel_speed_72.mdl",
    bone = "Cylinder",
    pos = Vector(0, 0, -1.407),
    angle = Angle(0, 0, 0),
    size = Vector(0.028, 0.028, 0.009),
    color = Color(100, 90, 90, 255),
    surpresslightning = false,
    material = "phoenix_storms/gear",
    skin = 0,
    bodygroup = {}
  },
  ["cylinderback2"] = {
    type = "Model",
    model = "models/Mechanics/wheels/wheel_speed_72.mdl",
    bone = "Cylinder",
    pos = Vector(0, 0, -1.42),
    angle = Angle(0, 180, 0),
    size = Vector(0.021, 0.021, 0.019),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["cylinderfront"] = {
    type = "Model",
    model = "models/Mechanics/wheels/wheel_speed_72.mdl",
    bone = "Cylinder",
    pos = Vector(0, 0, 1.001),
    angle = Angle(0, 0, 0),
    size = Vector(0.03, 0.03, 0.03),
    color = Color(100, 90, 90, 255),
    surpresslightning = false,
    material = "phoenix_storms/gear",
    skin = 0,
    bodygroup = {}
  },
  ["sight1"] = {
    type = "Model",
    model = "models/props_junk/iBeam01a.mdl",
    bone = "Python",
    pos = Vector(0, -1.706, 3.099),
    angle = Angle(90, 0, 0),
    size = Vector(0.045, 0.045, 0.039),
    color = Color(100, 90, 90, 255),
    surpresslightning = false,
    material = "phoenix_storms/grey_steel",
    skin = 0,
    bodygroup = {}
  },
  ["sight2"] = {
    type = "Model",
    model = "models/props_junk/iBeam01a.mdl",
    bone = "Python",
    pos = Vector(0, -1.287, 3.099),
    angle = Angle(90, 0, 0),
    size = Vector(0.045, 0.045, 0.05),
    color = Color(255, 100, 50, 255),
    surpresslightning = false,
    material = "phoenix_storms/Indenttiles_1-2",
    skin = 0,
    bodygroup = {}
  },
  ["light"] = {
    type = "Sprite",
    sprite = "particle/Particle_Glow_04",
    bone = "Cylinder",
    pos = Vector(0, 0.2, 0.6),
    size = {
      x = 4,
      y = 4
    },
    color = Color(255, 160, 0, 255),
    nocull = true,
    additive = true,
    vertexalpha = true,
    vertexcolor = true,
    ignorez = false
  }
}

SWEP.WElements = {
  ["barrel"] = {
    type = "Model",
    model = "models/props_c17/oildrum001.mdl",
    pos = Vector(8.829, 0.981, -3.664),
    angle = Angle(-90, 0.287, 0),
    size = Vector(0.039, 0.039, 0.144),
    color = Color(100, 90, 90, 255),
    surpresslightning = false,
    material = "phoenix_storms/grey_steel",
    skin = 0,
    bodygroup = {}
  },
  ["sight"] = {
    type = "Model",
    model = "models/props_junk/iBeam01a.mdl",
    pos = Vector(10.319, 0.856, -5.375),
    angle = Angle(0, 0.361, 90),
    size = Vector(0.048, 0.028, 0.035),
    color = Color(100, 90, 90, 255),
    surpresslightning = false,
    material = "phoenix_storms/grey_steel",
    skin = 0,
    bodygroup = {}
  },
  ["light"] = {
    type = "Sprite",
    sprite = "particle/Particle_Glow_04",
    pos = Vector(7.105, 0.968, -3.774),
    size = {
      x = 6.894,
      y = 6.894
    },
    color = Color(255, 80, 50, 255),
    nocull = true,
    additive = true,
    vertexalpha = true,
    vertexcolor = true,
    ignorez = true
  }
}

SWEP.HoldType = "pistol"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Cone = 0.012
SWEP.MaxAmmo = 6
SWEP.IronSightsPos = Vector(-4.83, 38, -0.15)
SWEP.IronSightsAng = Vector(0.5, -0.2, 1.15)

--------------------
function SWEP:Initialize()
  self:SetHoldType(self.HoldType)
  self.ReloadCheck = false
  self:InstallDataTable()
  self:DTVar("Int", 0, "NewAmmo")
  self:DTVar("Bool", 0, "Ironsights")

  if SERVER then
    self.dt.NewAmmo = self.MaxAmmo
    self.dt.Ironsights = false
    self.NextIdle = CurTime()
  end

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

function SWEP:FalsifyVars()
  self.ReloadCheck = false
  self.dt.Ironsights = false

  if SERVER and IsValid(self:GetOwner()) then
    self:GetOwner():SetFOV(0, 0.25)
  end
end

function SWEP:Holster()
  if CLIENT and IsValid(self:GetOwner()) then
    local vm = self:GetOwner():GetViewModel()

    if IsValid(vm) then
      self:ResetBonePositions(vm)
    end
  end

  self:FalsifyVars()

  return true
end

function SWEP:Equip(NewOwner)
  self:FalsifyVars()

  return true
end

function SWEP:OnDrop()
  self:FalsifyVars()

  return true
end

function SWEP:OwnerChanged()
  self:FalsifyVars()

  return true
end

function SWEP:Deploy()
  self:FalsifyVars()
  self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

  if SERVER then
    self.NextIdle = CurTime() + self:SequenceDuration()
  end

  self:SetNextPrimaryFire(CurTime() + 0.7)
  self:SetNextSecondaryFire(CurTime() + 0.7)

  return true
end

function SWEP:OnRemove()
  self:FalsifyVars()
  self:Holster()

  if CLIENT and IsValid(self) and IsValid(self:GetOwner()) and isfunction(self.RemoveModels) then
    self:RemoveModels()
  end
end

function SWEP:OnRestore()
  self.dt.Ironsights = false

  if SERVER then
    self:GetOwner():SetFOV(0, 0.25)
  end
end

function SWEP:Think()
  if not IsValid(self) or not IsValid(self:GetOwner()) then return end

  if SERVER and self.NextIdle <= CurTime() then
    self:SendWeaponAnim(ACT_VM_IDLE)
    self.NextIdle = CurTime() + self:SequenceDuration()
  end
end

function SWEP:Reload()
  if self:GetNextPrimaryFire() - 0.1 > CurTime() then return end

  -- Goldeneye-style reload
  if self.dt.NewAmmo < self.MaxAmmo then
    self:SetNextPrimaryFire(CurTime() + 2.1)
    self:SetNextSecondaryFire(CurTime() + 2.1)

    if SERVER then
      self.NextIdle = math.huge
      self:GetOwner():SetFOV(0, 0.25)
    end

    self.ReloadCheck = true
    self.dt.Ironsights = false
    self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    -- timers for sounds/whatever, tried to be efficient, that's why the code might look weird
    for i = 0, 3 do
      timer.Simple(0.3 + (i * 0.367), function()
        if not self.Weapon or not self.Weapon:IsValid() then return end
        if not self:GetOwner() or not self:GetOwner():Alive() then return end
        if not self.ReloadCheck then return end -- so you can't continue reloading if you switch weapons during

        if i == 0 then
          self:GetOwner():ViewPunch(Angle(0.6, -0.2, 0))
        end

        if i ~= 3 then
          if SERVER then
            self.Weapon:EmitSound("weapons/357/357_reload" .. 1 + math.ceil(i * 1.5) .. ".wav", 70, 100)
          end
        else
          self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

          if SERVER then
            self.Weapon:EmitSound("buttons/button9.wav", 70, 100)
            self.dt.NewAmmo = self.MaxAmmo
            self.NextIdle = CurTime() + self:SequenceDuration()
          end
        end
      end)
    end
  end
end

function SWEP:PrimaryAttack()
  local BulletShock = function(attacker, tr, dmginfo)
    local impact = EffectData()
    impact:SetOrigin(tr.HitPos)
    impact:SetNormal(tr.HitNormal)
    util.Effect("chimera_shock", impact)
    if CLIENT then return end
    sound.Play("ambient/levels/labs/electric_explosion" .. math.random(2, 4) .. ".wav", tr.HitPos, 95, math.random(95, 105))
    tes = ents.Create("point_tesla") -- extra electric effect
    tes:SetPos(tr.HitPos + (tr.HitNormal * 15))
    tes:SetKeyValue("m_SoundName", "")
    tes:SetKeyValue("texture", "sprites/bluelight1.spr")
    tes:SetKeyValue("m_Color", "255 150 200")
    tes:SetKeyValue("m_flRadius", "30")
    tes:SetKeyValue("beamcount_min", "7")
    tes:SetKeyValue("beamcount_max", "9")
    tes:SetKeyValue("thick_min", "2")
    tes:SetKeyValue("thick_max", "2")
    tes:SetKeyValue("lifetime_min", "0.3")
    tes:SetKeyValue("lifetime_max", "0.4")
    tes:SetKeyValue("interval_min", "0.1")
    tes:SetKeyValue("interval_max", "0.1")
    tes:Spawn()
    tes:Fire("DoSpark", "", 0)
    tes:Fire("DoSpark", "", 0.2)
    tes:Fire("DoSpark", "", 0.4)
    tes:Fire("DoSpark", "", 0.6)
    tes:Fire("kill", "", 1)
    dmginfo:SetDamageType(DMG_DISSOLVE)
    dmginfo:SetDamage(22)

    for k, v in ipairs(ents.FindInSphere(tr.HitPos, 30)) do
      v:TakeDamageInfo(dmginfo)

      -- rollermines go crazy, then explode
      if v:GetClass() == "npc_rollermine" then
        v:Fire("InteractivePowerDown")
      end
    end

    return true
  end

  local BulletFire = function(attacker, tr, dmginfo)
    local impact = EffectData()
    impact:SetOrigin(tr.HitPos)
    impact:SetNormal(tr.HitNormal)
    util.Effect("chimera_fire", impact)
    if CLIENT then return end
    sound.Play("ambient/fire/gascan_ignite1.wav", tr.HitPos, 95, math.random(95, 105))
    dmginfo:SetDamageType(DMG_BURN) -- ignites zombies/headcrabs/burnable props
    dmginfo:SetDamage(16)

    for k, v in ipairs(ents.FindInSphere(tr.HitPos, 55)) do
      v:TakeDamageInfo(dmginfo)
    end

    return true
  end

  local BulletExplode = function(attacker, tr, dmginfo)
    local impact = EffectData()
    impact:SetOrigin(tr.HitPos)
    impact:SetNormal(tr.HitNormal)
    util.Effect("chimera_explode", impact)
    if CLIENT then return end
    sound.Play("ambient/explosions/explode_9.wav", tr.HitPos, 95, math.random(95, 105))
    dmginfo:SetDamage(17)

    for k, v in ipairs(ents.FindInSphere(tr.HitPos, 80)) do
      if v:GetClass() == "npc_rollermine" then
        dmginfo:SetDamageType(DMG_BLAST) -- rollermines take blast damage so they die
      else
        dmginfo:SetDamageType(DMG_DIRECT) -- direct to anything else (so props don't ignite)
      end

      v:TakeDamageInfo(dmginfo)
    end

    return true
  end

  local BulletAcid = function(attacker, tr, dmginfo)
    local impact = EffectData()
    impact:SetOrigin(tr.HitPos)
    impact:SetNormal(tr.HitNormal)
    util.Effect("chimera_acid", impact)
    if CLIENT then return end

    -- double sounds since they're pretty quiet otherwise
    for i = 0, 1 do
      sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", tr.HitPos, 95, math.random(85, 95) + (i * 10))
      sound.Play("weapons/underwater_explode" .. math.random(3, 4) .. ".wav", tr.HitPos, 95, math.random(85, 95) + (i * 10))
    end

    dmginfo:SetDamageType(DMG_POISON) -- doesn't damage props or non-organic npcs
    dmginfo:SetDamage(20)

    for k, v in ipairs(ents.FindInSphere(tr.HitPos, 60)) do
      v:TakeDamageInfo(dmginfo)
    end

    return true
  end

  local acc = 1

  if self.dt.Ironsights == true then
    acc = 0.5 -- shots are more accurate while in ironsights
  end

  local bullet = {}
  bullet.Src = self:GetOwner():GetShootPos()
  bullet.Attacker = self:GetOwner()
  bullet.Dir = self:GetOwner():GetAimVector()
  bullet.Spread = Vector(self.Cone * acc, self.Cone * acc, 0)
  bullet.Num = 3
  bullet.Damage = 5
  bullet.Force = 15
  bullet.Tracer = 0

  -- effects and sound, if you have ammo
  if self.dt.NewAmmo > 0 then
    self.Weapon:EmitSound("npc/sniper/sniper1.wav", 140, math.random(97, 103))

    local randbullet = {BulletShock, BulletFire, BulletExplode, BulletAcid}

    bullet.Callback = randbullet[math.random(#randbullet)]

    if SERVER then
      self.dt.NewAmmo = self.dt.NewAmmo - 1
    end
  end

  self:FireBullets(bullet)
  self:GetOwner():ViewPunch(Angle(math.Rand(-1.8, -2.5), math.Rand(-1, 1), 0))
  self.Weapon:EmitSound("Weapon_357.Single")
  self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self:GetOwner():SetAnimation(PLAYER_ATTACK1)
  self:GetOwner():MuzzleFlash()

  if SERVER then
    self.NextIdle = CurTime() + (self:SequenceDuration() - 0.2)
  end

  self.Weapon:SetNextPrimaryFire(CurTime() + 0.6)
  self.Weapon:SetNextSecondaryFire(CurTime() + 0.6)

  if (game.SinglePlayer() and SERVER) or CLIENT then
    self.Weapon:SetNWFloat("LastShootTime", CurTime())
  end
end

function SWEP:SecondaryAttack()
  if SERVER then
    if self.dt.Ironsights == false then
      self.dt.Ironsights = true
      self:GetOwner():SetFOV(45, 0.25)
    else
      self.dt.Ironsights = false
      self:GetOwner():SetFOV(0, 0.25)
    end
  end

  self.Weapon:SetNextPrimaryFire(CurTime() + 0.25)
  self.Weapon:SetNextSecondaryFire(CurTime() + 0.25)
end

function SWEP:GetViewModelPosition(pos, ang)
  local bIron = self.dt.Ironsights

  if bIron ~= self.bLastIron then
    self.bLastIron = bIron
    self.fIronTime = CurTime()

    if bIron then
      self.SwayScale = 0.2
      self.BobScale = 0.1
    else
      self.SwayScale = 1
      self.BobScale = 1
    end
  end

  local fIronTime = self.fIronTime or 0
  if not bIron and fIronTime < CurTime() - 0.2 then return pos, ang end
  local Mul = 1

  if fIronTime > CurTime() - 0.2 then
    Mul = math.Clamp((CurTime() - fIronTime) / 0.2, 0, 1)

    if not bIron then
      Mul = 1 - Mul
    end
  end

  local Offset = self.IronSightsPos
  ang = ang * 1
  ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * Mul)
  ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * Mul)
  ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
  local Right = ang:Right()
  local Up = ang:Up()
  local Forward = ang:Forward()
  pos = pos + Offset.x * Right * Mul
  pos = pos + Offset.y * Forward * Mul
  pos = pos + Offset.z * Up * Mul

  return pos, ang
end

function SWEP:DrawHUD()
  if self.dt.Ironsights == true then return end
  local x, y

  if self:GetOwner() == LocalPlayer() and self:GetOwner():ShouldDrawLocalPlayer() then
    local tr = util.GetPlayerTrace(self:GetOwner())
    tr.mask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX)
    local trace = util.TraceLine(tr)
    local coords = trace.HitPos:ToScreen()
    x, y = coords.x, coords.y
  else
    x, y = ScrW() / 2, ScrH() / 2
  end

  local scaleh = (ScrH() / 770) * 15
  local scale = scaleh * self.Cone
  local LastShootTime = self.Weapon:GetNWFloat("LastShootTime", 0)
  scale = scale * (2 - math.Clamp((CurTime() - LastShootTime) * 5, 0.0, 1.0))
  surface.SetDrawColor(255, 255, 255, 200)
  local gap = 40 * scale
  local length = gap + 20 * scale
  surface.DrawLine(x - length, y, x - gap, y)
  surface.DrawLine(x + length, y, x + gap, y)
  surface.DrawLine(x, y - length, x, y - gap)
  surface.DrawLine(x, y + length, x, y + gap)
end

function SWEP:CustomAmmoDisplay()
  local ammodisplay = ammodisplay or {}
  ammodisplay.PrimaryClip = self.dt.NewAmmo

  return ammodisplay
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
      -- you can get in an infinite loop. Lets just hope nobodys that stupid.
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

    -- Create the clientside models here because Garry says we cant do it in the render hook
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
  -- WARNING: do not use on tables that contain themselves somewhere down the line or youll get an infinite loop
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

---------- EFFECTS BEYOND THIS LINE
if not CLIENT then return end
local EFFECT = {}

function EFFECT:Init(data)
  local Offset = data:GetOrigin()
  local Derp = data:GetNormal()
  local emitter = ParticleEmitter(Offset)

  for i = 1, 7 do
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 3)
    glow = emitter:Add("effects/energyball", Offset)
    glow:SetVelocity(Vec * math.Rand(250, 330))
    glow:SetPos(Offset + (Derp * 5))
    glow:SetDieTime(math.Rand(1.1, 1.4))
    glow:SetStartAlpha(255)
    glow:SetEndAlpha(0)
    glow:SetStartSize(20)
    glow:SetEndSize(0)
    glow:SetColor(200, 150, 255)
    glow:SetAirResistance(100)
    glow:SetGravity(Vector(0, 0, 0))
    glow:SetRoll(math.Rand(0, 360))
    glow:SetRollDelta(math.Rand(-2, 2))
    glow:SetBounce(0.6)
    glow:SetCollide(true)
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 3)
    spark = emitter:Add("effects/spark", Offset)
    spark:SetVelocity(Vec * math.Rand(150, 200))
    spark:SetPos(Offset + (Derp * 5))
    spark:SetDieTime(math.Rand(1.2, 1.5))
    spark:SetStartAlpha(255)
    spark:SetEndAlpha(0)
    spark:SetStartSize(25)
    spark:SetEndSize(0)
    spark:SetColor(50, 50, 255)
    spark:SetAirResistance(100)
    spark:SetGravity(Vector(0, 0, 0))
    spark:SetRoll(math.Rand(0, 360))
    spark:SetRollDelta(math.Rand(50, 70))
    spark:SetBounce(0.6)
    spark:SetCollide(true)
  end

  emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end

effects.Register(EFFECT, "chimera_shock", true)
local EFFECT = {}

function EFFECT:Init(data)
  local Offset = data:GetOrigin()
  local Derp = data:GetNormal()
  local emitter = ParticleEmitter(Offset)

  for i = 1, 14 do
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
    smoke = emitter:Add("particle/particle_smokegrenade", Offset)
    smoke:SetVelocity(Vec * math.Rand(650, 750))
    smoke:SetPos(Offset + (Derp * 5))
    smoke:SetDieTime(math.Rand(1.3, 1.6))
    smoke:SetStartAlpha(255)
    smoke:SetEndAlpha(0)
    smoke:SetStartSize(20)
    smoke:SetEndSize(40)
    smoke:SetColor(Color(150, 150, 150, 255))
    smoke:SetAirResistance(150)
    smoke:SetGravity(Vector(0, 0, 20))
    smoke:SetRoll(math.Rand(0, 360))
    smoke:SetRollDelta(math.Rand(-2, 2))
    smoke:SetBounce(0.3)
    smoke:SetCollide(true)
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
    local randcolor = math.random(60, 170)
    fire = emitter:Add("sprites/flamelet" .. math.random(1, 5), Offset)
    fire:SetVelocity(Vec * math.Rand(850, 950))
    fire:SetPos(Offset + (Derp * 5))
    fire:SetDieTime(math.Rand(1.1, 1.4))
    fire:SetStartAlpha(255)
    fire:SetEndAlpha(0)
    fire:SetStartSize(30)
    fire:SetEndSize(0)
    fire:SetColor(255, randcolor, randcolor)
    fire:SetAirResistance(250)
    fire:SetGravity(Vector(0, 0, 5))
    fire:SetRoll(math.Rand(0, 360))
    fire:SetRollDelta(math.Rand(-2, 2))
    fire:SetBounce(0.3)
    fire:SetCollide(true)
  end

  local Vec = Derp + (VectorRand():GetNormalized() / 10)
  heatwave = emitter:Add("sprites/heatwave", Offset)
  heatwave:SetVelocity(Vec * math.Rand(75, 85))
  heatwave:SetPos(Offset + (Derp * 5))
  heatwave:SetDieTime(math.Rand(1.2, 1.5))
  heatwave:SetStartAlpha(255)
  heatwave:SetEndAlpha(0)
  heatwave:SetStartSize(70)
  heatwave:SetEndSize(0)
  heatwave:SetColor(Color(255, 255, 255, 255))
  heatwave:SetAirResistance(200)
  heatwave:SetGravity(Vector(0, 0, 10))
  heatwave:SetRoll(math.Rand(0, 360))
  heatwave:SetRollDelta(math.Rand(-2, 2))
  heatwave:SetBounce(0.3)
  heatwave:SetCollide(true)
  emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end

effects.Register(EFFECT, "chimera_fire", true)
local EFFECT = {}

function EFFECT:Init(data)
  local Offset = data:GetOrigin()
  local Derp = data:GetNormal()
  local emitter = ParticleEmitter(Offset)

  for i = 1, 14 do
    local Vec = Derp * -0.1 + VectorRand():GetNormalized()
    smoke = emitter:Add("particle/particle_smokegrenade", Offset)
    smoke:SetVelocity(Vec * math.Rand(200, 250))
    smoke:SetPos(Offset + (Derp * 5))
    smoke:SetDieTime(math.Rand(0.6, 0.8))
    smoke:SetStartAlpha(255)
    smoke:SetEndAlpha(0)
    smoke:SetStartSize(40)
    smoke:SetEndSize(60)
    smoke:SetColor(Color(200, 200, 200, 255))
    smoke:SetAirResistance(150)
    smoke:SetGravity(Vector(0, 0, 20))
    smoke:SetRoll(math.Rand(0, 360))
    smoke:SetRollDelta(math.Rand(-5, 5))
    smoke:SetBounce(0.3)
    smoke:SetCollide(true)
    local Vec = Derp * -0.1 + VectorRand():GetNormalized()
    local size = math.random(20, 30)
    fire = emitter:Add("effects/fire_cloud2", Offset)
    fire:SetVelocity(Vec * math.Rand(250, 300))
    fire:SetPos(Offset + (Derp * 5))
    fire:SetDieTime(math.Rand(0.2, 0.4))
    fire:SetStartAlpha(255)
    fire:SetEndAlpha(0)
    fire:SetStartSize(size)
    fire:SetEndSize(size * 1.5)
    fire:SetColor(255, 255, 255)
    fire:SetAirResistance(150)
    fire:SetGravity(Vector(0, 0, 5))
    fire:SetRoll(math.Rand(0, 360))
    fire:SetRollDelta(math.Rand(-8, 8))
    fire:SetBounce(0.3)
    fire:SetCollide(true)
    local Vec = Derp * -0.1 + VectorRand():GetNormalized()
    local size = math.random(6, 14)
    local length = math.random(35, 45)
    blast = emitter:Add("effects/fire_cloud2", Offset)
    blast:SetVelocity(Vec * math.Rand(600, 800))
    blast:SetDieTime(math.Rand(0.1, 0.15))
    blast:SetStartAlpha(255)
    blast:SetEndAlpha(255)
    blast:SetStartSize(size)
    blast:SetEndSize(size)
    blast:SetStartLength(length)
    blast:SetEndLength(length)
    blast:SetColor(255, 255, 255)
    blast:SetAirResistance(100)
    blast:SetGravity(Vector(0, 0, 0))
    blast:SetBounce(0)
    blast:SetCollide(true)
  end

  for i = 1, 3 do
    local Vec = Derp + (VectorRand():GetNormalized() / 10)
    smoke2 = emitter:Add("particle/particle_smokegrenade", Offset)
    smoke2:SetVelocity(Vec * math.Rand(55, 65))
    smoke2:SetPos(Offset + (Derp * 5))
    smoke2:SetDieTime(math.Rand(0.9, 1.1))
    smoke2:SetStartAlpha(255)
    smoke2:SetEndAlpha(0)
    smoke2:SetStartSize(50)
    smoke2:SetEndSize(80)
    smoke2:SetColor(Color(160, 160, 160, 255))
    smoke2:SetAirResistance(30)
    smoke2:SetGravity(Vector(0, 0, 10))
    smoke2:SetRoll(math.Rand(0, 360))
    smoke2:SetRollDelta(math.Rand(-2, 2))
    smoke2:SetBounce(0.3)
    smoke2:SetCollide(true)
  end

  emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end

effects.Register(EFFECT, "chimera_explode", true)
local EFFECT = {}

function EFFECT:Init(data)
  local Offset = data:GetOrigin()
  local Derp = data:GetNormal()
  local emitter = ParticleEmitter(Offset)

  for i = 1, 12 do
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
    smoke = emitter:Add("particle/particle_noisesphere", Offset)
    smoke:SetVelocity(Vec * math.Rand(600, 700) + Vector(0, 0, 100))
    smoke:SetPos(Offset + (Derp * 5))
    smoke:SetDieTime(math.Rand(0.9, 1.2))
    smoke:SetStartAlpha(255)
    smoke:SetEndAlpha(0)
    smoke:SetStartSize(20)
    smoke:SetEndSize(30)
    smoke:SetColor(120, 240, 120)
    smoke:SetAirResistance(150)
    smoke:SetGravity(Vector(0, 0, -150))
    smoke:SetRoll(math.Rand(0, 360))
    smoke:SetRollDelta(math.Rand(-7, 7))
    smoke:SetBounce(0.3)
    smoke:SetCollide(true)
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
    smoke2 = emitter:Add("particle/particle_noisesphere", Offset)
    smoke2:SetVelocity(Vec * math.Rand(700, 800) + Vector(0, 0, 100))
    smoke2:SetPos(Offset + (Derp * 5))
    smoke2:SetDieTime(math.Rand(0.7, 1.0))
    smoke2:SetStartAlpha(255)
    smoke2:SetEndAlpha(0)
    smoke2:SetStartSize(20)
    smoke2:SetEndSize(40)
    smoke2:SetColor(Color(200, 200, 200))
    smoke2:SetAirResistance(150)
    smoke2:SetGravity(Vector(0, 0, -150))
    smoke2:SetRoll(math.Rand(0, 360))
    smoke2:SetRollDelta(math.Rand(-6, 6))
    smoke2:SetBounce(0.3)
    smoke2:SetCollide(true)
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
    local randcolor = math.random(30, 90)
    fire = emitter:Add("sprites/flamelet" .. math.random(1, 5), Offset)
    fire:SetVelocity(Vec * math.Rand(850, 950) + Vector(0, 0, 100))
    fire:SetPos(Offset + (Derp * 5))
    fire:SetDieTime(math.Rand(0.4, 0.6))
    fire:SetStartAlpha(255)
    fire:SetEndAlpha(0)
    fire:SetStartSize(40)
    fire:SetEndSize(0)
    fire:SetColor(randcolor, 255, randcolor)
    fire:SetAirResistance(250)
    fire:SetGravity(Vector(0, 0, -200))
    fire:SetRoll(math.Rand(0, 360))
    fire:SetRollDelta(math.Rand(-8, 8))
    fire:SetBounce(0.3)
    fire:SetCollide(true)
    local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
    local randcolor = math.random(30, 90)
    ember = emitter:Add("effects/fire_embers" .. math.random(1, 3), Offset)
    ember:SetVelocity(Vec * math.Rand(850, 950) + Vector(0, 0, 100))
    ember:SetPos(Offset + (Derp * 5))
    ember:SetDieTime(math.Rand(0.9, 1.1))
    ember:SetStartAlpha(255)
    ember:SetEndAlpha(0)
    ember:SetStartSize(40)
    ember:SetEndSize(0)
    ember:SetColor(randcolor, 255, randcolor)
    ember:SetAirResistance(200)
    ember:SetGravity(Vector(0, 0, -200))
    ember:SetRoll(math.Rand(0, 360))
    ember:SetRollDelta(math.Rand(-8, 8))
    ember:SetBounce(0.3)
    ember:SetCollide(true)
  end

  local Vec = Derp + (VectorRand():GetNormalized() / 10)
  heatwave = emitter:Add("sprites/heatwave", Offset)
  heatwave:SetVelocity(Vec * math.Rand(55, 65) + Vector(0, 0, 100))
  heatwave:SetPos(Offset + (Derp * 5))
  heatwave:SetDieTime(math.Rand(0.8, 1.1))
  heatwave:SetStartAlpha(255)
  heatwave:SetEndAlpha(0)
  heatwave:SetStartSize(70)
  heatwave:SetEndSize(0)
  heatwave:SetColor(Color(255, 255, 255, 255))
  heatwave:SetAirResistance(200)
  heatwave:SetGravity(Vector(0, 0, -100))
  heatwave:SetRoll(math.Rand(0, 360))
  heatwave:SetRollDelta(math.Rand(-2, 2))
  heatwave:SetBounce(0.3)
  heatwave:SetCollide(true)
  emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end

effects.Register(EFFECT, "chimera_acid", true)