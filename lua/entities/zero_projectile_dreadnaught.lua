AddCSLuaFile()
local ENT = {}
ENT.Type = "anim"

function ENT:Initialize()
  self:SetModel("models/maxofs2d/button_05.mdl")
  self:SetNoDraw(true)
  self:PhysicsInitSphere(45)

  if IsValid(self) then
    local ED = EffectData()
    ED:SetEntity(self)
    util.Effect("zero_proj_firetrail", ED)
  end

  self.spawntime = CurTime()
  self.NextBoom = CurTime() + 1.2
end

function ENT:Think()
  if isnumber(self.NextBoom) and CurTime() < self.NextBoom and SERVER then
    self:EmitSound("weapons/explode" .. math.random(3, 5) .. ".wav", 80, 100)
    self.NextBoom = CurTime() + math.Rand(0.9, 1)
  end
end

function ENT:PhysicsCollide(data, physobj)
  if IsValid(self) then
    util.BlastDamage(self, self:GetOwner(), self:GetPos() + self:OBBCenter(), 875, 250)
    local ED = EffectData()
    ED:SetOrigin(self:GetPos() + self:OBBCenter())
    ED:SetNormal(data.HitNormal)
    util.Effect("zero_proj_megaboom", ED)
    self:EmitSound("ambient/explosions/explode_" .. math.random(1, 5) .. ".wav", 100, 100)
    self:Remove()
  end
end

function ENT:PhysicsUpdate(physobj)
  physobj:AddVelocity(Vector(0, 0, -4))
end

--thanks to microosoft for the simulated gravity idea
scripted_ents.Register(ENT, "zero_projectile_dreadnaut", true)