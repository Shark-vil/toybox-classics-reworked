AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"
ENT.PrintName = "Zombie in a Can!"
ENT.Author = "MrNiceGuy518"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
  if SERVER then
    self.Entity:SetModel("models/props_c17/oildrum001.mdl")
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:GetPhysicsObject():Wake()
    self.laid = math.Round(CurTime())
    self.Entity:SetMaterial("models/props_pipes/GutterMetal01a")
  end
end

ENT.OurHealth = 50

function ENT:OnTakeDamage(dmg)
  self:TakePhysicsDamage(dmg)
  self:EmitSound("Zombie.Pain")
  self:EmitSound("Metal_Box.ImpactHard")
  if self.OurHealth <= 0 then return end
  self.OurHealth = self.OurHealth - dmg:GetDamage()

  if self.OurHealth <= 0 then
    self:Remove()
  end
end

function ENT:Touch(hitEnt)
  if hitEnt:IsValid() and hitEnt:IsPlayer() then
    self:EmitSound("Zombie.Alert")
  end
end

function ENT:PhysicsCollide(data, physobj)
  if data.Speed > 50 and data.DeltaTime > 0.2 then
    self:EmitSound("Metal_Barrel.ImpactSoft")
  end
end

function ENT:OnRemove()
  self:EmitSound("Zombie.Die")

  if SERVER then
    local zomb = ents.Create("npc_zombie")
    undo.ReplaceEntity(self.Entity, zomb)
    zomb:SetPos(self.Entity:GetPos() + Vector(0, 0, 15))
    zomb:Spawn()
  end

  local effectdata = EffectData()
  effectdata:SetOrigin(self:GetPos())
  effectdata:SetScale(1)
  effectdata:SetMagnitude(1)
  util.Effect("StriderBlood", effectdata, true, true)
end

function ENT:Think()
end

function ENT:Draw()
  self.Entity:DrawModel()
  local Pos = self:GetPos()
  local Ang = self:GetAngles()
  CZ = "Canned Zombie"
  surface.SetFont("HUDNumber5")
  local TextWidth = surface.GetTextSize("CAUTION")
  local TextWidth2 = surface.GetTextSize(CZ)
  Ang:RotateAroundAxis(Ang:Up(), 90)
  cam.Start3D2D(Pos + Ang:Up() * 45.3, Ang, 0.1)
  draw.WordBox(2, -TextWidth * 0.5, -15, "CAUTION", "HUDNumber5", Color(0, 0, 0, 0), Color(150, 0, 0, 255))
  draw.WordBox(2, -TextWidth2 * 0.5, 9, CZ, "HUDNumber5", Color(0, 0, 0, 0), Color(150, 0, 0, 255))
  cam.End3D2D()
end