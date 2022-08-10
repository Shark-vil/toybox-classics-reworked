AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Air Strike"
ENT.Spawnable = true
ENT.Category = "Toybox Classics"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if CLIENT then
  --Explosion effects
  local EFFECT = {}

  function EFFECT:Init(data)
    local start = data:GetOrigin()
    local em = ParticleEmitter(start)

    for i = 1, 256 do
      local part = em:Add("particle/particle_noisesphere", start) --Shockwave

      if part then
        part:SetColor(255, 255, 195, 255)
        part:SetVelocity(Vector(math.random(-10, 10), math.random(-10, 10), 0):GetNormal() * math.random(1500, 2000))
        part:SetDieTime(math.random(2, 3))
        part:SetLifeTime(math.random(0.3, 0.5))
        part:SetStartSize(60)
        part:SetEndSize(60)
        part:SetAirResistance(140)
        part:SetRollDelta(math.random(-2, 2))
      end

      local part1 = em:Add("effects/fire_cloud1", start) --Fire cloud

      if part1 then
        part1:SetColor(255, 255, 255, 255)
        part1:SetVelocity(Vector(math.random(-10, 10), math.random(-10, 10), math.random(5, 20)):GetNormal() * math.random(100, 2000))
        part1:SetDieTime(math.random(2, 3))
        part1:SetLifeTime(math.random(0.3, 0.5))
        part1:SetStartSize(80)
        part1:SetEndSize(50)
        part1:SetAirResistance(200)
        part1:SetRollDelta(math.random(-2, 2))
      end
    end

    em:Finish()
  end

  function EFFECT:Think()
  end

  function EFFECT:Render()
  end

  effects.Register(EFFECT, "poof")
end

function ENT:Initialize()
  if SERVER then
    self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
    self:PhysicsInitSphere(16, "metal_bouncy")
    self:SetCollisionBounds(Vector(-16, -16, -16), Vector(16, 16, 16))
  end
end

--Spawns the entity
function ENT:SpawnFunction(ply, tr, classname)
  if not tr.Hit then return end
  local SpawnPos = tr.HitPos + tr.HitNormal * 3000
  local ent = ents.Create(ClassName)
  ent:SetPos(SpawnPos)
  ent:Spawn()
  ent:Activate()
  local phys = ent:GetPhysicsObject()

  if IsValid(phys) then
    phys:Wake()
  end

  return ent
end

function ENT:PhysicsCollide(data, physobj)
  local d = EffectData()
  d:SetOrigin(self:GetPos())

  if math.random(1, 2) == 1 then
    sound.Play("ambient/explosions/explode_4.wav", self:GetPos(), 100, 100) --The explosion sound
  else
    sound.Play("ambient/explosions/explode_5.wav", self:GetPos(), 100, 100) --The explosion sound
  end

  util.Effect("poof", d) --Explosion effect
  util.BlastDamage(self, self or self:GetOwner(), self:GetPos(), 1024, 500) --Blast damage and radius
  self:Remove()
end