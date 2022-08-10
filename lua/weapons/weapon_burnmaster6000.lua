AddCSLuaFile()

if CLIENT then
  language.Add("weapon_burnmaster6000", "Burnmaster 6000")
end

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Toybox Classics"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 64
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false
SWEP.Author = "Heavy-D"
SWEP.Contact = "Just add me on Steam"
SWEP.Purpose = "Turn Your Enemies into Toast"
SWEP.Instructions = "Figure it out"
SWEP.PrintName = "Burnmaster 6000"
SWEP.Slot = 3
SWEP.SlotPos = 6
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "rpg"
--Seriously though. This code is bat-shit-crazy messy
-- Have to agree, might be a bit hard to fix...
local sndAttackLoop = Sound("fire_large")
local sndSprayLoop = Sound("ambient.steam01")
local sndAttackStop = Sound("ambient/_period.wav")
local sndIgnite = Sound("PropaneTank.Burst")

SWEP.VElements = {
  ["nozzlehose"] = {
    type = "Model",
    model = "models/props_c17/signpole001.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(1.843, -1.012, 3.312),
    angle = Angle(-179.032, 134.1, -179.907),
    size = Vector(0.337, 0.337, 0.337),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["chamber++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x4.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, 17.669),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.079, 0.079, 0.166),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["chamber++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x2.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, -1.938),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.075, 0.075, 0.075),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["fuel_line_1+"] = {
    type = "Model",
    model = "models/props_c17/GasPipes006a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(-2.708, -3.3, 3.319),
    angle = Angle(-0.588, 90.224, 104.481),
    size = Vector(0.159, 0.159, 0.159),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["chamber+++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x2b.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, -1.938),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.085, 0.085, 0.085),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["chamber++++++++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x4.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, 11.899),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.085, 0.085, 0.009),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["stock2"] = {
    type = "Model",
    model = "models/props_c17/FurnitureDrawer003a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.393, -0.838, -8.912),
    angle = Angle(7.105, -88.431, 0),
    size = Vector(0.21, 0.266, 0.204),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["nozzle01+"] = {
    type = "Model",
    model = "models/props_wasteland/laundry_washer001a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.906, -2.951, 0.317),
    angle = Angle(-92.064, 23.018, -34.826),
    size = Vector(0.014, 0.014, 0.014),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["nozzle01"] = {
    type = "Model",
    model = "models/props_wasteland/laundry_washer001a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.906, -2.951, 2.312),
    angle = Angle(-92.064, 23.018, -34.826),
    size = Vector(0.014, 0.014, 0.014),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["stock"] = {
    type = "Model",
    model = "models/props_c17/oildrum001.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.219, -0.844, -3.899),
    angle = Angle(0, 2.638, -25.194),
    size = Vector(0.136, 0.136, 0.048),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "phoenix_storms/gear",
    skin = 0,
    bodygroup = {}
  },
  ["chamber+++++++++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x4.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, 15.899),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.085, 0.085, 0.009),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["chamber+++++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x4.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, 5.663),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.072, 0.072, 0.072),
    color = Color(255, 255, 255, 255),
    surpresslightning = true,
    material = "phoenix_storms/chrome",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["flamenozzle"] = {
    type = "Model",
    model = "models/props_vehicles/carparts_muffler01a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(2.687, -0.131, 44),
    angle = Angle(-83.506, -136.644, 19.643),
    size = Vector(0.156, 0.156, 0.156),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["flame"] = {
    type = "Sprite",
    sprite = "sprites/glow02",
    bone = "ValveBiped.Crossbow_base",
    rel = "flamenozzle",
    pos = Vector(-5.645, 0, 0),
    size = {
      x = 2.566,
      y = 6.216
    },
    color = Color(255, 60, 0, 255),
    nocull = true,
    additive = true,
    vertexalpha = true,
    vertexcolor = true,
    ignorez = false
  },
  ["chamber++++++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x4.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, 3.9),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.085, 0.085, 0.009),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["tank"] = {
    type = "Model",
    model = "models/props_junk/gascan001a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(-2.664, -0.695, 5.425),
    angle = Angle(0, 180, 0),
    size = Vector(0.486, 0.486, 0.486),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["chamber++++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x1.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, -2.589),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.085, 0.085, 0.039),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["endnozzle"] = {
    type = "Model",
    model = "models/xqm/afterburner1medium.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(-0.025, -1.624, 55),
    angle = Angle(0, -1.226, 0),
    size = Vector(0.085, 0.085, 0.229),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {}
  },
  ["chamber+++++++++"] = {
    type = "Model",
    model = "models/hunter/tubes/tube1x1x4.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.187, -1.625, 7.9),
    angle = Angle(0, 9.394, 0),
    size = Vector(0.085, 0.085, 0.009),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "models/props_pipes/pipesystem01a_skin2",
    skin = 0,
    bodygroup = {
      [2] = 1
    }
  },
  ["radiator"] = {
    type = "Model",
    model = "models/props_wasteland/prison_heater001a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(1.906, -2.013, 3.805),
    angle = Angle(0, 0, 0),
    size = Vector(0.063, 0.063, 0.063),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["fuel_line_1"] = {
    type = "Model",
    model = "models/props_c17/GasPipes006a.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(-2.671, -3.3, 1.319),
    angle = Angle(-0.588, 90.224, 104.481),
    size = Vector(0.159, 0.159, 0.159),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["grip"] = {
    type = "Model",
    model = "models/props_c17/oildrum001.mdl",
    bone = "ValveBiped.Crossbow_base",
    rel = "",
    pos = Vector(0.056, 0.105, -3.789),
    angle = Angle(0, 0, -0.131),
    size = Vector(0.143, 0.143, 0.234),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  }
}

SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.ViewModelBoneMods = {
  ["ValveBiped.Bip01_L_Finger0"] = {
    scale = Vector(1, 1, 1),
    pos = Vector(-0.219, 0, 0),
    angle = Angle(0.361, -18.101, 0)
  },
  ["ValveBiped.bowl_wheel"] = {
    scale = Vector(0.009, 0.009, 0.009),
    pos = Vector(0, 0, 0),
    angle = Angle(0, 0, 0)
  },
  ["ValveBiped.bowl1"] = {
    scale = Vector(0, 0, 0),
    pos = Vector(0, 0, 0),
    angle = Angle(0, 0, 0)
  },
  ["ValveBiped.bowl2"] = {
    scale = Vector(0, 0, 0),
    pos = Vector(0, 0, 0),
    angle = Angle(0, 0, 0)
  },
  ["ValveBiped.bowr2"] = {
    scale = Vector(0, 0, 0),
    pos = Vector(0, 0, 0),
    angle = Angle(0, 0, 0)
  },
  ["ValveBiped.bowr1"] = {
    scale = Vector(0, 0, 0),
    pos = Vector(0, 0, 0),
    angle = Angle(0, 0, 0)
  },
  ["ValveBiped.pull"] = {
    scale = Vector(0, 0, 0),
    pos = Vector(0, 0, 1.549),
    angle = Angle(0, 0, 0)
  },
  ["ValveBiped.Crossbow_base"] = {
    scale = Vector(0.009, 0.009, 0.009),
    pos = Vector(0, 0, 0),
    angle = Angle(0, 0, 0)
  }
}

SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.
SWEP.Primary.ClipSize = 2500
SWEP.Primary.DefaultClip = 7500
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Damage = 3
SWEP.Secondary.NumShots = 1
SWEP.Secondary.Cone = 0.02
SWEP.Secondary.Delay = 0.
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:Think()
  if self:GetOwner():KeyReleased(IN_ATTACK) or self:GetOwner():KeyReleased(IN_ATTACK2) then
    self:StopSounds()
  end
end

function SWEP:CanReload()
  if self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():KeyDown(IN_ATTACK2) or self:Clip1() > 2499 or self:GetNWBool("Reloading") == true or (self:Clip1() == self:GetMaxClip1() and self:Clip2() == self:GetMaxClip2()) then return false end

  return true
end

function SWEP:Reload()
  if not self:CanReload() then return false end
  self:SetNWBool("Reloading", true)

  if CLIENT and not game.SinglePlayer() then
    self:EmitSound("weapons/ar2/npc_ar2_reload.wav")

    return
  else
    self:EmitSound("weapons/ar2/npc_ar2_reload.wav")
  end

  self:SendWeaponAnim(ACT_VM_HOLSTER)
  self.ReloadTime = CurTime() + 2
  self:SetDTBool(0, true)

  timer.Simple(2, function()
    if not IsValid(self) then return end
    self.Weapon:DefaultReload(ACT_VM_DRAW)
  end)

  timer.Simple(3, function()
    if not IsValid(self) then return end
    self:SetNWBool("Reloading", false)
  end)
end

function SWEP:CanPrimaryAttack()
  if self:GetNWBool("Reloading") == true or self:Clip1() < 1 then return false end

  return true
end

function SWEP:PrimaryAttack()
  local curtime = CurTime()
  local InRange = false
  self.Weapon:SetNextSecondaryFire(curtime + 0.8)
  self.Weapon:SetNextPrimaryFire(curtime + self.Primary.Delay)

  if not self:CanPrimaryAttack() or self:GetOwner():WaterLevel() > 1 or self:GetNWBool("Reloading") == true then
    self:StopSounds()

    return
  end

  if not self.EmittingSound then
    self.Weapon:EmitSound(sndAttackLoop)
    self.EmittingSound = true
  end

  self:TakePrimaryAmmo(1)
  --if SERVER then
  local PlayerVel = self:GetOwner():GetVelocity()
  local PlayerPos = self:GetOwner():GetShootPos()
  local PlayerAng = self:GetOwner():GetAimVector()
  local trace = {}
  trace.start = PlayerPos
  trace.endpos = PlayerPos + (PlayerAng * 4096)
  trace.filter = self:GetOwner()
  local traceRes = util.TraceLine(trace)
  local hitpos = traceRes.HitPos
  local jetlength = (hitpos - PlayerPos):Length()

  if jetlength > 568 then
    jetlength = 568
  end

  if jetlength < 6 then
    jetlength = 6
  end

  if self:GetOwner():Alive() then
    local effectdata = EffectData()
    effectdata:SetOrigin(hitpos)
    effectdata:SetEntity(self)
    effectdata:SetStart(PlayerPos)
    effectdata:SetNormal(PlayerAng)
    effectdata:SetScale(jetlength)
    effectdata:SetAttachment(1)
    util.Effect("flamepuffs", effectdata)
  end

  if self.DoShoot then
    local ptrace = {}
    ptrace.startpos = PlayerPos + PlayerAng:GetNormalized() * 16
    local ang = (traceRes.HitPos - ptrace.startpos):GetNormalized()
    ptrace.func = burndamage
    ptrace.movetype = MOVETYPE_FLY
    ptrace.velocity = ang * 728 + 0.5 * PlayerVel
    ptrace.model = "none"

    ptrace.filter = {self:GetOwner()}

    ptrace.killtime = (jetlength + 16) / ptrace.velocity:Length()
    ptrace.runonkill = false
    ptrace.collisionsize = 14
    ptrace.worldcollide = true
    ptrace.owner = self:GetOwner()
    ptrace.name = "flameparticle"
    ParticleTrace(ptrace)
    self.DoShoot = false
  else
    self.DoShoot = true
  end
  --end
end

function SWEP:GetViewModelPosition(origin, angles)
  local targetOffset = 0
  local wiggle = VectorRand()
  wiggle:Mul(0.001)
  if self:GetNWBool("Reloading") == true then return end

  if self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():KeyDown(IN_ATTACK2) then
    wiggle:Mul(200)
    targetOffset = 5
  end

  if self:GetOwner():KeyReleased(IN_ATTACK) or self:GetOwner():KeyReleased(IN_ATTACK2) then
    wiggle = vector_origin
  end

  if not isnumber(self.VMOffset) then
    self.VMOffset = 0
  end

  self.VMOffset = Lerp(FrameTime() * 20, self.VMOffset, targetOffset)
  local offset = angles:Forward()
  offset:Mul(self.VMOffset)
  offset:Add(wiggle)
  origin:Sub(offset)

  return origin, angles
end

function SWEP:SecondaryAttack()
  if not self:CanSecondaryAttack() or self:GetOwner():WaterLevel() > 1 or self:GetNWBool("Reloading") == true then
    self:StopSounds()

    return
  end

  local curtime = CurTime()
  self.Weapon:SetNextSecondaryFire(curtime + self.Primary.Delay)
  self.Weapon:SetNextPrimaryFire(curtime + 1)

  if not self:CanSecondaryAttack() or self:GetOwner():WaterLevel() > 1 then
    self:StopSounds()

    return
  end

  if not self.EmittingSound then
    self.Weapon:EmitSound(sndSprayLoop)
    self.EmittingSound = true
  end

  self:TakePrimaryAmmo(1)
  local PlayerVel = self:GetOwner():GetVelocity()
  local PlayerPos = self:GetOwner():GetShootPos()
  local PlayerAng = self:GetOwner():GetAimVector()
  local trace = {}
  trace.start = PlayerPos
  trace.endpos = PlayerPos + (PlayerAng * 4096)
  trace.filter = self:GetOwner()
  local traceRes = util.TraceLine(trace)
  local hitpos = traceRes.HitPos
  local jetlength = (hitpos - PlayerPos):Length()

  if jetlength > 568 then
    jetlength = 568
  elseif self.DoShoot then
    local normal = traceRes.HitNormal

    if traceRes.HitNonWorld then
      local hitent = traceRes.Entity
      local enttype = hitent:GetClass()

      if hitent:IsNPC() or hitent:IsPlayer() or enttype == "prop_physics" or enttype == "prop_vehicle" then
        local hitenttable = hitent:GetTable()
        hitenttable.FuelLevel = hitenttable.FuelLevel or 0
        hitenttable.FuelLevel = hitenttable.FuelLevel + 1
        util.Decal("BeerSplash", hitpos + normal, hitpos - normal)
      end
    elseif Vector(0, 0, 1):Dot(normal) > 0.25 then
      if SERVER then
        local fire = ents.Create("fire_controller")
        fire:SetPos(hitpos + normal * 16)
        fire:SetOwner(self:GetOwner())
        fire:Spawn()
      end

      util.Decal("BeerSplash", hitpos + normal, hitpos - normal)
    end

    if SERVER then
      for key, found in ipairs(ents.FindInSphere(hitpos, 32)) do
        local foundname = found:GetName()

        if found:GetClass() == "entityflame" or found:GetName() == "BurningFire" or found:GetName() == "flameparticle" then
          --If we hapen to be blowing napalm near an open flame...
          self:explode(self:GetOwner(), PlayerPos) --Then blow ourselves up.

          --Spawn some fires near our charred, lifeless corpse.
          for i = 1, 7 do
            local fire = ents.Create("env_fire")
            local randvec = Vector(math.random(-150, 150), math.random(-150, 150), 0)
            fire:SetKeyValue("StartDisabled", "0")
            fire:SetKeyValue("health", math.random(29, 31))
            fire:SetKeyValue("firesize", math.random(64, 72))
            fire:SetKeyValue("fireattack", "2")
            fire:SetKeyValue("ignitionpoint", "0")
            fire:SetKeyValue("damagescale", "35")
            fire:SetKeyValue("spawnflags", 2 + 4 + 128)
            fire:SetPos(PlayerPos + randvec)
            fire:SetOwner(self:GetOwner())
            fire:Spawn()
            fire:Fire("StartFire", "", "0")
          end

          break
        end
      end
    end

    self.DoShoot = false
  else
    self.DoShoot = true
  end

  if jetlength < 6 then
    jetlength = 6
  end

  local effectdata = EffectData()
  effectdata:SetEntity(self)
  effectdata:SetStart(PlayerPos)
  effectdata:SetNormal(PlayerAng)
  effectdata:SetScale(jetlength)
  effectdata:SetAttachment(1)
  util.Effect("gaspuffs", effectdata)
end

HumanModels = {"[Hh]umans", "[Pp]layer", "[Zz]ombie", "[Pp]olice.mdl", "[Ss]oldier", "[Aa]lyx.mdl", "[Bb]arney.mdl", "[Bb]reen.mdl", "[Ee]li.mdl", "[Mm]onk.mdl", "[Kk]leiner.mdl", "[Mm]ossman.mdl", "[Oo]dessa.mdl", "[Gg]man", "[Mm]agnusson"}

function IsHumanoid(ent)
  if ent:IsPlayer() then return true end
  local entmodel = ent:GetModel()

  for k, model in ipairs(HumanModels) do
    if string.find(entmodel, model) ~= nil then return true end
  end

  return false
end

function SWEP:explode(ent, pos)
  pos = pos or ent:GetPos()
  local boom = ents.Create("env_explosion")
  boom:SetKeyValue("iMagnitude", "10")
  boom:SetPos(pos)
  boom:SetOwner(ent)
  boom:Spawn()
  boom:Fire("Explode", "", "0")
  local effectdata = EffectData()
  effectdata:SetOrigin(pos)
  util.Effect("Explosion_Large", effectdata)
end

function SWEP:Immolate(ent, pos)
  pos = pos or ent:GetPos()

  if ent:IsPlayer() then
    ent:Kill()
  else
    ent:SetModel("models/Humans/Charple0" .. math.random(1, 4) .. ".mdl")
    ent:SetHealth(0)
  end

  local effectdata = EffectData()
  effectdata:SetOrigin(pos)
  util.Effect("immolate", effectdata)
end

function burndamage(ptres)
  local hitent = ptres.activator
  if hitent:WaterLevel() > 0 then return end
  local ttime = ptres.time

  --Division by zero is bad! D :
  if ttime == 0 then
    ttime = 0.1
  end

  local damage = math.ceil(3 / ttime)

  if damage > 400 then
    damage = 400
  end

  local radius = math.ceil(256 * ttime)

  if radius < 16 then
    radius = 16
  end

  local healthpercent = 3
  local isnpc = hitent:IsNPC()
  local enthealth = 2
  local enttable = hitent:GetTable()

  if isnpc and IsHumanoid(hitent) then
    enthealth = hitent:Health()
    healthpercent = math.ceil(enthealth / 5)
  end

  local fuel = enttable.FuelLevel

  if fuel and fuel > 0 then
    ptres.caller:EmitSound(sndIgnite)
    enttable.FuelLevel = 0
    local entpos = hitent:GetPos()
    local boompos = entpos
    boompos.z = boompos.z + hitent:BoundingRadius() / 2
    local damagemult = 1
    local radiusmult = radius + fuel
    local effectdata = EffectData()
    effectdata:SetOrigin(entpos)
    effectdata:SetEntity(hitent)
    effectdata:SetStart(entpos)
    effectdata:SetNormal(Vector(0, 0, 1))
    effectdata:SetScale(10)
    util.Effect("HelicopterMegaBomb", effectdata)
  else
    if IsValid(ptres.owner:GetActiveWeapon()) then
      util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, ptres.particlepos, radius, damage)
    else
      util.BlastDamage(ptres.owner, ptres.owner, ptres.particlepos, radius, damage)
    end

    if isnpc and IsHumanoid(hitent) then
      pos = entpos or hitent:GetPos()

      if hitent:IsPlayer() then
        hitent:Kill()
      else
        hitent:SetModel("models/Humans/Charple0" .. math.random(1, 4) .. ".mdl")
        hitent:SetHealth(0)
      end

      local effectdata = EffectData()
      effectdata:SetOrigin(pos)
      util.Effect("immolate", effectdata)
      ptres.caller:EmitSound(sndIgnite)
      hitent:Ignite(math.Rand(7, 11), 0)
    end
  end
end

local function DeFlamitize(ply)
  ply:GetTable().FuelLevel = 0

  if ply:IsOnFire() then
    ply:Extinguish()
  end
end

hook.Add("PlayerDeath", "deflame", DeFlamitize)

function SWEP:StopSounds()
  if self.EmittingSound then
    self.Weapon:StopSound(sndAttackLoop)
    self.Weapon:StopSound(sndSprayLoop)
    self.Weapon:EmitSound(sndAttackStop)
    self.EmittingSound = false
  end
end

function SWEP:Holster()
  self:StopSounds()

  if CLIENT and IsValid(self:GetOwner()) then
    local vm = self:GetOwner():GetViewModel()

    if IsValid(vm) then
      self:ResetBonePositions(vm)
    end
  end

  return true
end

function SWEP:OnRemove()
  self:Holster()

  return true
end

function SWEP:Initialize()
  self:SetHoldType(self.HoldType)
  self.EmittingSound = false
  util.PrecacheModel("models/Humans/Charple01.mdl")
  util.PrecacheModel("models/Humans/Charple02.mdl")
  util.PrecacheModel("models/Humans/Charple03.mdl")
  util.PrecacheModel("models/Humans/Charple04.mdl")

  -- other initialize code goes here
  if CLIENT then
    -- Create a new table for every weapon instance
    self.VElements = table.FullCopy(self.VElements)
    self.WElements = table.FullCopy(self.WElements)
    self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)
    self:CreateModels(self.VElements) -- create viewmodels
    self:CreateModels(self.WElements) -- create worldmodels

    -- init view model bone build function
    if IsValid(self:GetOwner()) then
      local vm = self:GetOwner():GetViewModel()

      if IsValid(vm) then
        self:ResetBonePositions(vm)

        -- Init viewmodel visibility
        if self.ShowViewModel == nil or self.ShowViewModel then
          vm:SetColor(Color(255, 255, 255, 255))
        else
          -- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
          vm:SetColor(Color(255, 255, 255, 1))
          -- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
          -- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
          vm:SetMaterial("Debug/hsv")
        end
      end
    end
  end
end

if CLIENT then
  local EFFECT = {}

  function EFFECT:Init(data)
    self.Position = data:GetStart()
    self.WeaponEnt = data:GetEntity()
    self.Attachment = data:GetAttachment()
    local Pos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
    local Velocity = data:GetNormal()
    local AddVel = self.WeaponEnt:GetOwner():GetVelocity() * 0.5
    local jetlength = data:GetScale()
    local maxparticles1 = math.ceil(jetlength / 81) + 1
    local maxparticles2 = math.ceil(jetlength / 190) + 1
    Pos = Pos + Velocity * 2
    local emitter = ParticleEmitter(Pos)

    for i = 1, maxparticles1 do
      local particle = emitter:Add("particles/flamelet" .. math.random(1, 5), Pos + Velocity * i * math.Rand(1.6, 3))
      local randvel = Velocity + Vector(math.Rand(-0.04, 0.04), math.Rand(-0.04, 0.04), math.Rand(-0.04, 0.04))
      local partvel = randvel * math.Rand(jetlength / 0.7, jetlength / 0.8) + AddVel
      local partime = jetlength / partvel:Length()

      if partime > 0.85 then
        partime = 0.85
      end

      particle:SetVelocity(partvel)
      particle:SetDieTime(partime)
      particle:SetStartAlpha(math.Rand(100, 150))
      particle:SetStartSize(1.7)
      particle:SetEndSize(math.Rand(72, 96))
      particle:SetRoll(math.Rand(0, 360))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(math.Rand(130, 230), math.Rand(100, 160), 120)
      --particle:VelocityDecay( false )
    end

    for i = 0, maxparticles2 do
      local particle = emitter:Add("particles/flamelet" .. math.random(1, 5), Pos + Velocity * i * math.Rand(0.3, 0.6))
      particle:SetVelocity(Velocity * math.Rand(0.42 * jetlength / 0.3, 0.42 * jetlength / 0.4) + AddVel)
      particle:SetDieTime(math.Rand(0.3, 0.4))
      particle:SetStartAlpha(255)
      particle:SetStartSize(0.6 * i)
      particle:SetEndSize(math.Rand(24, 32))
      particle:SetRoll(math.Rand(0, 360))
      particle:SetRollDelta(math.Rand(-0.5, 0.5))
      particle:SetColor(30, 15, math.Rand(190, 225))
      --particle:VelocityDecay( false )
    end

    emitter:Finish()
  end

  function EFFECT:Think()
    return false
  end

  function EFFECT:Render()
  end

  effects.Register(EFFECT, "flamepuffs")
end

if CLIENT then
  local EFFECT = {}

  function EFFECT:Init(data)
    self.Position = data:GetStart()
    self.WeaponEnt = data:GetEntity()
    self.Attachment = data:GetAttachment()
    local Pos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
    local Velocity = data:GetNormal()
    local AddVel
    local jetlength = data:GetScale()

    if IsValid(self.WeaponEnt) and IsValid(self.WeaponEnt:GetOwner()) then
      AddVel = self.WeaponEnt:GetOwner():GetVelocity() * 0.85
    elseif IsValid(self.WeaponEnt) then
      AddVel = self.WeaponEnt:GetVelocity() * 0.85
    else
      AddVel = Vector(17, -40, -40)
    end

    local maxparticles1 = math.ceil(jetlength / 71) + 1
    local maxparticles2 = math.ceil(jetlength / 190)
    Pos = Pos + Velocity * 2
    local emitter = ParticleEmitter(Pos)

    for i = 4, maxparticles1 do
      local particle = emitter:Add("particles/smokey", Pos + Velocity * i * math.Rand(1.5, 2.6))
      local partvel = Velocity * math.Rand(jetlength / 0.5, jetlength / 0.6) + AddVel
      local partime = jetlength / partvel:Length()

      if partime > 0.85 then
        partime = 0.85
      end

      particle:SetVelocity(partvel)
      particle:SetDieTime(partime)
      particle:SetStartAlpha(math.Rand(10, 20))
      particle:SetStartSize(2)
      particle:SetEndSize(math.Rand(96, 128))
      particle:SetRoll(math.Rand(0, 360))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(145, math.Rand(160, 200), 70)
      --particle:VelocityDecay( false )
    end

    for i = 0, maxparticles2 do
      local particle = emitter:Add("particles/smokey", Pos + Velocity * i * math.Rand(0.35, 0.55))
      particle:SetVelocity(Velocity * math.Rand(0.6 * jetlength / 0.3, 0.6 * jetlength / 0.4) + AddVel)
      particle:SetDieTime(math.Rand(0.3, 0.4))
      particle:SetStartAlpha(90)
      particle:SetStartSize(0.6 * i)
      particle:SetEndSize(math.Rand(24, 48))
      particle:SetRoll(math.Rand(0, 360))
      particle:SetRollDelta(math.Rand(-0.5, 0.5))
      particle:SetColor(135, math.Rand(120, 140), 60)
      --particle:VelocityDecay( false )
    end

    emitter:Finish()
  end

  function EFFECT:Think()
    return false
  end

  function EFFECT:Render()
  end

  effects.Register(EFFECT, "gaspuffs")
end

if CLIENT then
  local EFFECT = {}

  function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    local Pos = self.Position
    local Norm = Vector(0, 0, 1)
    Pos = Pos + Norm * 2
    local emitter = ParticleEmitter(Pos)

    for i = 1, 28 do
      local particle = emitter:Add("particles/flamelet" .. math.random(1, 5), Pos + Vector(math.random(-80, 80), math.random(-80, 80), math.random(0, 70)))
      particle:SetVelocity(Vector(math.random(-160, 160), math.random(-160, 160), math.random(250, 300)))
      particle:SetDieTime(math.Rand(3.4, 3.7))
      particle:SetStartAlpha(math.Rand(220, 240))
      particle:SetStartSize(48)
      particle:SetEndSize(math.Rand(160, 192))
      particle:SetRoll(math.Rand(360, 480))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(math.Rand(150, 255), math.Rand(100, 150), 100)
      --particle:VelocityDecay( false )
    end

    for i = 1, 20 do
      local particle = emitter:Add("particles/flamelet" .. math.random(1, 5), Pos + Vector(math.random(-40, 40), math.random(-40, 40), math.random(-30, 20)))
      particle:SetVelocity(Vector(math.random(-120, 120), math.random(-120, 120), math.random(170, 250)))
      particle:SetDieTime(math.Rand(3, 3.4))
      particle:SetStartAlpha(math.Rand(220, 240))
      particle:SetStartSize(32)
      particle:SetEndSize(math.Rand(128, 160))
      particle:SetRoll(math.Rand(360, 480))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(math.Rand(150, 255), math.Rand(100, 150), 100)
      --particle:VelocityDecay( false )
    end

    for i = 1, 36 do
      local particle = emitter:Add("particles/flamelet" .. math.random(1, 5), Pos + Vector(math.random(-40, 40), math.random(-40, 40), math.random(10, 70)))
      particle:SetVelocity(Vector(math.random(-300, 300), math.random(-300, 300), math.random(-20, 180)))
      particle:SetDieTime(math.Rand(1.8, 2))
      particle:SetStartAlpha(math.Rand(220, 240))
      particle:SetStartSize(48)
      particle:SetEndSize(math.Rand(128, 160))
      particle:SetRoll(math.Rand(360, 480))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(math.Rand(150, 255), math.Rand(100, 150), 100)
      --particle:VelocityDecay( true )	
    end

    for i = 1, 24 do
      local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-40, 40), math.random(-40, 40), math.random(-30, 10)))
      particle:SetVelocity(Vector(math.random(-280, 280), math.random(-280, 280), math.random(0, 180)))
      particle:SetDieTime(math.Rand(1.9, 2.3))
      particle:SetStartAlpha(math.Rand(60, 80))
      particle:SetStartSize(math.Rand(32, 48))
      particle:SetEndSize(math.Rand(192, 256))
      particle:SetRoll(math.Rand(360, 480))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(170, 160, 160)
      --particle:VelocityDecay( false )
    end

    -- big smoke cloud
    for i = 1, 24 do
      local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-40, 40), math.random(-40, 50), math.random(20, 80)))
      particle:SetVelocity(Vector(math.random(-180, 180), math.random(-180, 180), math.random(260, 340)))
      particle:SetDieTime(math.Rand(3.5, 3.7))
      particle:SetStartAlpha(math.Rand(60, 80))
      particle:SetStartSize(math.Rand(32, 48))
      particle:SetEndSize(math.Rand(192, 256))
      particle:SetRoll(math.Rand(480, 540))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(170, 170, 170)
      --particle:VelocityDecay( false )
    end

    for i = 1, 18 do
      local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-40, 40), math.random(-40, 40), math.random(-30, 60)))
      particle:SetVelocity(Vector(math.random(-200, 200), math.random(-200, 200), math.random(120, 200)))
      particle:SetDieTime(math.Rand(3.1, 3.4))
      particle:SetStartAlpha(math.Rand(60, 80))
      particle:SetStartSize(math.Rand(32, 48))
      particle:SetEndSize(math.Rand(192, 256))
      particle:SetRoll(math.Rand(480, 540))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(170, 170, 170)
      --particle:VelocityDecay( false )
    end

    emitter:Finish()
  end

  function EFFECT:Think()
    return false
  end

  function EFFECT:Render()
  end

  effects.Register(EFFECT, "Explosion_Large")
