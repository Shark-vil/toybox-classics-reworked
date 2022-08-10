AddCSLuaFile()
local NAIL = {}
NAIL.Type = "anim"
NAIL.Base = "base_anim"

if SERVER then
  function NAIL:Initialize()
    self:SetModel("models/weapons/w_models/w_nail.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_CUSTOM)
    self:SetHealth(1)
    self:PhysicsInitSphere(0.1)
    self:SetMoveCollide(3)
    local phys = self.Entity:GetPhysicsObject()

    if phys:IsValid() then
      phys:Wake()
      phys:SetMass(0.1)
      phys:EnableDrag(false)
      phys:SetBuoyancyRatio(0.1)
    end
  end

  function NAIL:PhysicsSimulate(phys, deltatime)
    return angle_zero, vector_origin, SIM_LOCAL_ACCELERATION
  end

  function NAIL:PhysicsCollide(data, physobj)
    if not self.Hit then
      if data.HitEntity == self:GetOwner() then return end

      if data.HitEntity:GetClass() == "scout_nail" then
        self:Remove()

        return
      end

      self:EmitSound("nailimpact.wav")
      self.Hit = true

      if data.HitEntity:GetClass() ~= "worldspawn" then
        self:SetPos(data.HitPos)
        data.HitEntity:TakeDamage(math.random(10, 30))
        self:SetParent(data.HitEntity)
      else
        timer.Simple(0, function()
          if not IsValid(self) then return end
          self:SetMoveType(MOVETYPE_NOCLIP)
          self:SetPos(self:GetPos() - self:GetAngles():Forward() * 10)
        end)
      end

      if data.HitEntity:IsNPC() or data.HitEntity:IsPlayer() then
        timer.Simple(.2, function()
          if IsValid(self) and data and data.HitEntity:Health() <= 0 then
            self:Remove()
          end
        end)
      end

      timer.Simple(20, function()
        if IsValid(self) then
          self:Remove()
        end
      end)
    end
  end
end

scripted_ents.Register(NAIL, "scout_nail", true)