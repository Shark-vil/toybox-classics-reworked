AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "Toybox Classics"
ENT.Spawnable = true
ENT.PrintName = "Ratchet Rift Inducer"
ENT.Model = Model("models/Combine_Helicopter/helicopter_bomb01.mdl")
ENT.Sound = Sound("nostalgia/ratchet/rift_loop.wav")
ENT.DieSound = Sound("nostalgia/ratchet/rift_close.wav")
ENT.EatSound = Sound("nostalgia/ratchet/rift_eat.wav")

if SERVER then
  function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create(ClassName)
    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()
    ent:SetOwner(ply)
    --Later used for filtering out suction
    ent.IsRiftInducer = true

    return ent
  end

  function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_NONE)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
      phys:EnableMotion(false)
    end

    self.PullForce = 60
    self.Scale = 1
    self.RemoveDelay = CurTime() + 6
    --Dont want it going through the ceiling
    local pos = self:GetPos()
    local tracedata = {}
    tracedata.start = pos
    tracedata.endpos = pos + Vector(0, 0, 100)
    local trace = util.TraceLine(tracedata)

    if trace.HitWorld then
      local dist = trace.StartPos:Distance(trace.HitPos)
      self:SetPos(pos + Vector(0, 0, dist - 5)) --A bit extra to give it space from the ceiling
    else
      self:SetPos(pos + Vector(0, 0, 100))
    end
  end

  function ENT:Think()
    if self.RemoveDelay < CurTime() and not self.IsDead then
      self:AlterScale(self.Scale - .5)

      if self.Scale < 1 then
        self:RiftDie()

        return
      end

      self.RemoveDelay = CurTime() + 4
    end

    local pos = self:GetPos()

    for _, ent in ipairs(ents.GetAll()) do
      if IsValid(ent) and ent ~= self:GetOwner() and ent ~= self:GetOwner():GetActiveWeapon() and not ent.IsRiftInducer then
        local entpos = ent:GetPos()
        local dist = pos:Distance(entpos)

        if dist < 512 then
          local physobj = ent:GetPhysicsObject()

          if IsValid(physobj) then
            local angle = entpos - pos
            local vect = angle:GetNormalized() * ((dist / 1.25) * self.PullForce) * -1
            physobj:ApplyForceCenter(vect)

            if dist < 200 then
              if dist <= (35 * math.Clamp(self.Scale * .5, 1, 3)) then
                if not ent:IsPlayer() then
                  self:Sucked(ent) --hohoho like voided
                end
              end

              --Need to disable gravity, or else an extremely high (and unrealistic) pull force is needed
              if ent:GetClass() == "prop_ragdoll" then
                local bones = ent:GetPhysicsObjectCount()

                for i = 0, bones - 1 do
                  ent:GetPhysicsObjectNum(i):EnableGravity(false)
                end
              else
                physobj:EnableGravity(false)
              end
            else
              if ent:GetClass() == "prop_ragdoll" then
                local bones = ent:GetPhysicsObjectCount()

                for i = 0, bones - 1 do
                  ent:GetPhysicsObjectNum(i):EnableGravity(true)
                end
              else
                physobj:EnableGravity(true)
              end
            end
          end

          if ent:IsNPC() or ent:IsPlayer() then
            ent:TakeDamage(5, self:GetOwner())
          end
        end
      end
    end
  end

  function ENT:Sucked(ent)
    --More it eats, bigger it gets!
    local phys = ent:GetPhysicsObject()
    local mass = phys:GetMass()
    self:EmitSound(self.EatSound, 100, math.Rand(70, 130)) --poot
    local addmass = math.Clamp(mass / 100, 0.01, 1)
    self:AlterScale(self.Scale + addmass)
    local effect = EffectData()
    effect:SetRadius(ent:OBBMaxs():Distance(vector_origin) / 2)
    effect:SetEntity(self)
    effect:SetOrigin(ent:GetPos() + ent:OBBCenter())
    effect:SetScale(mass)
    util.Effect("rift_eat", effect, nil, true)
    ent:Remove()
  end

  function ENT:AlterScale(scale)
    self.Scale = math.Clamp(scale, 0, 8)
    self.PullForce = math.Clamp(scale * 100, 60, 1200)
    net.Start("ToyBoxReworked_RiftScale")
    net.WriteEntity(self)
    net.WriteFloat(scale)
    net.Broadcast()
  end

  function ENT:RiftDie()
    self.IsDead = true
    net.Start("ToyBoxReworked_RiftDie")
    net.WriteEntity(self)
    net.Broadcast()

    timer.Simple(.2, function()
      if IsValid(self) then
        self:Remove()
      end
    end)
  end

  function ENT:OnRemove()
    self:EmitSound(self.DieSound)

    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 512)) do
      local physobj = ent:GetPhysicsObject()

      if IsValid(physobj) and not physobj:IsGravityEnabled() and not ent.IsRiftInducer then
        if ent:GetClass() == "prop_ragdoll" then
          local bones = ent:GetPhysicsObjectCount()

          for i = 0, bones - 1 do
            ent:GetPhysicsObjectNum(i):EnableGravity(true)
          end
        else
          physobj:EnableGravity(true)
        end
      end
    end
  end
