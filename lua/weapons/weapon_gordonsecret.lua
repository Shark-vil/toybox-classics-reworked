local math_Clamp, Sound, CurTime, ents_Create, ents_FindInSphere, math_random, util_PrecacheSound, Vector, ipairs, CreateSound = math.Clamp, Sound, CurTime, ents.Create, ents.FindInSphere, math.random, util.PrecacheSound, Vector, ipairs, CreateSound

AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "crowbar"
SWEP.DrawCrosshair = true
SWEP.PrintName = "Gordon's Secret"
SWEP.Author = "CryoShocked"
SWEP.Contact = "Don't."
SWEP.Purpose = "To destroy all those around you."
SWEP.Instructions = "Left click, hold right click, and drool over the amazingness that is this SWEP."
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.BobScale = 2
SWEP.SwayScale = 2
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0
SWEP.Primary.AnimationDelay = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Sound = Sound("music/HL2_song20_submix0.mp3")
SWEP.Volume = 30
SWEP.Influence = 0
SWEP.LastSoundRelease = 0
SWEP.RestartDelay = 0
SWEP.RandomEffectsDelay = .5

function SWEP:Reload() end

function SWEP:SecondaryAttack() end

function SWEP:PrimaryAttack()
  if self.Primary.AnimationDelay < CurTime() then
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self.Primary.AnimationDelay = CurTime() + .3
  end

  if self.Primary.Delay > CurTime() then return end
  self.Primary.Delay = CurTime() + .025

  local trace = self:GetOwner():GetEyeTrace()

  if trace.HitPos:Distance(self:GetOwner():GetShootPos()) <= 75 then
    self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
    bullet = {}
    bullet.Num = 1
    bullet.Src = self:GetOwner():GetShootPos()
    bullet.Dir = self:GetOwner():GetAimVector()
    bullet.Spread = Vector(0, 0, 0)
    bullet.Tracer = 0
    bullet.Force = 9000
    bullet.Damage = 9000
    self:GetOwner():FireBullets(bullet)
    self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet" .. math_random(3, 5) .. ".wav")
  else
    self.Weapon:EmitSound("ambient/water_splash1.wav")
    self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
  end
end

function SWEP:Initialize()
  self:SetHoldType("melee")

  if SERVER then
    self:SetWeaponHoldType(self.HoldType)
  end

  util_PrecacheSound("physics/flesh/flesh_impact_bullet" .. math_random(3, 5) .. ".wav")
  util_PrecacheSound("ambient/water_splash1.wav")
end

SWEP.RandomEffects = {
  {
    function(npc, pl)
      npc:Fire("ignite", "120", 0)
      npc:SetHealth(math_Clamp(npc:Health(), 5, 25))
      npc:AddEntityRelationship(pl, D_FR, 99)
    end,
    1
  },
  {
    function(npc)
      local explos = ents_Create("env_Explosion")
      explos:SetPos(npc:GetPos() + Vector(0, 0, 4))
      explos:SetKeyValue("iMagnitude", 1500)
      explos:SetKeyValue("iRadiusOverride", 200)
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

    if self:GetOwner():KeyDown(IN_ATTACK2) and self.LastSoundRelease + self.RestartDelay < CurTime() then
      if not self.SoundObject then
        self:CreateSound()
      end

      self.SoundObject:PlayEx(5, 100)
      self.Volume = math_Clamp(self.Volume + CurTime() - self.LastFrame, 0, 2)
      self.Influence = math_Clamp(self.Influence + (CurTime() - self.LastFrame) / 2, 0, 1)
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
      for _, npc in ipairs(ents_FindInSphere(self:GetOwner():GetPos(), 768)) do
        if npc:IsNPC() and npc:Health() > 0 then
          --we want only NPCs vaguely in view to be affected, so players can always see their torture victims. also, it's more loyal to the chaingun-esque original shown in video.
          local vec1 = ((npc:GetShootPos() or npc:GetPos()) - self:GetOwner():GetShootPos()):GetNormalized()
          local vec2 = self:GetOwner():GetAimVector()
          local dot = vec1:Dot(vec2)

          --good enough for fov 90
          if dot > 0.5 then
            --apply random effects.
            local chanceMul = self.Influence * (768 - ((npc:GetShootPos() or npc:GetPos()) - self:GetOwner():GetShootPos()):Length()) / 1000
            local index = math_random(1, #self.RandomEffects)
            local value = self.RandomEffects[index]
            npc.effects = npc.effects or {}

            if not npc.effects[index] and math_random() < chanceMul * value[2] * dot then
              value[1](npc, self:GetOwner())
              npc.effects[index] = true
              break
            end
          end
        end
      end

      self.LastRandomEffects = CurTime()
    end
  end
end

function SWEP:CreateSound()
  self.SoundObject = CreateSound(self.Weapon, self.Sound)
  self.SoundObject:Play()
end

function SWEP:Holster()
  if SERVER then
    GAMEMODE:SetPlayerSpeed(self:GetOwner(), 200, 500)
  end

  self:EndSound()

  return true
end

function SWEP:OwnerChanged()
  self:EndSound()
end

function SWEP:OnRemove()
  self:Holster()
end

function SWEP:EndSound()
  if self.SoundObject then
    self.SoundObject:Stop()
  end
end

function SWEP:Deploy()
  if SERVER then
    GAMEMODE:SetPlayerSpeed(self:GetOwner(), 400, 2000)
  end

  return true
end