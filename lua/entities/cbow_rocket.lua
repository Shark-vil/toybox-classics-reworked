AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
game.AddParticles("particles/grenade_fx.PCF")
PrecacheParticleSystem("grenade_explosion_01")

function ENT:Initialize()
  self.Sound = CreateSound(self, "Missile.Accelerate")
  self.Sound:Play()

  if SERVER then
    self:SetModel("models/Weapons/W_missile_closed.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysWake()
    self:SetModel("models/Weapons/W_missile.mdl") --lol
  end

  self:SetModelScale(1.5)
end

function ENT:Explode(data)
  self.Sound:Stop()
  self:EmitSound("BaseExplosionEffect.Sound")
  util.BlastDamage((IsValid(self.Inflictor) and self.Inflictor) or self, self.Attacker or self, self:GetPos(), 180, 140)
  ParticleEffect("grenade_explosion_01", self:GetPos(), data.HitNormal:Angle(), nil)
  util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
  net.Start("ToyBoxReworked_ExplodeDynamicLight")
  net.WriteFloat(self:EntIndex())
  net.WriteVector(self:GetPos())
  net.Broadcast()
  util.ScreenShake(self:GetPos(), 20, 5, 1, 300)
  self:Remove()
end

function ENT:PhysicsCollide(data)
  self:Explode(data)
end

function ENT:Draw()
  self:DrawModel()
end

scripted_ents.Register(ENT, "cbow_rocket", true)