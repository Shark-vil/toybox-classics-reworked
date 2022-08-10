AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"
ENT.PrintName = "Anti-RPG Laser"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
  if SERVER then
    self.Entity:SetModel("models/props_wasteland/laundry_basket001.mdl")
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.AimProp = ents.Create("prop_physics")
    self.AimProp:SetModel("models/props_c17/canister01a.mdl")
    self.AimProp:SetPos(self:GetPos() + Vector(0, 0, 30)) --Temporary
    self.AimProp:Spawn()
    self.AimProp:SetSolid(SOLID_NONE)
    self.AimProp:SetMoveType(MOVETYPE_NONE)
    self.IsAntiRPG = true
  end

  self.Distance = 1024
end

function ENT:TClass()
  return "anti_rpg"
end

if SERVER then
  function ENT:OnRemove()
    self.AimProp:Remove()
  end
end

--Hooked
function ENT:Tick()
  if SERVER then
    self.AimProp:SetPos(self:LocalToWorld(Vector(0, 0, 30)))
  end

  if SERVER and not IsValid(self.Target) then
    self.AimProp:SetAngles(self:GetAngles()) --Set to our own angles otherwise it looks crap
    local rpgs = ents.FindByClass("rpg_missile")

    for _, v in ipairs(rpgs) do
      if not v.ShotDown and v:GetPos():Distance(self:GetPos()) < self.Distance then
        v:SetHealth(0)
        v.ShotDown = true
        self.Target = v
        --Aim towards so that the effect isn't off
        local pos = self.Target:GetPos() - self:GetPos()
        self.AimProp:SetAngles(pos:Angle() + Angle(90, 0, 0))
        self.Target = v
        --Give it a fancy fire trail
        local trail = ents.Create("env_fire_trail")
        trail:SetPos(self.Target:GetPos())
        trail:SetAngles(self.Target:GetAngles())
        trail:SetKeyValue("startsize", "25")
        trail:SetKeyValue("endsize", "0")
        trail:SetKeyValue("startcolor", "255 180 0")
        trail:SetKeyValue("firesprite", "sprites/firetrail.spr")
        trail:SetParent(self.Target)
        trail:Spawn()
        trail:Activate()

        timer.Simple(0.7, function()
          if not IsValid(self) or not IsValid(v) then return end
          local shooter = self
          local rpg = v
          --print("YESYESYES")
          local bullet = {}
          bullet.Src = v:GetPos()
          bullet.Num = 1
          bullet.Dir = Vector(0, 0, 0)
          bullet.Damage = 0
          bullet.Force = 0
          bullet.Tracer = 0
          shooter:FireBullets(bullet)
          shooter.Target = NULL
        end)

        local eff = EffectData()
        eff:SetScale(0.5) -- Duration
        eff:SetMagnitude(self.AimProp:EntIndex()) --Our entity
        eff:SetEntity(self.Target)
        eff:SetOrigin(Vector(0, 0, 10)) --Offset
        util.Effect("LaserKillRPG", eff)
        break --Only one RPG per think
      end
    end
  elseif SERVER then
    --We have a target, aim at it
    local pos = self.Target:GetPos() - self:GetPos()
    self.AimProp:SetAngles(pos:Angle() + Angle(90, 0, 0))
  end

  self:NextThink(CurTime() - 1)
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

--Do a tick hook so we aim faster
if SERVER then
  hook.Add("Tick", "AntiRPGTicks", function()
    for _, v in ipairs(ents.GetAll()) do
      if v.IsAntiRPG then
        v:Tick()
      end
    end
  end)
end

if not CLIENT then return end

function ENT:Draw()
  self:DrawModel()
end

--Effect hack
local Lasor = Material("cable/redlaser")
local EFFECT = {}

function EFFECT:Init(data)
  self.Time = CurTime() + data:GetScale()
  self.Anti = Entity(data:GetMagnitude())
  self.RPG = data:GetEntity()
  self.Offset = data:GetOrigin()
end

function EFFECT:Think()
  if CurTime() > self.Time or not IsValid(self.Anti) or not IsValid(self.RPG) then return false end
  local StartPos = self.Anti:LocalToWorld(self.Offset)
  local EndPos = self.RPG:GetPos()
  self.Entity:SetRenderBoundsWS(StartPos, EndPos)

  return true
end

function EFFECT:Render()
  if IsValid(self.RPG) and IsValid(self.Anti) then
    render.SetMaterial(Lasor)
    local StartPos = self.Anti:LocalToWorld(self.Offset)
    local EndPos = self.RPG:GetPos()
    render.DrawBeam(StartPos, EndPos, 10, 0, 0, Color(255, 255, 255, 255))
  end
end

effects.Register(EFFECT, "LaserKillRPG", true) --Hacky