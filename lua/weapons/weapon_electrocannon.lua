AddCSLuaFile()

if CLIENT then
  language.Add("weapon_electrocannon", "Electrocannon")
  language.Add("electromissile", "Rhino Missile")
end

SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Electrocannon"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 4
SWEP.SlotPos = 5
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "PRIMARY: Shock Buster\nSECONDARY: Rhino Missile"
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true
SWEP.HoldType = "rpg"
SWEP.Primary.Cone = 0.07
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.CrossHairScale = 1
SWEP.IronSightsPos = Vector(-6.5, -10.5, 5.3)
SWEP.IronSightsAng = Vector(0, -5, 30)

--------------------
function SWEP:Initialize()
  self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
  local ShockLaser = function(attacker, tr, dmginfo)
    sound.Play("weapons/physcannon/superphys_small_zap" .. math.random(1, 4) .. ".wav", tr.HitPos, 90, math.random(95, 105))
    local beam = EffectData()
    beam:SetOrigin(tr.HitPos)
    beam:SetStart(self:GetOwner():GetShootPos())
    beam:SetAttachment(1)
    beam:SetEntity(self)
    util.Effect("electrocannon_shocktracer", beam)

    if SERVER then
      tes = ents.Create("point_tesla")
      tes:SetPos(tr.HitPos + (tr.HitNormal * 20))
      tes:SetKeyValue("m_SoundName", "")
      tes:SetKeyValue("texture", "sprites/bluelight1.spr")
      tes:SetKeyValue("m_Color", "255 255 255")
      tes:SetKeyValue("m_flRadius", "80")
      tes:SetKeyValue("beamcount_min", "3")
      tes:SetKeyValue("beamcount_max", "4")
      tes:SetKeyValue("thick_min", "15")
      tes:SetKeyValue("thick_max", "30")
      tes:SetKeyValue("lifetime_min", "0.05")
      tes:SetKeyValue("lifetime_max", "0.09")
      tes:SetKeyValue("interval_min", "0.1")
      tes:SetKeyValue("interval_max", "0.15")
      tes:Spawn()
      tes:Fire("DoSpark", "", 0)
      tes:Fire("DoSpark", "", 0.05)
      tes:Fire("DoSpark", "", 0.1)
      tes:Fire("kill", "", 0.4)
    end

    local dmg = DamageInfo()
    dmg:SetDamageType(DMG_DISSOLVE)
    dmg:SetDamage(7)
    dmg:SetDamagePosition(tr.HitPos)
    dmg:SetDamageForce(VectorRand() * 512)
    dmg:SetInflictor(self)
    dmg:SetAttacker(self:GetOwner())

    for k, v in ipairs(ents.FindInSphere(tr.HitPos, 60)) do
      if SERVER then
        v:TakeDamageInfo(dmg)
      end
    end

    return true
  end

  local FireLaser = function(attacker, tr, dmginfo)
    sound.Play("ambient/fire/gascan_ignite1.wav", tr.HitPos, 95, math.random(97, 103))
    local beam = EffectData()
    beam:SetOrigin(tr.HitPos)
    beam:SetStart(self:GetOwner():GetShootPos())
    beam:SetAttachment(1)
    beam:SetEntity(self)
    util.Effect("electrocannon_firetracer", beam)
    local impact = EffectData()
    impact:SetOrigin(tr.HitPos)
    impact:SetNormal(tr.HitNormal)
    util.Effect("electrocannon_fireburst", impact)
    local dmg = DamageInfo()
    dmg:SetDamageType(DMG_DIRECT)
    dmg:SetDamage(15)
    dmg:SetDamagePosition(tr.HitPos)
    dmg:SetDamageForce(VectorRand() * 512)
    dmg:SetInflictor(self)
    dmg:SetAttacker(self:GetOwner())

    if SERVER then
      for k, v in ipairs(ents.FindInSphere(tr.HitPos, 40)) do
        v:TakeDamageInfo(dmg)
      end
    end

    return true
  end

  local bullet = {}
  bullet.Src = self:GetOwner():GetShootPos()
  bullet.Attacker = self:GetOwner()
  bullet.Dir = self:GetOwner():GetAimVector()
  bullet.Spread = Vector(self.Primary.Cone, self.Primary.Cone, 0)
  bullet.Num = 10
  bullet.Damage = 0
  bullet.Force = 50
  bullet.Tracer = 0
  bullet.Callback = ShockLaser
  local fbullet = {}
  fbullet.Src = self:GetOwner():GetShootPos()
  fbullet.Attacker = self:GetOwner()
  fbullet.Dir = self:GetOwner():GetAimVector()
  fbullet.Spread = Vector(self.Primary.Cone / 5, self.Primary.Cone / 5, 0)
  fbullet.Num = 3
  fbullet.Damage = 0
  fbullet.Force = 100
  fbullet.Tracer = 0
  fbullet.Callback = FireLaser
  self:FireBullets(bullet)
  self:FireBullets(fbullet)
  self:GetOwner():ViewPunch(Angle(math.Rand(-1.5, -2.5), math.Rand(-1, 1), 0))
  self:EmitSound("weapons/grenade_launcher1.wav", 85, 100)
  self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self:GetOwner():SetAnimation(PLAYER_ATTACK1)
  self:SetNextPrimaryFire(CurTime() + 0.7)
  self:SetNextSecondaryFire(CurTime() + 0.7)

  if (game.SinglePlayer() and SERVER) or CLIENT then
    self:SetNWFloat("LastShootTime", CurTime())
  end
