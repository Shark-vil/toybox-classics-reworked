AddCSLuaFile()
local ENT = {}
ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:Explosion()
  if not IsValid(self) then return end
  if not SERVER then return end
  self:EmitSound("npc/dog/dog_drop_gate1.wav")
  self:EmitSound("ambient/explosions/explode_8.wav")
  self:Discharge()

  timer.Simple(0.1, function()
    if IsValid(self) then
      self:Remove()
    end
  end)
end

function ENT:Discharge()
  if not SERVER then return end
  if not IsValid(self) then return end
  self:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 200, 100)
  self:EmitSound("ambient/fire/gascan_ignite1.wav", 200, 100)
  self:EmitSound("weapons/physcannon/superphys_small_zap" .. math.random(1, 4) .. ".wav", 200, math.random(95, 105))
  tes = ents.Create("point_tesla")
  tes:SetPos(self.Entity:GetPos())
  tes:SetKeyValue("m_SoundName", "")
  tes:SetKeyValue("texture", "sprites/bluelight1.spr")
  tes:SetKeyValue("m_Color", "255 255 255")
  tes:SetKeyValue("m_flRadius", "150")
  tes:SetKeyValue("beamcount_min", "12")
  tes:SetKeyValue("beamcount_max", "12")
  tes:SetKeyValue("thick_min", "25")
  tes:SetKeyValue("thick_max", "50")
  tes:SetKeyValue("lifetime_min", "0.15")
  tes:SetKeyValue("lifetime_max", "0.25")
  tes:SetKeyValue("interval_min", "0.3")
  tes:SetKeyValue("interval_max", "0.5")
  tes:Spawn()
  tes:Fire("DoSpark", "", 0)
  tes:Fire("DoSpark", "", 0.1)
  tes:Fire("DoSpark", "", 0.2)
  tes:Fire("kill", "", 0.5)
  local dmg = DamageInfo()
  dmg:SetDamageType(DMG_DISSOLVE)
  dmg:SetDamage(40)
  dmg:SetDamagePosition(self:LocalToWorld(self:OBBCenter()))
  dmg:SetDamageForce(VectorRand() * 512)
  dmg:SetAttacker(self:GetOwner())
  dmg:SetInflictor(self)

  for k, v in ipairs(ents.FindInSphere(self:GetPos(), 120)) do
    v:TakeDamageInfo(dmg)
  end

  local boom = ents.Create("env_explosion")
  boom:SetOwner(self:GetOwner())
  boom:SetPos(self:GetPos())
  boom:SetKeyValue("iMagnitude", "80")
  boom:Spawn()
  boom:Activate()
  boom:Fire("Explode", "", 0)
  local particle = EffectData()
  particle:SetOrigin(self:GetPos())
  util.Effect("electrocannon_missileburst", particle)

  timer.Simple(0.2, function()
    if IsValid(self) then
      self:Discharge()
    end
  end)
end

function ENT:Initialize()
  if SERVER then
    self.Entity:SetModel("models/weapons/w_missile_closed.mdl")
    self.Entity:PhysicsInitSphere(2, "metal")
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    local phys = self.Entity:GetPhysicsObject()

    if phys:IsValid() and self:GetClass() == "electromissile" then
      phys:EnableGravity(false)
      phys:EnableDrag(false)
      phys:Wake()
      local trail = EffectData()
      trail:SetEntity(self)
      util.Effect("electrocannon_missiletrail", trail)
    end

    self.Entity:SetModel("models/weapons/w_missile.mdl")
  end

  timer.Simple(0.4, function()
    if IsValid(self) then
      self:Discharge()
    end
  end)

  timer.Simple(10, function()
    if IsValid(self) then
      self:Explosion()
    end
  end)
end

function ENT:Think()
end

function ENT:PhysicsCollide(data, physobj)
  self:Explosion()
end

function ENT:Draw()
  self:DrawModel()
end

scripted_ents.Register(ENT, "electromissile")