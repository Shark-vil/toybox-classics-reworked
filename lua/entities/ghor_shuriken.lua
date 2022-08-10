AddCSLuaFile()
local ENT = {} --shurikens that STICK TO BONES!
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
  self:SetModel("models/scav/shuriken.mdl")

  if SERVER then
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
  end
end

function ENT:PhysicsUpdate()
  if self.Stuck and (self.dt.StickEntity ~= NULL) then
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
  end
end

function ENT:Think()
  local ent = self.dt.StickEntity

  if SERVER and self.Welded and not IsValid(self.Weld) then
    self.Welded = false
    self:Fire("Kill", nil, 5)

    return
  end

  if (ent ~= nil) and (ent ~= NULL) then
    if self.dt.StickEntity:IsWorld() then
      self:SetPos(self.dt.StickPos)
      self:SetAngles(self.dt.StickAngle)

      return
    end

    if SERVER then
      self.laststuckentity = self.dt.StickEntity

      if (ent:IsNPC() and (ent:Health() <= 0)) or (ent:IsPlayer() and not ent:Alive()) then
        self:SetParent()
        self.dt.StickEntity = NULL
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:GetPhysicsObject():SetVelocity(ent:GetVelocity())
        self:Fire("Kill", nil, 30)

        return
      end

      if ent ~= self:GetParent() and ent:GetClass() ~= "func_tracktrain" then
        self:SetParent(ent)
      end
      --local bone = self.dt.StickBone
      --local bonepos,boneang = ent:GetBonePosition(bone)
      --local pos,ang = LocalToWorld(self.dt.StickPos,self.dt.StickAngle,bonepos,boneang)
      -- self:SetPos(pos)
      -- self:SetAngles(ang)
    end
  elseif (self:GetMoveType() == MOVETYPE_NONE) and SERVER then
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:GetPhysicsObject():EnableGravity(true)
    self:GetPhysicsObject():Wake()
  end
end

function ENT:SetupDataTables()
  self:DTVar("Entity", 0, "StickEntity")
  self:DTVar("Int", 0, "StickBone")
  self:DTVar("Vector", 0, "StickPos")
  self:DTVar("Angle", 0, "StickAngle")
  self.dt.StickEntity = NULL
end

local bonetrace = {}
bonetrace.mask = MASK_SHOT
bonetrace.mins = Vector(-1, -1, -1)
bonetrace.maxs = Vector(1, 1, 1)

local function ragdollweld(self, ragdoll, hitbone, localpos, localang)
  if IsValid(self) and IsValid(ragdoll) then
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local myphys = self:GetPhysicsObject()
    myphys:EnableGravity(true)
    local phys = ragdoll:GetPhysicsObjectNum(hitbone)
    local ragdollbonepos = phys:GetPos()
    local ragdollboneang = phys:GetAngles()
    local pos, ang = LocalToWorld(localpos, localang, ragdollbonepos, ragdollboneang)
    self:SetPos(pos)
    self:SetAngles(ang)
    self.Welded = true
    self.Weld = constraint.Weld(self, ragdoll, 0, hitbone, 0, true)
  end
end

local function transfertoragdoll(self, ragdoll)
  self:SetParent()
  self.dt.StickEntity = NULL
  ragdollweld(self, ragdoll, ragdoll:TranslateBoneToPhysBone(self.dt.StickBone), self.dt.StickPos, self.dt.StickAngle)
end

hook.Add("CreateEntityRagdoll", "TransferShurikens", function(ent, rag)
  for k, v in ipairs(ents.FindByClass("ghor_shuriken")) do
    if v.laststuckentity == ent then
      transfertoragdoll(v, rag)
    end
  end
end)