end

if CLIENT then
  local EFFECT = {}

  function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    local Pos = self.Position
    local Norm = Vector(0, 0, 1)
    Pos = Pos + Norm * 6
    local emitter = ParticleEmitter(Pos)

    --firecloud
    for i = 1, 16 do
      local particle = emitter:Add("particles/flamelet" .. math.random(1, 5), Pos + Vector(math.random(-20, 20), math.random(-20, 20), math.random(-30, 50)))
      particle:SetVelocity(Vector(math.random(-30, 30), math.random(-30, 30), math.random(90, 120)))
      particle:SetDieTime(math.Rand(1.6, 1.8))
      particle:SetStartAlpha(math.Rand(200, 240))
      particle:SetStartSize(16)
      particle:SetEndSize(math.Rand(48, 64))
      particle:SetRoll(math.Rand(360, 480))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(math.Rand(150, 255), math.Rand(100, 150), 100)
      --particle:VelocityDecay( false )
    end

    --smoke cloud
    for i = 1, 18 do
      local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-25, 25), math.random(-25, 25), math.random(-30, 70)))
      particle:SetVelocity(Vector(math.random(-30, 30), math.random(-30, 30), math.random(35, 50)))
      particle:SetDieTime(math.Rand(2.4, 2.9))
      particle:SetStartAlpha(math.Rand(160, 200))
      particle:SetStartSize(24)
      particle:SetEndSize(math.Rand(32, 48))
      particle:SetRoll(math.Rand(360, 480))
      particle:SetRollDelta(math.Rand(-1, 1))
      particle:SetColor(20, 20, 20)
      --particle:VelocityDecay( false )
    end

    emitter:Finish()
  end

  function EFFECT:Think()
    -- Die instantly
    return false
  end

  function EFFECT:Render()
  end

  effects.Register(EFFECT, "immolate")
