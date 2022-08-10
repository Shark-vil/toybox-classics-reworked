AddCSLuaFile()
-- TODO:
--    * Add a secondary fire
--    * Fix player not getting credit for killing antlions (antlions kill themselves O.o)
--    * Fix and add back dynamic lights
--    * Fix choppers not taking damage
--    * Fix shadows going weird
-- fixed not dealing damage to some npcs
-- tweaked some delays/rates
-- added particle effects to hitpos
-- added lighting effects to hitpos
-- added a slight recharge period when you run out of power while firing
-- added idle animation
-- added twist #1, #2, #3, #4
-- fixed effects and sounds firing while weapon is holstered
-- fixed not being able to use weapon if power is depleted
-- removed lighting effects due to lag and flickering
-- added back decals
-- added kill and selection icons
-- fixed players not getting credit for killing burning npcs
-- fixed players not getting credit for killing combine npcs
-- fixed power not recharging right away if weapon was not fired
-- made the lasers force much stronger
-- made the laser cut zombies in half
-- tweaked more delays
-- fixed beam not drawing when player starts firing off-screen
-- tweaked viewmodel wiggling
-- fixed sounds still playing when the player dies
-- made radio break when going out of audible range
-- added slight radial damage
-- made underwater damaging a bit better
-- made the beam endpos fall back a bit
-- made the beam explode striders
-- fixed some potential glitches
-- fixed error when damaging hoppers
-- tweaked beam effect
-- removed beam fallback effect, tweaked the beam more
-- ---
-- fixed some nil/null value errors
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Laser Gun"
SWEP.Author = "Nev"
SWEP.Instructions = "Primary: Fire laser beam"
SWEP.Slot = 2
SWEP.SlotPos = 3
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "smg"
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.Weight = 25
SWEP.UseHands = true

SWEP.Primary = {
  ClipSize = 100,
  DefaultClip = 100,
  Automatic = true,
  Ammo = "None"
}

SWEP.Secondary = {
  ClipSize = -1,
  DefaultClip = -1,
  Automatic = true,
  Ammo = "None"
}

local WarmupSound = Sound("npc/attack_helicopter/aheli_charge_up.wav")
local DischargeSound = Sound("ambient/levels/citadel/zapper_loop2.wav")
local CooldownSound = Sound("npc/turret_floor/die.wav")
local WarmupLength = 1.5964626073837
local CooldownLength = 1.3695101737976
local PHASE_NONE = 0
local PHASE_WARMUP = 1
local PHASE_FIRE = 2
local PHASE_COOLDOWN = 3
local RadioModel = "models/props_lab/citizenradio.mdl"
local RadioModelPortal = "models/props/radio_reference.mdl"

local RadioLightOffsets = {
  [RadioModel] = Vector(10, 1.5, 7.5),
  [RadioModelPortal] = Vector(5, 0, 2)
}

local RadioSongs = {
  [RadioModel] = {
    {Sound("music/HL2_song15.mp3"), 31},
    {Sound("music/HL2_song14.mp3"), 80},
    {Sound("music/HL2_song16.mp3"), 76},
    {Sound("music/HL1_song25_REMIX3.mp3"), 27},
    {Sound("music/HL2_song20_submix0.mp3"), 46},
    {Sound("music/HL2_song20_submix4.mp3"), 62},
    {Sound("music/HL2_song25_Teleporter.mp3"), 21},
    {Sound("music/HL2_song29.mp3"), 60},
    {Sound("music/HL2_song3.mp3"), 45},
    {Sound("music/HL2_song31.mp3"), 44},
    {Sound("music/HL2_song4.mp3"), 26},
    {Sound("music/HL2_song6.mp3"), 20}
  },
  [RadioModelPortal] = {
    {Sound("ambient/music/looping_radio_mix.wav"), 22}
  }
}

local SparkSound = Sound("ambient/energy/zap1.wav")
PrecacheParticleSystem("striderbuster_explode_core")

------------------------------------------------------------------------------------------------------
--    Purpose: returns true if the given entity is a radio prop, false otherwise
------------------------------------------------------------------------------------------------------
local function IsRadioProp(entity)
  local isRadioModel = entity:GetModel() == RadioModel or entity:GetModel() == RadioModelPortal

  return entity:GetClass():find("prop_physics") and isRadioModel
