AddCSLuaFile()
local M = {}
M.Type = "anim"

function M:Initialize()
  if CLIENT then
    local mat = Matrix()
    mat:Scale(Vector(0.5, 1.3, 1.2))
    self:EnableMatrix("RenderMultiply", mat)
  else
    self:SetModel(Model("models/weapons/W_missile_closed.mdl"))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_FLY)
    self:SetSolid(SOLID_VPHYSICS)

    function self:Explode(self)
      local entities = ents.FindInSphere(self:GetPos(), 250)

      for _, ent in ipairs(entities) do
        if constraint.HasConstraints(ent) then
          constraint.RemoveAll(ent)
        end

        ent:SetUnFreezable(false)

        if ent:GetPhysicsObject():IsValid() then
          local phys = ent:GetPhysicsObject()
          phys:EnableMotion(true)
          phys:ApplyForceOffset(10 * phys:GetMass() * (Vector(0, 0, 7) + (ent:GetPos() - self:GetPos()):GetNormalized() * 100), self:GetPos())
        end
      end

      self:Remove()
    end
  end
end

if SERVER then
  function M:Think()
    if self:GetNWInt("activ") < CurTime() then
      if self:GetNWInt("det") < CurTime() then
        self:Explode(self)
      end

      local ent = self:GetNWEntity("target")

      if not ent:IsValid() then
        self:SetVelocity(Vector(0, 0, -220))

        return
      end

      if (ent:LocalToWorld(ent:OBBCenter()) - self:GetPos()):Length() < 70 then
        self:Explode(self)

        return
      end

      self:SetVelocity((ent:LocalToWorld(ent:OBBCenter()) + ent:GetVelocity() * 0.1 - self:GetVelocity() * (0.2 * (self:GetVelocity():Length() / 820)) - self:GetPos()):GetNormalized() * 38000 * FrameTime())
      self:SetAngles((ent:LocalToWorld(ent:OBBCenter()) + ent:GetVelocity() * 0.1 - self:GetVelocity() * (0.2 * (self:GetVelocity():Length() / 820)) - self:GetPos()):Angle())
    end
  end

  function M:StartTouch(ent)
    self:Explode(self)
  end
end

if CLIENT then
  function M:Think()
    if math.random() > 0.2 then
      local vPoint = self:GetPos()
      local effectdata = EffectData()
      effectdata:SetStart(vPoint)
      effectdata:SetOrigin(vPoint)
      effectdata:SetNormal(self:GetVelocity():GetNormalized())
      effectdata:SetScale(1)
      effectdata:SetMagnitude(1)
      effectdata:SetRadius(10)
      util.Effect("WheelDust", effectdata)
    end
  end
end

function M:OnRemove()
  local effectdata = EffectData()
  effectdata:SetOrigin(self:GetPos())
  effectdata:SetScale(15)
  effectdata:SetMagnitude(17)
  effectdata:SetRadius(200)
  util.Effect("HelicopterMegaBomb", effectdata, true, true)
  self:EmitSound(Sound("ambient/explosions/explode_3.wav"))
  --print (self:GetOwner())
  --print (self)
  util.BlastDamage(self, self:GetOwner(), self:GetPos(), 240, 250)
end

scripted_ents.Register(M, "sent_hmissile", true)