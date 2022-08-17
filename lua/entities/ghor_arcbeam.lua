AddCSLuaFile()
local Electrocute

if SERVER then
	local tracep = {}
	tracep.mask = CONTENTS_SOLID
	tracep.mins = Vector(-5, -5, -5)
	tracep.maxs = Vector(5, 5, 5)
	local dmg = DamageInfo()

	--works like util.blast damage but only damages entities in the water and uses shock damage	
	function Electrocute(inflictor, attacker, position, radius, damage, effect)
		for k, v in ipairs(ents.FindInSphere(position, radius)) do
			--waterlevel is acting strange..
			if v:WaterLevel() > 0 then
				tracep.start = position
				tracep.endpos = v:GetPos() + v:OBBCenter()
				local tr = util.TraceHull(tracep)

				if not tr.Hit then
					dmg:SetDamageType(DMG_SHOCK)
					dmg:SetDamage(math.max(1, (1 - (tracep.endpos:Distance(position) / radius)) * damage))
					dmg:SetDamagePosition(tracep.endpos)
					dmg:SetAttacker(attacker)
					dmg:SetInflictor(inflictor)
					dmg:SetDamageForce(tr.Normal * damage * 100)
					v:TakeDamageInfo(dmg)
				end
			end
		end

		if effect then
			net.Start("ToyBoxReworked_scv_elc")
			net.WriteVector(position)
			net.WriteFloat(radius)
			net.Broadcast()
		end
	end
else
	net.Receive("ToyBoxReworked_scv_elc", function()
		local pos = net.ReadVector()
		local radius = net.ReadFloat()
		sound.Play("ambient/explosions/explode_7.wav", pos)
		local dlight = DynamicLight(0)

		if dlight then
			dlight.Pos = pos
			dlight.r = 100
			dlight.g = 100
			dlight.b = 255
			dlight.Brightness = 10
			dlight.Size = radius
			dlight.Decay = radius
			dlight.DieTime = CurTime() + 1
		end
	end)
end

local ENT = {}
ENT.Type = "anim"
ENT.Base = "base_anim"
do
	local range = 350
	ENT.Range = range
	ENT.RangeSqr = range ^ 2
end
ENT.Cone = 50
local tracep = {}
tracep.mask = MASK_SHOT

function ENT:GetTrace(length, filter, mins, maxs, mask)
	if self.Player:IsPlayer() then
		tracep.start = self.Player:GetShootPos()
		tracep.endpos = tracep.start + self.Player:GetAimVector() * length
	else
		local posang = self.Player:GetAttachment(self.Player:LookupAttachment("eyes")) or {
			["Pos"] = self:GetPos(),
			["Ang"] = self:GetAngles()
		}

		tracep.start = posang.Pos
		tracep.endpos = tracep.start + posang.Ang:Forward() * length
	end

	tracep.filter = filter or self.Player
	tracep.mins = mins
	tracep.maxs = maxs
	tracep.mask = mask or MASK_SHOT

	if mins then
		return util.TraceHull(tracep)
	else
		return util.TraceLine(tracep)
	end
end

function ENT:GetMuzzlePosAng()
	local pl = self.Player

	if not IsValid(pl) or not IsValid(self.Weapon) then
		return {self:GetPos(), self:GetAngles()}
	end

	if CLIENT and (pl == GetViewEntity()) then
		local vm = pl:GetViewModel()

		return vm:GetAttachment(vm:LookupAttachment("muzzle"))
	else
		local wep = self.Weapon

		return wep:GetAttachment(1)
	end
end

function ENT:Initialize()
	self:SetColor(Color(255, 255, 255, 254))
	self:SetMoveType(MOVETYPE_NONE)
	self.Weapon = self:GetOwner()
	self.Player = self:GetOwner():GetOwner()

	if not IsValid(self.Player) then
		self:Remove()
		return
	end

	self:SetPos(self.Player:GetPos())
	self:SetParent(self:GetOwner())
	self:AddEffects(EF_NOSHADOW)
	self.Created = CurTime()

	if CLIENT then
		self.dlights = {}
		self.em = ParticleEmitter(self:GetPos())
		self.lerpoffset = 0
		self.BeamRes = 20
		self.DisplacementTable = {}
		self.Wave = VectorRand() * 12
		self.NextWave = VectorRand() * 12
		self.WaveLerp = 0
		self.LastBeamAdvance = CurTime()

		for i = 1, self.BeamRes do
			self.DisplacementTable[i] = LerpVector(0.4, self.DisplacementTable[i - 1] or VectorRand(), VectorRand() * math.Rand(4, 16))
		end
	else
		self:EmitSound("weapons/stunstick/stunstick_impact1.wav", 75, 100)

		if not self.sound then
			self.sound = CreateSound(self, "ambient/energy/electric_loop.wav")
			self.sound:Play()
		end

		self.LastDamage = 0
	end
end

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "endent")
end

function ENT:OnRemove()
	if self.sound then
		self.sound:Stop()
	end
end