end

------------------------------------------------------------------------------------------------------
--    Purpose: initialize the weapon, default vars
------------------------------------------------------------------------------------------------------
function SWEP:Initialize()
  self:SetWeaponHoldType(self.HoldType)
  self:InstallDataTable()
  self:DTVar("Int", 0, "Phase")

  if CLIENT then
    -- great.. StopSound doesn't work
    self.WarmupSound = CreateSound(self, WarmupSound)
    self.FiringSound = CreateSound(self, DischargeSound)
    self.ChargeFrac = 0
    self.ChargeSpeed = 0
    self.LastPhase = PHASE_NONE
    self.HudAlphaFrac = 0.5
    self.VMOffset = 0
    self.NextHitEffect = CurTime()

    if not killicon.Exists(self.ClassName) then
      killicon.AddFont(self.ClassName, "HL2MPTypeDeath", '5', Color(80, 170, 255))
    end
  else
    self.dt.Phase = PHASE_NONE
    self.FirstTimeFired = true
    self.NextAmmoRegen = CurTime()
    self.NextIdle = CurTime()
  end
end

------------------------------------------------------------------------------------------------------
--    Purpose: do warmup actions
------------------------------------------------------------------------------------------------------
function SWEP:DoWarmup()
  self:SetNextPrimaryFire(CurTime() + WarmupLength)
  self.dt.Phase = PHASE_WARMUP
  self.FirstTimeFired = false
  self.NextAmmoRegen = -1
end

------------------------------------------------------------------------------------------------------
--    Purpose: do cooldown actions
------------------------------------------------------------------------------------------------------
function SWEP:DoCooldown()
  self:SetNextPrimaryFire(CurTime() + CooldownLength)
  self.dt.Phase = PHASE_COOLDOWN
  self.FirstTimeFired = true
  self.NextAmmoRegen = CurTime() + CooldownLength
end

------------------------------------------------------------------------------------------------------
--    Purpose: timer callback that unowns flame damage
------------------------------------------------------------------------------------------------------
local function Timer_FixCredits(entity)
  if IsValid(entity) then
    entity.FlameOwner = nil
    entity.FlameOwnerWeapon = nil
  end
end