else --CLIENT
  ENT.RenderGroup = RENDERGROUP_OPAQUE
  ENT.Sprite = Material("effects/blueflare1")
  ENT.Refraction = Material("refract_ring")

  function ENT:Initialize()
    self:CreateEmitter()
    self.Scale = 1
    self.SoundLoop = CreateSound(self, self.Sound)
    self.SoundLoop:Play()
  end

  function ENT:Draw()
    if self.NewScale and self.NewScale ~= self.Scale then
      local multi = self.Scale / 3

      if self.IsDead then
        multi = self.Scale * 6
      end

      self.Scale = math.Approach(self.Scale, self.NewScale, FrameTime() * multi)
    end

    render.SetMaterial(self.Sprite)
    render.DrawSprite(self:GetPos(), 25, 25, Color(140, 0, 255, 255))
    --Light-bendy effect
    local Distance = EyePos():Distance(self:GetPos())
    local Pos = self:GetPos() --+ (EyePos() - self:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8
    local Scale = self.Scale * 80
    self.Refraction:SetFloat("$refractamount", math.sin(400 * math.pi) * 0.5 + 0.5)
    render.SetMaterial(self.Refraction)
    render.UpdateRefractTexture()
    render.DrawSprite(Pos, Scale, Scale)
  end

  function ENT:Think()
    if self.IsDead then return end
    --Subtle floating effect
    local OldPos = self:GetPos()
    self:SetPos(OldPos + self:GetAngles():Up() * math.sin(RealTime() * 3) * .2)

    --Reduce model scale as it gets closer to wormhole
    for _, ent in ipairs(ents.GetAll()) do
      if IsValid(ent) and not ent:IsPlayer() and not ent:IsWeapon() and ent:GetClass() ~= "env_sprite" then
        local dist = self:GetPos():Distance(ent:GetPos())

        if dist <= 300 then
          local calcscale = dist / 150
          local scale = math.Clamp(calcscale, 0.01, 1) --Clamp scale
          ent:SetModelScale(scale, 0)
        else
          ent:SetModelScale(1, 0)
        end
      end
    end

    if not self.NextParticle or CurTime() > self.NextParticle then
      local pos = self:GetPos()
      local sprpos = self:GetPos() + (VectorRand() * (self.Scale * 100))
      local angle = sprpos - pos
      local dist = pos:Distance(sprpos)
      local vect = angle:GetNormalized() * ((dist / 1.25) * -1)

      for i = 0, 16 do
        local particle = self.Emitter:Add("sprites/powerup_effects", sprpos)

        if particle then
          particle:SetVelocity(vect)
          particle:SetDieTime(1.25)
          particle:SetStartAlpha(0)
          particle:SetEndAlpha(255)
          particle:SetStartSize(10)
          particle:SetEndSize(0)
          particle:SetRoll(math.Rand(0, 360))
          particle:SetRollDelta(math.Rand(-5.5, 5.5))
          particle:SetColor(math.random(50, 255), 0, 255)
        end
      end

      self.NextParticle = CurTime() + 0.06
    end

    local dlight = DynamicLight(self:EntIndex())

    if dlight then
      dlight.Pos = self:GetPos()
      dlight.r = 115
      dlight.g = 0
      dlight.b = 255
      dlight.Brightness = self.Scale / 1.5
      dlight.Size = self.Scale * 10 + 190
      dlight.Decay = 128 * 2
      dlight.DieTime = CurTime() + 0.5
    end
  end

  function ENT:CreateEmitter()
    if self.Emitter then return end --we already have one!
    self.Emitter = ParticleEmitter(self:GetPos())
  end

  function ENT:RemoveEmitter()
    if not self.Emitter then return end --we dont have an emitter!
    self.Emitter:Finish()
    self.Emitter = nil
  end

  function ENT:OnRemove()
    self:RemoveEmitter()

    if self.SoundLoop then
      self.SoundLoop:Stop()
    end

    --Fix Model Scale
    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 512)) do
      if IsValid(ent) then
        ent:SetModelScale(1, 0)
      end
    end
  end

  net.Receive("ToyBoxReworked_RiftScale", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent.IsDead then return end
    ent.NewScale = net.ReadFloat()
  end)

  net.Receive("ToyBoxReworked_RiftDie", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent.IsDead = true
    ent.NewScale = 0
  end)

  -- Big thanks to the dude behind the Scav Jr.
  local EFFECT = {}

  local function RiftParticlesThink(particle)
    if not IsValid(particle.Owner) or not particle then return false end
    local newpos = LerpVector(math.sqrt(particle.LifeTime - CurTime()), particle.Owner:GetPos(), particle.StartPos + particle.Velocity * (CurTime() - particle.StartTime))
    particle:SetPos(newpos)
    particle:SetNextThink(CurTime() + 0.1)
  end

  function EFFECT:Init(data)
    local emitter = ParticleEmitter(self:GetPos())
    local particle = emitter:Add("effects/yellowflare", self:GetPos())

    if particle then
      particle:SetColor(255, 255, 255)
      particle:SetRoll(math.Rand(0, 6.28))
      particle:SetRollDelta(math.Rand(0, 12))
      particle:SetDieTime(1)
      particle:SetStartSize(data:GetRadius() * 2)
      particle:SetEndSize(2)
      particle:SetStartAlpha(255)
      particle:SetEndAlpha(128)
      particle.Owner = data:GetEntity()
    end

    --emitter:Finish()
    local partmass = math.Clamp(data:GetScale(), 4, 150)

    for i = 1, partmass do
      if IsValid(emitter) then
        local particle = emitter:Add("effects/yellowflare", self:GetPos() + data:GetRadius() * VectorRand())

        if particle then
          particle:SetColor(255, 150, 255)
          local offset = math.Rand(0, 1)
          particle.Velocity = VectorRand() * 32
          particle.LifeTime = CurTime() + offset + 1
          particle.StartTime = CurTime() + offset
          particle.StartPos = particle:GetPos()
          particle.Owner = data:GetEntity()
          particle:SetDieTime(offset + 1)
          particle:SetRoll(math.Rand(0, 6.28))
          particle:SetRollDelta(math.Rand(0, 12))
          particle:SetStartSize(data:GetRadius() / 2)
          particle:SetEndSize(2)
          particle:SetStartAlpha(255)
          particle:SetEndAlpha(20)
          particle:SetThinkFunction(RiftParticlesThink)
          particle:SetNextThink(CurTime() + 0.1)
        end
      end
    end

    if IsValid(emitter) then
      emitter:Finish()
    end
  end

  function EFFECT:Think()
    return false
  end

  function EFFECT:Render()
  end

  effects.Register(EFFECT, "rift_eat")
end