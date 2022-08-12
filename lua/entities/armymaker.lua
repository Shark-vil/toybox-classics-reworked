AddCSLuaFile()

ENT.Type = "anim"
ENT.Category = "Toybox Classics"
ENT.PrintName = "ArmyMaker"
ENT.Spawnable = true
ENT.AdminSpawnable = false

if CLIENT then

	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

	language.Add("toybox_reworked.army_maker.0", "Army Maker: If your computer survives to see this, Done!")
	language.Add("toybox_reworked.army_maker.1", "Army Maker Active-Please type 1 for zombie,2 for Fast Zombie,3 for Combine, or remove me to cancel.")
	language.Add("toybox_reworked.army_maker.2", "Army Maker Stage 2 (allies): Please type 1 for Alyx Army, 2 for Citzen Army, 3 for Barney Army.")
	language.Add("toybox_reworked.army_maker.3", "Army Maker Stage 3: Now please state the number of units in enemy army.")
	language.Add("toybox_reworked.army_maker.4", "Army Maker Stage 4: Now please state the number of units in ally army.")

	net.Receive("ToyBoxReworked - ArmyMaker", function()
		local stage = net.ReadUInt( 3 )
		local ent = net.ReadEntity()

		if IsValid( ent ) then
			local frame = vgui.Create("DFrame")
			frame:SetPos(50, 50)
			frame:SetSize( ScreenScale( 300 ), ScreenScale( 20 ) )
			frame:SetTitle( "#toybox_reworked.army_maker." .. stage)
			frame:MakePopup()
			frame:Center()

			local myText = vgui.Create("DTextEntry", frame)
			myText:RequestFocus()
			myText:Dock(FILL)

			myText.OnEnter = function(self)
				if IsValid( ent ) then
					net.Start("ToyBoxReworked - ArmyMaker")
						net.WriteUInt( tonumber( myText:GetText() ) or 0, 10 )
						net.WriteEntity( ent )
					net.SendToServer()
				end

				if IsValid( frame ) then
					frame:Close()
				end
			end
		end
	end)
end

if SERVER then

	local mins, maxs = Vector(-16, -16, -16), Vector(16, 16, 16)
	function ENT:Initialize()
		self:SetModel("models/props_c17/cashregister01a.mdl")
		self:PhysicsInitSphere(16, "metal_bouncy")
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionBounds( mins, maxs )
	end

	util.AddNetworkString( "ToyBoxReworked - ArmyMaker" )

	function ENT:SetStage( ply, stage )
		net.Start( "ToyBoxReworked - ArmyMaker" )
			net.WriteUInt( stage, 3 )
			net.WriteEntity( self )
		net.Send( ply )

		self.Stage = stage
	end

	ENT.Stage = 0

	function ENT:Use( ply )
		if ply:IsPlayer() then
			self:SetOwner( ply )
			self:SetStage( ply, 1 )
		end
	end

	function ENT:GetDistance()
		local world = game.GetWorld()
		if world ~= NULL then
			local mins, maxs = world:GetModelRenderBounds()
			return math.max( maxs[1], maxs[2] )
		end
	end

	do
		local util_IsInWorld = util.IsInWorld
		local math_random = math.random
		local ents_Create = ents.Create
		local IsValid = IsValid
		local Vector = Vector

		function ENT:CreateArmy( class, amount, ply )
			local npcs = list.Get("NPC")
			if (npcs) then
				local npc_data = npcs[ class ]
				if (npc_data) then
					local key_values = npc_data.KeyValues or {}

					local weps = {}
					table.Add( weps, npc_data.Weapons )
					table.insert( weps, "weapon_smg1" )

					undo.Create( class .. "_army" )
					undo.SetPlayer( ply )

					local count = 0
					local distance = self:GetDistance()
					while count < amount do
						local pos = self:LocalToWorld( Vector( math_random( -distance, distance ), math_random( -distance, distance ), 0 ) )
						if util_IsInWorld( pos ) then
							local ent = ents_Create( class )
							if IsValid( ent ) then
								ent:SetPos( pos )

								key_values.additionalequipment = table.Random( weps )
								for k, v in pairs( key_values ) do
									ent:SetKeyValue( k, v )
								end

								if util.TraceHull({
									start = pos,
									endpos = pos,
									filter = ent,
									mins = mins,
									maxs = maxs
								}).Hit then
									ent:Remove()
									continue
								end

								ent:Spawn()
								ent:Activate()
								undo.AddEntity( ent )
								count = count + 1
							end
						end
					end

					undo.Finish( "Army of " .. class .. "'s" )
				end
			end
		end
	end

	ENT.ArmyMakerTAS = {"npc_zombie", "npc_fastzombie", "npc_combine_s"}
	ENT.ArmyMakerTBS = {"npc_alyx", "npc_citizen", "npc_barney"}

	function ENT:NetRequest( ply, count )
		if self.Stage == 1 then
			self.ArmyMakerTA = math.Clamp( count, 1, 3 )
			self:SetStage( ply, 2 )
			return
		end

		if self.Stage == 2 then
			self.ArmyMakerTB = count
			self:SetStage( ply, 3 )
			return
		end

		if self.Stage == 3 then
			self.ArmyMakerNA = count
			self:SetStage( ply, 4 )
			return
		end

		if self.Stage == 4 then
			self:CreateArmy( self.ArmyMakerTAS[ self.ArmyMakerTA ], self.ArmyMakerNA, ply )
			self:CreateArmy( self.ArmyMakerTBS[ self.ArmyMakerTB ], count, ply )
			self:SetStage( ply, 0 )
			return
		end
	end

	net.Receive("ToyBoxReworked - ArmyMaker", function(_, ply)
		local count = net.ReadUInt( 10 )
		if (count < 1) then return end

		local ent = net.ReadEntity()
		if IsValid( ent ) and ent:GetClass() == "armymaker" then
			if ent:GetOwner() ~= ply then return end
			ent:NetRequest( ply, count )
		end
	end)
end