------------------------------------------------------------------------------------------------------
--    Purpose: do damage to the entity we're looking at
------------------------------------------------------------------------------------------------------
function SWEP:DoDischarge()
  self.dt.Phase = PHASE_FIRE
  local tr = self:GetOwner():GetEyeTraceNoCursor()
  local damageForce = tr.Normal * 1500

  -- push and do damage to valid entities
  if tr.Hit and not tr.HitSky and IsValid(tr.Entity) then
    local entity = tr.Entity
    local className = tr.Entity:GetClass()
    entity.LaserExposure = (entity.LaserExposure or 0) + 0.1

    if className == "npc_rollermine" then
      if entity.LaserExposure >= 4 then
        local effectData = EffectData()
        effectData:SetOrigin(entity:GetPos())
        util.Effect("Explosion", effectData)
        entity:Remove()
        self:DoCooldown()

        return
      elseif entity.LaserExposure >= 2 and not entity.IsOff then
        entity.IsOff = true
        entity:Fire("TurnOff")
        self:DoCooldown()

        return
      end
    elseif className == "combine_mine" then
      if entity.LaserExposure >= 3 and not entity.IsFriendly then
        entity.Disarmer = self:GetOwner()
        entity.IsFriendly = true
        entity:Fire("Disarm")
        -- open hooks
        entity:SetPoseParameter("blendstates", 64)
        self:DoCooldown()

        return
      end
    elseif className == "npc_turret_floor" then
      if entity.LaserExposure >= 4 and not entity.IsDying then
        entity.IsDying = true
        entity:Fire("SelfDestruct")
        self:DoCooldown()

        return
      end
    elseif className == "item_suitcharger" then
      if not entity.NextRecharge or CurTime() > entity.NextRecharge then
        entity:Fire("Recharge")
        entity.NextRecharge = CurTime() + 0.5
      end
    elseif className == "npc_strider" then
      if entity.LaserExposure >= 8 then
        local damageInfo = DamageInfo()
        damageInfo:SetInflictor(entity)
        damageInfo:SetAttacker(entity)
        damageInfo:SetDamagePosition(tr.HitPos)
        damageInfo:SetDamage(entity:Health())
        damageInfo:SetDamageType(DMG_GENERIC)
        entity:TakeDamageInfo(damageInfo)
        ParticleEffect("striderbuster_explode_core", tr.HitPos, entity:GetAngles())
        self:DoCooldown()

        return
      end
    elseif IsRadioProp(entity) then
      local maxExposure = (entity:GetModel() == RadioModel) and 3 or 5

      if entity.LaserExposure >= maxExposure and not entity.IsPlaying then
        local randomSong = table.Random(RadioSongs[entity:GetModel()])
        entity.IsPlaying = true
        entity.Song = CreateSound(entity, randomSong[1])
        entity.Song:Play()

        if not IsValid(entity.Glow) then
          local glow = ents.Create("env_glow")
          glow:SetPos(entity:LocalToWorld(RadioLightOffsets[entity:GetModel()]))
          glow:SetColor(0, 255, 0, 255)
          glow:SetKeyValue("model", "effects/blueflare1.vmt")
          glow:SetKeyValue("scale", "0.125")
          glow:SetKeyValue("GlowProxySize", "4")
          glow:SetKeyValue("spawnflags", "1")
          glow:SetParent(entity)
          glow:Spawn()
          glow:Activate()
          entity.Glow = glow
        end

        entity.Glow:Fire("ShowSprite")

        -- Still Alive will play forever
        if entity:GetModel() == RadioModel then
          entity.SongDieTime = CurTime() + randomSong[2]
        end

        self:DoCooldown()

        return
      end

      damageForce = nil
    else
      local isZombie = className:find("zombie") ~= nil
      local minZombieHealth = entity:GetMaxHealth() / 5

      -- slice up zombies that are near death and can be sliced
      if isZombie and entity:Health() <= minZombieHealth and not className:find("poison") then
        self:CutZombieInHalf(entity, damageForce)
      else
        local damageType, damageAmount = DMG_GENERIC, 6

        -- gunships need this much damage, though, they die almost instantly..
        if className == "npc_helicopter" or className == "npc_combinegunship" then
          damageType, damageAmount = DMG_BLAST, 50
        end

        local damageInfo = DamageInfo()
        damageInfo:SetDamage(damageAmount)
        damageInfo:SetDamageType(damageType)
        damageInfo:SetDamagePosition(tr.HitPos)
        damageInfo:SetInflictor(self)
        damageInfo:SetAttacker(self:GetOwner())
        entity:TakeDamageInfo(damageInfo)
        entity:Ignite(10, 0)
        -- fire can kill entities before the beam, this fixes that
        entity.FlameOwner = self:GetOwner()
        entity.FlameOwnerWeapon = self
        timer.Adjust(entity:EntIndex() .. "FlameFix", 10, 0, Timer_FixCredits, entity)
      end
    end

    local physObj = entity:GetPhysicsObject()

    -- damageInfo.SeDamageForce doesn't work
    if IsValid(physObj) and damageForce then
      physObj:ApplyForceOffset(damageForce, tr.HitPos)
    end
  end

  self:DoRadialDamage(tr)
  self:SetClip1(self:Clip1() - 1)
  self:SetNextPrimaryFire(CurTime() + 0.1)
end

------------------------------------------------------------------------------------------------------
--    Purpose: damages all entities near hitpos
------------------------------------------------------------------------------------------------------
function SWEP:DoRadialDamage(tr)
  local damageInfo = DamageInfo()
  damageInfo:SetDamageType(DMG_RADIATION)
  damageInfo:SetInflictor(self)
  damageInfo:SetAttacker(self:GetOwner())
  damageInfo:SetDamage(1)

  for i, entity in ipairs(ents.FindInSphere(tr.HitPos, 32)) do
    if entity ~= tr.Entity then
      damageInfo:SetDamagePosition(entity:NearestPoint(tr.HitPos))
      entity:TakeDamageInfo(damageInfo)
    end
  end
end

