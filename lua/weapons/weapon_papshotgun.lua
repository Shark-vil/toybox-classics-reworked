AddCSLuaFile()
SWEP.Author = "ZeroXOne"
SWEP.Contact = "ZeroXOne"
SWEP.Purpose = "Maul down anything"
SWEP.PrintName = "Pack-A-Punch Shotgun"
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.ViewModelFOV = 55
SWEP.UseHands = true
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Toybox Classics"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.DefaultClip = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Firemodes = {}
SWEP.CurFiremode = 1

if CLIENT then
  language.Add("weapon_papshotgun", "Pack-a-Punch Shotgun")

  surface.CreateFont("ScoreboardText", {
    font = "Tahoma",
    size = 16,
    weight = 1000,
    antialias = true
  })
end

--[[---------------------------------------------------------
---------------------------------------------------------]]
function SWEP:Initialize()
  self:SetWeaponHoldType("shotgun")
  self.NextShoot = CurTime()
  self.Firemodes = {}

  self.Firemodes[1] = function()
    self:EmitSound("weapons/cguard/charging.wav")

    timer.Simple(1, function()
      if IsValid(self) then
        self:FireLaser()
      end
    end)
  end

  self.Firemodes[2] = function()
    self:EmitSound("weapons/cguard/charging.wav")

    timer.Simple(1, function()
      if IsValid(self) then
        self:FireElectric()
      end
    end)
  end

  self.Firemodes[3] = function()
    self:EmitSound("weapons/cguard/charging.wav")

    timer.Simple(1, function()
      if IsValid(self) then
        self:FireSlug()
      end
    end)
  end
end

function SWEP:PrimaryAttack()
  self:SetNextPrimaryFire(CurTime() + 1.75)
  local firemode = self.Firemodes[self:GetNWInt("CurFiremode", 1)]

  if firemode and IsFirstTimePredicted() then
    firemode(self)
  else
    print('this is not right')
  end
end

function SWEP:FireLaser()
  if not IsValid(self) then return end

  if self:GetOwner() and self then
    local bullet = {}
    bullet.Src = self:GetOwner():GetShootPos()
    bullet.Attacker = self:GetOwner()
    bullet.Dir = self:GetOwner():GetAimVector()
    bullet.Spread = Vector(0.075, 0.075, 0)
    bullet.Num = 24
    bullet.Damage = 0
    bullet.Force = 200
    bullet.Tracer = 0

    bullet.Callback = function(attacker, tr, dmginfo)
      local ED = EffectData()
      local posang = self:GetOwner():GetViewModel():GetAttachment(self:GetOwner():GetViewModel():LookupAttachment("muzzle"))
      ED:SetStart(posang.Pos)
      ED:SetOrigin(tr.HitPos)
      ED:SetEntity(self)
      util.Effect("zeroxone_laser_shotgun_tracer", ED)
      dmginfo:SetDamage(12)
      dmginfo:SetDamageType(DMG_DISSOLVE)
      tr.Entity:TakeDamageInfo(dmginfo)
    end

    self:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav")

    if game.SinglePlayer() then
      self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    end

    local aimvec = self:GetOwner():GetAimVector()
    self:GetOwner():SetVelocity(Vector(aimvec.x * 1.25, aimvec.y * 1.25, aimvec.z * 0.45) * -1024)

    if SERVER then
      self:FireBullets(bullet)
    end

    if SERVER and not game.SinglePlayer() then
      self:SendWeaponAnim(ACT_VM_IDLE)

      timer.Simple(0.1, function()
        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
      end)
    end
  end
end

function SWEP:FireElectric()
  if not IsValid(self) then return end

  if self:GetOwner() and self then
    local bullet = {}
    bullet.Src = self:GetOwner():GetShootPos()
    bullet.Attacker = self:GetOwner()
    bullet.Dir = self:GetOwner():GetAimVector()
    bullet.Spread = Vector(0.075, 0.075, 0)
    bullet.Num = 12
    bullet.Damage = 0
    bullet.Force = 200
    bullet.Tracer = 0

    bullet.Callback = function(attacker, tr, dmginfo)
      local ED = EffectData()
      local posang = self:GetOwner():GetViewModel():GetAttachment(self:GetOwner():GetViewModel():LookupAttachment("muzzle"))
      ED:SetStart(posang.Pos)
      ED:SetOrigin(tr.HitPos)
      ED:SetEntity(self)
      util.Effect("zeroxone_electric_shotgun_tracer", ED)
      local es = EffectData()
      es:SetEntity(tr.Entity)
      es:SetMagnitude(7.25)
      es:SetScale(1.25)
      util.Effect("TeslaHitBoxes", es)
      dmginfo:SetDamage(15)
      dmginfo:SetDamageType(DMG_SHOCK)
      tr.Entity:TakeDamageInfo(dmginfo)

      if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
        tr.Entity:SetVelocity(tr.Entity:GetVelocity() * -0.25)
      end
    end

    if game.SinglePlayer() then
      self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    end

    self:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav", 100, 100)
    local aimvec = self:GetOwner():GetAimVector()
    self:GetOwner():SetVelocity(Vector(aimvec.x * 1.25, aimvec.y * 1.25, aimvec.z * 0.3) * -1024)

    if SERVER then
      self:FireBullets(bullet)
    end

    if SERVER and not game.SinglePlayer() then
      self:SendWeaponAnim(ACT_VM_IDLE)

      timer.Simple(0.1, function()
        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
      end)
    end
  end
end

