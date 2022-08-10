AddCSLuaFile()
local Missile = {}
Missile.Type = "anim"

function Missile:PhysicsUpdate()
	local phy = self:GetPhysicsObject()
	if not phy:IsValid() then return end

	local owner = self:GetOwner()

	if IsValid(owner) then
		phy:SetVelocity(self:GetForward() * (1024 * self.SpeedMultiplier))

		local DTTTrace = {}
		DTTTrace.start = self.Entity:GetPos()
		DTTTrace.endpos = self.Entity:GetPos() + (self.Entity:GetForward() * 65536)
		DTTTrace.filter = self.Entity
		local DTTTraceRes = util.TraceLine(DTTTrace)
		owner:SetNWVector("toybox_629_dtt", DTTTraceRes.HitPos)
		owner:SetNWVector("toybox_629_rocketpos", self.Entity:GetPos())

		if self:WaterLevel() >= 1 then
			self:ExplodeMissile()
		end
	else
		self:Remove()
	end
end

function Missile:ExplodeMissile()
	if self.Exploded then return end
	self.Exploded = true
	local MissileExpEffectData = EffectData()
	MissileExpEffectData:SetOrigin(self:GetPos())

	if self:WaterLevel() >= 1 then
		util.BlastDamage(self, self:GetOwner(), self:GetPos(), 256, 256)
		util.Effect("WaterSurfaceExplosion", MissileExpEffectData, true, true)
	else
		util.BlastDamage(self, self:GetOwner(), self:GetPos(), 512, 512)
		util.Effect("Explosion", MissileExpEffectData, true, true)
	end

	if SERVER then
		if IsValid(self.Launcher) then
			self.Launcher:DoReloadingAnimation()
		end

		self:Remove()
	end
end

function Missile:OnRemove()
	if CLIENT then return end

	if self.RocketSound:IsPlaying() then
		self.RocketSound:Stop()
	end
	hook.Remove("KeyPress", "toybox_629_keypress")

	local owner = self:GetOwner()

	if IsValid(owner) then
		net.Start("ToyBoxReworked_toybox_629_disablehooks")
		net.Send(owner)

		if owner:GetMoveType(MOVETYPE_NONE) then
			owner:SetMoveType(self:GetVar("OldMoveType", MOVETYPE_WALK))
		end

		owner:SetViewEntity(owner)
		owner.CanFireNewRocket = true
	end

	if IsValid(self.Trail) then
		self.Trail:Remove()
	end

	if timer.Exists("toybox_629_nofuel") then
		timer.Remove("toybox_629_nofuel")
	end
end

function Missile:PhysicsCollide(data, phys)
	if self.Exploded then return end

	local target = phys:GetEntity()
	if target == self:GetOwner() then return end

	self:ExplodeMissile()
end

function Missile:OnTakeDamage(dmginfo)
	if self.Exploded then return end
	self:ExplodeMissile()
end

