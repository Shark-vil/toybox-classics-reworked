AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.Category = "Toybox Classics"
ENT.PrintName = "The Box"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Spaces = {}
ENT.SpaceEnt = {}

local LockedZones = {}
local tocreatespace = {}
local MasterEntity = nil
local maxbox = CreateConVar("thebox_maximumboxes", "900", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local boxperthink = CreateConVar("thebox_boxperthink", "5", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local maxents = maxbox:GetInt() or 900
local boxes = 0
local toolsWhitelist = {
	"material", "colour", "weld", "light", "balloon", "muscle", "motor", "hydraulic", "elastic", "axis", "slider", "nail", "pulley", "rope", "ballsocket", "winch", "lamp", "turret", "thruster", "wheel", "button", "paint", "ignite", "button", "dynamite"
}

function ENT:Initialize()
	if SERVER then
		self.Entity:SetModel("models/props_junk/wood_crate001a.mdl")
		self.Entity:PhysicsInitBox(Vector(-19, -19, -19), Vector(19, 19, 19))
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:SetCollisionBounds(Vector(-19, -19, -19), Vector(19, 19, 19))
		self.Entity.TheBox = true

		if IsValid(MasterEntity) then
			MasterEntity:DeleteOnRemove(self.Entity)
		end

		local physobj = self.Entity:GetPhysicsObject()
		physobj:EnableMotion(false)
	end
end

local function TheBoxCanTool(pl, tr, toolmode)
	if tr.Entity.TheBox then
		if table.HasValue(toolsWhitelist, toolmode) then
			return true
		end

		return false
	end
end
hook.Add("CanTool", "ToyBoxReworked.TheBox.CanToolRestiction", TheBoxCanTool)

local function TheBoxPickup(pl, ent)
	if ent.TheBox then return false end
end
hook.Add("PhysgunPickup", "ToyBoxReworked.TheBox.PhysgunPickup", TheBoxPickup)

local function PostCleanupMap()
	LockedZones = {}
	boxes = 0
end
hook.Add("PostCleanupMap", "ToyBoxReworked.TheBox.ResetSettings", PostCleanupMap)

local function TheBoxMove(pl, move)
	if pl:GetMoveType() ~= MOVETYPE_NOCLIP then return end
	local vel = move:GetVelocity()

	if vel == Vector(0, 0, 0) then
		vel = Vector(0, 0, 1000)
	end

	local trace = {}
	trace.start = pl:GetPos()
	trace.endpos = pl:GetPos() + vel * FrameTime() + vel:GetNormalized()
	trace.filter = {pl}
	trace.mask = MASK_SHOT_HULL

	local tr = util.TraceEntity(trace, pl)

	if tr.Hit and (tr.Entity.TheBox or (tr.HitWorld and IsValid(MasterEntity))) then
		pl:SetMoveType(MOVETYPE_WALK)
		pl:SetPos(tr.HitPos - vel * 2 - vel:GetNormalized())
		move:SetVelocity(Vector(0, 0, 0))
		move:SetSideSpeed(0)
		move:SetForwardSpeed(0)
		move:SetUpSpeed(0)
	end
end
hook.Add("Move", "ToyBoxReworked.TheBox.PlayerMoveSettings", TheBoxMove)

local function TheBoxThink()
	if #tocreatespace > 0 then
		for i = 1, math.Clamp(#tocreatespace, 1, boxperthink:GetInt() or 5) do
			if tocreatespace[1][1] and tocreatespace[1][1]["CreateSpace"] then
				tocreatespace[1][1]:CreateSpace(tocreatespace[1][2])
			end

			table.remove(tocreatespace, 1)
		end
	end
end
hook.Add("Think", "ToyBoxReworked.TheBox.ThinkCreateSpaces", TheBoxThink)

local function TheBoxSpawn(pl)
	if pl.OrigSpawnPosition and IsValid(MasterEntity) then
		pl:SetPos(pl.OrigSpawnPosition)
	end
end
hook.Add("PlayerSpawn", "ToyBoxReworked.TheBox.PlayerSpawn", TheBoxSpawn)

local function R(x)
	if x < 0 then return math.ceil(x) end
	if x > 0 then return math.floor(x) end

	return 0
end

function ENT:Space(vec)
	self.Spaces[vec.x .. "/" .. vec.y .. "/" .. vec.z] = vec
end

function ENT:SpaceG(vec)
	vec = self:Conv(vec)
	self.Spaces[vec.x .. "/" .. vec.y .. "/" .. vec.z] = vec
end

function ENT:Conv(vec)
	vec = vec / 38
	vec.x = R(vec.x)
	vec.y = R(vec.y)
	vec.z = R(vec.z)

	return vec
end

function ENT:Check(vec)
	return self.Spaces[vec.x .. "/" .. vec.y .. "/" .. vec.z]
end

function ENT:CheckEnt(vec)
	return self.SpaceEnt[vec.x .. "/" .. vec.y .. "/" .. vec.z]
end

function ENT:CheckBoth(vec)
	if self:Check(vec) or self:CheckEnt(vec) then return true end
end

function ENT:VectorHasLocked(vec)
	return LockedZones[vec.x .. "/" .. vec.y .. "/" .. vec.z]
end

function ENT:Create(vec)
	if boxes > maxents then return false end

	if not self:VectorHasLocked(vec) then
		local ent = ents.Create(self.ClassName)
		ent:SetPos(vec * 38)
		ent:Spawn()
		ent:Activate()

		local spVec = ent:Conv(ent:GetPos())
		self.SpaceEnt[spVec.x .. "/" .. spVec.y .. "/" .. spVec.z] = ent
		ent.SpaceEnt[spVec.x .. "/" .. spVec.y .. "/" .. spVec.z] = ent
		LockedZones[spVec.x .. "/" .. spVec.y .. "/" .. spVec.z] = true

		boxes = boxes + 1
	end

	return true
end

function ENT:CreateSpace(vec)
	local ent = self.SpaceEnt[vec.x .. "/" .. vec.y .. "/" .. vec.z]
	local a = {}
	local b = {}
	local c = {}
	local d = {}
	local e = {}
	local f = {}

	if not self:CheckBoth(vec + Vector(1, 0, 0)) then
		a[1] = true
		a[2] = self:Create(vec + Vector(1, 0, 0))
	end

	if not self:CheckBoth(vec + Vector(-1, 0, 0)) then
		b[1] = true
		b[2] = self:Create(vec + Vector(-1, 0, 0))
	end

	if not self:CheckBoth(vec + Vector(0, 1, 0)) then
		c[1] = true
		c[2] = self:Create(vec + Vector(0, 1, 0))
	end

	if not self:CheckBoth(vec + Vector(0, -1, 0)) then
		d[1] = true
		d[2] = self:Create(vec + Vector(0, -1, 0))
	end

	if not self:CheckBoth(vec + Vector(0, 0, 1)) then
		e[1] = true
		e[2] = self:Create(vec + Vector(0, 0, 1))
	end

	if not self:CheckBoth(vec + Vector(0, 0, -1)) then
		f[1] = true
		f[2] = self:Create(vec + Vector(0, 0, -1))
	end

	if IsValid(ent) then
		if a[1] and not a[2] then return end
		if b[1] and not b[2] then return end
		if c[1] and not c[2] then return end
		if d[1] and not d[2] then return end
		if e[1] and not e[2] then return end
		if f[1] and not f[2] then return end
		ent:Remove()
	end
end

function ENT:SpawnFunction(ply, tr)
	self.ClassName = ClassName

	if not IsValid(MasterEntity) then
		MasterEntity = ents.Create("info_player_terrorist") -- Eh, it's easier to do it this way.
		MasterEntity:Spawn()

		local function ResetParams()
			self.SpaceEnt = {}
			self.Spaces = {}
			LockedZones = {}
			boxes = 0
		end

		do
			local OnRemove = MasterEntity.OnRemove
			function MasterEntity:OnRemove()
				ResetParams()
				OnRemove(MasterEntity)
			end
		end

		undo.Create("Escape The Box!")
		undo.AddEntity(MasterEntity)
		undo.AddFunction(ResetParams)
		undo.SetPlayer(ply)
		undo.Finish()
	end

	local newSpaces = {}

	for k, v in ipairs(player.GetAll()) do
		local pos = v:GetPos()
		v.OrigSpawnPosition = pos

		for x = -3, 3 do
			for y = -3, 3 do
				for z = -3, 3 do
					local vec = self:Conv(pos) + Vector(x, y, z)
					self.Spaces[vec.x .. "/" .. vec.y .. "/" .. vec.z] = vec
					newSpaces[vec.x .. "/" .. vec.y .. "/" .. vec.z] = vec
				end
			end
		end
	end

	local lastent

	for k, v in pairs(newSpaces) do
		lastent = self:CreateSpace(v)
	end

	return lastent
end

function ENT:OnRemove()
	local vec = self:Conv(self:GetPos())
	self.SpaceEnt[vec.x .. "/" .. vec.y .. "/" .. vec.z] = nil
	self.Spaces[vec.x .. "/" .. vec.y .. "/" .. vec.z] = vec
	boxes = boxes - 1
end

function ENT:OnTakeDamage(dmginfo)
	local vec = self:Conv(self:GetPos())
	table.insert(tocreatespace, { self, vec })
end

if CLIENT then
	language.Add("Undone_Escape The Box!", "Undone 'Escape The Box!' Shame on you.")

	function ENT:Draw()
		render.SuppressEngineLighting(true)
		self.Entity:DrawModel()
		render.SuppressEngineLighting(false)
	end

	function ENT:DrawTranslucent()
		render.SuppressEngineLighting(true)
		self.Entity:DrawModel()
		render.SuppressEngineLighting(false)
	end
end