if SERVER then
	function ENT:SeekTarget(pos, dir)
		local ent = self
		local currentdist = self.RangeSqr
		local currentang = self.Cone

		for k, v in ipairs(ents.FindInSphere(pos, self.Range)) do
			if v:IsNPC() or (v:IsPlayer() and v ~= self.Player and v:Alive()) then
				local entpos = v:GetPos() + v:OBBCenter()
				local dist = entpos:DistToSqr(pos)

				if dist < currentdist then
					local ang = math.abs(self:EntAng(v, pos, dir))

					if (ang <= self.Cone) and (ang <= currentang) then
						currentang = ang
						currentdist = dist
						ent = v
					end
				end
			end
		end

		return ent
	end

	function ENT:EntAng(ent, pos, dir)
		local entpos = ent:GetPos() + ent:OBBCenter()
		local entang = ent:GetAngles()
		-- local localpos, localang = WorldToLocal(entpos, entang, pos, dir:Angle())
		local localpos, _ = WorldToLocal(entpos, entang, pos, dir:Angle())
		local linedist = math.sqrt(localpos.z ^ 2 + localpos.y ^ 2)
		local ang = math.deg(math.atan2(localpos.x, linedist)) - 90

		return ang
	end

	function ENT:Kill()
		if self.sound then
			self.sound:Stop()
		end
		self.Killed = true
		self:Fire("Kill", nil, 0.1)
	end

	local shocksounds = {"ambient/energy/zap1.wav", "ambient/energy/zap2.wav", "ambient/energy/zap3.wav", "ambient/energy/zap5.wav", "ambient/energy/zap6.wav", "ambient/energy/zap7.wav", "ambient/energy/zap8.wav", "ambient/energy/zap9.wav",}

	function ENT:Think()
		local pl = self.Player
		if self.Killed then return end

		if not IsValid(pl) then
			self:Kill()

			return
		end

		local tr = self:GetTrace(60, nil, nil, nil, bit.bor(MASK_SHOT, CONTENTS_WATER))
		local ent = self.dt.endent
		local pos = self.Player:GetShootPos()
		local ang = self.Player:GetAimVector():Angle()

		if IsValid(ent) then
			local entpos = ent:GetPos() + ent:OBBCenter()
			local dist = entpos:DistToSqr(pos)
			local entconeang = math.abs(self:EntAng(ent, pos, ang:Forward()))

			if ent:GetClass() == "npc_rollermine" then
				ent:Fire("InteractivePowerDown", nil, 0)
			elseif ent:GetClass() == "npc_turret_floor" then
				ent:Fire("SelfDestruct", nil, 0)
			end

			if (dist > self.RangeSqr) or (entconeang > self.Cone) or (ent:IsPlayer() and not ent:Alive()) or (ent:IsNPC() and (ent:Health() <= 0)) then
				self.dt.endent = NULL
				ent = NULL
			else
				if self.LastDamage + 0.1 < CurTime() then
					local dmg = DamageInfo()
					dmg:SetDamageType(DMG_SHOCK)
					dmg:SetDamagePosition(entpos)
					dmg:SetDamage(6)
					dmg:SetAttacker(self.Player)
					dmg:SetInflictor(self)
					dmg:SetDamageForce(vector_origin)
					ent:TakeDamageInfo(dmg)
					self.LastDamage = CurTime()

					if ent:WaterLevel() > 0 then
						Electrocute(self, self.Player, ent:GetPos(), 500, 25, true)
					end
				end

				ent:EmitSound(table.Random(shocksounds))
			end
		end

		local shockself = false

		if self.Player:WaterLevel() > 1 then
			Electrocute(self, self.Player, self.Player:GetShootPos(), 500, 300, true)
			shockself = true
		end

		if not IsValid(ent) then
			if not shockself and (tr.MatType == MAT_SLOSH) then
				Electrocute(self, self.Player, tr.HitPos, 500, 25, true)
			end

			local newent = self:SeekTarget(pos, ang:Forward())

			if newent ~= self then
				self.dt.endent = newent
				self.LastDamage = CurTime()
			elseif IsValid(tr.Entity) then
				if self.LastDamage + 0.1 < CurTime() then
					local dmg = DamageInfo()
					dmg:SetDamageType(DMG_SHOCK)
					dmg:SetDamagePosition(tr.HitPos)
					dmg:SetDamage(6)
					dmg:SetAttacker(self.Player)
					dmg:SetInflictor(self)
					dmg:SetDamageForce(vector_origin)
					tr.Entity:TakeDamageInfo(dmg)
					self.LastDamage = CurTime()
				end
			else
				self.LastDamage = CurTime()
			end
		end
	end
end