function Missile:Think()
	if CLIENT then return end

	local owner = self:GetOwner()

	if IsValid(owner) then
		-- owner:SetMoveType(MOVETYPE_NONE)

		if SERVER and self.Entity:GetPhysicsObject():IsAsleep() then
			self.Entity:GetPhysicsObject():Wake()
		end

		-- if owner:KeyDown(IN_FORWARD) then
		-- 	self:SetAngles(self:GetAngles():Up() * 2)
		-- end

		-- if owner:KeyDown(IN_FORWARD) and (not owner:KeyDown(IN_BACK)) and (self:GetAngles().p >= -88) then
		-- 	self:SetAngles(self:GetAngles() + Angle(-2, 0, 0))
		-- elseif owner:KeyDown(IN_BACK) and (not owner:KeyDown(IN_FORWARD)) and (self:GetAngles().p <= 88) then
		-- 	self:SetAngles(self:GetAngles() + Angle(2, 0, 0))
		-- elseif owner:KeyDown(IN_FORWARD) and owner:KeyDown(IN_BACK) then
		-- 	self:SetAngles(self:GetAngles() + Angle(0, 0, 0))
		-- else
		-- 	self:SetAngles(self:GetAngles() + Angle(0, 0, 0))
		-- end

		-- if owner:KeyDown(IN_MOVELEFT) and (not owner:KeyDown(IN_MOVERIGHT)) then
		-- 	self:SetAngles(self:GetAngles() + Angle(0, 2, 0))
		-- elseif owner:KeyDown(IN_MOVERIGHT) and (not owner:KeyDown(IN_MOVELEFT)) then
		-- 	self:SetAngles(self:GetAngles() + Angle(0, -2, 0))
		-- elseif owner:KeyDown(IN_MOVELEFT) and owner:KeyDown(IN_MOVERIGHT) then
		-- 	self:SetAngles(self:GetAngles() + Angle(0, 0, 0))
		-- else
		-- 	self:SetAngles(self:GetAngles() + Angle(0, 0, 0))
		-- end
	else
		self:Remove()
	end

	if isnumber(self.FuelEndTime) and self.FuelEndTime < CurTime() then
		self:ExplodeMissile()
	end

	self:NextThink(CurTime() + 0.01)

	return true
end

function Missile:Boost()
	if SERVER then
		if timer.Exists("toybox_629_nofuel") then
			timer.Remove("toybox_629_nofuel")
		end

		if self.Boosted then
			self.SpeedMultiplier = 1
			self.Boosted = false
			net.Start("ToyBoxReworked_toybox_629_fuelbarspeed")
			net.WriteBool(false)
			net.Send(self:GetOwner())
			self.FuelEndTime = ((self.FuelEndTime - CurTime()) * 3) + CurTime()
			--timer.Create("toybox_629_nofuel",self.FuelEndTime-CurTime(),1,self.ExplodeMissile,self)
		else
			self.SpeedMultiplier = 3
			self.Boosted = true
			net.Start("ToyBoxReworked_toybox_629_fuelbarspeed")
			net.WriteBool(true)
			net.Send(self:GetOwner())
			self.FuelEndTime = ((self.FuelEndTime - CurTime()) / self.SpeedMultiplier) + CurTime()
			--timer.Create("toybox_629_nofuel",self.FuelEndTime-CurTime(),1,self.ExplodeMissile,self)
		end

		self:GetOwner():SendLua("surface.PlaySound('weapons/rpg/rocketfire1.wav')")
	end
end

function Missile:Initialize()
	if CLIENT then
		killicon.AddFont("toybox_629_valkyrie_cr", "HL2MPTypeDeath", "3", Color(255, 80, 0, 255))
	end

	local owner = self:GetVar("MissileOwner", Entity(1))
	self:SetOwner(owner)

	local steamif64 = owner:SteamID64()

	self.Launcher = self:GetVar("MissileLauncher", Entity(1))
	self.Boosted = false
	self.Exploded = false

	owner.CanFireNewRocket = false

	if SERVER then
		self:SetModel(Model("models/weapons/w_missile_closed.mdl"))
		self:DrawShadow(true)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		if self.Entity:GetPhysicsObject():IsValid() then
			self.Entity:GetPhysicsObject():Wake()
			self.Entity:GetPhysicsObject():EnableGravity(false)
		end
	end

	self.SpeedMultiplier = 1
	self.RocketSound = CreateSound(self.Entity, "Missile.Ignite")
	self.RocketSound:Play()

	if SERVER then
		--timer.Create("toybox_629_nofuel",15,1,self.ExplodeMissile,self)
		self.FuelEndTime = CurTime() + 15

		hook.Add("KeyPress", "ToyBox_valkyrie_cr_for_" .. steamif64, function(ply, key)
			if not IsValid(self) then
				hook.Remove("KeyPress", "ToyBox_valkyrie_cr_for_" .. steamif64)
				return
			end

			if ply ~= self:GetOwner() then return end

			if key == IN_ATTACK2 then
				self:ExplodeMissile()
			elseif key == IN_ATTACK then
				self:Boost()
			end
		end)

		self.Trail = ents.Create("env_smoketrail")
		self.Trail:SetKeyValue("opacity", "0.2")
		self.Trail:SetKeyValue("spawnrate", "100")
		self.Trail:SetKeyValue("lifetime", "0.5")
		self.Trail:SetKeyValue("startcolor", "160 160 160")
		self.Trail:SetKeyValue("endcolor", "0 0 0")
		self.Trail:SetKeyValue("startsize", "8")
		self.Trail:SetKeyValue("endsize", "32")
		self.Trail:SetKeyValue("spawnradius", "4")
		self.Trail:SetKeyValue("mispeed", "2")
		self.Trail:SetKeyValue("maxspeed", "16")
		self.Trail:SetKeyValue("firesprite", "sprites/fire")
		self.Trail:SetKeyValue("smokesprite", "sprites/smoke")
		self.Trail:SetPos(self:GetPos())
		self.Trail:SetParent(self)
		self.Trail:Spawn()
	end
