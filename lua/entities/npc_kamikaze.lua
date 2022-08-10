AddCSLuaFile()
ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Kamikaze"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"

if CLIENT then
	language.Add("npc_kamikaze", "Kamikaze")
end

function ENT:Initialize()
	self:SetModel("models/Humans/Group01/male_07.mdl")
	util.PrecacheSound("npc/zombie/zo_attack2.wav")
	self.Speed = 200
	self.Injured = false
	self.InjuredVoice = false
	self.SwingTimer = 0
	self.VoiceTimer = 0
	self.WanderTimer = 0
	self.Exploded = false

	if SERVER then
		self:SetMaxHealth(22)
	end

	self:SetHealth(22)
	self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Head1"), Vector(0.001, 0.001, 0.001))
	self:SetSubMaterial(2, "models/flesh")

	if CLIENT then
		self.Emitter = ParticleEmitter(self:GetPos())
		self.LeftBomb = ClientsideModel("models/props_phx/cannonball.mdl")
		self.LeftBomb:SetParent(self)
		self.LeftBomb:SetModelScale(0.2, 0)
		self.RightBomb = ClientsideModel("models/props_phx/cannonball.mdl")
		self.RightBomb:SetParent(self)
		self.RightBomb:SetModelScale(0.2, 0)
		self.LeftBomb.LastSmoke = 0
		self.LeftBomb.SmokeDelay = 1 / 10
		self.LeftBomb.Emitter = self.Emitter
		self.LeftBomb:DrawShadow(false)
		self.RightBomb:DrawShadow(false)
	end
end

function ENT:Think()
	self:FindEnemy()
	self:AlertAllies()
	self:ExplosionCheck()

	if self.SwingTimer ~= 0 and self.SwingTimer < CurTime() then
		self.SwingTimer = 0
		self.Injured = false
		self.InjuredVoice = false
		self:SetNWBool("injured", false)
		self:StartActivity(ACT_RUN)
		self.Speed = 200
		self.loco:SetDesiredSpeed(130)

		return
	end

	--self:StartActivity( ACT_RUN )
	if self.Injured == true and self.SwingTimer == 0 then
		self:SetNWBool("injured", true)
		self.Speed = 0
		self.loco:SetDesiredSpeed(0)
		self:StartActivity(ACT_IDLE)
		self:ResetSequenceInfo()
		self:ResetSequence("photo_react_startle")
		self:SetPlaybackRate(3)
		self:EmitSound("vo/npc/male01/pain03.wav", 100, 33)
		self:StopScreaming()
		self.SwingTimer = CurTime() + self:SequenceDuration()
	end

	if CLIENT and self:GetNWBool("injured") and self:LookupBone("ValveBiped.Bip01_L_Clavicle") then
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_Clavicle"), Angle(0, 0, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_UpperArm"), Angle(-40, 0, -90))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_ForeArm"), Angle(0, -60, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_Hand"), Angle(0, 0, -90))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_Clavicle"), Angle(0, 0, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_UpperArm"), Angle(40, 0, 90))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_ForeArm"), Angle(-0, -60, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(-20, 0, 90))
	elseif CLIENT and self:LookupBone("ValveBiped.Bip01_L_Clavicle") then
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_Clavicle"), Angle(0, 0, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_UpperArm"), Angle(-40, 0, -140))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_ForeArm"), Angle(0, 30, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_Hand"), Angle(0, 0, -90))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_Clavicle"), Angle(0, 0, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_UpperArm"), Angle(30, 15, 120))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_ForeArm"), Angle(-0, 40, 0))
		self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(-20, 0, 90))
	end

	if CLIENT and IsValid(self.LeftBomb) and self:LookupAttachment("anim_attachment_LH") ~= 0 then
		local leftnpos, leftnang = LocalToWorld(Vector(-1.3, -2.3, -4), Angle(), self:GetAttachment(self:LookupAttachment("anim_attachment_LH")).Pos, self:GetAttachment(self:LookupAttachment("anim_attachment_LH")).Ang)
		local rightnpos, rightnang = LocalToWorld(Vector(-1.3, 2.3, -4), Angle(), self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Pos, self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Ang)
		self.LeftBomb:SetPos(leftnpos)
		self.RightBomb:SetPos(rightnpos)
		self.LeftBomb:SetAngles(leftnang)
		self.RightBomb:SetAngles(rightnang)
	end

	self:StartScreaming()
