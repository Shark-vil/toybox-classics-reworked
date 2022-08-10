AddCSLuaFile()

if CLIENT then
	language.Add("rchelicopter", "RC Helicopter")
end

ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"

if SERVER then
	NEXTUSE = 0
	CreateConVar("gw_helicopter_rocketspeed", "2000")
	CreateConVar("gw_helicopter_impact_dmg", "0")

	function ENT:SpawnFunction(ply, tr)
		if not tr.Hit then return end
		local SpawnPos = tr.HitPos + Vector(0, 0, 200)
		local ent = ents.Create(ClassName)
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()
		ent.Owner = ply

		return ent
	end

	function ENT:Initialize()
		self.Entity:SetModel("models/combine_helicopter.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:SetColor(Color(255, 255, 255, 0))
		self.Entity:SetCustomCollisionCheck(true)
		self.StrafeSpeed = 200
		self.ForwardSpeed = 300
		--self.ViewPos:SetPos(self.ViewPos:LocalToWorld(Vector(0,-20,-20)))
		self.Rocket1 = Vector(10.3790, 62.3330, -84.9927)
		self.RocketSpeed = GetConVar("gw_helicopter_rocketspeed"):GetInt()
		self.Rocket2 = Vector(13.2264, -62.9697, -84.2544)
		self.VEnt = ents.Create("prop_dynamic")
		self.VEnt:SetPos(self.Entity:GetPos())
		self.VEnt:SetAngles(self.Entity:GetAngles())
		self.VEnt:SetModel("models/combine_helicopter.mdl")
		self.VEnt:SetParent(self.Entity)
		self.VEnt:Spawn()
		self.VEnt:Activate()
		local phys = self.Entity:GetPhysicsObject()

		if phys:IsValid() then
			phys:Wake()
			phys:SetMass(20000)
		end

		self.Color = Color(255, 255, 255, 255)
		self:SetColor(Color(self.Color.r, self.Color.g, self.Color.b, self.Color.a))
		self.VEnt:SetColor(Color(self.Color.r, self.Color.g, self.Color.b, self.Color.a))
		self.InUse = false
		self.User = nil
		self.Entity:SetUseType(SIMPLE_USE)
		self.Sound = CreateSound(self.Entity, "npc/attack_helicopter/aheli_rotor_loop1.wav")
		--    self.Sound = CreateSound(self.Entity,"npc/attack_helicopter/aheli_rotor_loop1.wav")
		self.TimeX = 0
		self.TimeY = 0
		self.TimeZ = 0
		self.LastAttacker = nil
		self.RTimeX = 0
		self.RTimeY = 0
		self.GrenadeBomb = "landmine"
		self.RTimeZ = 0
		self.Gunstate = CurTime()
		self.RoundsLeft = 20
		self.LastBomb = 0
		self.Healthz = 2000
		self.Sploding = false
		--self.GunSound = CreateSound( self.Entity, "npc/attack_helicopter/aheli_weapon_fire_loop3.wav" )
		self.FireUp = CreateSound(self.Entity, "npc/attack_helicopter/aheli_charge_up.wav")
		self:SetPos(self:GetPos() - Vector(0, 0, self:OBBMins().z + 100))
		self.AimingRocket = true
	end

	function ENT:Use(ply, cal)
		if not self.InUse and self.Healthz > 0 and AngTest(self.Entity:GetAngles()) and not self.IsLocked then
			self.InUse = true
			self.User = ply
			local player = ply
			local e = self
			--[[
local ent = ents.Create("prop_dynamic")
ent:SetPos(e:LocalToWorld(Vector(115.8960, 0.3125, -26.6820)))
local es = string.gsub(player:GetModel(),"group02","group01")
 if VehiclePlayerModelFixes[es] then
 ent:SetModel(VehiclePlayerModelFixes[es])


 else
ent:SetModel(player:GetModel())
end
ent:SetAngles(e:GetAngles() )
ent:SetName("das")
ent:Spawn()
if string.find(ent:GetModel(),"player") or string.find(ent:GetModel(),"pmc") then
ent:Fire("setanimation","ACT_HL2MP_SIT")
else
ent:Fire("setanimation","sit")
end
ent:SetParent(e)
ent:SetColor(100,100,100,255)
self.ViewPos = ent
]]
			--
			--    if IsValid(self.ViewPos) then ply:EnterVehicle(self.ViewPos) end
			ply:SetNWEntity("Heli", self.Entity)
			self.VEnt:SetPlaybackRate(1.0)
			self.VEnt:SetSequence(0)
			self.Entity:StartMotionController()
			self.Sound:PlayEx(1, 100)
			self.Entity:GetPhysicsObject():Wake()
			ply:SetNetworkedBool("InChopper", true)
			self.User:SetNWInt("HHealthz", self.Healthz)
			self.User:SetNWInt("HBullets", self.RoundsLeft)
			self.User:SetNWInt("HGunReloadTime", self.Gunstate)
			self.User:SetNWInt("HLastBomb", self.LastBomb)
			self.Entity:SetNWEntity("sh_Entity", self.VEnt)
			self.Entity:SetNWBool("USE", true)
			self.TimeX = 0
			self.TimeY = 0
			self.TimeZ = 0
			self.RWash = ents.Create("env_rotorwash_emitter")
			self.RWash:SetPos(self.Entity:GetPos())
			self.RWash:SetParent(self.Entity)
			self.RWash:Activate()

			hook.Add("ShouldCollide", self, function(_, _, target)
				if not self.InUse then
					hook.Remove("ShouldCollide", self)
					return
				end

				if target == ply then return false end
			end)
		end
	end

	function ENT:PhysicsSimulate(phys, deltatime)
		phys:Wake()
		local poss = phys:GetPos()
		local angg = Angle(0, 0, 0)
		angg.y = self.User:EyeAngles().y
		local forw = angg:Forward():GetNormalized() * self.ForwardSpeed
		local righ = angg:Right():GetNormalized() * self.StrafeSpeed
		local uppp = angg:Up():GetNormalized() * 200

		if self.User:KeyDown(8) then
			poss = poss + forw
			angg.p = angg.p + 30
		end

		if self.User:KeyDown(16) then
			poss = poss - forw
			angg.p = angg.p - 20
		end

		if self.User:KeyDown(1024) then
			poss = poss + righ
			angg.r = angg.r + 25
			angg.y = angg.y - 25
		end

		if self.User:KeyDown(512) then
			poss = poss - righ
			angg.r = angg.r - 25
			angg.y = angg.y + 25
		end

		if self.User:KeyDown(2) then
			poss = poss + uppp
		end

		if self.User:KeyDown(131072) then
			poss = poss - uppp
		end

		self.RTimeX = math.Rand(1, 2.5)
		self.RTimeY = math.Rand(1, 2.5)
		self.RTimeZ = math.Rand(1, 2.5)
		self.TimeX = self.TimeX + (deltatime * self.RTimeX)
		self.TimeY = self.TimeY + (deltatime * self.RTimeY)
		self.TimeZ = self.TimeZ + (deltatime * self.RTimeZ)
		poss.x = poss.x + math.sin(self.TimeX) * 50
		poss.y = poss.y + math.sin(self.TimeY) * 50
		poss.z = poss.z + math.sin(self.TimeZ) * 25
		self.ShadowParams = {}
		self.ShadowParams.secondstoarrive = 1
		self.ShadowParams.pos = poss
		self.ShadowParams.angle = angg
		self.ShadowParams.maxangular = 500000000000
		self.ShadowParams.maxangulardamp = 10000
		self.ShadowParams.maxspeed = 1000000000000000
		self.ShadowParams.maxspeeddamp = 10000
		self.ShadowParams.dampfactor = 0.8
		self.ShadowParams.teleportdistance = 0
		self.ShadowParams.deltatime = deltatime
		phys:ComputeShadowControl(self.ShadowParams)
	end

	function ENT:Think()
		self:NextThink(CurTime() + 0.1)

		if self.Healthz <= 0 then
			self:Splode()
		end

		if not self.InUse then return end
		self.Entity:SetNWEntity("sh_Entity", self.VEnt)
		local phys = self.Entity:GetPhysicsObject()
		local a_velo = phys:GetAngleVelocity()
		local eyes = self.User:EyeAngles()
		local angs = self.Entity:GetAngles()
		local w_p = -eyes.p + angs.p
		w_p = math.Max(-90, w_p)
		w_p = math.Min(20, w_p)
		local w_y = eyes.y - angs.y

		if w_y > 180 then
			w_y = w_y - 360
		end

		if w_y < -180 then
			w_y = 360 + w_y
		end

		w_y = math.Max(-40, w_y)
		w_y = math.Min(40, w_y)
		local rud = a_velo.y * -0.5
		rud = math.Max(-45, rud)
		rud = math.Min(45, rud)
		self.Entity:SetPoseParameter("weapon_pitch", w_p)
		self.VEnt:SetPoseParameter("weapon_pitch", w_p)
		self.Entity:SetPoseParameter("weapon_yaw", w_y)
		self.VEnt:SetPoseParameter("weapon_yaw", w_y)
		self.Entity:SetPoseParameter("rudder", rud)
		self.VEnt:SetPoseParameter("rudder", rud)
		local ptab = self.User:GetTable()
		local cam = nil

		if ptab.UsingCamera then
			cam = ptab.UsingCamera
		end

		local okay = false

		if cam and cam:IsValid() then
			okay = true
		end

		self.User:SetNetworkedBool("UsingCam", okay)

		if self.User:KeyDown(2048) and (not self.NextRocket or self.NextRocket < CurTime()) then
			self.NextRocket = CurTime() + 0.2
			self:FireRocket(Angle(self.Entity:GetAngles().p - w_p, self.Entity:GetAngles().y + w_y, 0))
		end

		if self.User:KeyDown(1) then
			self:FireGun(Angle(self.Entity:GetAngles().p - w_p, self.Entity:GetAngles().y + w_y, 0))
		end

		--if (self.User:KeyDown(1)) then self:ChargeGun(true) else self:ChargeGun(false) end
		if ((self.User:KeyDown(32) and (self.TimeX > 1)) or (self.Entity:WaterLevel() > 1) or (not self.User:Alive())) and not self.CanExit then
			self.CanExit = true

			timer.Simple(0.5, function()
				if IsValid(self) and IsValid(self.User) and IsValid(self.VEnt) and IsValid(self.RWash) then
					self.CanExit = false
					--    if IsValid(self.ViewPos) then self.ViewPos:Remove() end
					self.VEnt:SetPlaybackRate(0)
					self.InUse = false
					self.User.HasChute = true
					self.User:SetNetworkedBool("InChopper", false)
					self.User.WasDead = true
					self.User.Heli = true
					self.User:SetColor(Color(255, 255, 255, 255))
					self.User = nil
					self.Entity:StopMotionController()
					self.Sound:Stop()
					self.RWash:Remove()
					self.Entity:SetNWBool("USE", false)
					hook.Remove("ShouldCollide", self)
				end
			end)
		end

		return true
	end

	function ENT:IsVehicle()
		return true
	end

	function ENT:OnRemove()
		if self.User then
			self.User.Heli = true
			self.User:Spawn()
		end

		self.InUse = false

		if self.User then
			self.User:UnSpectate()
		end

		if self.User then
			self.User:DrawWorldModel(true)
		end

		if self.User then
			self.User:SetNetworkedBool("InChopper", false)
		end

		if self.User then
			self.User.HasChute = true
		end

		if self.User then
			self.User:SetColor(Color(255, 255, 255, 255))
		end

		self.User = nil
		self.Sound:Stop()
		self.Entity:StopMotionController()
		self.Entity:SetNWBool("USE", false)
		hook.Remove("ShouldCollide", self)
	end

	function ENT:FireRocket(angs)
		if self.RoundsLeft > 0 and (not self.NextRS or self.NextRS < CurTime()) then
			self.RoundsLeft = self.RoundsLeft - 2
			self.NextRS = CurTime() + 0.2
			self.Entity:EmitSound("NPC_Helicopter.FireRocket")
			local attach = self.Entity:LookupAttachment("muzzle")
			attach = self.Entity:GetAttachment(attach)
			local pos = attach.Pos
			local rocket = ents.Create("rpg_missile")
			if not rocket:IsValid() then return false end
			rocket:SetAngles(angs)

			if self.RightRocket then
				rocket:SetPos(self:LocalToWorld(self.Rocket2))
				self.RightRocket = false
			else
				rocket:SetPos(self:LocalToWorld(self.Rocket1))
				self.RightRocket = true
			end

			rocket.Small = true
			rocket:SetOwner(self)
			rocket.ParL = self
			rocket.LTime = CurTime()
			local trace = {}
			trace.start = pos

			if self.AimingRocket then
				trace.endpos = pos + self.User:GetAimVector() * 40000
			else
				trace.endpos = pos + self.Entity:GetForward() * 40000
			end

			trace.filter = {self, self.User}

			trace.mask = MASK_SHOT
			rocket.TargetPos = util.TraceLine(trace).HitPos
			rocket.LastPosition = rocket:GetPos()
			rocket:Spawn()
			rocket.LastPosition = rocket:GetPos()
			rocket.Speed = self.RocketSpeed
			rocket.Next = CurTime() + 1
			rocket:Activate()
			rocket:SetKeyValue("damage", 100)
			rocket:SetSaveValue("m_flDamage", 100)
			self:GetPhysicsObject():AddVelocity(self:GetForward() * -200)
			-- Make a muzzle flash
			local effectdata = EffectData()
			effectdata:SetEntity(self.Entity)
			effectdata:SetScale(0.5)
			util.Effect("StriderMuzzleFlash", effectdata)
		elseif not self.Reloading then
			self.Reloading = true
			self:Reload()
		end
	end

	function ENT:Reload()
		self:EmitSound("vehicles/tank_readyfire1.wav", 100, 60)

		timer.Simple(2.3, function()
			if IsValid(self) then
				self.Reloading = false
				self.RoundsLeft = 30
			end
		end)
	end

	function ENT:FireGun(angs)
		if self.RoundsLeft > 0 then
			self.RoundsLeft = self.RoundsLeft - 1
			---    self.GunSound:PlayEx(1,100)
			self.Entity:EmitSound("Weapon_SG552.Single")
			local attach = self.Entity:LookupAttachment("muzzle")
			attach = self.Entity:GetAttachment(attach)
			local poss = attach.Pos
			local bullet = {}
			bullet.Num = 3
			bullet.Src = poss
			bullet.Dir = angs:Forward()
			bullet.Spread = Vector(0.025, 0.025, 0)
			bullet.Tracer = 3
			bullet.TracerName = "Tracer"
			bullet.Force = 1000
			bullet.Damage = 10
			bullet.Attacker = self.User
			self.Entity:FireBullets(bullet)
			--    self.User:SetSharedVar("HBullets", self.RoundsLeft)
			local e = EffectData()
			e:SetOrigin(attach.Pos)
			e:SetAngles(attach.Ang)
			e:SetScale(3)
			e:SetMagnitude(20)
			util.Effect("MuzzleEffect", e)
		elseif not self.Reloading then
			self.Reloading = true
			self:Reload()
		end
		--[[
						if self.RoundsLeft != 0 then
				self.GunSound:PlayEx(1,100)
				local attach = self.Entity:LookupAttachment( "muzzle" )
				attach = self.Entity:GetAttachment(attach)
				local poss = attach.Pos
				local bullet = {}
						bullet.Num             = 7
						bullet.Src             = poss
						bullet.Dir             = angs:Forward()
						bullet.Spread         = Vector(0.165,0.165,0)
						bullet.Tracer        = 1
						bullet.TracerName     = "HelicopterTracer"
						bullet.Force        = 5
						bullet.Damage        = 6
						bullet.Attacker     = self.User        
				self.Entity:FireBullets( bullet )
				self.RoundsLeft = self.RoundsLeft -1
				self.User:SetSharedVar("HBullets", self.RoundsLeft)
		
				// Make a muzzle flash
				local effectdata = EffectData()
						effectdata:SetEntity(self.Entity)
						effectdata:SetScale( 0.5 )
				util.Effect( "StriderMuzzleFlash", effectdata )
				end
end
]]
		--
	end

	function ENT:ChargeGun(bool)
		if self.RoundsLeft == 0 then
			if not bool or (CurTime() > self.Gunstate + 3) then
				self.Gunstate = CurTime()
				self.User:SetNWInt("HGunReloadTime", self.Gunstate)
				self.FireUp:Stop()

				return
			end

			self.FireUp:PlayEx(1, 100)

			if CurTime() > (self.Gunstate + 2) then
				self.RoundsLeft = 30
				--        self.User:SetSharedVar("HBullets", 20)
			end
		end
	end

	function ENT:DropBomb()
		if CurTime() < self.LastBomb + 1.5 then return end
		self.LastBomb = CurTime()
		self.User:SetNWInt("HLastBomb", self.LastBomb)
		self.Entity:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav", 100, 100)
		local da_bomb = ents.Create(self.GrenadeBomb)
		local attach = self.Entity:LookupAttachment("Bomb")
		attach = self.Entity:GetAttachment(attach)
		da_bomb:SetPos(attach.Pos - self.Entity:GetForward() * 3 - self.Entity:GetUp() * 3)
		da_bomb:SetAngles(Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
		da_bomb:Spawn()
		da_bomb:Activate()
		da_bomb:Fire("ExplodeIn", 10, 0)
		da_bomb:GetPhysicsObject():ApplyForceCenter(self.Entity:GetForward() * -0.4)
	end

	function ENT:OnTakeDamage(dmg)
		local multiplier = 1

		if dmg:IsBulletDamage() then
			multiplier = 0.5
		end

		self.Healthz = self.Healthz - (dmg:GetDamage() * multiplier)

		if IsValid(dmg:GetAttacker()) then
			self.LastAttacker = dmg:GetAttacker()
		end

		self.Entity:EmitSound("npc/attack_helicopter/aheli_damaged_alarm1.wav")

		if self.User then
			self.User:SetNWInt("HHealthz", self.Healthz)
		end
	end

	function ENT:Splode(attacker)
		if self.Sploding then return end
		self.Entity:SetColor(Color(255, 255, 255, 255))
		--[[
		self.InUse = false

		if self.User then self.User:UnSpectate() end
		if self.User then self.User:DrawViewModel(true) end
		if self.User then self.User:DrawWorldModel(true) end
		if self.User then self.User:SetNetworkedBool("InChopper",false) end
		if self.User then self.User:Spawn() end
		if self.User then self.User:SetColor(255,255,255,255) end
		if self.User then self.User:SetPos(self.Entity:GetPos() - 200*self.Entity:GetRight() - 50*self.Entity:GetUp()) end
		self.User = nil
		]]
		--
		self.Entity:StopMotionController()
		self.Sound:Stop()
		self.Entity:SetNWBool("USE", false)
		local explod = ents.Create("env_explosion")
		explod:SetPos(self.Entity:GetPos())

		if self.User and IsValid(self.LastAttacker) and self.LastAttacker ~= self.User then
			if self.LastAttacker:IsPlayer() then
				self.LastAttacker:AddFrags(3)
			elseif IsValid(self.LastAttacker:GetOwner()) then
				self.LastAttacker:GetOwner():AddFrags(3)
			end
		end

		explod:SetOwner(self.User)
		explod:Spawn()
		explod:SetKeyValue("iMagnitude", "500")
		explod:Fire("Explode", 0, 0)
		explod:EmitSound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", 256, 100)
		self.Sploding = true
		local ent = self

		if ent:Health() < 0 and not ent.Dead then
			ent.Dead = true
			local tra = {}
			tra.start = ent:GetPos() + Vector(0, 0, 200)
			tra.endpos = ent:GetPos() + Vector(0, 0, 200) - Vector(0, 0, 1000)

			tra.filter = {ent}

			tra.mask = MASK_SHOT
			local tr = util.TraceLine(tra)
			local e = EffectData()
			e:SetOrigin(tr.HitPos)
			e:SetScale(4)
			util.Effect("effect_smokedoor", e)
			local ef = EffectData()
			ef:SetOrigin(ent:LocalToWorld(Vector(math.random(-150, 150), math.random(-150, 150), math.random(40, 60))))
			ef:SetScale(2)
			ef:SetMagnitude(20)
			util.Effect("Explosion", ef)

			for i = 1, 10 do
				timer.Simple(math.Rand(0, 2.6), function()
					local pos = ent:LocalToWorld(Vector(math.random(-150, 150), math.random(-150, 150), math.random(40, 60)))
					ef:SetOrigin(pos)
					util.Effect("Explosion", ef)
					local ang = Angle(-math.Rand(0, 180), math.Rand(0, 360), math.Rand(0, 360))
					local pos = ent:LocalToWorld(Vector(math.random(-40, 40), math.random(-40, 40), math.random(40, 60)))
				end)
			end

			for i = 1, 4 do
				timer.Simple(math.Rand(2.6, 3), function()
					ef:SetOrigin(ent:LocalToWorld(Vector(math.random(-150, 150), math.random(-150, 150), math.random(40, 60))))
					util.Effect("HelicopterMegaBomb", ef)
				end)
			end

			timer.Simple(1.5, function()
				WorldSound("ambient/explosions/explode_" .. math.random(3, 4) .. ".wav", ent:GetPos(), 160, 100)
				ef:SetOrigin(ent:LocalToWorld(Vector(math.random(-150, 150), math.random(-150, 150), math.random(40, 60))))
				ef:SetScale(0.1)
				ef:SetMagnitude(20)
				util.Effect("Artillery_Explosion", ef)
			end)
			--for i = 1, 6 do
			--local fla = SpawnFire(dent:LocalToWorld(Vector(math.random(-50,50),math.random(-20,20),math.random(40,60))), 100, 50, 50, nil,dent)
			--end
		end

		timer.Simple(1.5, function()
			self:TheEnd()
		end)
		--    self.Entity:Ignite(10,100)
	end

	hook.Add("Tick", "HeliTick", function()
		for k, v in pairs(player.GetAll()) do
			if v:GetNWBool("InChopper", false) then
				v.Helia = true
				v:SetMoveType(0)
			elseif v.Helia then
				v.Helia = false
				v:SetMoveType(2)
			end
		end
	end)

	function ENT:TheEnd()
		local gib1 = ents.Create("prop_physics")
		local attach = self.Entity:LookupAttachment("Damage3")
		attach = self.Entity:GetAttachment(attach)
		gib1:SetPos(attach.Pos + Vector(0, 0, 25))
		gib1:SetAngles(self.Entity:GetAngles())
		gib1:SetModel("models/Gibs/helicopter_brokenpiece_04_cockpit.mdl")
		gib1:Spawn()
		gib1:Activate()
		local flame = ents.Create("ttt_flame")
		--      flame:SetPos(vstart)
		flame:SetPos(gib1:GetPos())
		flame:SetDieTime(CurTime() + 20 + math.Rand(-2, 2))
		flame:SetExplodeOnDeath(false)
		flame:SetDamageParent(self:GetOwner())
		flame:SetOwner(self:GetOwner())
		flame:Spawn()
		local Ambient = ents.Create("ambient_generic")
		Ambient:SetPos(flame:GetPos())
		Ambient:SetKeyValue("message", "ambient/fire/fire_med_loop1.wav")
		Ambient:SetKeyValue("health", 10)
		Ambient:SetKeyValue("preset", 0)
		Ambient:SetKeyValue("radius", 1500)
		Ambient:Spawn()
		Ambient:SetParent(flame)
		Ambient:Activate()
		Ambient:Fire("PlaySound", "", 0)
		Ambient:Fire("kill", "", 20)
		flame:SetParent(gib1)
		gib1:SetColor(self:GetColor())
		gib1:GetPhysicsObject():EnableDrag(false)
		gib1:GetPhysicsObject():SetVelocity(self.Entity:GetForward() * 150 + self.Entity:GetUp() * 250 + self.Entity:GetRight() * -150)
		local gib2 = ents.Create("prop_physics")
		attach = self.Entity:LookupAttachment("Damage1")
		attach = self.Entity:GetAttachment(attach)
		gib2:SetPos(attach.Pos + Vector(0, 0, 25))
		gib2:SetAngles(self.Entity:GetAngles())
		gib2:SetModel("models/Gibs/helicopter_brokenpiece_06_body.mdl")
		gib2:Spawn()
		gib2:Activate()
		gib2:SetColor(self:GetColor())
		local Ambient = ents.Create("ambient_generic")
		Ambient:SetPos(flame:GetPos())
		Ambient:SetKeyValue("message", "ambient/fire/fire_med_loop1.wav")
		Ambient:SetKeyValue("health", 10)
		Ambient:SetKeyValue("preset", 0)
		Ambient:SetKeyValue("radius", 1500)
		Ambient:Spawn()
		Ambient:SetParent(flame)
		Ambient:Activate()
		Ambient:Fire("PlaySound", "", 0)
		Ambient:Fire("kill", "", 20)
		gib2:GetPhysicsObject():SetVelocity(self.Entity:GetRight() * 250 + self.Entity:GetUp() * 500)
		local gib3 = ents.Create("prop_physics")
		attach = self.Entity:LookupAttachment("Damage2")
		attach = self.Entity:GetAttachment(attach)
		gib3:SetPos(attach.Pos + Vector(0, 0, 25))
		gib3:SetAngles(self.Entity:GetAngles())
		gib3:SetModel("models/Gibs/helicopter_brokenpiece_05_tailfan.mdl")
		gib3:Spawn()
		gib3:Activate()
		gib3:SetColor(self:GetColor())
		gib3:Ignite(15, 0)
		gib3:GetPhysicsObject():SetVelocity(self.Entity:GetForward() * -500 + self.Entity:GetUp() * 250)
		local Ambient = ents.Create("ambient_generic")
		Ambient:SetPos(flame:GetPos())
		Ambient:SetKeyValue("message", "ambient/fire/fire_med_loop1.wav")
		Ambient:SetKeyValue("health", 10)
		Ambient:SetKeyValue("preset", 0)
		Ambient:SetKeyValue("radius", 1500)
		Ambient:Spawn()
		Ambient:SetParent(gib3)
		Ambient:Activate()
		Ambient:Fire("PlaySound", "", 0)
		Ambient:Fire("kill", "", 20)
		local explod = ents.Create("env_explosion")
		explod:SetPos(self.Entity:GetPos())
		explod:SetOwner(self:GetOwner())
		explod:Spawn()
		explod:SetKeyValue("iMagnitude", "500") --the magnitude
		explod:Fire("Explode", 0, 0)
		explod:EmitSound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", 256, 100)
		self:Remove()
	end

	function AngTest(ang)
		ang = ang + Angle(45, 45, 45)
		local b1, b2, ret = false, false, false

		if ang.p < 90 and ang.p >= 0 then
			b1 = true
		end

		if ang.r < 90 and ang.r >= 0 then
			b2 = true
		end

		if b1 and b2 then
			ret = true
		end

		return ret
	end
end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Radio Controlled Helicopter"
ENT.Author = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

if CLIENT then
	function AimPos(start, angs)
		local tracedata = {}
		tracedata.start = start
		tracedata.endpos = start + angs:Forward() * 1000
		local trace = util.TraceLine(tracedata)
		LocalPlayer().AIMPOS = trace.HitPos:ToScreen()
	end

	function HUD()
		if LocalPlayer():GetNetworkedBool("InChopper") and not LocalPlayer():GetNetworkedBool("UsingCam") then
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawOutlinedRect(LocalPlayer().AIMPOS.x - 5, LocalPlayer().AIMPOS.y - 5, 10, 10)

			for k, v in pairs(ents.GetAll()) do
				if (v:IsNPC() or v:IsPlayer()) and v ~= LocalPlayer() then
					local pos = v:GetPos() + Vector(0, 0, 30)
					local name = "Undefined Target"

					if v:IsNPC() then
						name = v:GetClass()
					end

					if v:IsPlayer() then
						name = v:Nick()
					end

					draw.DrawText("+", "ScoreboardText", pos:ToScreen().x, pos:ToScreen().y - 10, Color(255, 0, 0, 255), 1)
					draw.DrawText(name, "ScoreboardText", pos:ToScreen().x + 3, pos:ToScreen().y - 15, Color(255, 0, 0, 255), 0)
				end
			end

			local GRTime = math.Max(CurTime() - LocalPlayer():GetNWInt("HGunReloadTime") - 0.1, 0)
			GRTime = math.Min(2, GRTime)
			draw.RoundedBox(4, 100, 20, 10, ScrH() - 40, Color(50, 50, 255, 100))

			if GRTime ~= 0 then
				draw.RoundedBox(4, 100, 20, 10, (GRTime / 2) * (ScrH() - 40), Color(255, 0, 0, 225))
			end

			for loop = 1, 20 do
				draw.RoundedBox(4, 20, loop * (ScrH() / 22), 20, 15, Color(50, 50, 255, 100))
			end

			--    for loop=1,LocalPlayer():GetSharedVar("HBullets"), 1 do
			--        draw.RoundedBox( 4, 23, ((21-loop)*(ScrH()/22))+3, 14, 9, Color(255,0,0,225) )
			--    end
			BRTime = math.Min(CurTime() - LocalPlayer():GetNWInt("HLastBomb"), 1.5)
			draw.RoundedBox(4, ScrW() - 300, 20, 250, 70, Color(50, 50, 255, 100))

			if BRTime ~= 0 then
				draw.RoundedBox(4, ScrW() - 300, 20, BRTime * (250 / 1.5), 70, Color(255, 0, 0, 225))
			end

			Healthz = LocalPlayer():GetNWInt("HHealthz") / 2000
			draw.RoundedBox(4, ScrW() - 100, 100, 50, ScrH() - 120, Color(50, 50, 255, 100))

			if BRTime ~= 0 then
				draw.RoundedBox(4, ScrW() - 100, ScrH() - ((ScrH() - 120) * Healthz + 20), 50, (ScrH() - 120) * Healthz, Color(255, 0, 0, 225))
			end
		end
	end

	--hook.Add("HUDPaint", "ChopperHUD", HUD)
	hook.Add("ShouldDrawLocalPlayer", "DrawChop", function()
		if LocalPlayer():GetNWBool("InChopper", false) and LocalPlayer().HeliIronsight then return true end
	end)

	function ENT:Think()
		if self.Entity:GetNWBool("USE", false) and IsValid(self.Entity:GetNWEntity("sh_Entity")) and LocalPlayer().PREVY then
			local VEnt = self.Entity:GetNWEntity("sh_Entity")
			local a_velo = self.Entity:GetAngles().y - LocalPlayer().PREVY

			if a_velo > 180 then
				a_velo = a_velo - 360
			end

			if a_velo < -180 then
				a_velo = 360 + a_velo
			end

			a_velo = a_velo / (CurTime() - LocalPlayer().PREVT)
			PREVT = CurTime()
			local eyes = LocalPlayer():EyeAngles()
			local angs = self.Entity:GetAngles()
			PREVY = angs.y
			local w_p = -eyes.p + angs.p
			w_p = math.Max(-90, w_p)
			w_p = math.Min(20, w_p)
			local w_y = eyes.y - angs.y

			if w_y > 180 then
				w_y = w_y - 360
			end

			if w_y < -180 then
				w_y = 360 + w_y
			end

			w_y = math.Max(-40, w_y)
			w_y = math.Min(40, w_y)
			local rud = a_velo * 0.5
			rud = math.Max(-45, rud)
			rud = math.Min(45, rud)
			self.Entity:SetPoseParameter("weapon_pitch", w_p)
			VEnt:SetPoseParameter("weapon_pitch", w_p)
			self.Entity:SetPoseParameter("weapon_yaw", w_y)
			VEnt:SetPoseParameter("weapon_yaw", w_y)
			self.Entity:SetPoseParameter("rudder", rud)
			VEnt:SetPoseParameter("rudder", rud)
			local attach = self.Entity:LookupAttachment("muzzle")
			attach = VEnt:GetAttachment(attach)
			AimPos(attach.Pos, Angle(self.Entity:GetAngles().p - w_p, self.Entity:GetAngles().y + w_y, 0))
		end

		self:NextThink(CurTime() + 0.01)
	end

	function LocalPlSetup()
		if not LocalPlayer().PREVY then
			LocalPlayer().PREVY = 0
			LocalPlayer().PREVT = 0
			LocalPlayer().AIMPOS = {}
			LocalPlayer().AIMPOS.x = 0
			LocalPlayer().AIMPOS.y = 0
		end
	end

	hook.Add("InitPostEntity", "localplsetup", LocalPlSetup)
	hook.Add("HUDPaint", "localplsetusp", LocalPlSetup)

	local function SCalcView(pl, origin, angles, fov)
		if LocalPlayer():GetNWBool("InChopper", false) then
			if LocalPlayer().HeliIronsight and IsValid(LocalPlayer():GetNWEntity("Heli", nil)) then
				local e = LocalPlayer():GetNWEntity("Heli", nil)
				local view = GAMEMODE.BaseClass:CalcView(pl, origin, angles, fov)
				--    origin = self.CurrentMapScene.position + (ang:Forward() * i * (up * 6)) +  (dmd == 0 and (ang:Right() * 0.1 * i) or (ang:Right() * -0.1 * i)  ),

				return {
					vm_origin = Vector(0, 0, 0),
					vm_angles = Angle(0, 0, 0),
					origin = e:GetAttachment(e:LookupAttachment("muzzle")).Pos,
					angles = e:GetAttachment(e:LookupAttachment("muzzle")).Angle,
					fov = fov
				}
			else
				local view = GAMEMODE.BaseClass:CalcView(pl, origin, angles, fov)

				return view
			end
			--    view.origin = origin - LocalPlayer():GetAimVector()*-250 //+ math.random(-5,5)*LocalPlayer():GetUp() + math.random(-5,5)*LocalPlayer():GetRight()
			--view.origin = origin - LocalPlayer():GetAimVector()*300 //+ math.random(-5,5)*LocalPlayer():GetUp() + math.random(-5,5)*LocalPlayer():GetRight()
		end
	end

	hook.Add("CalcView", "HeliC", SCalcView)

	local function PUMPPPTSEST()
		local player = LocalPlayer()

		if (IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_ttt_binoculars") or LocalPlayer().Binoculars or (LocalPlayer():GetNWBool("InChopper", false) and LocalPlayer().HeliIronsight) then
			DrawMaterialOverlay("effects/combine_binocoverlay.vmt", 0.3)
		end
	end

	hook.Add("RenderScreenspaceEffects", "SRenderColorModifyPOO", PUMPPPTSEST)

	function KeyPressed(P, key)
		if not P.NextHeliUse or P.NextHeliUse < CurTime() then
			if key == IN_RELOAD and LocalPlayer():GetNWBool("InChopper", false) then
				LocalPlayer():EmitSound("Weapon_AR2.Special" .. (LocalPlayer().HeliIronsight and "1" or "2"))
				LocalPlayer().HeliIronsight = not LocalPlayer().HeliIronsight
				LocalPlayer().NextHeliUse = CurTime() + 1
			end
		end
	end

	hook.Add("KeyPress", "KeyPressedHook", KeyPressed)

	local function ColorToTeam()
		return Color(0, 155, 0, 255)
	end

	function HudP()
		if LocalPlayer().Helicopt or (LocalPlayer().HeliIronsight and LocalPlayer():GetNWBool("InChopper", false)) then
			if LocalPlayer():GetNWBool("InChopper", false) then
				local x = ScrW() - 80
				local length = 170
				local gap = 20
				local x = ScrW() / 2.0
				local y = ScrH() / 2.0
				surface.SetDrawColor(Color(ColorToTeam().r, ColorToTeam().g, ColorToTeam().b, 255))

				for i = 1, 3 do
					surface.DrawLine(x - (length * i), y + (20 * i), x - (length * i), y - (20 * i))
					surface.DrawLine(x + (length * i), y + (20 * i), x + (length * i), y - (20 * i))
					surface.DrawLine(x - (20 * i), y - ((ScrH() / 8) * i), x + (20 * i), y - ((ScrH() / 8) * i))
					surface.DrawLine(x - (20 * i), y + ((ScrH() / 8) * i), x + (20 * i), y + ((ScrH() / 8) * i))
				end

				local length = 110
				local length = 20
				local gap = 10
				local i = 3
				surface.SetDrawColor(Color(ColorToTeam().r * 0.5, ColorToTeam().g * 0.5, ColorToTeam().b * 0.5, 255))
				surface.DrawLine(x + length, y, x + 10 + (gap * i), y)
				surface.DrawLine(x, y - length, x, y - 10 - (gap * i))
				surface.DrawLine(x, y + length, x, y + 10 + (gap * i))
				surface.DrawLine(x - length, y, x - 10 - (gap * i), y)
				surface.DrawLine(x + length, y, x + 10 + gap, y)
				surface.DrawLine(x, y - length, x, y - 10 - gap)
				surface.DrawLine(x, y + length, x, y + 10 + gap)
				surface.DrawLine(x + length, y, x + 10 + gap, y)
				surface.DrawLine(x, y - length, x, y - 10 - gap)
				surface.DrawLine(x, y + length, x, y + 10 + gap)
				surface.SetFont("DefaultFixedDropShadow")
				surface.SetTextColor(ColorToTeam())
				surface.SetTextPos(x + length, y - length)
				surface.SetDrawColor(ColorToTeam())
				-- fml
				local cx = ScrW() / 2.0 -- hope you don't change res in-game
				local cy = ScrH() / 2.0
				local sz = math.min(cx, cy)

				local verts_tr = {
					-- tl
					{
						x = cx,
						y = cy - sz,
						u = 0,
						v = 1,
					},
					-- tr
					{
						x = cx + sz,
						y = cy - sz,
						u = 1,
						v = 1,
					},
					-- br
					{
						x = cx + sz,
						y = cy,
						u = 1,
						v = 0,
					},
					-- bl
					{
						x = cx,
						y = cy,
						u = 0,
						v = 0,
					},
				}

				local x = ScrW() / 2.0
				local y = ScrH() / 2.0
				local scope_size = ScrH()
				-- crosshair
				local gap = 100
				local length = scope_size
				surface.DrawLine(x - length, y, x - gap, y)
				surface.DrawLine(x + length, y, x + gap, y)
				surface.DrawLine(x, y - length, x, y - gap)
				surface.DrawLine(x, y + length, x, y + gap)
				gap = 0
				--  length = 50
				--    surface.DrawLine( x - length, y, x - gap, y )
				--    surface.DrawLine( x + length, y, x + gap, y )
				--    surface.DrawLine( x, y - length, x, y - gap )
				--   surface.DrawLine( x, y + length, x, y + gap )
				-- cover edges
			end
		end
	end

	hook.Add("HUDPaint", "Jsk", HudP)

	function ENT:Draw()
		self.Entity:DrawModel()
	end
end