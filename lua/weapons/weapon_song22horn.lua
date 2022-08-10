AddCSLuaFile()
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Toybox Classics"
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.DrawCrosshair = false
SWEP.PrintName = "Epic VLVX SWEP"
SWEP.Author = "valve"
SWEP.Contact = ""
SWEP.Purpose = "Left Click to play VLVX_song22 music that will cause NPC's to explod."
SWEP.Instructions = ""
SWEP.ViewModel = "models/weapons/c_models/c_bugle/c_bugle.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_bugle/c_bugle.mdl"
SWEP.BobScale = 2
SWEP.SwayScale = 2
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
--actual SWEP details
SWEP.ViewModelDefPos = Vector(-40.9885, -90.7463, -22.2584)
SWEP.ViewModelDefAng = Vector(-178.6234, 40.6472, 100.4833)
SWEP.MoveToPos = Vector(-105, -53, 20)
SWEP.MoveToAng = Vector(-230, 45, 185)
SWEP.Sound = Sound("music/HL1_song25_REMIX3.mp3")
SWEP.Volume = 500
SWEP.Influence = 0
SWEP.LastSoundRelease = 0
SWEP.RestartDelay = 1
SWEP.RandomEffectsDelay = 0.2

function SWEP:PrimaryAttack() end

function SWEP:SecondaryAttack() end

function SWEP:GetViewModelPosition(pos, ang, inv, mul)
	local mul = 0

	if self.Weapon:GetNWBool("on") then
		self.Volume = math.Clamp(self.Volume + FrameTime() * 3, 0, 1)
	else
		self.Volume = math.Clamp(self.Volume - FrameTime() * 3, 0, 1)
	end

	mul = self.Volume
	--this is always applied
	local DefPos = self.ViewModelDefPos
	local DefAng = self.ViewModelDefAng

	if DefAng then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), DefAng.x)
		ang:RotateAroundAxis(ang:Up(), DefAng.y)
		ang:RotateAroundAxis(ang:Forward(), DefAng.z)
	end

	if DefPos then
		local Right = ang:Right()
		local Up = ang:Up()
		local Forward = ang:Forward()
		pos = pos + DefPos.x * Right
		pos = pos + DefPos.y * Forward
		pos = pos + DefPos.z * Up
	end

	--and some more
	local AddPos = self.MoveToPos - self.ViewModelDefPos
	local AddAng = self.MoveToAng - self.ViewModelDefAng

	if AddAng then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), AddAng.x * mul)
		ang:RotateAroundAxis(ang:Up(), AddAng.y * mul)
		ang:RotateAroundAxis(ang:Forward(), AddAng.z * mul)
	end

	if AddPos then
		local Right = ang:Right()
		local Up = ang:Up()
		local Forward = ang:Forward()
		pos = pos + AddPos.x * Right * mul
		pos = pos + AddPos.y * Forward * mul
		pos = pos + AddPos.z * Up * mul
	end

	return pos, ang
end

SWEP.RandomEffects = {
	{
		function(npc, pl)
			npc:Fire("ignite", "120", 0)
			npc:SetHealth(math.Clamp(npc:Health(), 5, 25))
			npc:AddEntityRelationship(pl, D_FR, 99)
		end,
		1
	},
	{
		function(npc)
			local explos = ents.Create("env_Explosion")
			explos:SetPos(npc:GetPos() + Vector(0, 0, 4))
			explos:SetKeyValue("iMagnitude", 200)
			explos:SetKeyValue("iRadiusOverride", 50)
			explos:Spawn()
			explos:Fire("explode", "", 0)
			explos:Fire("kill", "", 0.1)
		end,
		0.1
	},
	{function(npc) end, 0.1},
}

function SWEP:Think()
	if SERVER then
		self.LastFrame = self.LastFrame or CurTime()
		self.LastRandomEffects = self.LastRandomEffects or 0

		if self:GetOwner():KeyDown(IN_ATTACK) and self.LastSoundRelease + self.RestartDelay < CurTime() then
			if not self.SoundObject then
				self:CreateSound()
			end

			self.SoundObject:PlayEx(5, 100)
			self.Volume = math.Clamp(self.Volume + CurTime() - self.LastFrame, 0, 2)
			self.Influence = math.Clamp(self.Influence + (CurTime() - self.LastFrame) / 2, 0, 1)
			self.SoundObject:ChangeVolume(self.Volume)
			self.SoundPlaying = true
		else
			if self.SoundObject and self.SoundPlaying then
				self.SoundObject:FadeOut(0.8)
				self.SoundPlaying = false
				self.LastSoundRelease = CurTime()
				self.Volume = 0
				self.Influence = 0
			end
		end

		self.LastFrame = CurTime()
		self.Weapon:SetNWBool("on", self.SoundPlaying)

		if self.Influence > 0.5 and self.LastRandomEffects + self.RandomEffectsDelay < CurTime() then
			--print ("influence: "..self.Influence)
			for _, npc in ipairs(ents.FindInSphere(self:GetOwner():GetPos(), 768)) do
				if npc:IsNPC() and npc:Health() > 0 then
					--print (tostring(npc))
					--we want only NPCs vaguely in view to be affected, so players can always see their torture victims. also, it's more loyal to the chaingun-esque original shown in video.
					local vec1 = ((npc:GetShootPos() or npc:GetPos()) - self:GetOwner():GetShootPos()):GetNormalized()
					local vec2 = self:GetOwner():GetAimVector()
					local dot = vec1:DotProduct(vec2)

					--print (dot)
					--good enough for fov 90
					if dot > 0.5 then
						--apply random effects.
						local chanceMul = self.Influence * (768 - ((npc:GetShootPos() or npc:GetPos()) - self:GetOwner():GetShootPos()):Length()) / 1000

						--print (chanceMul)
						for k, v in ipairs(self.RandomEffects) do
							npc.effects = npc.effects or {}

							if math.random() < chanceMul * v[2] * dot and not npc.effects[k] then
								--print ("effect "..k)
								v[1](npc, self:GetOwner())
								--npc.effects[k] = true
								done = true
							end
						end
					end
				end
			end

			self.LastRandomEffects = CurTime()
			--print ("\n")
		end
	end
end

function SWEP:CreateSound()
	self.SoundObject = CreateSound(self.Weapon, self.Sound)
	self.SoundObject:Play()
end

function SWEP:Holster()
	self:EndSound()

	return true
end

function SWEP:OwnerChanged()
	self:EndSound()
end

function SWEP:EndSound()
	if self.SoundObject then
		self.SoundObject:Stop()
	end
end