end

function SWEP:SecondaryAttack()
  local pos = self:GetOwner():GetShootPos()
  local ang = self:GetOwner():GetAimVector()
  local shooteffect = EffectData()
  shooteffect:SetOrigin(pos + (ang * 40))

  --util.Effect("electrocannon_shoot", shooteffect)
  -- too annoying, sorry
  if SERVER then
    local ent = ents.Create("electromissile")
    if not IsValid(ent) then return end
    ent:SetPos(self:GetOwner():GetShootPos())
    ent:SetAngles(self:GetOwner():EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()

    if IsValid(ent:GetPhysicsObject()) then
      ent:GetPhysicsObject():EnableGravity(false)
      ent:GetPhysicsObject():SetBuoyancyRatio(0)
      ent:GetPhysicsObject():EnableDrag(false)
      ent:GetPhysicsObject():AddVelocity(self:GetOwner():GetAimVector() * 700)
    end

    ent.Inflictor = self
    ent.Attacker = self:GetOwner()
  end

  self:GetOwner():ViewPunch(Angle(math.Rand(-3.5, -5.5), math.Rand(-1, 1), 0))
  self:EmitSound("weapons/stinger_fire1.wav", 90, 100)
  self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self:GetOwner():SetAnimation(PLAYER_ATTACK1)
  self:SetNextPrimaryFire(CurTime() + 2)
  self:SetNextSecondaryFire(CurTime() + 2)

  if (game.SinglePlayer() and SERVER) or CLIENT then
    self:SetNWFloat("LastShootTime", CurTime())
  end
end

function SWEP:DrawHUD()
  local center = Vector(ScrW() / 2, ScrH() / 2, 0)
  local scalecircle = Vector(100, 100, 0)
  local segmentdist = 360 / (2 * math.pi * math.max(scalecircle.x, scalecircle.y) / 2)
  scalecircle = scalecircle / 25
  surface.SetDrawColor(0, 0, 255, 200)

  for a = 0, 360 - segmentdist, segmentdist do
    surface.DrawLine(center.x + math.cos(math.rad(a)) * scalecircle.x, center.y - math.sin(math.rad(a)) * scalecircle.y, center.x + math.cos(math.rad(a + segmentdist)) * scalecircle.x, center.y - math.sin(math.rad(a + segmentdist)) * scalecircle.y)
  end

  local x = ScrW() / 2
  local y = ScrH() / 2
  local scalebyheight = (ScrH() / 770) * 15
  local scale = scalebyheight * self.Primary.Cone
  if not self:GetOwner():IsValid() then return end
  LastShootTime = self:GetNWFloat("LastShootTime", 0)
  scale = scale * (2 - math.Clamp((CurTime() - LastShootTime) * 5, 0.0, 1.0))
  surface.SetDrawColor(255, 255, 255, 200)
  self.CrossHairScale = math.Approach(self.CrossHairScale, scale, FrameTime() * 3 + math.abs(self.CrossHairScale - scale) * 0.012)
  local dispscale = self.CrossHairScale
  local gap = 40 * dispscale
  local length = gap + 20 * scale
  surface.DrawLine(x - length, y, x - gap, y)
  surface.DrawLine(x + length, y, x + gap, y)
  surface.DrawLine(x, y - length, x, y - gap)
  surface.DrawLine(x, y + length, x, y + gap)
end

function SWEP:GetViewModelPosition(pos, ang)
  self.SwayScale = 0.3
  self.BobScale = 0.1
  local Offset = self.IronSightsPos
  ang = ang * 1
  ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x)
  ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y)
  ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z)
  local Right = ang:Right()
  local Up = ang:Up()
  local Forward = ang:Forward()
  pos = pos + Offset.x * Right
  pos = pos + Offset.y * Forward
  pos = pos + Offset.z * Up

  return pos, ang
end

----------
if not CLIENT then return end
local EFFECT = {}

