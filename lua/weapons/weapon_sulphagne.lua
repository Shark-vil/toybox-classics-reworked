AddCSLuaFile()
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
SWEP.Category = "Toybox Classics"
SWEP.PrintName = "Sulphagne"
SWEP.Slot = 0
SWEP.SlotPos = 3
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Author = "Irtimid"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.HoldType = "normal"
SWEP.Instructions = "Write that down."
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
fadeEntities = {}
fadeAmt = {}

function SWEP:Initialize()
  self.counter = 0
  self.firing = false
  self.cooldown = 0
  self:SetWeaponHoldType(self.HoldType)
end

--[[---------------------------------------------------------
    Reload does nothing
---------------------------------------------------------]]
function SWEP:Reload()
end

function SWEP:ShiftFadeEntities(pos)
  for i = pos, #fadeEntities - 1 do
    -- print(i .. " -> " .. (i+1))
    fadeEntities[i] = fadeEntities[i + 1]
  end

  if #fadeEntities > 1 then
    fadeEntities[#fadeEntities] = nil
  end
end

function SWEP:Think()
  if #fadeEntities > 0 then
    for i = 1, #fadeEntities do
      if fadeEntities[i] ~= nil and fadeEntities[i]:IsValid() then
        local ent = fadeEntities[i]
        -- print(ent .. ", " .. ent.fadeAmt)
        local fade = fadeAmt[ent]

        if fade == nil then
          fadeAmt[ent] = 0
          fade = 0
        end

        -- print(fade)
        -- ent:SetColor(255, math.max(255-ent.fadeAmt, 100), 255-ent.fadeAmt, 255-ent.fadeAmt)
        ent:SetRenderMode(RENDERMODE_TRANSALPHA)
        ent:SetColor(Color(255, 220, 75, 255 - fade))
        fade = fade + 2

        if fade > 254 then
          fadeAmt[ent] = nil
          ent:Remove()
          fadeEntities[i] = nil
          self:ShiftFadeEntities(i)
        else
          fadeAmt[ent] = fade
        end
      end
    end

    if #fadeEntities == 1 and fadeEntities[1] == nil then
      fadeEntities = {}
    end
  end

  --if(self.cooldown == 10 && self.firing) then self:EmitSound("beam_start") end
  if self.firing then
    self.tracker = self.tracker - 1

    if self.tracker < 1 then
      self.firing = false
      self:EmitSound("sulphagne/beam_stop.wav")
    end
  else
    self.cooldown = math.max(0, self.cooldown - 1)
  end
end

--[[---------------------------------------------------------
    PrimaryAttack
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
  if not self.firing then
    self.firing = true
    self.cooldown = 10
    self:EmitSound("sulphagne/beam_start.wav")
  end

  if self.cooldown < 1 or self.firing then
    self.tracker = 2
    local tr = self:GetOwner():GetEyeTrace()

    if self.BeamTime == nil then
      self.BeamTime = CurTime()
    end

    if CurTime() - self.BeamTime > 0.05 then
      local effectdata = EffectData()
      local id = self:GetOwner():LookupAttachment("eyes")
      local eyepos = self:GetOwner():GetAttachment(id)
      local addDir = 0

      if eyepos ~= nil then
        addDir = eyepos.Ang.r + 360 + 90
        effectdata:SetStart(tr.HitPos)
        effectdata:SetOrigin(eyepos.Pos + 2 * Vector(math.cos(addDir), math.sin(addDir), 0))
        util.Effect("sulphagne_beam", effectdata)
        effectdata:SetOrigin(eyepos.Pos - 2 * Vector(math.cos(addDir), math.sin(addDir), 0))
        util.Effect("sulphagne_beam", effectdata)
        self.BeamTime = CurTime()
      else
        eyepos = self:GetOwner():EyePos()
        addDir = self:GetOwner():EyeAngles().r + 360 + 90
        effectdata:SetStart(tr.HitPos)
        effectdata:SetOrigin(eyepos + 2 * Vector(math.cos(addDir), math.sin(addDir), 0))
        util.Effect("sulphagne_beam", effectdata)
        effectdata:SetOrigin(eyepos - 2 * Vector(math.cos(addDir), math.sin(addDir), 0))
        util.Effect("sulphagne_beam", effectdata)
        self.BeamTime = CurTime()
      end
    end

    -- self:EmitSound( ShootSound )
    if not SERVER then return end

    if tr.Entity ~= nil and tr.Entity:IsValid() and fadeAmt[tr.Entity] == nil then
      if tr.Entity:IsPlayer() or tr.Entity:IsNPC() and tr.Entity:GetClass() ~= "npc_turret_floor" then
        if tr.Entity:Health() < 2 then
          fadeEntities[#fadeEntities + 1] = tr.Entity
          tr.Entity.fadeAmt = 0
          tr.Entity:SetMaterial("models/debug/debugwhite")
          tr.Entity:SetMoveType(MOVETYPE_NONE)
          tr.Entity:SetSolid(SOLID_NONE)
        else
          tr.Entity:TakeDamage(1, self:GetOwner(), self:GetOwner())
          local dmgAmt = tr.Entity:Health() / tr.Entity:GetMaxHealth()
          tr.Entity:SetColor(Color(255, 255 - dmgAmt * 35, 255 - dmgAmt * 125, 255))
        end
      else
        if tr.Entity.sCounter == nil then
          tr.Entity.sCounter = 0
        end

        tr.Entity.sCounter = tr.Entity.sCounter + 1
        local dmgAmt = 0

        if tr.Entity:GetPhysicsObject() ~= nil and tr.Entity:GetPhysicsObject():IsValid() then
          dmgAmt = tr.Entity.sCounter / tr.Entity:GetPhysicsObject():GetMass()
        else
          dmgAmt = tr.Entity.sCounter / 100
        end

        tr.Entity:SetColor(Color(255, 255 - dmgAmt * 35, 255 - dmgAmt * 125, 255))

        if dmgAmt >= 1 then
          fadeEntities[#fadeEntities + 1] = tr.Entity
          tr.Entity.fadeAmt = 0
          tr.Entity:SetMaterial("models/debug/debugwhite")
          tr.Entity:SetMoveType(MOVETYPE_NONE)
          tr.Entity:SetSolid(SOLID_NONE)
        end
      end
    end

    self.counter = self.counter + 1
  end
end

--[[---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------]]
function SWEP:ShouldDropOnDie()
  return false
end

local EFFECT = {}

function EFFECT:Init(effectdata)
  self.startPos = effectdata:GetOrigin()
  self.endPos = effectdata:GetStart()
  self.material = Material("cable/redlaser")
  --  self.counter = 0;
  self.startTime = CurTime()
  self.r = 0
end

function EFFECT:Think()
  self.r = self.r + 0.01
  -- self.counter = self.counter + 1;
  --self.counter < 5;

  return CurTime() - self.startTime < 0.07
end

function EFFECT:Render()
  local width = math.sin(self.r) * 2 + 3
  render.SetMaterial(self.material)
  render.DrawBeam(self.startPos, self.endPos, width, 0, 0, Color(0, 255, 0, 255))
end

if CLIENT then
  effects.Register(EFFECT, "sulphagne_beam")
end