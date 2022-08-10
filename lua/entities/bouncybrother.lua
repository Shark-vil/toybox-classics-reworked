AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"
ENT.PrintName = "Bouncy Brother"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
  if SERVER then
    self.Entity:SetModel("models/gman_high.mdl")
    self.Entity:PhysicsInitSphere(22, "metal_bouncy")
    self.Entity:SetCollisionBounds(Vector(-16, -16, -10), Vector(16, 16, 16))
  end
end

function ENT:SpawnFunction(ply, tr)
  if not tr.Hit then return end
  local SpawnPos = tr.HitPos + tr.HitNormal * 16
  local ent = ents.Create(ClassName)
  ent:SetPos(SpawnPos)
  ent:Spawn()
  ent:Activate()

  return ent
end

-- Copy here and paste! You cheeky monkey!
function ENT:PhysicsCollide(data, physobj)
  if data.Speed > 80 and data.DeltaTime > 0.2 then
    local boom = ents.Create("env_explosion")
    boom:SetPos(self:GetPos())
    boom:SetKeyValue("iMagnitude", 100)
    boom:SetKeyValue("iRadiusOverride", 120)
    boom:Spawn()
    boom:Fire("explode")
  end
end
-- And its that simple!