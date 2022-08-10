AddCSLuaFile()
local ENT = {}
ENT.Type = "anim"

function ENT:Draw()
  return false
end

function ENT:Initialize()
  local ent = self.Entity
  -- Note that we need a physics object to make it call triggers
  ent:DrawShadow(false)
  ent:SetCollisionBounds(Vector(-20, -20, -10), Vector(20, 20, 10))
  ent:PhysicsInitBox(Vector(-20, -20, -10), Vector(20, 20, 10))
  local phys = ent:GetPhysicsObject()

  if phys:IsValid() then
    phys:EnableCollisions(false)
  end

  ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
  ent:SetNotSolid(true)
  ent:DrawShadow(false)
  --remove this ent after a few minutes
end

function ENT:StartFire()
  local ent = self.Entity
  local fire = ents.Create("env_fire")
  fire:SetKeyValue("StartDisabled", "0")
  fire:SetKeyValue("health", math.random(5, 10))
  fire:SetKeyValue("firesize", math.random(40, 60))
  fire:SetKeyValue("fireattack", "1")
  fire:SetKeyValue("ignitionpoint", "0.3")
  fire:SetKeyValue("damagescale", "35")
  fire:SetKeyValue("spawnflags", 2 + 128)
  fire:SetPos(ent:GetPos())
  fire:SetOwner(ent:GetOwner())
  fire:Spawn()
  fire:Fire("Enable", "", "0")
  fire:DeleteOnRemove(ent)
  fire:Fire("StartFire", "", "0")
  fire:SetName("BurningFire")
  self.Entity:Remove()
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmginfo)
  self:StartFire()
end

scripted_ents.Register(ENT, "fire_controller", true)