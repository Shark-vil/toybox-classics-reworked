AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Nitroglycerine"
ENT.Author = "krassell"
ENT.Spawnable = true
ENT.Category = "Toybox Classics"
ENT.RenderGroup = RENDERGROUP_OPAQUE

if CLIENT then
  language.Add("nitroglycerine", "Nitroglycerine")
end

if SERVER then
  function ENT:Initialize()
    self:PhysicsInitBox(Vector(-4, -8, -4), Vector(4, 8, 4))
    self:SetCollisionBounds(Vector(-4, -8, -4), Vector(4, 8, 4))
    self:DrawShadow(false)
    self.Xploded = false
    self:SetModel("models/props_lab/labpart.mdl")
    self:SetUseType(SIMPLE_USE)
    local parphys = self:GetPhysicsObject()

    if parphys:IsValid() then
      parphys:Wake()
      parphys:EnableMotion(true)
    end
  end

  function ENT:OnTakeDamage(dmg)
    self:TakePhysicsDamage(dmg)

    if (dmg:GetDamage() > 1) and not self.Xploded then
      self.Entity:Explode()
    end
  end

  function ENT:Explode()
    self.Xploded = true
    local fx = EffectData()
    fx:SetOrigin(self:GetPos())
    sound.Play("ambient/explosions/explode_4.wav", self.Entity:GetPos(), math.random(50, 100), 100) --The explosion sound
    util.ScreenShake(self:GetPos(), 5, 5, 3, 8192)
    util.Effect("NG_Bang", fx) --Explosion effect
    util.BlastDamage(self.Entity, self.Entity or self:GetOwner(), self.Entity:GetPos(), 1024, 500) -- A BOOM MOTHAFOCKA
    self.Entity:Remove()
  end

  function ENT:PhysicsCollide(data, physobj)
    if data.Speed > 250 and not self.Xploded then
      self.Entity:Explode()
    end
  end
end

if CLIENT then
  RENDELAY = 1

  function ENT:Initialize()
    if ClassName then
      language.Add(ClassName, "NitroGlycerine")
    end
  end

  function ENT:Think()
  end

  function ENT:Draw()
    self:DrawModel()
  end

  --Explosion effects
  local EFFECT = {}

  function EFFECT:Init(data)
    self.size = 10
    self.refract = 1
    self.timing = CurTime() + RENDELAY
    self.start = data:GetOrigin()
    local start = data:GetOrigin()
    local emi = ParticleEmitter(start)

    for t = 1, 2 do
      local rv = VectorRand()
      local av = rv:Angle()

      for i = 1, 180 do
        --shockwave rings
        av:RotateAroundAxis(av:Up(), 2)
        local particle = emi:Add("particles/flamelet" .. math.random(1, 5), start)
        particle:SetVelocity(av:Forward() * math.random(200, 300))
        particle:SetDieTime(5)
        particle:SetStartAlpha(math.Rand(230, 250))
        particle:SetStartSize(2 * math.Rand(64, 128))
        particle:SetEndSize(math.Rand(5, 2))
        particle:SetColor(math.random(100, 255), math.random(100, 150), 50)
      end
    end

    --now those thorns
    local rw = VectorRand()

    for t = 1, math.random(9, 15) do
      local rv = VectorRand()

      for i = 1, 20 do
        local particle2 = emi:Add("particle/particle_noisesphere", start - rv * i * 50)
        particle2:SetVelocity(rw * math.Rand(50, 105))
        particle2:SetDieTime(5)
        particle2:SetStartAlpha(math.Rand(230, 250))
        particle2:SetEndAlpha(0)
        particle2:SetStartSize((21 - i) * 2 * math.Rand(10, 15))
        particle2:SetEndSize((21 - i) * math.Rand(10, 15))
        particle2:SetRoll(math.Rand(20, 80))
        particle2:SetRollDelta(math.random(-1, 1))
        particle2:SetColor(80, 80, 80)
      end
    end

    emi:Finish()
  end

  function EFFECT:Think()
    if CurTime() < self.timing then
      return true
    else
      return false
    end
  end

  function EFFECT:Render()
    self.size = 8192 * ((RENDELAY - (self.timing - CurTime())) / RENDELAY)
    self.refract = 1 - ((RENDELAY - (self.timing - CurTime())) / RENDELAY)
    refring = Material("refract_ring")
    refring:SetFloat("$refractamount", self.refract)
    render.SetMaterial(refring)
    render.UpdateRefractTexture()
    render.DrawSprite(self.start, self.size, self.size)
  end

  effects.Register(EFFECT, "NG_Bang")
end