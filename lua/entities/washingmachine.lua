AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"
ENT.PrintName = "Washing Machine"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Information = "A Washing Machine, Cleans Props"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Running = false
ENT.Item = NULL

local TimeToFinish = 0
local WASHTIME = 4
local Functions = {
	['prop_physics'] = {
		Start = function(self, ent)
			ent:SetNoDraw(true)
			ent:SetNotSolid(true)
			ent:SetPos(self:GetPos())
			ent:SetParent(self)
		end,
		Stop = function(self, ent, spawnpos)
			ent:SetNoDraw(false)
			ent:SetNotSolid(false)

			local phy = ent:GetPhysicsObject()
			if IsValid(phy) then
				local velocity = Vector(0, 0, 100) + (self:GetForward()  * 350)
				ent:SetPos(spawnpos)
				ent:GetPhysicsObject():SetVelocity(velocity)
			else
				spawnpos = self:GetPos() + Vector(0, 0, 50) + (self:GetForward()  * 100)
				ent:SetPos(spawnpos)
			end
		end
	},
	['player'] = {
		Start = function(self, ply)
			self.PastPlayerMoveType = ply:GetMoveType()

			ply:SetViewEntity(self)
			ply:SetMoveType(MOVETYPE_NONE)
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)

			local weapon = ply:GetActiveWeapon()
			if IsValid(weapon) then
				weapon:SetNoDraw(true)
			end

			hook.Add("PlayerSwitchWeapon", self, function(target)
				if target == ply then
					return true
				end
			end)
		end,
		Stop = function(self, ply, spawnpos)
			ply:SetNoDraw(false)
			ply:SetNotSolid(false)
			ply:SetViewEntity(NULL)
			ply:SetMoveType(self.PastPlayerMoveType or MOVETYPE_WALK)

			local weapon = ply:GetActiveWeapon()
			if IsValid(weapon) then
				weapon:SetNoDraw(false)
			end

			spawnpos = self:GetPos() + Vector(0, 0, 50) + (self:GetForward()  * 100)
			ply:SetPos(spawnpos)

			hook.Remove("PlayerSwitchWeapon", self)
		end
	},
	['npc'] = {
		Start = function(self, npc)
			npc:SetNoDraw(true)
			npc:SetNotSolid(true)
			npc:AddEFlags(EFL_NO_THINK_FUNCTION)

			local weapon = npc:GetActiveWeapon()
			if IsValid(weapon) then
				weapon:SetNoDraw(true)
			end
		end,
		Stop = function(self, npc, spawnpos)
			npc:SetNoDraw(false)
			npc:SetNotSolid(false)
			npc:RemoveEFlags(EFL_NO_THINK_FUNCTION)

			local weapon = npc:GetActiveWeapon()
			if IsValid(weapon) then
				weapon:SetNoDraw(false)
			end

			spawnpos = self:GetPos() + Vector(0, 0, 50) + (self:GetForward()  * 100)
			npc:SetPos(spawnpos)
		end,
	}
}

--Structure
--[[
		SERVER
]]
--
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:GetPhysicsObject():Wake()

		hook.Add("OnPhysgunPickup", self, function(_, ply, ent)
			if ent:IsPlayer() or (isfunction(ent.IsBot) and ent:IsBot()) then
				ent.ToyBox_WashingMachine_PhysgunPickup = true
				local timerName = "ToyBox_WashingMachine_PhysgunPickup_" .. ent:EntIndex()
				timer.Remove(timerName)
			end
		end)

		hook.Add("PhysgunDrop", self, function(_, ply, ent)
			local timerName = "ToyBox_WashingMachine_PhysgunPickup_" .. ent:EntIndex()
			if ent.ToyBox_WashingMachine_PhysgunPickup and not timer.Exists(timerName) then
				timer.Create(timerName, 1, 1, function()
					ent.ToyBox_WashingMachine_PhysgunPickup = false
				end)
			end
		end)
	end

	function ENT:GetSound()
		if not self.Sound then
			self.Sound = CreateSound(self, Sound("ambient/levels/labs/machine_moving_loop4.wav"))
		end
		return self.Sound
	end

	function ENT:SpawnFunction(ply, tr)
		if not tr.Hit then return end
		local SpawnPos = tr.HitPos + tr.HitNormal * 64
		local ent = ents.Create(ClassName)
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:StartTouch(ent)
		local entity_type, tbl
		local entity_class = ent:GetClass()

		if entity_class == "prop_physics" then
			entity_type = 'prop_physics'
		elseif ent:IsPlayer() or (isfunction(ent.IsBot) and ent:IsBot()) then
			entity_type = 'player'
		elseif ent:IsNPC() then
			entity_type = 'npc'
		else
			return
		end

		tbl = Functions[entity_type]
		if not istable(tbl) or not isfunction(tbl.Start) or not isfunction(tbl.Stop) then return end

		if not IsValid(self.Item) and not self.Running then
			self.Item = ent
			self.EntityType = entity_type
			self.EntityClass = entity_class
			self.F_Start = tbl.Start
			self.F_Stop = tbl.Stop

			if isfunction(self.F_Start) then
				self.F_Start(self, self.Item)
			end

			if entity_type == "player" and not ent.ToyBox_WashingMachine_PhysgunPickup then
				self:Use(ent)
			end
		end
	end

	function ENT:Use(ply)
		if not IsValid(self.Item) or self.Running then return end

		self.Running = true
		TimeToFinish = CurTime() + WASHTIME

		self:GetSound():Play()
	end

	function ENT:Think()
		if self.Running then
			self:GetPhysicsObject():AddVelocity(VectorRand() * 50)

			if TimeToFinish < CurTime() then
				self:Fin()
			end
		end
	end

	function ENT:Fin()
		if self.Running then
			self.Running = false
			self:GetSound():Stop()
			self:EmitSound(Sound("HL1/fvox/bell.wav"))
		end

		if IsValid(self.Item) then
			self.Item:SetColor(Color(255, 255, 255, 255))
			self.Item:SetMaterial("")
			BroadcastLua("RunConsoleCommand('r_cleardecals')")
			self.Item:SetParent()
			local spawnpos = self:GetPos() + Vector(0, 0, 50)
			if isfunction(self.F_Stop) then
				self.F_Stop(self, self.Item, spawnpos)
			end
		end

		self.Item = NULL
		self.F_Stop = nil
		self.F_Start = nil
	end

	function ENT:OnRemove()
		self:Fin()
	end
end