function SWEP:FireSlug()
  if not IsValid(self) then return end

  if self:GetOwner() and self then
    local pos = self:GetOwner():GetShootPos()
    local aimvec = self:GetOwner():GetAimVector()
    local tracedata = {}
    tracedata.start = pos

    tracedata.filter = {self:GetOwner()}

    tracedata.endpos = pos + (aimvec * 10000000)

    for i = 1, 10 do
      local inum = i
      local tr = util.TraceLine(tracedata)
      local Pos1 = tr.HitPos + tr.HitNormal
      local Pos2 = tr.HitPos - tr.HitNormal
      util.Decal("FadingScorch", Pos1, Pos2)

      if i == 10 and CLIENT then
        local ED = EffectData()
        ED:SetStart(pos)
        ED:SetOrigin(tr.HitPos)
        ED:SetEntity(self)
        util.Effect("zeroxone_slug_shotgun_tracer", ED)
      end

      if tr.HitNonWorld then
        if tr.Entity:IsValid() and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) then
          local dmginfo = DamageInfo()
          dmginfo:SetDamage(240 - inum * 12)
          dmginfo:SetDamageType(DMG_PLASMA)
          dmginfo:SetAttacker(self:GetOwner())
          dmginfo:SetInflictor(self.Weapon)
          dmginfo:SetDamagePosition(tr.HitPos)
          dmginfo:SetDamageForce(Vector(math.Rand(-100, 100), math.Rand(-100, 100), 500) * 50000)
          tr.Entity:TakeDamageInfo(dmginfo)
          table.insert(tracedata.filter, tr.Entity)
        end
      end
    end

    if game.SinglePlayer() then
      self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    end

    if SERVER and not game.SinglePlayer() then
      self:SendWeaponAnim(ACT_VM_IDLE)

      timer.Simple(0.1, function()
        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
      end)
    end

    self:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav")
    self:GetOwner():SetVelocity(Vector(aimvec.x * 1.25, aimvec.y * 1.25, aimvec.z * 0.3) * -1024)
  end
end

function SWEP:SecondaryAttack()
  self:SetNextSecondaryFire(CurTime() + 0.6)
  self:SetNWInt("CurFiremode", self:GetNWInt("CurFiremode", 1) + 1)

  if self:GetNWInt("CurFiremode", 1) > #self.Firemodes then
    self:SetNWInt("CurFiremode", 1)
  end

  self:EmitSound("weapons/smg1/switch_burst.wav")
end

if CLIENT then
  function SWEP:DrawHUD()
    draw.SimpleText("Firemode: " .. self:GetNWInt("CurFiremode", 1) .. " / " .. #self.Firemodes, "ScoreboardText", ScrW() * 0.05, ScrH() * 0.875, Color(0, 255, 30, 255))
  end

  local EFFECT = {}

  function EFFECT:Init(data)
    self.endpos = data:GetOrigin()
    self.startpos = self:GetTracerShootPos(data:GetStart(), data:GetEntity(), 1)
    self.EndTime = CurTime() + 0.8
    self.Laser = Material("cable/redlaser")
    self.Entity:SetRenderBoundsWS(self.startpos, self.endpos)
  end

  function EFFECT:Think()
    if self.EndTime < CurTime() then
      self:Remove()

      return false
    else
      return true
    end
  end

  function EFFECT:Render()
    render.SetMaterial(self.Laser)
    render.DrawBeam(self.startpos, self.endpos, Lerp((self.EndTime - CurTime()) * 1.25, 0, 20), 0, 10, Color(255, 255, 255, 255))

    if self.EndTime < CurTime() then
      self:Remove()

      return false
    else
      return true
    end
  end

  effects.Register(EFFECT, "zeroxone_laser_shotgun_tracer")
  local EFFECT2 = {}

  function EFFECT2:Init(data)
    self.endpos = data:GetOrigin()
    self.startpos = self:GetTracerShootPos(data:GetStart(), data:GetEntity(), 1)
    self.EndTime = CurTime() + 0.8
    self.Laser = Material("trails/electric")
    self.Entity:SetRenderBoundsWS(self.startpos, self.endpos)
  end

  function EFFECT2:Think()
    if self.EndTime < CurTime() then
      self:Remove()

      return false
    else
      return true
    end
  end

  function EFFECT2:Render()
    render.SetMaterial(self.Laser)
    render.DrawBeam(self.startpos, self.endpos, Lerp((self.EndTime - CurTime()) * 1.25, 0, 20), 0, 256, Color(255, 255, 255, 255))

    if self.EndTime < CurTime() then
      self:Remove()

      return false
    else
      return true
    end
  end

  local EFFECT3 = {}

  function EFFECT3:Init(data)
    self.endpos = data:GetOrigin()
    self.startpos = self:GetTracerShootPos(data:GetStart(), data:GetEntity(), 1)
    self.EndTime = CurTime() + 3
    self.Laser = Material("trails/plasma")
    self.Entity:SetRenderBoundsWS(self.startpos, self.endpos)
  end

  function EFFECT3:Think()
    if self.EndTime < CurTime() then
      self:Remove()

      return false
    else
      return true
    end
  end

  function EFFECT3:Render()
    render.SetMaterial(self.Laser)
    render.DrawBeam(self.startpos, self.endpos, Lerp((self.EndTime - CurTime()) * 0.33, 0, 20), 0, 80, Color(255, 255, 255, 255))

    if self.EndTime < CurTime() then
      self:Remove()

      return false
    else
      return true
    end
  end

  effects.Register(EFFECT3, "zeroxone_slug_shotgun_tracer")
  effects.Register(EFFECT2, "zeroxone_electric_shotgun_tracer")
  effects.Register(EFFECT, "zeroxone_laser_shotgun_tracer")
end