end

function ParticleTrace(partrace)
  if SERVER then
    if not partrace.func or not partrace.startpos or not (partrace.ang or partrace.velocity) then return end
    partrace.speed = partrace.speed or 1024
    partrace.ang = partrace.ang or partrace.velocity:GetNormalized() or Vector(0, 0, 0)
    partrace.owner = partrace.owner or 0
    partrace.name = partrace.name or ""
    partrace.collisionsize = partrace.collisionsize or 1
    partrace.worldcollide = partrace.worldcollide or true
    partrace.mask = partrace.mask or 3
    partrace.killtime = partrace.killtime or 12
    partrace.runonkill = partrace.runonkill or false
    partrace.movetype = partrace.movetype or MOVETYPE_FLY
    partrace.model = partrace.model or "none"
    partrace.color = partrace.color or Color(255, 255, 255, 255)
    partrace.doblur = partrace.doblur or false
    partrace.filter = partrace.filter or {}
    partrace.starttime = CurTime()
    partrace.dodraw = false
    partrace.issprite = false
    partrace.entid = ents.Create("trace_particle")

    if partrace.model == "none" then
      partrace.entid:SetModel("models/Items/combine_rifle_ammo01.mdl")
    elseif string.find(partrace.model, ".mdl") ~= nil then
      partrace.entid:SetModel(partrace.model)
      partrace.dodraw = true
    else
      partrace.entid:SetModel("models/Items/combine_rifle_ammo01.mdl")
      partrace.dodraw = true
      partrace.issprite = true
      partrace.model = string.gsub(string.gsub(string.gsub(partrace.model, ".vmt", ""), ".vtf", ""), ".spr", "")
    end

    table.insert(partrace.filter, partrace.entid)

    if partrace.speed > 8192 then
      partrace.speed = 8192
    end

    partrace.entid:SetVar("tracedata", partrace)
    partrace.entid:SetPos(partrace.startpos)
    partrace.entid:SetAngles(partrace.ang:Angle())
    partrace.entid:Spawn()
    partrace.entid:SetOwner(partrace.owner)
    partrace.entid:SetName(partrace.name)
    local physobj = partrace.entid:GetPhysicsObject()

    if partrace.velocity then
      partrace.ang = partrace.velocity:GetNormalized()
    else
      partrace.velocity = partrace.ang * partrace.speed
    end

    physobj:SetMass(1e-9)
    physobj:EnableGravity(partrace.gravity)
    physobj:SetVelocity(partrace.velocity)
    partrace.entid:SetVelocity(partrace.velocity)

    if partrace.initfunc then
      partrace.initfunc(partrace.entid)
    end
  end