------------------------------------------------------------------------------------------------------
--    Purpose: disables radios that go out of audible range
------------------------------------------------------------------------------------------------------
local function Think()
  if CLIENT then return end

  for i, entity in ipairs(ents.FindByClass("prop_*")) do
    if IsRadioProp(entity) and entity.IsPlaying then
      local shortestDist

      for index, pl in ipairs(player.GetAll()) do
        local distTo = (pl:GetPos() - entity:GetPos()):LengthSqr()

        if not shortestDist or shortestDist > distTo then
          shortestDist = distTo
        end
      end

      local inRange = shortestDist <= 1024 ^ 2

      if not inRange or (entity.SongDieTime and CurTime() > entity.SongDieTime) then
        entity.Song:Stop()
        local effectData = EffectData()
        effectData:SetOrigin(entity.Glow:GetPos())
        effectData:SetNormal(entity:GetForward())
        effectData:SetMagnitude(2)
        effectData:SetScale(3)
        effectData:SetRadius(3)
        util.Effect("sparks", effectData, true, true)
        entity:EmitSound(SparkSound)
        entity.Glow:Fire("HideSprite")
        -- allow them to do it again
        entity.IsPlaying = nil
        entity.LaserExposure = nil
      end
    end
  end
end

hook.Add("Think", "LaserGun_DisableRadios", Think)

------------------------------------------------------------------------------------------------------
--    Purpose: creates a server side ragdoll gib
--    TODO: make this client side
------------------------------------------------------------------------------------------------------
local function CreateRagdollGib(model, origin, angles, force, ignite, removeDelay)
  local gib = ents.Create("prop_ragdoll")
  gib:SetModel(model)
  gib:SetPos(origin)
  gib:SetAngles(angles)
  gib:Spawn()
  gib:Activate()
  gib:SetCollisionGroup(COLLISION_GROUP_WORLD)
  gib:SetVelocity(force * gib:GetPhysicsObject():GetMass())

  if ignite then
    gib:Ignite(10, 0)
  end

  SafeRemoveEntityDelayed(gib, removeDelay or 10)

  return gib
end

-- zombie leg and torso models
local ZombieLegs = Model("models/Zombie/Classic_legs.mdl")
local FastZombieLegs = Model("models/Gibs/Fast_Zombie_Legs.mdl")
local ZombineLegs = Model("models/Zombie/zombie_soldier_legs.mdl")
local ZombieTorso = Model("models/Zombie/Classic_torso.mdl")
local FastZombieTorso = Model("models/Gibs/Fast_Zombie_Torso.mdl")
local ZombineTorso = Model("models/Zombie/zombie_soldier_torso.mdl")
local ZombieSliceSound = Sound("ambient/machines/slicer2.wav")

------------------------------------------------------------------------------------------------------
--    Purpose: cuts zombies in half
--    Notes: taken from the hl2 source code
------------------------------------------------------------------------------------------------------
function SWEP:CutZombieInHalf(entity, damageForce)
  local legsModel, torsoModel

  if entity:GetClass() == "npc_fastzombie" then
    legsModel, torsoModel = FastZombieLegs, FastZombieTorso
  elseif entity:GetClass() == "npc_zombie" then
    legsModel, torsoModel = ZombieLegs, ZombieTorso
  elseif entity:GetClass() == "npc_zombine" then
    legsModel, torsoModel = ZombineLegs, ZombineTorso
  end

  if not legsModel or not torsoModel then return end
  local gibLegs = CreateRagdollGib(legsModel, entity:GetPos(), entity:GetAngles(), Vector(math.Rand(-400, 400), math.Rand(-400, 400), math.Rand(0, 250)), true)
  local forceTorso = damageForce * math.Rand(0.04, 0.06)
  forceTorso.z = math.Rand(4800, 7200)
  local anglesTorso = entity:GetAngles()
  anglesTorso.p = anglesTorso.p - 90
  local gibTorso = CreateRagdollGib(torsoModel, entity:GetPos() + Vector(0, 0, 64), anglesTorso, forceTorso, true)
  -- fake zombie death
  net.Start("PlayerKilledNPC")
  net.WriteString(entity:GetClass())
  net.WriteString(self:GetClass())
  net.WriteEntity(self:GetOwner())
  net.Broadcast()
  self:GetOwner():SetFrags(self:GetOwner():Frags() + 1)
  entity:EmitSound(ZombieSliceSound)
  entity:Remove()