end

--Clientside effects
if CLIENT then
	local function ValkyrieColorModification()
		local ScreenEffects = {}
		ScreenEffects["$pp_colour_addr"] = 0
		ScreenEffects["$pp_colour_addg"] = 0
		ScreenEffects["$pp_colour_addb"] = 0
		ScreenEffects["$pp_colour_brightness"] = 0
		ScreenEffects["$pp_colour_contrast"] = 1
		ScreenEffects["$pp_colour_colour"] = 0
		ScreenEffects["$pp_colour_mulr"] = 0
		ScreenEffects["$pp_colour_mulg"] = 0
		ScreenEffects["$pp_colour_mulb"] = 0
		DrawColorModify(ScreenEffects)
	end

	local function ValkyrieDrawMissileHUD()
		surface.SetDrawColor(191, 191, 191, 255)
		--center
		surface.DrawOutlinedRect(ScrW() / 2 - 28, ScrH() / 2 - 28, 56, 56)
		surface.DrawLine(ScrW() / 2, ScrH() / 2 - 88, ScrW() / 2, ScrH() / 2 - 28)
		surface.DrawLine(ScrW() / 2, ScrH() / 2 + 28, ScrW() / 2, ScrH() / 2 + 88)
		surface.DrawLine(ScrW() / 2 - 88, ScrH() / 2, ScrW() / 2 - 28, ScrH() / 2)
		surface.DrawLine(ScrW() / 2 + 28, ScrH() / 2, ScrW() / 2 + 88, ScrH() / 2)
		--UL corner
		surface.DrawLine(ScrW() / 2 - 192, ScrH() / 2 - 192, ScrW() / 2 - 136, ScrH() / 2 - 192)
		surface.DrawLine(ScrW() / 2 - 192, ScrH() / 2 - 192, ScrW() / 2 - 192, ScrH() / 2 - 136)
		--UR corner
		surface.DrawLine(ScrW() / 2 + 136, ScrH() / 2 - 192, ScrW() / 2 + 192, ScrH() / 2 - 192)
		surface.DrawLine(ScrW() / 2 + 192, ScrH() / 2 - 192, ScrW() / 2 + 192, ScrH() / 2 - 136)
		--LL corner
		surface.DrawLine(ScrW() / 2 - 192, ScrH() / 2 + 192, ScrW() / 2 - 136, ScrH() / 2 + 192)
		surface.DrawLine(ScrW() / 2 - 192, ScrH() / 2 + 136, ScrW() / 2 - 192, ScrH() / 2 + 192)
		--LR corner
		surface.DrawLine(ScrW() / 2 + 136, ScrH() / 2 + 192, ScrW() / 2 + 192, ScrH() / 2 + 192)
		surface.DrawLine(ScrW() / 2 + 192, ScrH() / 2 + 136, ScrW() / 2 + 192, ScrH() / 2 + 192)
		--small parts
		surface.DrawLine(ScrW() / 2 - 200, ScrH() / 2 - 10, ScrW() / 2 - 184, ScrH() / 2 + 1)
		surface.DrawLine(ScrW() / 2 - 200, ScrH() / 2 + 10, ScrW() / 2 - 184, ScrH() / 2 - 1)
		surface.DrawLine(ScrW() / 2 - 4, ScrH() / 2 - 194, ScrW() / 2 + 4, ScrH() / 2 - 194)
		surface.DrawLine(ScrW() / 2 - 8, ScrH() / 2 - 198, ScrW() / 2 + 8, ScrH() / 2 - 198)
		surface.DrawLine(ScrW() / 2 - 12, ScrH() / 2 - 202, ScrW() / 2 + 12, ScrH() / 2 - 202)
		surface.DrawLine(ScrW() / 2, ScrH() / 2 - 214, ScrW() / 2 - 8, ScrH() / 2 - 230)
		surface.DrawLine(ScrW() / 2, ScrH() / 2 - 214, ScrW() / 2 + 8, ScrH() / 2 - 230)
		surface.DrawLine(ScrW() / 2 - 4, ScrH() / 2 + 194, ScrW() / 2 + 4, ScrH() / 2 + 194)
		surface.DrawLine(ScrW() / 2 - 8, ScrH() / 2 + 198, ScrW() / 2 + 8, ScrH() / 2 + 198)
		surface.DrawLine(ScrW() / 2 - 12, ScrH() / 2 + 202, ScrW() / 2 + 12, ScrH() / 2 + 202)
		surface.DrawLine(ScrW() / 2, ScrH() / 2 + 214, ScrW() / 2 - 8, ScrH() / 2 + 230)
		surface.DrawLine(ScrW() / 2, ScrH() / 2 + 214, ScrW() / 2 + 8, ScrH() / 2 + 230)
		--fuel dispenser icon
		surface.DrawLine(ScrW() / 2 + 264, ScrH() / 2 - 150, ScrW() / 2 + 272, ScrH() / 2 - 150)
		surface.DrawLine(ScrW() / 2 + 264, ScrH() / 2 - 150, ScrW() / 2 + 264, ScrH() / 2 - 144)
		surface.DrawLine(ScrW() / 2 + 271, ScrH() / 2 - 150, ScrW() / 2 + 271, ScrH() / 2 - 144)
		surface.DrawRect(ScrW() / 2 + 264, ScrH() / 2 - 144, 8, 12)
		surface.DrawLine(ScrW() / 2 + 271, ScrH() / 2 - 150, ScrW() / 2 + 273, ScrH() / 2 - 150)
		surface.DrawLine(ScrW() / 2 + 273, ScrH() / 2 - 150, ScrW() / 2 + 277, ScrH() / 2 - 144)
		surface.DrawLine(ScrW() / 2 + 277, ScrH() / 2 - 144, ScrW() / 2 + 277, ScrH() / 2 - 135)
		surface.DrawLine(ScrW() / 2 + 273, ScrH() / 2 - 136, ScrW() / 2 + 275, ScrH() / 2 - 134)
		surface.DrawLine(ScrW() / 2 + 273, ScrH() / 2 - 135, ScrW() / 2 + 277, ScrH() / 2 - 135)
		surface.DrawLine(ScrW() / 2 + 273, ScrH() / 2 - 142, ScrW() / 2 + 273, ScrH() / 2 - 134)
		surface.DrawLine(ScrW() / 2 + 271, ScrH() / 2 - 144, ScrW() / 2 + 273, ScrH() / 2 - 142)
		--text
		draw.SimpleText("VP " .. math.floor(LocalPlayer():GetNWVector("toybox_629_rocketpos").x * 100) / 100 .. "/" .. math.floor(LocalPlayer():GetNWVector("toybox_629_rocketpos").y * 100) / 100 .. "/" .. math.floor(LocalPlayer():GetNWVector("toybox_629_rocketpos").z * 100) / 100, "ArialNarrow18", ScrW() / 2, ScrH() / 2 - 256, Color(255, 255, 255, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("DTT " .. math.floor(LocalPlayer():GetNWVector("toybox_629_rocketpos"):Distance(LocalPlayer():GetNWVector("toybox_629_dtt")) * 100) / 100, "ArialNarrow18", ScrW() / 2 - 208, ScrH() / 2, Color(255, 255, 255, 191), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText("DFO " .. math.floor(LocalPlayer():GetNWVector("toybox_629_rocketpos"):Distance(LocalPlayer():GetPos()) * 100) / 100, "ArialNarrow18", ScrW() / 2, ScrH() / 2 + 256, Color(255, 255, 255, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		local TextPrimary = markup.Parse("<font=ArialNarrow18><color=255,255,255,255>Press </color><color=255,255,0,255>PRIMARY</color><color=255,255,255,255> to boost</color></font>")
		local TextSecondary = markup.Parse("<font=ArialNarrow18><color=255,255,255,255>Press </color><color=255,255,0,255>SECONDARY</color><color=255,255,255,255> to detonate</color></font>")
		TextPrimary:Draw(64, ScrH() - 74, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		TextSecondary:Draw(64, ScrH() - 48, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local function ValkyrieDrawMarkers()
		for _, allents in ipairs(ents.GetAll()) do
			if allents:IsPlayer() or allents.IsNPC() then
				local entpos = allents:GetPos() + allents:OBBCenter()
				local Gap = 32

				if SmallGap then
					Gap = 16
				else
					Gap = 32
				end

				if allents:IsPlayer() and (allents == LocalPlayer()) then
					surface.SetDrawColor(0, 255, 0, 255)
					surface.DrawLine(entpos:ToScreen().x - Gap, entpos:ToScreen().y, entpos:ToScreen().x, entpos:ToScreen().y - Gap)
					surface.DrawLine(entpos:ToScreen().x, entpos:ToScreen().y - Gap, entpos:ToScreen().x + Gap, entpos:ToScreen().y)
					surface.DrawLine(entpos:ToScreen().x + Gap, entpos:ToScreen().y, entpos:ToScreen().x, entpos:ToScreen().y + Gap)
					surface.DrawLine(entpos:ToScreen().x, entpos:ToScreen().y + Gap, entpos:ToScreen().x - Gap, entpos:ToScreen().y)
				else
					surface.SetDrawColor(255, 0, 0, 255)
					surface.DrawLine(entpos:ToScreen().x - Gap, entpos:ToScreen().y, entpos:ToScreen().x, entpos:ToScreen().y - Gap)
					surface.DrawLine(entpos:ToScreen().x, entpos:ToScreen().y - Gap, entpos:ToScreen().x + Gap, entpos:ToScreen().y)
					surface.DrawLine(entpos:ToScreen().x + Gap, entpos:ToScreen().y, entpos:ToScreen().x, entpos:ToScreen().y + Gap)
					surface.DrawLine(entpos:ToScreen().x, entpos:ToScreen().y + Gap, entpos:ToScreen().x - Gap, entpos:ToScreen().y)
				end
			end
		end
	end

	local function ValkyrieHUDUpdateFuelBarSpeed()
		if net.ReadBool() then
			HUDFuelEndTime = ((HUDFuelEndTime - CurTime()) / 3) + CurTime()
			HUDMultiplier = 3
		else
			HUDFuelEndTime = ((HUDFuelEndTime - CurTime()) * 3) + CurTime()
			HUDMultiplier = 1
		end
	end

	local function ValkyrieDrawFuelBar()
		local BarBottomLeftX, BarBottomLeftY = ScrW() / 2 + 240, ScrH() / 2 + 150
		surface.SetDrawColor(191, 191, 191, 191)
		surface.DrawRect(BarBottomLeftX, BarBottomLeftY - 300, 16, 300)

		if math.ceil((HUDFuelEndTime - CurTime()) * 10) >= 1 then
			surface.SetDrawColor(255 - math.floor((HUDFuelEndTime - CurTime()) * 10) / (150 / HUDMultiplier) * 255, math.floor((HUDFuelEndTime - CurTime()) * 10) / (150 / HUDMultiplier) * 255, 0, 255)
			surface.DrawRect(BarBottomLeftX, BarBottomLeftY - math.ceil((HUDFuelEndTime - CurTime()) * 10) * HUDMultiplier * 2, 16, math.ceil((HUDFuelEndTime - CurTime()) * 10) * HUDMultiplier * 2)
		end
	end

	local function ValkyrieDrawDeadScreen()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetTexture(surface.GetTextureID("effects/security_noise2"))
		surface.DrawTexturedRectUV(math.random(-128, 0), math.random(-128, 0), ScrW() + 128, ScrH() + 128, 256, 256, 256, 256)
	end

	local function ValkyrieKillHUD(elem)
		if elem == "CHudWeaponSelection" or elem == "CHudSuitPower" or elem == "CHudHealth" or elem == "CHudBattery" or elem == "CHudAmmo" or elem == "CHudSecondaryAmmo" or elem == "CHudCrosshair" then return false end
	end

	local function ValkyrieHUDCreate()
		if timer.Exists("toybox_629_killhooks") then
			hook.Remove("HUDShouldDraw", "toybox_629_hidehud")
			hook.Remove("HUDPaint", "toybox_629_hud")
			hook.Remove("HUDPaintBackground", "toybox_629_signallost")
			hook.Remove("RenderScreenspaceEffects", "toybox_629_visualeffects")
			timer.Remove("toybox_629_killhooks")
		end

		HUDMultiplier = 1
		HUDFuelEndTime = CurTime() + 15
		hook.Add("HUDShouldDraw", "toybox_629_hidehud", ValkyrieKillHUD)
		hook.Add("HUDPaint", "toybox_629_hud", ValkyrieDrawMissileHUD)
		hook.Add("HUDPaint", "toybox_629_hudFuel", ValkyrieDrawFuelBar)
		SmallGap = false

		timer.Create("toybox_629_squaresize", 0.5, 0, function()
			SmallGap = not SmallGap
		end)

		hook.Add("HUDPaint", "toybox_629_hudMarkers", ValkyrieDrawMarkers)
		hook.Add("RenderScreenspaceEffects", "toybox_629_visualeffects", ValkyrieColorModification)
	end

	local function ValkyrieHUDDestroy()
		hook.Remove("HUDPaint", "toybox_629_hudFuel")
		hook.Remove("HUDPaint", "toybox_629_hudMarkers")

		if timer.Exists("toybox_629_squaresize") then
			timer.Remove("toybox_629_squaresize")
		end

		hook.Add("HUDPaintBackground", "toybox_629_signallost", ValkyrieDrawDeadScreen)

		timer.Create("toybox_629_killhooks", 1, 1, function()
			hook.Remove("HUDShouldDraw", "toybox_629_hidehud")
			hook.Remove("HUDPaint", "toybox_629_hud")
			hook.Remove("HUDPaintBackground", "toybox_629_signallost")
			hook.Remove("RenderScreenspaceEffects", "toybox_629_visualeffects")
		end)
	end

	net.Receive("ToyBoxReworked_toybox_629_enablehooks", ValkyrieHUDCreate)
	net.Receive("ToyBoxReworked_toybox_629_disablehooks", ValkyrieHUDDestroy)
	net.Receive("ToyBoxReworked_toybox_629_fuelbarspeed", ValkyrieHUDUpdateFuelBarSpeed)
end

scripted_ents.Register(Missile, "toybox_629_valkyrie_cr")