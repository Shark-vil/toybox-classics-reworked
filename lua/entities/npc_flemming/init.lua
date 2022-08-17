local coroutine_wait, coroutine_yield, ents_Create, include, math_abs, math_acos, math_cos, math_random, math_sqrt, player_GetAll, util_PrecacheSound, Vector, CurTime, ipairs, IsValid, Path, isentity, timer_Simple = coroutine.wait, coroutine.yield, ents.Create, include, math.abs, math.acos, math.cos, math.random, math.sqrt, player.GetAll, util.PrecacheSound, Vector, CurTime, ipairs, IsValid, Path, isentity, timer.Simple

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local attack_distance_sqr = 40 ^ 2

function ENT:Initialize()
	self:SetModel("models/humans/group01/male_04.mdl")
	util_PrecacheSound("npc/zombie/zo_attack2.wav")
	self.IsBob = true
	self.Width = self:BoundingRadius() * 1
	self.Speed = 200
	self.Swinged = false
	self.SwingedVoice = false
	self.SwingTimer = 0
	self.VoiceTimer = 0
	self.HasCleanupMap = false
	self:SetHealth(math_random(92220, 112220))
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Head1"), Vector(2, 2, 2))

	hook.Add("PreCleanupMap", self, function()
		self.HasCleanupMap = true
	end)
end

function ENT:Think()
	self:FindEnemy()
	--self:DidHit()
	self:Hit()

	if self.SwingTimer ~= 0 and self.SwingTimer < CurTime() then
		self.SwingTimer = 0
		--print("Finished.")
		self.Swinged = false
		self.SwingedVoice = false
		self:StartActivity(ACT_RUN)
		self.Speed = 200
		self.loco:SetDesiredSpeed(200)

		return
	end

	--self:StartActivity( ACT_RUN )
	if self.Swinged == true and self.SwingTimer == 0 then
		self.loco:FaceTowards(self:GetNWEntity("enemy"):GetPos())
		--self:SetAngles(Angle(self:GetAngles().p, self:GetNWEntity("enemy"):GetPos():Angle().yaw, self:GetAngles().r))
		self.Speed = 0
		self.loco:SetDesiredSpeed(0)
		self:StartActivity(ACT_IDLE)
		self:ResetSequenceInfo()
		self:ResetSequence("swing")
		self:SetPlaybackRate(3)
		self:EmitSound("vo/npc/male01/hi0" .. math_random(1, 2) .. ".wav")
		self.SwingTimer = CurTime() + self:SequenceDuration()
	end
end

function ENT:RunBehaviour()
	while true do
		if self.Swinged == false then
			self:StartActivity(ACT_RUN)
			self:Move()
			self:EmitSound("vo/npc/male01/hi0" .. math_random(1, 2) .. ".wav")
		end

		coroutine_wait(2)
	end
end

function ENT:Hit()
	local players = player_GetAll()

	for k, v in ipairs(players) do
		local distance = v:GetPos():DistToSqr(self:GetPos())

		if distance < attack_distance_sqr and v:Alive() and self.Swinged == false then
			self.Swinged = true
			v:EmitSound("Flesh.ImpactHard")
			v:TakeDamage(1, self, self)
		elseif distance > attack_distance_sqr then
			self.SwingedVoice = false

			if math_random(1, 3) == 2 and self:Eyes() and self.VoiceTimer ~= 0 and self.VoiceTimer < CurTime() then
				self:EmitSound("vo/npc/male01/hi0" .. math_random(1, 2) .. ".wav")
				self.VoiceTimer = 0
			elseif self.VoiceTimer == 0 then
				self.VoiceTimer = CurTime() + 1
			end
		end
	end
end

function ENT:Move()
	if not IsValid(self:GetNWEntity("enemy")) then return end
	local enemy = self:GetNWEntity("enemy")
	self.loco:SetDesiredSpeed(self.Speed or 200)
	local path = Path("Follow")
	path:Compute(self, enemy:GetPos())
	if not path:IsValid() then return end

	while path:IsValid() and IsValid(enemy) do
		if path:GetAge() > 0.1 then
			path:Compute(self, enemy:GetPos())
		end

		path:Update(self)

		--path:Draw()
		if self.loco:IsStuck() then
			self:HandleStuck()

			return
		end

		coroutine_yield()
	end

	return
end

function ENT:Eyes()
	if not IsValid(self:GetNWEntity("enemy")) then return end
	local enemy = self:GetNWEntity("enemy")
	if not enemy:Alive() then return true end
	local ViewEnt = enemy:GetViewEntity()
	--if ViewEnt == self.Victim and not self:HasVictimLOS() then return false end
	local fov = enemy:GetFOV()
	local Disp = self:GetPos() - ViewEnt:GetPos()
	local Dist = Disp:Length()
	local MaxCos = math_abs(math_cos(math_acos(Dist / math_sqrt(Dist * Dist + self.Width * self.Width)) + fov * (math.pi / 180)))
	Disp:Normalize()
	if Disp:Dot(ViewEnt:EyeAngles():Forward()) > MaxCos then return true end

	return false
end

function ENT:FindEnemy()
	local players = player_GetAll()
	local distance = 9999 ^ 2
	local target = players[1]

	for k, v in ipairs(players) do
		local distanceplayer = v:GetPos():DistToSqr(self:GetPos())

		if distance > distanceplayer then
			distance = distanceplayer
			target = v
		end
	end

	--print(player:Nick().." is the closest!")
	self:SetNWEntity("enemy", target)

	return target
end

function ENT:OnRemove()
	if self.HasCleanupMap then return end

	local flemming = ents_Create(self:GetClass())
	if not IsValid(self) then return end -- doesn't exist!
	if not IsValid(flemming) then return end

	flemming:SetPos(self:GetPos())
	flemming:SetAngles(self:GetAngles())
	flemming:SetMaterial(self:GetMaterial())
	flemming:SetColor(self:GetColor())
	flemming:SetName(self:GetName())
	flemming:SetModel(self:GetModel())
	flemming:SetNoDraw(true)

	timer_Simple(10, function()
		-- you won fair and square, guess i'm gone!
		if IsValid(flemming) and isentity(flemming) then
			flemming:SetNoDraw(false)
			flemming:Activate()
			flemming:Spawn()
		end
	end)
end