end

------------------------------------------------------------------------------------------------------
--    Purpose: stops the song from playing when a radio is removed
------------------------------------------------------------------------------------------------------
local function EntityRemoved(entity)
  if entity.Song then
    entity.Glow:Remove()
    entity.Song:Stop()
  elseif entity.WarmupSound then
    -- stop sounds from playing when the player dies
    entity.WarmupSound:Stop()
    entity.FiringSound:Stop()
  end
end

hook.Add("EntityRemoved", "LaserGun_RemoveRadio", EntityRemoved)

------------------------------------------------------------------------------------------------------
--    Purpose: gives credit to players for killing burning entities and for using hoppers
------------------------------------------------------------------------------------------------------
local function EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
  if not IsValid(inflictor) or not IsValid(attacker) then return end

  if amount >= entity:Health() then
    local isFlameOwned = IsValid(entity.FlameOwner)
    local isFlame = inflictor:GetClass() == "entityflame" or attacker:GetClass() == "entityflame"
    local isCombine = entity:GetClass():find("combine") ~= nil or entity:GetClass():find("police") ~= nil

    if isFlameOwned and ((not isFlame and isCombine) or isFlame) then
      damageInfo:SetInflictor(entity.FlameOwnerWeapon)
      damageInfo:SetAttacker(entity.FlameOwner)
    end

    local attacker = damageInfo:GetAttacker()

    if attacker.IsFriendly and IsValid(attacker.Disarmer) then
      damageInfo:SetAttacker(attacker.Disarmer)
    end
  end
end

hook.Add("EntityTakeDamage", "LaserGun_CreditFlameOwner", EntityTakeDamage)

------------------------------------------------------------------------------------------------------
--    Purpose: damages all entities in a radius that are under water
------------------------------------------------------------------------------------------------------
function SWEP:DoUnderwaterDischarge()
  local damageInfo = DamageInfo()
  damageInfo:SetDamagePosition(self:GetPos())
  damageInfo:SetInflictor(self)
  damageInfo:SetAttacker(self:GetOwner())

  for i, entity in ipairs(ents.FindInSphere(self:GetPos(), 512)) do
    if entity:WaterLevel() >= 3 then
      damageInfo:SetDamage(math.max(1, entity:Health() - 1))
      damageInfo:SetDamageType(entity:IsPlayer() and DMG_RADIATION or DMG_GENERIC)
      entity:TakeDamageInfo(damageInfo)
      entity:EmitSound(SparkSound)
    end
  end

  local effectData = EffectData()
  effectData:SetEntity(self:GetOwner())
  effectData:SetRadius(512)
  util.Effect("LaserGun_Lightning", effectData)
  self:SetClip1(0)
end

------------------------------------------------------------------------------------------------------
--    Purpose: do damage to the entity we're looking at
------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack()
  if CLIENT then return end

  if self.FirstTimeFired then
    -- allow the weapon to recharge for a bit
    if self:Clip1() <= 25 then return end
    self:DoWarmup()
  else
    if self:GetOwner():WaterLevel() >= 3 then
      self:DoUnderwaterDischarge()
      self:DoCooldown()

      return
    end

    self:DoDischarge()

    if self:Clip1() <= 0 then
      self:DoCooldown()
    end
  end
end

------------------------------------------------------------------------------------------------------
--    Purpose: process key presses and releases, do damage 
------------------------------------------------------------------------------------------------------
function SWEP:Think()
  if CLIENT then
    self:ProcessEffects()

    return
  end

  if self:GetOwner():KeyReleased(IN_ATTACK) and not self.FirstTimeFired then
    local oldPhase = self.dt.Phase
    self:DoCooldown()

    if oldPhase ~= PHASE_FIRE then
      self.NextAmmoRegen = CurTime() + 0.025
    end
  end

  if self.NextAmmoRegen ~= -1 and CurTime() > self.NextAmmoRegen then
    self:SetClip1(math.min(self:Clip1() + 1, 100))
    self.NextAmmoRegen = CurTime() + 0.02
    self.dt.Phase = PHASE_NONE
  end

  if CurTime() > self.NextIdle then
    self:SendWeaponAnim(ACT_VM_IDLE)
    self.NextIdle = CurTime() + self:SequenceDuration()
  end
