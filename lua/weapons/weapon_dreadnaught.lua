AddCSLuaFile()

if CLIENT then
  language.Add("weapon_dreadnaught", "Dreadnaught Cannon")
end

SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Dreadnaught Cannon"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Shoot huge fucking exploding rockets."
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
  self:SetWeaponHoldType("rpg")
end

function SWEP:Reload()
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
  if self:CanPrimaryAttack() then
    local tr = self:GetOwner():GetEyeTrace()

    if SERVER then
      local ent = ents.Create("zero_projectile_dreadnaut")
      ent:Spawn()
      ent:SetOwner(self:GetOwner())
      ent:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector() * 1500)
      ent:GetPhysicsObject():EnableGravity(false)
      local p = self:GetOwner():GetShootPos()
      local a = self:GetOwner():GetAimVector():Angle()
      ent:SetPos(p + a:Right() * 8 + a:Up() * -8)
    end

    self:SetNextPrimaryFire(CurTime() + 3)
    self:ShootEffects()
    self:EmitSound("Weapon_RPG.Single", 100, math.random(80, 100))
  end
end

function SWEP:SecondaryAttack()
end

function SWEP:ShouldDropOnDie()
  return false
end

if CLIENT then
  local EFFECT = {}

  function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local norm = data:GetNormal()
    local em = ParticleEmitter(pos)
    local normang = norm:Angle()
    local normang2 = norm:Angle()
    normang2:RotateAroundAxis(norm:Angle():Right(), math.Rand(-45, 45))
    normang2:RotateAroundAxis(norm:Angle():Up(), math.Rand(-45, 45))
    self.now = CurTime()
    local sts, ens, dt, vel, rol = 2, 120, 0.7, 1200, 3

    for i = 1, 4 do
      local part = em:Add("effects/fire_cloud" .. math.random(1, 2), pos)
      part:SetVelocity(Vector(0, 0, 0))
      part:SetDieTime(1.25)
      part:SetStartSize(1)
      part:SetEndSize(675)
      part:SetRoll(math.Rand(-rol * 3, rol * 3))
      part:SetRollDelta(math.Rand(-rol * 3, rol * 3))
    end

    for i = 1, 36 do
      local ra = math.rad(i * 10)
      local part = em:Add("effects/fire_cloud" .. math.random(1, 2), pos)
      part:SetVelocity((normang:Right() * math.sin(ra) + normang:Up() * math.cos(ra)) * vel)
      part:SetDieTime(dt)
      part:SetStartSize(sts)
      part:SetEndSize(ens)
      part:SetRoll(math.Rand(-rol, rol))
      part:SetRollDelta(math.Rand(-rol, rol))
    end

    for i = 1, 36 do
      local ra = math.rad(i * 10)
      local part = em:Add("effects/fire_cloud" .. math.random(1, 2), pos)
      part:SetVelocity((normang2:Right() * math.sin(ra) + normang2:Forward() * math.cos(ra)) * vel)
      part:SetDieTime(dt)
      part:SetStartSize(sts)
      part:SetEndSize(ens)
      part:SetRoll(math.Rand(-rol, rol))
      part:SetRollDelta(math.Rand(-rol, rol))
    end

    for i = 1, 36 do
      local ra = math.rad(i * 10)
      local part = em:Add("effects/fire_cloud" .. math.random(1, 2), pos)
      part:SetVelocity((normang2:Forward() * math.sin(ra) + normang2:Up() * math.cos(ra)) * vel)
      part:SetDieTime(dt)
      part:SetStartSize(sts)
      part:SetEndSize(ens)
      part:SetRoll(math.Rand(-rol, rol))
      part:SetRollDelta(math.Rand(-rol, rol))
    end

    for i = 1, 144 do
      local StartFade = CurTime() + 4.5
      local ra = math.rad(i * 10)
      local part = em:Add("particle/particle_smokegrenade", pos - normang:Forward() * 22.5)
      part:SetVelocity((normang:Right() * math.sin(ra) + normang:Up() * math.cos(ra)) * 750)
      local r = math.floor(math.Rand(180, 255))
      part:SetColor(Color(r, r, r, 255))
      part:SetDieTime(math.Rand(4.9, 5.1))
      part:SetStartAlpha(255)
      part:SetEndAlpha(0)
      part:SetStartSize(0)
      part:SetEndSize(512)
      part:SetRoll(math.Rand(-5, 5))
      part:SetRollDelta(math.Rand(-5, 5))
      part:SetGravity(Vector(0, 0, -10) + VectorRand() * 10)
    end

    if SERVER then
      self.prop = ents.Create("prop_physics")
      self.prop:SetModel('models/Combine_Helicopter/helicopter_bomb01.mdl')
      self.prop:SetPos(pos)
      self.prop:Spawn()
      self.prop:SetMaterial("sprites/heatwave")
    end
  end

  function EFFECT:Think()
    if not SERVER then return false end

    if (CurTime() - 4) < self.now then
      if self.prop and IsValid(self.ent) then
        self.prop:SetModelScale(self.prop:GetModelScale() * 1.04 + Vector(0.2, 0.2, 0.2))
      end

      return true
    end

    SafeRemoveEntity(self.prop)

    return false
  end

  function EFFECT:Render()
    if (CurTime() - 4) < self.now then
      if self.prop then
        self.prop:DrawModel()
      end

      return true
    end

    return false
  end

  effects.Register(EFFECT, "zero_proj_megaboom")
  local EFFECT = {}

  function EFFECT:Init(data)
    self.ent = data:GetEntity() or (ents.FindByClass("zero_projectile_dreadnaut")[1] or Entity(1) or ents.GetAll()[1] or table.Random(ents.GetAll()))

    if IsValid(self.ent) then
      self.em = ParticleEmitter(self.ent:GetPos())
      self.NextFire = CurTime()
    end
  end

  function EFFECT:Think()
    if IsValid(self.ent) then
      --for i=1,2 do
      if CurTime() > self.NextFire then
        local part = self.em:Add("sprites/flamelet" .. math.random(1, 5), self.ent:GetPos() + self.ent:OBBCenter())
        part:SetVelocity(VectorRand() * 10)
        part:SetDieTime(1)
        part:SetStartSize(64)
        part:SetEndSize(0)
        part:SetStartAlpha(255)
        part:SetEndAlpha(0)
        part:SetRoll(math.Rand(-2, 2))
        part:SetRollDelta(math.Rand(-2, 2))
        self.NextFire = CurTime() + 0.04
      end

      for i = 1, 2 do
        local part = self.em:Add("particle/particle_smokegrenade", self.ent:GetPos() + self.ent:OBBCenter())
        part:SetVelocity(VectorRand() * 4)
        local r = math.floor(math.Rand(150, 255))
        part:SetColor(Color(r, r, r, 255))
        part:SetDieTime(math.Rand(4.8, 5.2))
        part:SetStartAlpha(255)
        part:SetEndAlpha(0)
        part:SetStartSize(0)
        part:SetEndSize(96)
        part:SetRoll(math.Rand(-2, 2))
        part:SetRollDelta(math.Rand(-2, 2))
        part:SetGravity(Vector(0, 0, -8) + VectorRand() * 8)
      end

      return true
    else
      return false
    end
  end

  function EFFECT:Render()
    return true
  end

  effects.Register(EFFECT, "zero_proj_firetrail")
end