function EFFECT:Init(data)
  local Offset = data:GetOrigin()
  local emitter = ParticleEmitter(Offset)

  for i = 1, 15 do
    smoke = emitter:Add("particle/particle_smokegrenade", Offset)

    if smoke then
      smoke:SetVelocity(VectorRand():GetNormalized() * 50)
      smoke:SetDieTime(1)
      smoke:SetStartAlpha(250)
      smoke:SetEndAlpha(0)
      smoke:SetStartSize(20)
      smoke:SetEndSize(10)
      smoke:SetColor(170, 170, 170)
      smoke:SetAirResistance(10)
      smoke:SetGravity(Vector(0, 0, 50))
      smoke:SetBounce(0.3)
      smoke:SetRoll(math.Rand(0, 360))
      smoke:SetRollDelta(math.Rand(-2, 2))
      smoke:SetCollide(true)
    end
  end

  emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end

effects.Register(EFFECT, "electrocannon_shoot", true)

function EFFECT:Init(data)
  self.ent = data:GetEntity()

  if IsValid(self.ent) then
    self.emitter = ParticleEmitter(self.ent:GetPos())
    self.NextEmit = CurTime()
  end
end

function EFFECT:Think()
  if IsValid(self.ent) then
    if self.NextEmit < CurTime() then
      for i = 1, 2 do
        spark = self.emitter:Add("effects/bluespark", self.ent:GetPos() + self.ent:OBBCenter())

        if spark then
          spark:SetVelocity(VectorRand():GetNormalized() * 10)
          spark:SetDieTime(1.5)
          spark:SetStartAlpha(230)
          spark:SetStartSize(20)
          spark:SetStartLength(10)
          spark:SetEndSize(0)
          spark:SetEndLength(0)
          spark:SetColor(255, 255, 255)
          spark:SetGravity(Vector(0, 0, 15))
          spark:SetBounce(0)
          spark:SetRoll(math.random(-5, 5))
          spark:SetCollide(true)
        end
      end

      smoke = self.emitter:Add("particle/particle_smokegrenade", self.ent:GetPos() + self.ent:OBBCenter())

      if smoke then
        smoke:SetDieTime(2)
        smoke:SetStartAlpha(250)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(10)
        smoke:SetEndSize(20)
        smoke:SetColor(170, 170, 170)
        smoke:SetGravity(Vector(0, 0, 15))
        smoke:SetBounce(0.3)
        smoke:SetRoll(math.Rand(0, 360))
        smoke:SetRollDelta(math.Rand(-2, 2))
        smoke:SetCollide(true)
      end

      self.NextEmit = CurTime() + 0.05
    end

    return true
  else
    return false
  end
end

function EFFECT:Render()
  return true
end

effects.Register(EFFECT, "electrocannon_missiletrail", true)
local EFFECT = {}

function EFFECT:Init(data)
  local Offset = data:GetOrigin()
  local emitter = ParticleEmitter(Offset)

  for i = 1, 25 do
    bolt = emitter:Add(CreateMaterial("electrocannon_bluelight", "UnlitGeneric", {
      ["$basetexture"] = "sprites/bluelight1",
      ["$additive"] = 1
    }), Offset)

    if bolt then
      bolt:SetVelocity(VectorRand():GetNormalized() * 800)
      bolt:SetDieTime(0.35)
      bolt:SetStartAlpha(250)
      bolt:SetStartSize(200)
      bolt:SetStartLength(80)
      bolt:SetEndSize(0)
      bolt:SetEndLength(0)
      bolt:SetColor(255, 255, 255)
      bolt:SetAirResistance(100)
      bolt:SetBounce(0)
      bolt:SetRoll(math.random(-5, 5))
      bolt:SetCollide(true)
    end

    smoke = emitter:Add("particle/particle_smokegrenade", Offset)

    if smoke then
      smoke:SetVelocity(VectorRand():GetNormalized() * 300)
      smoke:SetDieTime(1)
      smoke:SetStartAlpha(100)
      smoke:SetEndAlpha(0)
      smoke:SetStartSize(100)
      smoke:SetEndSize(30)
      smoke:SetColor(170, 170, 170)
      smoke:SetAirResistance(80)
      smoke:SetGravity(Vector(0, 0, 50))
      smoke:SetBounce(0.3)
      smoke:SetRoll(math.Rand(0, 360))
      smoke:SetRollDelta(math.Rand(-2, 2))
      smoke:SetCollide(true)
    end

    fire = emitter:Add("sprites/flamelet" .. math.random(1, 5), Offset)

    if fire then
      fire:SetVelocity(VectorRand():GetNormalized() * 500)
      fire:SetDieTime(0.7)
      fire:SetStartAlpha(150)
      fire:SetEndAlpha(0)
      fire:SetStartSize(75)
      fire:SetEndSize(0)
      fire:SetColor(255, 255, 255)
      fire:SetAirResistance(200)
      fire:SetGravity(Vector(0, 0, 5))
      fire:SetBounce(0.3)
      fire:SetRoll(math.Rand(0, 360))
      fire:SetRollDelta(math.Rand(-2, 2))
      fire:SetCollide(true)
    end
  end

  emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end

