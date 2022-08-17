local ents_Create, ents_FindByClass, timer_Simple, util_Effect, Vector, IsValid, ipairs, Angle, EffectData, effects_Register, Material, CurTime, Color = ents.Create, ents.FindByClass, timer.Simple, util.Effect, Vector, IsValid, ipairs, Angle, EffectData, effects.Register, Material, CurTime, Color

local render_DrawBeam, render_SetMaterial

if CLIENT then
	render_DrawBeam, render_SetMaterial = render.DrawBeam, render.SetMaterial
end

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

		self.AimProp = ents_Create("prop_physics")
		self.AimProp:SetModel("models/props_c17/canister01a.mdl")
		self.AimProp:SetPos(self:GetPos() + Vector(0, 0, 30)) --Temporary
		self.AimProp:Spawn()
		self.AimProp:SetSolid(SOLID_NONE)
		self.AimProp:SetMoveType(MOVETYPE_NONE)
		self.IsAntiRPG = true
	end

	self.Distance = 1024 ^ 2
end

function ENT:TClass()
	return "anti_rpg"
end

if SERVER then
	function ENT:OnRemove()
		self.AimProp:Remove()
	end
end

function ENT:Think()
	if SERVER then
		self.AimProp:SetPos(self:LocalToWorld(Vector(0, 0, 30)))
	end

	if SERVER and not IsValid(self.Target) then
		self.AimProp:SetAngles(self:GetAngles()) --Set to our own angles otherwise it looks crap

		for _, v in ipairs(ents_FindByClass("rpg_missile")) do
			if not v.ShotDown and v:GetPos():DistToSqr(self:GetPos()) < self.Distance then
				v:SetHealth(0)
				v.ShotDown = true
				self.Target = v
				--Aim towards so that the effect isn't off
				local pos = self.Target:GetPos() - self:GetPos()
				self.AimProp:SetAngles(pos:Angle() + Angle(90, 0, 0))
				self.Target = v
				--Give it a fancy fire trail
				local trail = ents_Create("env_fire_trail")
				trail:SetPos(self.Target:GetPos())
				trail:SetAngles(self.Target:GetAngles())
				trail:SetKeyValue("startsize", "25")
				trail:SetKeyValue("endsize", "0")
				trail:SetKeyValue("startcolor", "255 180 0")
				trail:SetKeyValue("firesprite", "sprites/firetrail.spr")
				trail:SetParent(self.Target)
				trail:Spawn()
				trail:Activate()

				timer_Simple(0.7, function()
					if not IsValid(self) or not IsValid(v) then return end
					local shooter = self
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
				eff:SetStart(self:GetPos())
				eff:SetEntity(self.Target)
				eff:SetOrigin(Vector(0, 0, 10)) --Offset
				util_Effect("LaserKillRPG", eff)
				break --Only one RPG per think
			end
		end
	elseif SERVER then
		--We have a target, aim at it
		local pos = self.Target:GetPos() - self:GetPos()
		self.AimProp:SetAngles(pos:Angle() + Angle(90, 0, 0))
	end
end

function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents_Create(ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
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
	self.StartPos = data:GetStart()
	self.RPG = data:GetEntity()
	self.Offset = data:GetOrigin()
end

function EFFECT:Think()
	if CurTime() > self.Time or not IsValid(self.RPG) then return false end
	local StartPos = self.StartPos
	local EndPos = self.RPG:GetPos()
	self.Entity:SetRenderBoundsWS(StartPos, EndPos)

	return true
end

function EFFECT:Render()
	if IsValid(self.RPG) then
		render_SetMaterial(Lasor)
		local StartPos = self.StartPos
		local EndPos = self.RPG:GetPos()
		render_DrawBeam(StartPos, EndPos, 10, 0, 0, Color(255, 255, 255, 255))
	end
end

effects_Register(EFFECT, "LaserKillRPG", true) --Hacky