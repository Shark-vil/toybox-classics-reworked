AddCSLuaFile()

if CLIENT then
	language.Add("weapon_valkyrierockets", "Valkyrie Rockets")

	surface.CreateFont("ArialNarrow18", {
		font = "Arial Narrow",
		size = 18,
		weight = 600
	})
end

SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Valkyrie Rockets"
SWEP.Purpose = "Control Valkyrie rockets from Call of Duty: Black Ops."
SWEP.Instructions = "Primary to fire rocket. When rocket is in air, use mouse or movement keys to control rocket, primary fire to toggle boost and secondary fire to detonate in air."
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false
SWEP.ViewModel = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"
SWEP.Author = "SiPlus, Treyarch"
SWEP.Contact = "http://steamcommunity.com/id/SiPlus"

function SWEP:Initialize()
	util.PrecacheSound("weapons/rpg/rocketfire1.wav")
	self:SetWeaponHoldType("rpg")
	self:SetDeploySpeed(1)
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:PrimaryAttack()
	if SERVER then
		local owner = self:GetOwner()
		if owner:WaterLevel() >= 2 then return end
		if owner.CanFireNewRocket == false then return end
		self.Rocket = ents.Create("toybox_629_valkyrie_cr")
		local SpawnOrExplode = {}
		SpawnOrExplode.Start = owner:GetPos()
		SpawnOrExplode.Endpos = owner:GetPos() + (owner:GetAimVector() * 40)

		SpawnOrExplode.Filter = {owner}

		local SpawnOrExplodeTrace = util.TraceLine(SpawnOrExplode)

		if SpawnOrExplodeTrace.Hit == true then
			self.Rocket:SetPos(owner:GetPos() + (owner:GetForward() * 150) + Vector(0, 0, 36))
		else
			self.Rocket:SetPos(owner:GetPos() + Vector(0, 0, 36))
		end

		self.Rocket:SetAngles(owner:GetAngles())
		self.Rocket:SetVar("MissileOwner", owner)
		self.Rocket:SetVar("MissileLauncher", self)
		self.Rocket:SetVar("OldMoveType", owner:GetMoveType())
		self.Rocket:Spawn()

		if SERVER then
			net.Start("ToyBoxReworked_toybox_629_enablehooks")
			net.Send(owner)
			self:EmitSound("weapons/rpg/rocketfire1.wav")
			--owner:SendLua("surface.PlaySound('weapons/rpg/rocketfire1.wav')")
			print("ACTIVATE!")
		end

		owner:SetViewEntity(self.Rocket)
		owner:SetMoveType(MOVETYPE_NONE)
		owner.CanFireNewRocket = false
	end
end

function SWEP:Think()
	if CLIENT then return end

	if IsValid(self.Rocket) then
		self.Rocket:SetAngles(Angle(math.Clamp(self.Rocket:GetAngles().p + (self:GetOwner():GetCurrentCommand():GetMouseY() / 32), -89, 89), self.Rocket:GetAngles().y - (self:GetOwner():GetCurrentCommand():GetMouseX() / 32), 0))
	end

	self:NextThink(0.02)
end

function SWEP:DoReloadingAnimation()
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self:SetNextPrimaryFire(CurTime() + 1.5)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end