if CLIENT then
	-- local beamglowmat1 = Material("sprites/blueglow1")
	local beamglowmat2 = Material("sprites/blueglow2")
	local beammat = Material("sprites/scav_tr_phys")
	local particleglow = Material("sprites/physg_glow1")

	function ENT:Think()
		if not IsValid(self.Player) then return end
		local angpos = self:GetMuzzlePosAng()

		if not angpos or not angpos.Pos then
			angpos = {
				["Pos"] = self:GetPos(),
				["Ang"] = self:GetAngles()
			}
		end

		local pos = angpos.Pos
		local ang = angpos.Ang
		self:SetPos(pos)
		self:SetAngles(ang)
		self:UpdateDLight(0, pos)
		self.WaveLerp = self.WaveLerp + FrameTime() * 8

		if self.WaveLerp < 1 then
			self.Wave = LerpVector(self.WaveLerp, self.Wave, self.NextWave)
		else
			self.WaveLerp = 0
			self.Wave = self.NextWave

			if IsValid(self.dt.endent) then
				self.NextWave = VectorRand() * 18
			else
				self.NextWave = VectorRand() * 3
			end
		end
	end

	function ENT:BuildDLight(ind, pos)
		self.dlights[ind] = DynamicLight(0)
		self.dlights[ind].Pos = pos
		self.dlights[ind].r = 100
		self.dlights[ind].g = 100
		self.dlights[ind].b = 200
		self.dlights[ind].Brightness = 3
		self.dlights[ind].Size = 200
		self.dlights[ind].Decay = 500
		self.dlights[ind].DieTime = CurTime() + 1
	end

	function ENT:UpdateDLight(ind, pos)
		if self.dlights[ind] then
			self.dlights[ind].Pos = pos
			self.dlights[ind].Brightness = 2
			self.dlights[ind].Size = 200
			self.dlights[ind].DieTime = CurTime() + 1
		else
			self:BuildDLight(ind, pos)
		end
	end

	local lasercol = Color(255, 255, 255, 255)
	local glowcol = Color(255, 255, 255, 40)
	local glowcol2 = Color(170, 170, 255, 40)

	function ENT:GetPointOnCurve(lerpvalue, startpos, startguide, endpos, endguide)
		lerpvalue = math.Clamp(lerpvalue, 0, 1)

		return LerpVector(lerpvalue, LerpVector(lerpvalue, startpos, startpos + startguide), LerpVector(lerpvalue, endpos, endpos + endguide))
	end

	function ENT:AdvanceBeam()
		while self.LastBeamAdvance + 0.04 * 10 / self.BeamRes < CurTime() do
			table.insert(self.DisplacementTable, 1, LerpVector(0.4, self.DisplacementTable[1], VectorRand() * math.Rand(4, 16)) + self.Wave)
			self.DisplacementTable[self.BeamRes + 1] = nil
			self.LastBeamAdvance = self.LastBeamAdvance + 0.04 * 10 / self.BeamRes
			self.lerpoffset = 0
		end
	end

	function ENT:Draw()
		if not IsValid(self.Player) then return end
		local angpos = self:GetMuzzlePosAng()

		if not angpos or not angpos.Pos then
			angpos = {
				["Pos"] = self:GetPos(),
				["Ang"] = self:GetAngles()
			}
		end

		local ang = angpos.Ang
		local pos1 = angpos.Pos
		local pos2

		if IsValid(self.dt.endent) then
			pos2 = self.dt.endent:GetPos() + self.dt.endent:OBBCenter()
			glowcol.a = 10
		else
			local tr = self:GetTrace(60)
			pos2 = tr.HitPos
			glowcol.a = 2
		end

		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)
		render.SetMaterial(beamglowmat2)
		local startpos = pos1
		local startguide = vector_origin

		if IsValid(self.dt.endent) then
			starguide = ang:Forward() * math.min(self.Range, pos1:Distance(pos2))
		end

		local endpos = pos2
		self:UpdateDLight(1, endpos)
		local ctime = CurTime() * 80
		self:AdvanceBeam()
		local postable = {}

		do
			local spritepos = self:GetPointOnCurve(0, startpos, startguide, endpos, vector_origin)
			postable[1] = spritepos
			local radius = (1 + math.abs(math.sin(ctime - 1)) * 3) * 8
			render.DrawSprite(spritepos, radius, radius, lasercol)
		end

		for i = 1, self.BeamRes - 1 do
			local spritepos = self:GetPointOnCurve((i + self.lerpoffset) / self.BeamRes, startpos, startguide, endpos, vector_origin) + self.DisplacementTable[i] * math.sin(i * math.pi / self.BeamRes)
			postable[i + 1] = spritepos
			local radius = (1 + math.abs(math.sin(ctime - i)) * 3) * 24
			render.SetMaterial(beamglowmat2)
			render.DrawSprite(spritepos, radius, radius, glowcol)
			render.SetMaterial(particleglow)
			render.DrawSprite(spritepos, 96 - radius, 96 - radius, glowcol2)
		end

		if dodebug then
			dodebug = false
		end

		render.SetMaterial(beammat)
		render.StartBeam(self.BeamRes)
		local mult = 1

		if IsValid(self.dt.endent) then
			mult = 1 + math.abs(math.sin(CurTime() * 4)) * 3
		end

		for i = 1, self.BeamRes do
			render.AddBeam(postable[i], math.Rand(1, 4) * mult, i - 1, lasercol)
		end

		render.EndBeam()
	end
end

scripted_ents.Register(ENT, "ghor_arcbeam", true)