end

if CLIENT then
  SWEP.vRenderOrder = nil

  function SWEP:ViewModelDrawn()
    local vm = self:GetOwner():GetViewModel()
    if not IsValid(vm) then return end
    if not self.VElements then return end
    self:UpdateBonePositions(vm)

    if not self.vRenderOrder then
      -- we build a render order because sprites need to be drawn after models
      self.vRenderOrder = {}

      for k, v in pairs(self.VElements) do
        if v.type == "Model" then
          table.insert(self.vRenderOrder, 1, k)
        elseif v.type == "Sprite" or v.type == "Quad" then
          table.insert(self.vRenderOrder, k)
        end
      end
    end

    for k, name in ipairs(self.vRenderOrder) do
      local v = self.VElements[name]

      if not v then
        self.vRenderOrder = nil
        break
      end

      if v.hide then continue end
      local model = v.modelEnt
      local sprite = v.spriteMaterial
      if not v.bone then continue end
      local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
      if not pos then continue end

      if v.type == "Model" and IsValid(model) then
        model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        model:SetAngles(ang)
        --model:SetModelScale(v.size)
        local matrix = Matrix()
        matrix:Scale(v.size)
        model:EnableMatrix("RenderMultiply", matrix)

        if v.material == "" then
          model:SetMaterial("")
        elseif model:GetMaterial() ~= v.material then
          model:SetMaterial(v.material)
        end

        if v.skin and v.skin ~= model:GetSkin() then
          model:SetSkin(v.skin)
        end

        if v.bodygroup then
          for k, v in pairs(v.bodygroup) do
            if model:GetBodygroup(k) ~= v then
              model:SetBodygroup(k, v)
            end
          end
        end

        if v.surpresslightning then
          render.SuppressEngineLighting(true)
        end

        render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
        render.SetBlend(v.color.a / 255)
        model:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)

        if v.surpresslightning then
          render.SuppressEngineLighting(false)
        end
      elseif v.type == "Sprite" and sprite then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        render.SetMaterial(sprite)
        render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
      elseif v.type == "Quad" and v.draw_func then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        cam.Start3D2D(drawpos, ang, v.size)
        v.draw_func(self)
        cam.End3D2D()
      end
    end
  end

  SWEP.wRenderOrder = nil

  function SWEP:DrawWorldModel()
    if self.ShowWorldModel == nil or self.ShowWorldModel then
      self:DrawModel()
    end

    if not self.WElements then return end

    if not self.wRenderOrder then
      self.wRenderOrder = {}

      for k, v in pairs(self.WElements) do
        if v.type == "Model" then
          table.insert(self.wRenderOrder, 1, k)
        elseif v.type == "Sprite" or v.type == "Quad" then
          table.insert(self.wRenderOrder, k)
        end
      end
    end

    if IsValid(self:GetOwner()) then
      bone_ent = self:GetOwner()
    else
      -- when the weapon is dropped
      bone_ent = self
    end

    for k, name in ipairs(self.wRenderOrder) do
      local v = self.WElements[name]

      if not v then
        self.wRenderOrder = nil
        break
      end

      if v.hide then continue end
      local pos, ang

      if v.bone then
        pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
      else
        pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
      end

      if not pos then continue end
      local model = v.modelEnt
      local sprite = v.spriteMaterial

      if v.type == "Model" and IsValid(model) then
        model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        model:SetAngles(ang)
        --model:SetModelScale(v.size)
        local matrix = Matrix()
        matrix:Scale(v.size)
        model:EnableMatrix("RenderMultiply", matrix)

        if v.material == "" then
          model:SetMaterial("")
        elseif model:GetMaterial() ~= v.material then
          model:SetMaterial(v.material)
        end

        if v.skin and v.skin ~= model:GetSkin() then
          model:SetSkin(v.skin)
        end

        if v.bodygroup then
          for k, v in pairs(v.bodygroup) do
            if model:GetBodygroup(k) ~= v then
              model:SetBodygroup(k, v)
            end
          end
        end

        if v.surpresslightning then
          render.SuppressEngineLighting(true)
        end

        render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
        render.SetBlend(v.color.a / 255)
        model:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)

        if v.surpresslightning then
          render.SuppressEngineLighting(false)
        end
      elseif v.type == "Sprite" and sprite then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        render.SetMaterial(sprite)
        render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
      elseif v.type == "Quad" and v.draw_func then
        local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        cam.Start3D2D(drawpos, ang, v.size)
        v.draw_func(self)
        cam.End3D2D()
      end
    end
  end

  function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
    local bone, pos, ang

    if tab.rel and tab.rel ~= "" then
      local v = basetab[tab.rel]
      if not v then return end
      -- Technically, if there exists an element with the same name as a bone
      -- you can get in an infinite loop. Let's just hope nobody's that stupid.
      pos, ang = self:GetBoneOrientation(basetab, v, ent)
      if not pos then return end
      pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
      ang:RotateAroundAxis(ang:Up(), v.angle.y)
      ang:RotateAroundAxis(ang:Right(), v.angle.p)
      ang:RotateAroundAxis(ang:Forward(), v.angle.r)
    else
      bone = ent:LookupBone(bone_override or tab.bone)
      if not bone then return end
      pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
      local m = ent:GetBoneMatrix(bone)

      if m then
        pos, ang = m:GetTranslation(), m:GetAngles()
      end

      if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and ent == self:GetOwner():GetViewModel() and self.ViewModelFlip then
        ang.r = -ang.r -- Fixes mirrored models
      end
    end

    return pos, ang
  end

  function SWEP:CreateModels(tab)
    if not tab then return end

    -- Create the clientside models here because Garry says we can't do it in the render hook
    for k, v in pairs(tab) do
      if v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and string.find(v.model, ".mdl") and file.Exists(v.model, "GAME") then
        v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)

        if IsValid(v.modelEnt) then
          v.modelEnt:SetPos(self:GetPos())
          v.modelEnt:SetAngles(self:GetAngles())
          v.modelEnt:SetParent(self)
          v.modelEnt:SetNoDraw(true)
          v.createdModel = v.model
        else
          v.modelEnt = nil
        end
      elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists("materials/" .. v.sprite .. ".vmt", "GAME") then
        local name = v.sprite .. "-"

        local params = {
          ["$basetexture"] = v.sprite
        }

        -- make sure we create a unique name based on the selected options
        local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}

        for i, j in pairs(tocheck) do
          if v[j] then
            params["$" .. j] = 1
            name = name .. "1"
          else
            name = name .. "0"
          end
        end

        v.createdSprite = v.sprite
        v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
      end
    end
  end

  local allbones
  local hasGarryFixedBoneScalingYet = false

  function SWEP:UpdateBonePositions(vm)
    if self.ViewModelBoneMods then
      if not vm:GetBoneCount() then return end
      -- !! WORKAROUND !! //
      -- We need to check all model names :/
      local loopthrough = self.ViewModelBoneMods

      if not hasGarryFixedBoneScalingYet then
        allbones = {}

        for i = 0, vm:GetBoneCount() do
          local bonename = vm:GetBoneName(i)

          if self.ViewModelBoneMods[bonename] then
            allbones[bonename] = self.ViewModelBoneMods[bonename]
          else
            allbones[bonename] = {
              scale = Vector(1, 1, 1),
              pos = Vector(0, 0, 0),
              angle = Angle(0, 0, 0)
            }
          end
        end

        loopthrough = allbones
      end

      -- !! ----------- !! //
      for k, v in pairs(loopthrough) do
        local bone = vm:LookupBone(k)
        if not bone then continue end
        -- !! WORKAROUND !! //
        local s = Vector(v.scale.x, v.scale.y, v.scale.z)
        local p = Vector(v.pos.x, v.pos.y, v.pos.z)
        local ms = Vector(1, 1, 1)

        if not hasGarryFixedBoneScalingYet then
          local cur = vm:GetBoneParent(bone)

          while cur >= 0 do
            local pscale = loopthrough[vm:GetBoneName(cur)].scale
            ms = ms * pscale
            cur = vm:GetBoneParent(cur)
          end
        end

        s = s * ms

        -- !! ----------- !! //
        if vm:GetManipulateBoneScale(bone) ~= s then
          vm:ManipulateBoneScale(bone, s)
        end

        if vm:GetManipulateBoneAngles(bone) ~= v.angle then
          vm:ManipulateBoneAngles(bone, v.angle)
        end

        if vm:GetManipulateBonePosition(bone) ~= p then
          vm:ManipulateBonePosition(bone, p)
        end
      end
    else
      self:ResetBonePositions(vm)
    end
  end

  function SWEP:ResetBonePositions(vm)
    if not vm:GetBoneCount() then return end

    for i = 0, vm:GetBoneCount() do
      vm:ManipulateBoneScale(i, Vector(1, 1, 1))
      vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
      vm:ManipulateBonePosition(i, Vector(0, 0, 0))
    end
  end

  --[[*************************
		Global utility code
	*************************]]
  -- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
  -- Does not copy entities of course, only copies their reference.
  -- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
  function table.FullCopy(tab)
    if not tab then return nil end
    local res = {}

    for k, v in pairs(tab) do
      if type(v) == "table" then
        res[k] = table.FullCopy(v) -- recursion ho!
      elseif type(v) == "Vector" then
        res[k] = Vector(v.x, v.y, v.z)
      elseif type(v) == "Angle" then
        res[k] = Angle(v.p, v.y, v.r)
      else
        res[k] = v
      end
    end

    return res
  end
end