end

------------------------------------------------------------------------------------------------------
--    Purpose: stop sounds and beam effect when holstering
------------------------------------------------------------------------------------------------------
function SWEP:Deploy()
  if SERVER then
    self.dt.Phase = PHASE_NONE
  end

  return true
end

------------------------------------------------------------------------------------------------------
--    Purpose: stop sounds and beam effect when holstering
------------------------------------------------------------------------------------------------------
function SWEP:Holster()
  if self.dt.Phase == PHASE_FIRE or self.dt.Phase == PHASE_WARMUP then
    if SERVER then
      self:SetNextPrimaryFire(CurTime())
      self.FirstTimeFired = true
      self.NextAmmoRegen = CurTime()
    else
      self.WarmupSound:Stop()
      self.FiringSound:Stop()
      self:EmitSound(CooldownSound)
      self.ChargeFrac = 0
      self.ChargeSpeed = 0
      self.Emitter:Finish()
    end
  end

  return true
end

------------------------------------------------------------------------------------------------------
--    Purpose: stop sounds and beam effect when weapon is dropped
------------------------------------------------------------------------------------------------------
function SWEP:OnDrop()
  if SERVER and (self.dt.Phase == PHASE_FIRE or self.dt.Phase == PHASE_WARMUP) then
    self:DoCooldown()
  end
end

if SERVER then return end

------------------------------------------------------------------------------------------------------
--    Purpose: play sounds and increase or decrease alpha of the muzzle accordingly
------------------------------------------------------------------------------------------------------
function SWEP:ProcessEffects()
  -- the phase has shifted
  if self.dt.Phase ~= self.LastPhase then
    if self.dt.Phase == PHASE_WARMUP then
      self.WarmupSound:Play()
      self.ChargeSpeed = 1 / WarmupLength
      self.Emitter = ParticleEmitter(self:GetPos())
      -- set the bounds here incase the weapon is off-screen
      local tr = self:GetOwner():GetEyeTraceNoCursor()
      self:SetRenderBoundsWS(tr.StartPos, tr.HitPos)
    elseif self.dt.Phase == PHASE_COOLDOWN then
      self.WarmupSound:Stop()
      self.FiringSound:Stop()
      self:EmitSound(CooldownSound)
      self.ChargeSpeed = -1 / CooldownLength
      self.Emitter:Finish()
      self.Emitter = nil
    elseif self.dt.Phase == PHASE_FIRE then
      self.WarmupSound:Stop()
      self.FiringSound:Play()
    end

    self.LastPhase = self.dt.Phase
  end

  self.ChargeFrac = math.Clamp(self.ChargeFrac + self.ChargeSpeed * FrameTime(), 0, 1)
end

local LaserMaterial = Material("sprites/bluelaser1")

local MuzzleMaterial = CreateMaterial("LaserGunMuzzle", "UnlitGeneric", {
  ["$basetexture"] = "sprites/blueglow1",
  ["$vertexcolor"] = 1,
  ["$vertexalpha"] = 1,
  ["$additive"] = 1
})

local MuzzleColor = Color(255, 255, 255)