function ENT:PhysicsCollide(data, phys)
  local class = data.HitEntity:GetClass()
  if not IsValid(self) or self.Stuck or (class == "npc_antlion_grub") then return end
  local brush = string.find(data.HitEntity:GetModel(), "*", 0, true)
  bonetrace.start = self:GetPos()
  bonetrace.endpos = bonetrace.start + data.OurOldVelocity:GetNormalized() * 100

  bonetrace.filter = {self, self:GetOwner()}

  local tr = util.TraceLine(bonetrace)

  if data.HitEntity:IsWorld() then
    self.dt.StickEntity = data.HitEntity
    self.dt.StickBone = 0
    self.dt.StickPos = data.HitPos - data.OurOldVelocity:GetNormalized()
    self.dt.StickAngle = self:GetAngles()
    self:Fire("Kill", nil, 120)
    self.Stuck = true
    self:ImpactEffect(tr)

    return
  end

  local getbonecenter = false

  if not brush and (tr.Entity ~= data.HitEntity) then
    tr = util.TraceHull(bonetrace)

    if tr.Entity == data.HitEntity then
      local hitbox = tr.HitBox
      local bone = tr.Entity:GetHitBoxBone(hitbox, 0)
      local pos, ang = tr.Entity:GetBonePosition(bone)
      bonetrace.endpos = pos
      tr = util.TraceLine(bonetrace)
    end
  end

  if tr.Entity ~= data.HitEntity then
    bonetrace.endpos = data.HitEntity:GetPos() + data.HitEntity:OBBCenter()
    tr = util.TraceLine(bonetrace)
  end

  local ent = tr.Entity

  if ent == data.HitEntity then
    if ent:GetClass() == "prop_ragdoll" then
      local hitbox = tr.HitBox
      local bone = ent:GetHitBoxBone(hitbox)
      local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone)

      if phys:IsValid() then
        local bonepos = phys:GetPos()
        local boneang = phys:GetAngles()

        if bonepos then
          local localpos, localang = WorldToLocal(tr.HitPos - tr.Normal, self:GetAngles(), bonepos, boneang)
          timer.Simple(0, ragdollweld, self, ent, tr.PhysicsBone, localpos, localang)
        end
      end
    elseif brush then
      local phys = ent:GetPhysicsObject()

      if phys:IsValid() then
        local bonepos = phys:GetPos()
        local boneang = phys:GetAngles()

        if bonepos then
          local localpos, localang = WorldToLocal(tr.HitPos - tr.Normal, self:GetAngles(), bonepos, boneang)
          timer.Simple(0, ragdollweld, self, ent, 0, localpos, localang)
        end
      end
    else
      if tr.Entity:IsNPC() and (ent:GetClass() ~= "npc_antlionguard") then
        tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
      end

      local hitbox = tr.HitBox
      local bone = ent:GetHitBoxBone(hitbox, 0)
      local bonepos, boneang = ent:GetBonePosition(bone)
      self.dt.StickEntity = ent
      self.laststuckentity = ent
      self.dt.StickBone = bone

      if bonepos then
        local stickpos, stickang = WorldToLocal(tr.HitPos - tr.Normal, self:GetAngles(), bonepos, boneang)
        self.dt.StickPos, self.dt.StickAngle = stickpos, stickang
      else
        local stickpos, stickang = WorldToLocal(tr.HitPos - tr.Normal, self:GetAngles(), ent:GetPos(), ent:GetAngles())
        self.dt.StickPos, self.dt.StickAngle = stickpos, stickang
      end

      local dmg = DamageInfo()
      dmg:SetDamageType(DMG_SLASH)
      dmg:SetDamagePosition(tr.HitPos)

      if self:GetOwner():IsValid() then
        dmg:SetAttacker(self:GetOwner())
      else
        dmg:SetAttacker(self)
      end

      dmg:SetInflictor(self)
      dmg:SetDamageForce(data.OurOldVelocity * 90000)

      --dmg:SetDamage((data.OurOldVelocity:Length()^2)/50000)
      --print(dmg:GetDamage())
      if self.WussMode then
        dmg:SetDamage(75)
      else
        dmg:SetDamage(15 + math.random(0, 12))
      end

      ent:TakeDamageInfo(dmg)
    end

    self.Stuck = true
  end

  self:ImpactEffect(tr)
end

function ENT:Draw()
  local ent = self.dt.StickEntity

  if (ent ~= NULL) and not ent:IsWorld() and (ent ~= GetViewEntity()) then
    local bone = self.dt.StickBone
    local bonepos, boneang = ent:GetBonePosition(bone)

    if bonepos then
      local pos, ang = LocalToWorld(self.dt.StickPos, self.dt.StickAngle, bonepos, boneang)
      self:SetPos(pos)
      self:SetAngles(ang)
    end
  end

  if ent ~= GetViewEntity() then
    self:DrawModel()
  end
end

function ENT:ImpactEffect(tr)
  if not IsValid(self) or dodebug then return end
  local ef = EffectData()
  ef:SetOrigin(tr.HitPos)
  ef:SetNormal(tr.HitNormal)
  local mat = tr.MatType
  local pos = self:GetPos()

  if (mat == MAT_BLOODYFLESH) or (mat == MAT_FLESH) then
    util.Effect("BloodImpact", ef)
    sound.Play("physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav", pos, 50)
  elseif (mat == MAT_CONCRETE) or (mat == MAT_DIRT) then
    --util.Effect("Impact",ef)
    sound.Play("physics/concrete/concrete_impact_bullet" .. math.random(1, 4) .. ".wav", pos, 50)
  elseif mat == MAT_PLASTIC then
    --util.Effect("Impact",ef)
    sound.Play("physics/plastic/plastic_box_impact_hard" .. math.random(1, 4) .. ".wav", pos, 50)
  elseif (mat == MAT_GLASS) or (mat == MAT_TILE) then
    util.Effect("GlassImpact", ef)
    sound.Play("physics/concrete/concrete_impact_bullet" .. math.random(1, 4) .. ".wav", pos, 50)
  elseif (mat == MAT_METAL) or (mat == MAT_GRATE) then
    util.Effect("ManhackSparks", ef)
    sound.Play("physics/metal/metal_solid_impact_bullet" .. math.random(1, 4) .. ".wav", pos, 50)
  elseif mat == MAT_WOOD then
    --util.Effect("Impact",ef)
    sound.Play("physics/wood/wood_solid_impact_bullet" .. math.random(1, 5) .. ".wav", pos, 50)
  elseif mat == MAT_SAND then
    --util.Effect("Impact",ef)
    sound.Play("physics/surfaces/sand_impact_bullet" .. math.random(1, 4) .. ".wav", pos, 50)
  end

  self:EmitSound("physics/metal/sawblade_stick2.wav")
end

scripted_ents.Register(ENT, "ghor_shuriken", true)