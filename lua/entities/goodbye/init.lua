AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
  if not tr.Hit then return end
  local SpawnPos = tr.HitPos + tr.HitNormal * 16
  local ent = ents.Create(ClassName)
  ent:SetPos(SpawnPos)
  ent:Spawn()
  ent:Activate()

  return ent
end

function ENT:Initialize()
  self:SetModel("models/props_c17/briefcase001a.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:DrawShadow(true)
  local phys = self:GetPhysicsObject()

  if IsValid(phys) then
    phys:Wake()
  end

  self.Packed = 0
  self.PackedDelay = CurTime()
end

function ENT:Think()
  if self.Alpha then
    self:SetColor(Color(255, 255, 255, self.Alpha))
    self.Alpha = math.Approach(self.Alpha, 0, -10)

    if self.Alpha <= 0 then
      self:Remove()
    end
  end

  if self:IsOnGround() and self.IsSailing then
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
      phys:SetVelocity(Vector(0, 0, 20))
    end
  end
end

function ENT:Touch(ent)
  if self.IsDying then return end
  if not IsValid(ent) or ent:IsPlayer() or self.PackedDelay > CurTime() then return end
  ent:Remove()
  self:EmitSound("goodbye/zipup.wav")
  self.Packed = self.Packed + 1

  if self.Packed >= 4 then
    self:SetSail() -- goodbye... my friends...

    return
  end

  net.Start("ToyBoxReworked_GoodbyePack")
  net.WriteEntity(self)
  net.WriteInt(self.Packed, 32)
  net.Broadcast()
  self.PackedDelay = CurTime() + 0.5
end

function ENT:SetSail()
  self.IsDying = true

  if self:CanSail() then
    self.IsSailing = true
    self:MakeBalloon()
    self:DramaticDie()
  else
    self:Suicide()
  end
end

function ENT:CanSail()
  local tr = util.TraceLine({
    start = self:GetPos(),
    endpos = self:GetPos() + Vector(0, 0, 1000),
    filter = self,
    mask = MASK_SOLID_BRUSHONLY
  })

  if tr.HitWorld then return false end

  return true
end

function ENT:MakeBalloon()
  local balloon = ents.Create("gmod_balloon")
  balloon:SetPos(self:GetPos() + Vector(0, 0, 48))
  balloon:SetModel("models/maxofs2d/balloon_classic.mdl")
  balloon:Spawn()
  balloon:SetRenderMode(RENDERMODE_TRANSALPHA)
  balloon:SetColor(Color(250, 0, 100, 255))
  balloon:SetForce(130)
  local ent1, ent2 = self, balloon
  local pos1, pos2 = self:GetPos(), balloon:GetPos()
  pos1 = self:WorldToLocal(pos1)
  pos2 = balloon:WorldToLocal(pos2)
  constraint.Rope(ent1, ent2, 0, 0, pos1, pos2, 48, 0, 0, .1, "cable/cable2", false)
  self.Balloon = balloon
end

function ENT:Suicide()
  self:EmitSound("weapons/357/357_spin1.wav")

  timer.Simple(1, function()
    if IsValid(self) then
      self:EmitSound("weapons/357/357_fire2.wav")
      local phys = self:GetPhysicsObject()

      if IsValid(phys) then
        phys:SetVelocity(VectorRand() * 800)
      end

      local gun = ents.Create("prop_physics")
      gun:SetModel("models/Weapons/W_357.mdl")
      gun:SetPos(self:GetPos() + Vector(0, -5, 0))
      gun:SetAngles(Angle(0, 90, 0))
      gun:Spawn()
      self.Gun = gun
    end
  end)
end

function ENT:DramaticDie()
  game.ConsoleCommand("host_timescale .4\n")

  for _, ply in ipairs(player.GetAll()) do
    ply:Freeze(true)
    ply:StripWeapons()
  end

  net.Start("ToyBoxReworked_GoodbyeDie")
  net.WriteEntity(self)
  net.Broadcast()

  timer.Simple(17, function()
    if not IsValid(self) then return end
    self.Alpha = 255
    game.ConsoleCommand("host_timescale 1\n")

    for _, ply in ipairs(player.GetAll()) do
      ply:Kill()
      ply:Freeze(false)
    end

    net.Start("ToyBoxReworked_GoodbyeDieRemove")
    net.WriteEntity(self)
    net.Broadcast()
  end)
end

function ENT:OnRemove()
  net.Start("ToyBoxReworked_GoodbyeDieRemove")
  net.Broadcast()

  for _, ply in ipairs(player.GetAll()) do
    ply:Freeze(false)
  end

  game.ConsoleCommand("host_timescale 1\n")

  if IsValid(self.Balloon) then
    self.Balloon:Remove()
  end

  if IsValid(self.Gun) then
    self.Gun:Remove()
  end
end