------------------------------------------------------------------------------------------------------
--    Purpose: draw the beam effect, sparks and decals
------------------------------------------------------------------------------------------------------
function SWEP:DrawLaserBeam(viewSpace)
  -- get the proper muzzle attachment
  local weaponModel = viewSpace and self:GetOwner():GetViewModel() or self
  local muzzle = weaponModel:GetAttachment(weaponModel:LookupAttachment("muzzle"))
  local tr = self:GetOwner():GetEyeTraceNoCursor()
  MuzzleColor.a = self.ChargeFrac * 255
  local muzzleSize = 16 + math.Rand(-self.ChargeFrac, self.ChargeFrac)

  if self.dt.Phase == PHASE_FIRE then
    muzzleSize = muzzleSize * 1.5
  end

  local muzzleOffset = muzzle.Ang:Forward()
  muzzleOffset:Mul((weaponModel == self) and 0 or 8)
  local muzzlePos = muzzle.Pos + muzzleOffset
  render.SetMaterial(MuzzleMaterial)
  render.DrawSprite(muzzlePos, muzzleSize, muzzleSize, MuzzleColor)
  render.DrawSprite(muzzlePos, muzzleSize, muzzleSize, MuzzleColor)

  if self.dt.Phase == PHASE_FIRE then
    render.DrawSprite(tr.HitPos, 16, 16, color_white)
    render.DrawSprite(tr.HitPos, 16, 16, color_white)
    render.SetMaterial(LaserMaterial)
    render.DrawBeam(muzzlePos, tr.HitPos, 6, 0, 0, color_white)
    render.DrawBeam(muzzlePos, tr.HitPos, 6, 0, 0, color_white)
    local increment = tr.HitPos - muzzlePos
    local distance = increment:Length()
    local num = math.Clamp(math.floor(distance / 40), 8, 100)
    increment:Normalize()
    increment:Mul(distance / num)
    render.StartBeam(num + 1)
    -- don't add a wiggle to the first cp
    render.AddBeam(muzzlePos, 5, 1)

    for i = 1, num do
      local vectorRand = VectorRand()
      vectorRand:Mul(1.111)
      muzzlePos:Add(increment)
      render.AddBeam(muzzlePos + vectorRand, 5, 1)
    end

    render.EndBeam()

    if CurTime() > self.NextHitEffect then
      self:DoHitEffects(tr)
      self.NextHitEffect = CurTime() + 0.01
    end
  end

  return muzzle, tr
end

