AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"
ENT.PrintName = "ArmyMaker"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.ArmyMaker_mode = 0

local ArmyMakerTAS = {"npc_zombie", "npc_fastzombie", "npc_combine_s"}

local ArmyMakerTBS = {"npc_alyx", "npc_citizen", "npc_barney"}

local function AM_Respond(ply, ent, v)
	if CLIENT then return end
	net.Start("ToyBoxReworked_ArmyMakerRespond")
	net.WriteString(v)
	net.WriteEntity(ent)
	net.Send(ply)
end

if CLIENT then
	net.Receive("ToyBoxReworked_ArmyMakerRespond", function()
		local title = net.ReadString()
		local ent = net.ReadEntity()

		local DermaPanel = vgui.Create("DFrame") -- Creates the frame itself
		DermaPanel:SetPos(50, 50) -- Position on the players screen
		DermaPanel:SetSize(800, 44) -- Size of the frame
		DermaPanel:SetTitle(title) -- Title of the frame
		DermaPanel:SetVisible(true)
		DermaPanel:SetDraggable(true) -- Draggable by mouse?
		DermaPanel:ShowCloseButton(true) -- Show the close button?
		DermaPanel:MakePopup() -- Show the frame
		local myText = vgui.Create("DTextEntry", DermaPanel)
		myText:SetPos(0, 22)
		myText:SetText("")

		myText.OnEnter = function(self)
			net.Start("ToyBoxReworked_ArmyMakerAnswer")
			net.WriteString(myText:GetText())
			net.WriteEntity(ent)
			net.SendToServer()

			DermaPanel:Close()
		end
	end)
end

function ENT:Initialize()
	if SERVER then
		self.Entity:SetModel("models/props_c17/cashregister01a.mdl")
		self.Entity:PhysicsInitSphere(16, "metal_bouncy")
		self.Entity:SetUseType(SIMPLE_USE)
		self.Entity:SetCollisionBounds(Vector(-16, -16, -16), Vector(16, 16, 16))
	end
end

function CreateArmy(cn, am)
	local p = 0
	local R = 3200

	while p < am do
		--This should fix map-specific errors.
		local SpawnPos = Vector(math.random(-R, R), math.random(-R, R), 64)
		local ent = ents.Create(cn)
		ent:SetPos(SpawnPos)
		ent:SetKeyValue("additionalequipment", "weapon_smg1")
		ent:Spawn()
		ent:Activate()
		p = p + 1
	end
end

function ENT:Use(activator, caller)
	self:SetOwner(activator)
	AM_Respond(activator, self, "Army Maker Active-Please type 1 for zombie,2 for Fast Zombie,3 for Combine,or remove me to cancel.")
	self.ArmyMaker_mode = 1
end

if SERVER then
	net.Receive("ToyBoxReworked_ArmyMakerAnswer", function(_, ply)
		local strText = net.ReadString()
		local ent = net.ReadEntity()

		if strText == "" or not IsValid(ent) or ent:GetOwner() ~= ply or not ent.ArmyMaker_mode then
			return
		end

		if ent.ArmyMaker_mode == 1 then
			ArmyMakerTA = math.Clamp(tonumber(strText), 1, 3)
			AM_Respond(ply, ent, "Army Maker Stage 2 (allies): Please type 1 for Alyx Army, 2 for Citzen Army, 3 for Barney Army.")
			ent.ArmyMaker_mode = 2

			return
		end

		if ent.ArmyMaker_mode == 2 then
			ArmyMakerTB = tonumber(strText)
			AM_Respond(ply, ent, "Army Maker Stage 3: Now please state the number of units in enemy army.")
			ent.ArmyMaker_mode = 3

			return
		end

		if ent.ArmyMaker_mode == 3 then
			ArmyMakerNA = tonumber(strText)
			AM_Respond(ply, ent, "Army Maker Stage 4: Now please state the number of units in ally army.")
			ent.ArmyMaker_mode = 4

			return
		end

		if ent.ArmyMaker_mode == 4 then
			CreateArmy(ArmyMakerTAS[ArmyMakerTA], ArmyMakerNA)
			CreateArmy(ArmyMakerTBS[ArmyMakerTB], tonumber(strText))
			AM_Respond(ply, ent, "Army Maker: If your computer survives to see this, Done!")
			ent.ArmyMaker_mode = 0

			return
		end
	end)
end