end

--[[1:
		id	=	1
		name	=	eyes
2:
		id	=	2
		name	=	mouth
3:
		id	=	3
		name	=	chest
4:
		id	=	4
		name	=	forward
5:
		id	=	5
		name	=	anim_attachment_RH
6:
		id	=	6
		name	=	anim_attachment_LH
7:
		id	=	7
		name	=	anim_attachment_head
1:
		id	=	1
		name	=	eyes
2:
		id	=	2
		name	=	mouth
3:
		id	=	3
		name	=	chest
4:
		id	=	4
		name	=	forward
5:
		id	=	5
		name	=	anim_attachment_RH
6:
		id	=	6
		name	=	anim_attachment_LH
7:
		id	=	7
		name	=	anim_attachment_head
]]
function ENT:OnInjured(dmginfo)
	self.Injured = true
end

function ENT:OnKilled(dmginfo)
	hook.Call("OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor())
	self:Explode(dmginfo)
end

function ENT:StartScreaming()
	if not self.Screaming then
		self.Screaming = CreateSound(self, "npc/kamikaze/AttackKamikaze.wav")
	end

	if not IsValid(self:GetNWEntity("enemy")) or self:GetNWBool("injured") then
		self:StopScreaming()

		return
	end

	self.IsScreaming = true
	self.Screaming:SetSoundLevel(90)
	self.Screaming:Play()
end

function ENT:StopScreaming()
	self.IsScreaming = false

	if self.Screaming then
		self.Screaming:Stop()
	end
end

function ENT:AlertAllies(enemy)
	local pos = self:GetPos()
	local range = self.AlertRange
	local items = ents.FindByClass("npc_kamikaze")

	for k, v in ipairs(items) do
		if (v:GetPos():Distance(pos) < 600) and IsValid(self:GetNWEntity("enemy")) and v ~= self then
			if not IsValid(v:GetNWEntity("enemy")) then
				v:SetNWEntity("enemy", self:GetNWEntity("enemy"))
			end
		end
	end
end

function ENT:Explode(dmginfo)
	if self.Exploded then return end
	self.Injured = false
	self:SetNWBool("injured", false)
	self.Exploded = true
	self:StopScreaming()
	local edata = EffectData()
	edata:SetOrigin(self:GetPos() + self:OBBCenter() + Vector(0, 0, 12))
	edata:SetAngles(self:GetAngles())
	edata:SetNormal(vector_up)
	edata:SetMagnitude(400)
	util.Effect("sam_kamikaze_gib", edata, true, true)

	--[[	local legs = ents.Create("prop_ragdoll")
	legs:SetAngles(self:GetAngles())
	legs:SetPos(self:GetPos()+Vector(0, 0, 16))
	legs:SetModel("models/Zombie/Classic_legs.mdl")
	legs:Spawn()
	legs:SetVelocity(Vector(0, 0, 300))
	legs:Fire("FadeAndRemove", "", 13)
	legs:SetCollisionGroup(COLLISION_GROUP_DEBRIS)]]
	if SERVER then
		local exp = ents.Create("env_explosion")
		exp:SetOwner(attacker)
		exp:SetPos(self:GetPos() + self:OBBCenter())
		exp:SetKeyValue("iMagnitude", 75)
		exp:SetKeyValue("iRadiusOverride", 120)
		exp.KamikazeExplosion = true
		exp:Spawn()
		exp:Fire("explode")
	end

	self:SetModel("models/Zombie/Classic_legs.mdl")
	self:SetPos(self:GetPos() + Vector(0, 0, 16))

	if SERVER then
		self:BecomeRagdoll(dmginfo)
	end

	self:SetVelocity(Vector(0, 0, 300))

	for k, v in ipairs(ents.FindByClass("serioussurprise")) do
		if IsValid(v) then
			v:SetNWFloat("score", v:GetNWFloat("score") + 1)
		end
	end

	--[[if IsValid(self:GetOwner()) and self:GetOwner():GetClass() == "serioussurprise" then
		self:GetOwner():SetNWFloat("score", self:GetOwner():GetNWFloat("score") + 1)
	end]]
	self:Remove()
end

-- This was broke in GMod 12
function ENT:DoSmoke(bomb)
end

--[[	if ((CurTime()-bomb.LastSmoke) < bomb.SmokeDelay) then
		return;
	end
	local part = bomb.Emitter:Add("particles/smokey", bomb:GetPos() + Vector(0,0,3));
	if (part) then
		part:SetDieTime(0.5);
		part:SetStartSize(math.random(4,9));
		part:SetEndSize(math.random(14, 18));
		part:SetStartAlpha(255);
		part:SetEndAlpha(0);
		part:SetVelocity(self:GetVelocity());
		part:SetAirResistance(0.5);
		part:SetRollDelta(math.random(-3, 3));
		part:SetColor(130, 130, 130);
	end
	bomb.LastSmoke = CurTime();]]
function ENT:OnRemove()
	--self:Explode()
	self:StopScreaming()
	self:RemoveBombs()
end

function ENT:RemoveBombs()
	if CLIENT and IsValid(self.LeftBomb) then
		print("CLIENT")
		print(self.LeftBomb)
		self.LeftBomb:Remove()
		self.RightBomb:Remove()
	end
end

function ENT:RunBehaviour()
	while true do
		if self.Injured == false and IsValid(self:GetNWEntity("enemy")) then
			self:StartActivity(ACT_RUN)
			self:Move()
		else
			self:StartActivity(ACT_IDLE)
		end

		--[[elseif self.Injured == false and !IsValid(self:GetNWEntity("enemy")) then
			self:StartActivity( ACT_WALK )
			self.loco:SetDesiredSpeed( 100 )
			self:MoveToPos(self:FindSpot("random", {type = "hiding", radius = 5000}))
			self:StartActivity( ACT_IDLE )
		end]]
		coroutine.wait(1)
	end
end

function ENT:ExplosionCheck()
	local players = player.GetAll()

	for k, v in ipairs(players) do
		local distance = v:GetPos():Distance(self:GetPos())

		if distance < 90 and v:Alive() and self:GetNWBool("injured") == false then
			self:Explode(DamageInfo())
			self:RemoveBombs()
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

		coroutine.yield()
	end

	return
end

function ENT:FindEnemy()
	local players = player.GetAll()
	local distance = 9999
	local target = players[1]

	for k, v in ipairs(players) do
		local distanceplayer = v:GetPos():Distance(self:GetPos())

		if distance > distanceplayer then
			distance = distanceplayer
			target = v
		end
	end

	--print(player:Nick().." is the closest!")
	self:SetNWEntity("enemy", target)

	return target
end

util.PrecacheModel("models/Gibs/Antlion_gib_medium_2.mdl") --Arm
util.PrecacheModel("models/Gibs/HGIBS_spine.mdl") --Spine
util.PrecacheModel("models/Gibs/Antlion_gib_medium_1.mdl") --Innards
util.PrecacheModel("models/props_junk/watermelon01_chunk01a.mdl") --Chest

if CLIENT then
	local EFFECT = {}
	local vec_arm_l = Vector(0, 11, 0)
	local vec_arm_r = Vector(0, -11, 0)
	local angle_zero = Angle(0, 0, 0)
	local ang_chest = Angle(90, -90, 0)
	local ang_arm_l = Angle(180, 90, 90)
	local ang_arm_r = Angle(180, -90, 90)

	function EFFECT:Init(data)
		local pos = data:GetOrigin()
		local normal = data:GetNormal()
		local magnitude = data:GetMagnitude()
		local ang = data:GetAngles()
		local edata = EffectData()
		--Chest
		local gibpos, gibang = LocalToWorld(vector_origin, ang_chest, pos, ang)
		edata:SetOrigin(gibpos)
		edata:SetStart((normal + VectorRand() * 0.3) * magnitude)
		edata:SetAngles(gibang)
		edata:SetHitBox(1)
		util.Effect("sam_kamikaze_giblet", edata)
		edata:SetNormal(edata:GetStart():GetNormalized())
		edata:SetFlags(0xFF)
		edata:SetColor(BLOOD_COLOR_RED)
		edata:SetScale(10)
		util.Effect("bloodspray", edata)
		--Left Arm
		local gibpos, gibang = LocalToWorld(vec_arm_l, ang_arm_l, pos, ang)
		edata:SetOrigin(gibpos)
		edata:SetAngles(gibang)
		edata:SetStart((normal + VectorRand() * 0.3) * magnitude)
		--edata:SetStart(((gibpos-pos):GetNormalized()+VectorRand()*0.3)*self.magnitude)
		edata:SetHitBox(2)
		util.Effect("sam_kamikaze_giblet", edata)
		edata:SetNormal(edata:GetStart():GetNormalized())
		edata:SetFlags(0xFF)
		edata:SetColor(BLOOD_COLOR_RED)
		edata:SetScale(10)
		util.Effect("bloodspray", edata)
		--Right Arm
		local gibpos, gibang = LocalToWorld(vec_arm_r, ang_arm_r, pos, ang)
		edata:SetOrigin(gibpos)
		edata:SetAngles(gibang)
		edata:SetStart((normal + VectorRand() * 0.3) * magnitude)
		--edata:SetStart(((gibpos-pos):GetNormalized()+VectorRand()*0.3)*self.magnitude)
		edata:SetHitBox(2)
		util.Effect("sam_kamikaze_giblet", edata)
		edata:SetNormal(edata:GetStart():GetNormalized())
		edata:SetFlags(0xFF)
		edata:SetColor(BLOOD_COLOR_RED)
		edata:SetScale(10)
		util.Effect("bloodspray", edata)
	end

	function EFFECT:Think()
		return false
	end

	function EFFECT:Render()
		return false
	end

	effects.Register(EFFECT, "sam_kamikaze_gib")
end

if CLIENT then
	local EFFECT = {}
	EFFECT.RenderGroup = RENDERGROUP_BOTH

	local models = {"models/props_junk/watermelon01_chunk01a.mdl", "models/Gibs/Antlion_gib_medium_2.mdl"}

	function EFFECT:Init(data)
		self.DeathTime = CurTime() + 15
		self:EmitSound("Flesh_Bloody.ImpactHard")
		self:SetPos(data:GetOrigin())
		self:SetAngles(data:GetAngles())
		self:SetMaterial("models/flesh")
		self:SetModel(models[data:GetHitBox()])
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		local phys = self:GetPhysicsObject()

		if phys:IsValid() then
			phys:SetMaterial("watermelon")
			phys:SetVelocity(data:GetStart())
			phys:AddAngleVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50)))
		end

		self.em = ParticleEmitter(self:GetPos())
		self.nextSteam = 15 - 0.1
	end

	local decalTrace = {}
	decalTrace.mask = MASK_SOLID
	local grav_smoke = Vector(0, 0, 30)

	function EFFECT:Think()
		local phys = self:GetPhysicsObject()

		if phys:IsValid() and not phys:IsAsleep() then
			decalTrace.filter = self
			decalTrace.start = self:GetPos()
			decalTrace.endpos = decalTrace.start + self:GetVelocity() * (FrameTime() * 8)
			local tr = util.TraceLine(decalTrace)

			if tr.Hit then
				util.Decal("blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			end
		end

		local lifeleft = self.DeathTime - CurTime()

		if not isnumber(self.nextSteam) then
			self.nextSteam = 15 - 0.1
		end

		if not IsValid(self.em) then
			self.em = ParticleEmitter(self:GetPos())
		end

		if self.nextSteam > lifeleft then
			self.nextSteam = self.nextSteam - (2 / lifeleft)
			local part = self.em:Add("particles/smokey", self:GetPos())

			if part then
				part:SetDieTime(2 * (lifeleft / 15))
				part:SetStartSize(math.random(4, 9) * (lifeleft / 15) * 3)
				part:SetEndSize(math.random(14, 18))
				part:SetStartAlpha(60 * (lifeleft / 15))
				part:SetEndAlpha(0)
				part:SetRollDelta(math.random(-3, 3))
				part:SetColor(170, 170, 170)
				part:SetGravity(grav_smoke)
			end
		end

		if lifeleft <= 0 then
			self:Remove()

			return false
		end

		return true
	end

	function EFFECT:Render()
		local lifeleft = self.DeathTime - CurTime()

		if lifeleft <= 2 then
			render.SetBlend(lifeleft * 0.5)
		end

		self:DrawModel()
		render.SetBlend(1)
	end

	effects.Register(EFFECT, "sam_kamikaze_giblet")
end