------------------------------------------------------------------------------------------------------
--    Purpose: draw the beam in view model space
------------------------------------------------------------------------------------------------------
function SWEP:DoHitEffects(tr)
  if self.Emitter then
    self.Emitter:SetPos(tr.HitPos)

    for i = 1, 2 do
      local velocity = (tr.HitNormal + VectorRand()):GetNormalized()
      velocity:Mul(math.Rand(100, 125))
      local p = self.Emitter:Add("effects/spark", tr.HitPos)
      p:SetVelocity(velocity)
      p:SetDieTime(2)
      p:SetStartSize(math.Rand(3, 5))
      p:SetEndSize(2)
      p:SetStartAlpha(200)
      p:SetEndAlpha(0)
      p:SetStartLength(7)
      p:SetEndLength(5)
      p:SetGravity(physenv.GetGravity())
      p:SetCollide(true)
      p:SetBounce(0.4)
    end
  end

  util.Decal("FadingScorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
end

------------------------------------------------------------------------------------------------------
--    Purpose: draw the beam in view model space
------------------------------------------------------------------------------------------------------
function SWEP:ViewModelDrawn()
  self:DrawLaserBeam(true)
end

------------------------------------------------------------------------------------------------------
--    Purpose:
------------------------------------------------------------------------------------------------------
local function PostPlayerDraw(pl)
  local activeWeapon = pl:GetActiveWeapon()

  if activeWeapon.DrawLaserBeam then
    local muzzle, tr = activeWeapon:DrawLaserBeam(false)
    -- make sure the beam always draws
    -- TODO: this breaks the player's shadow
    activeWeapon:SetRenderBoundsWS(muzzle.Pos, tr.HitPos)
  end
end

hook.Add("PostPlayerDraw", "LaserGun_PostPlayerDraw", PostPlayerDraw)

------------------------------------------------------------------------------------------------------
--    Purpose: add push-back and wiggle effects to the viewmodel
------------------------------------------------------------------------------------------------------
function SWEP:GetViewModelPosition(origin, angles)
  local targetOffset = 0
  local wiggle = VectorRand()
  wiggle:Mul(self.ChargeFrac * 0.15)

  if self.dt.Phase == PHASE_FIRE then
    wiggle:Mul(0.5)
    targetOffset = 5
  end

  if self.dt.Phase == PHASE_COOLDOWN or self.dt.Phase == PHASE_NONE then
    wiggle = vector_origin
  end

  self.VMOffset = Lerp(FrameTime() * 20, self.VMOffset, targetOffset)
  local offset = angles:Forward()
  offset:Mul(self.VMOffset)
  offset:Add(wiggle)
  origin:Sub(offset)

  return origin, angles
end

surface.CreateFont("LaserGun_Selection", {
  font = "HalfLife2",
  size = 64 * ScrH() / 480,
  weight = 0,
  antialias = true,
  additive = true
})

local BackgroundColor = Color(0, 0, 0, 76)

------------------------------------------------------------------------------------------------------
--    Purpose: draw a custom ammo hud
------------------------------------------------------------------------------------------------------
function SWEP:DrawHUD()
  self.HudAlphaFrac = Lerp(FrameTime() * 2, self.HudAlphaFrac, (self:Clip1() >= 100 and self.ChargeFrac <= 0) and 0.5 or 1)
  surface.SetFont("ChatFont")
  local textW, textH = surface.GetTextSize("Power:")
  local boxW, boxH = 200, textH * 2 + 60
  local x, y = ScrW() - boxW - 32, ScrH() - boxH - 32
  local alpha = 255 * self.HudAlphaFrac
  BackgroundColor.a = 76 * self.HudAlphaFrac
  draw.RoundedBox(4, x, y, boxW, boxH, BackgroundColor)
  x, y = x + 8, y + 8
  surface.SetTextColor(255, 128, 0, alpha)
  surface.SetTextPos(x, y)
  surface.DrawText("Buffer:")
  y, boxW = y + textH + 4, boxW - 16
  surface.SetDrawColor(255, 255, 0, alpha)
  surface.DrawRect(x, y, boxW * self.ChargeFrac, 16)
  surface.SetDrawColor(255, 128, 0, alpha)
  surface.DrawOutlinedRect(x, y, boxW, 16)
  y = y + 20
  surface.SetTextPos(x, y)
  surface.DrawText("Power:")
  y = y + textH + 4
  surface.SetDrawColor(255, 255, 0, alpha)
  surface.DrawRect(x, y, boxW * self:Clip1() / 100, 16)
  surface.SetDrawColor(255, 128, 0, alpha)
  surface.DrawOutlinedRect(x, y, boxW, 16)
end

------------------------------------------------------------------------------------------------------
--    Purpose: draw a custom selection hud
------------------------------------------------------------------------------------------------------
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
  surface.SetFont("LaserGun_Selection")
  local mainW, mainH = surface.GetTextSize('a')
  local otherW, otherH = surface.GetTextSize('j')
  local frac = math.sin(CurTime() * 5) / 2 + 0.5
  surface.SetTextColor(80, 170, 255, alpha * frac)
  surface.SetTextPos(x + w / 2 - mainW / 2, y + h / 2 - mainH / 2)
  surface.DrawText('a')
  surface.SetTextColor(255, 220, 0, alpha * (1 - frac))
  surface.SetTextPos(x + w / 2 - otherW / 2, y + h / 2 - otherH / 2)
  surface.DrawText('j')
end

local EFFECT = {}
effects.Register(EFFECT, "LaserGun_Lightning")

------------------------------------------------------------------------------------------------------
--    Purpose: initialize the effect
------------------------------------------------------------------------------------------------------
function EFFECT:Init(data)
  self.DieTime = CurTime() + 0.6
  self.Player = data:GetEntity()
  self.Radius = data:GetRadius()
end

------------------------------------------------------------------------------------------------------
--    Purpose: validate the effect
------------------------------------------------------------------------------------------------------
function EFFECT:Think()
  return IsValid(self.Player) and self.DieTime > CurTime()
end

------------------------------------------------------------------------------------------------------
--    Purpose: draw lightning arcs
------------------------------------------------------------------------------------------------------
function EFFECT:Render()
  local startPos = self.Player:GetShootPos()

  for j, entity in ipairs(ents.FindInSphere(startPos, self.Radius)) do
    -- for some reason the entity is nil sometimes
    if IsValid(entity) then
      render.SetMaterial(LaserMaterial)
      local increment = entity:LocalToWorld(entity:OBBCenter())
      increment:Sub(startPos)
      local distance = increment:Length()
      local num = math.floor(distance / 40)
      local beamPos = Vector(startPos.x, startPos.y, startPos.z)
      increment:Normalize()
      increment:Mul(distance / num)
      render.StartBeam(num + 1)
      render.AddBeam(beamPos, 8, 1)

      for i = 1, num do
        local vectorRand = VectorRand()
        vectorRand:Mul(10)
        beamPos:Add(increment)
        render.AddBeam(beamPos + vectorRand, 8, 1)
      end

      render.EndBeam()
    end
  end
end