effects.Register(EFFECT, "electrocannon_missileburst", true)
local EFFECT = {}

EFFECT.Mat = CreateMaterial("electrocannon_bluelight", "UnlitGeneric", {
  ["$basetexture"] = "sprites/bluelight1",
  ["$additive"] = 1
})

function EFFECT:Init(data)
  self.Position = data:GetStart()
  selfEnt = data:GetEntity()
  self.Attachment = data:GetAttachment()
  self.StartPos = self:GetTracerShootPos(self.Position, selfEnt, self.Attachment)
  self.EndPos = data:GetOrigin()
  self.EndTime = CurTime() + 0.2
end

function EFFECT:Think()
  self.StartPos = self:GetTracerShootPos(self.Position, selfEnt, self.Attachment)
  self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

  if self.EndTime < CurTime() then
    self:Remove()

    return false
  else
    return true
  end
end

function EFFECT:Render()
  self.Length = (self.StartPos - self.EndPos):Length()
  render.SetMaterial(self.Mat)
  local texcoord = math.Rand(0, 1)

  for i = 1, 2 do
    render.DrawBeam(self.StartPos, self.EndPos, Lerp((self.EndTime - CurTime()) * 5, 0, 15), texcoord, texcoord + self.Length / 128, Color(255, 255, 255, 255))
  end
end

effects.Register(EFFECT, "electrocannon_shocktracer", true)
local EFFECT = {}
EFFECT.Mat = Material("particle/bendibeam")

function EFFECT:Init(data)
  self.Position = data:GetStart()
  selfEnt = data:GetEntity()
  self.Attachment = data:GetAttachment()
  self.StartPos = self:GetTracerShootPos(self.Position, selfEnt, self.Attachment)
  self.EndPos = data:GetOrigin()
  self.EndTime = CurTime() + 0.3
end

function EFFECT:Think()
  self.StartPos = self:GetTracerShootPos(self.Position, selfEnt, self.Attachment)
  self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)

  if self.EndTime < CurTime() then
    self:Remove()

    return false
  else
    return true
  end
end

function EFFECT:Render()
  self.Length = (self.StartPos - self.EndPos):Length()
  render.SetMaterial(self.Mat)
  local texcoord = math.Rand(0, 1)

  for i = 1, 3 do
    render.DrawBeam(self.StartPos, self.EndPos, Lerp((self.EndTime - CurTime()) * 3.33, 0, 20), texcoord, texcoord + self.Length / 128, Color(255, 100, 0, 255))
  end
end

effects.Register(EFFECT, "electrocannon_firetracer", true)
local EFFECT = {}

function EFFECT:Init(data)
  local Offset = data:GetOrigin()
  local Derp = data:GetNormal()
  local emitter = ParticleEmitter(Offset)

  for i = 1, 8 do
    smoke = emitter:Add("particle/particle_smokegrenade", Offset)

    if smoke then
      local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
      smoke:SetVelocity(Vec * 1500)
      smoke:SetPos(Offset + (Derp * 5))
      smoke:SetDieTime(0.8)
      smoke:SetStartAlpha(100)
      smoke:SetEndAlpha(0)
      smoke:SetStartSize(50)
      smoke:SetEndSize(30)
      smoke:SetColor(170, 170, 170)
      smoke:SetAirResistance(100)
      smoke:SetGravity(Vector(0, 0, 50))
      smoke:SetBounce(0.3)
      smoke:SetRoll(math.Rand(0, 360))
      smoke:SetRollDelta(math.Rand(-2, 2))
      smoke:SetCollide(true)
    end

    fire = emitter:Add("sprites/flamelet" .. math.random(1, 5), Offset)

    if fire then
      local Vec = Derp * -0.1 + (VectorRand():GetNormalized() / 4)
      fire:SetVelocity(Vec * 1800)
      fire:SetPos(Offset + (Derp * 5))
      fire:SetDieTime(0.6)
      fire:SetStartAlpha(150)
      fire:SetEndAlpha(0)
      fire:SetStartSize(40)
      fire:SetEndSize(0)
      fire:SetColor(255, 255, 255)
      fire:SetAirResistance(200)
      fire:SetGravity(Vector(0, 0, 5))
      fire:SetBounce(0.3)
      fire:SetRoll(math.Rand(0, 360))
      fire:SetRollDelta(math.Rand(-2, 2))
      fire:SetCollide(true)
    end
  end

  emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end

effects.Register(EFFECT, "electrocannon_fireburst", true)