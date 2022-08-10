AddCSLuaFile()

if SERVER then
  SWEP.Weight = 5
  SWEP.AutoSwitchTo = false
  SWEP.AutoSwitchFrom = false
end

if CLIENT then
  SWEP.PrintName = "Freeze Ray"
  SWEP.Slot = 3
  SWEP.SlotPos = 1
  SWEP.DrawAmmo = false
  SWEP.DrawCrosshair = false
end

SWEP.Author = "ZeroXOne"
SWEP.Contact = ""
SWEP.Purpose = "fuck shit up"
SWEP.Instructions = ""
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/Weapons/c_superphyscannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

if CLIENT then
  GLOBALFREEZEENTS = {}
end

--[[---------------------------------------------------------
Reload does nothing
---------------------------------------------------------]]
function SWEP:SetupDataTables()
  self:DTVar('Bool', 0, 'firing')
  self:DTVar('Bool', 1, 'imploding')
  self:DTVar('Float', 0, 'implodeend')
end

function SWEP:Reload()
end

function SWEP:Deploy()
  self:SpawnLaser()
end

function SWEP:DrawWorldModel()
  self:SetSkin(2)
  self:DrawModel()
end

--[[---------------------------------------------------------
Think does nothing
---------------------------------------------------------]]
function SWEP:Think()
  if self:GetOwner():KeyDown(IN_ATTACK) and not self.dt.imploding then
    self.dt.firing = true
  else
    self.dt.firing = false
  end

  if self.dt.firing and self:GetOwner():KeyDown(IN_ATTACK) and not self.dt.imploding then
    local pos = self:GetOwner():GetShootPos()
    local ang = self:GetOwner():GetAimVector()
    local tdat = {}
    tdat.start = pos
    tdat.endpos = pos + (ang * 1024)
    tdat.filter = self:GetOwner()
    local tr = util.TraceLine(tdat)

    if tr.Entity:IsNPC() or tr.Entity:IsPlayer() and SERVER then
      local dmginfo = DamageInfo()
      dmginfo:SetDamage(1)
      dmginfo:SetDamageType(DMG_BURN)
      dmginfo:SetInflictor(self)
      dmginfo:SetAttacker(self:GetOwner())
      dmginfo:SetDamageForce(Vector(0, 0, 0))

      if SERVER then
        if tr.Entity:Health() <= 1 then
          self:CreateIcething(tr.Entity)
          dmginfo:SetDamage(0)
        end

        tr.Entity:TakeDamageInfo(dmginfo)
      end
    end
  else
    self.dt.firing = false
    self.Sound:Stop()
  end

  if self.dt.imploding then
    self.Sound2:ChangePitch(Lerp(self.dt.implodeend - CurTime() / 2, 175, 25))
  end
end

function SWEP:CreateIcething(ent)
  if ent:IsNPC() then
    local proprag = ents.Create("prop_ragdoll")
    proprag:SetModel(ent:GetModel())
    proprag:SetPos(ent:GetPos())
    proprag:Spawn()
    proprag:SetColor(Color(135, 230, 255))
    proprag.Breakhp = proprag:OBBMins():Distance(proprag:OBBMaxs())
    BroadcastLua("table.insert(GLOBALFREEZEENTS,Entity(" .. proprag:EntIndex() .. "))")

    for i = 0, 32 do
      proprag:SetBodygroup(i, ent:GetBodygroup(i))
    end

    for i = 0, proprag:GetPhysicsObjectCount() do
      local physobj = proprag:GetPhysicsObjectNum(i)

      if physobj and IsValid(physobj) then
        local pos, ang = ent:GetBonePosition(ent:TranslatePhysBoneToBone(i))
        physobj:SetPos(pos)
        physobj:SetAngles(ang)
        physobj:EnableMotion(false)
      end
    end

    ent:Remove()
  end
end

function DestroyIcething(ent)
  for i = 0, 20 do
    local pos = ent:LocalToWorld(Vector(math.Rand(ent:OBBMins().x, ent:OBBMaxs().x), math.Rand(ent:OBBMins().y, ent:OBBMaxs().y), math.Rand(ent:OBBMins().z, ent:OBBMaxs().z)))
    local ED = EffectData()
    ED:SetStart(pos)
    ED:SetOrigin(pos)
    util.Effect("zeroxone_IceBreak", ED)
  end

  ent:EmitSound("physics/glass/glass_largesheet_break" .. math.random(1, 3) .. ".wav")
  SafeRemoveEntity(ent)
end

--[[---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
  self.Sound:Play()

  return true
end

function SWEP:SpawnLaser()
  local ED = EffectData()
  ED:SetEntity(self)
  util.Effect("zeroxone_ice_beam_hit", ED)
end

--[[---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------]]
function SWEP:SecondaryAttack()
  if not self.dt.imploding then
    self.dt.implodeend = CurTime() / 2 + 1
    self.Sound2:Play()

    timer.Simple(2, function()
      if IsValid(self) then
        self:Implode()
      end
    end)

    self.dt.imploding = true
  end
end

function SWEP:Implode()
  if IsValid(self) and IsValid(self:GetOwner()) and SERVER then
    for k, v in ipairs(ents.FindInSphere(self:GetPos(), 512)) do
      if (v:IsNPC() or v:IsPlayer()) and not (v == self:GetOwner()) then
        self:CreateIcething(v)
        --[[local ED = EffectData()
                ED:SetStart(v:GetPos()+v:OBBCenter())
                util.Effect("zeroxone_areaboom",ED)]]
      end

      local ED = EffectData()
      ED:SetStart(self:GetOwner():GetPos() + self:GetOwner():OBBCenter())
      util.Effect("zeroxone_areaboom", ED)
      self.Sound2:Stop()
      self.dt.imploding = false
    end

    self:GetOwner():EmitSound("weapons/physcannon/energy_disintegrate4.wav")
  end
end

function SWEP:Holster()
  self.Sound:Stop()

  return true
end

--[[---------------------------------------------------------
Name: ShouldDropOnDie
Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------]]
function SWEP:ShouldDropOnDie()
  self.Sound:Stop()

  return false
end

if CLIENT then
  local mat = Material("models/debug/debugwhite")

  hook.Add("RenderScreenspaceEffects", "FreezeOverlay", function()
    cam.Start3D(EyePos(), EyeAngles())
    s = 1
    render.SetColorModulation(0, 0.85 * s, 1 * s)
    render.SetBlend(0.5)
    render.MaterialOverride(mat)

    if CurTime() > (GLOBALFREEZEENTSNEXTTHINK or 0) then
      local oldtable = GLOBALFREEZEENTS
      GLOBALFREEZEENTS = {}

      for k, v in ipairs(oldtable) do
        if IsValid(v) then
          v:DrawModel()
          table.insert(GLOBALFREEZEENTS, v)
        end
      end

      oldtable = nil
      GLOBALFREEZEENTSNEXTTHINK = CurTime() + 1
    else
      for k, v in ipairs(GLOBALFREEZEENTS) do
        if IsValid(v) then
          v:DrawModel()
        end
      end
    end

    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
    render.MaterialOverride()
    cam.End3D()
  end)
end

function SWEP:Initialize()
  self.Sound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
  self.Sound2 = CreateSound(self, "weapons/physcannon/superphys_hold_loop.wav")
  self:SetHoldType("physgun")

  if CLIENT then
    local EFFECT = {}

    function EFFECT:Init(data)
      self.data = data
      self.ent = data:GetEntity()
      self.em = ParticleEmitter(util.QuickTrace(self.ent:GetOwner():GetShootPos(), self.ent:GetOwner():GetAimVector() * 1024).HitPos)
      self.Laser = Material("trails/laser")
    end

    function EFFECT:Think()
      if IsValid(self.ent) and self.ent.dt.firing and IsValid(self.ent:GetOwner()) then
        local pos = self.ent:GetOwner():GetShootPos()
        local ang = self.ent:GetOwner():GetAimVector()
        local tdat = {}
        tdat.start = pos
        tdat.endpos = pos + (ang * 1024)
        tdat.filter = self.ent:GetOwner()
        local tr = util.TraceLine(tdat)
        self.data:SetOrigin(tr.StartPos)
        self:SetRenderBoundsWS(tr.StartPos, tr.HitPos)

        for i = 1, 5 do
          local ice = self.em:Add("effects/strider_muzzle", tr.HitPos)
          ice:SetPos(tr.HitPos)
          ice:SetVelocity(Vector(math.Rand(-16, 16), math.Rand(-16, 16), math.Rand(-16, 16)) * 3)
          ice:SetStartSize(8)
          ice:SetStartAlpha(130)
          ice:SetRoll(math.Rand(-3, 3))
          ice:SetRollDelta(math.Rand(-3, 3))
          ice:SetEndSize(30)
          ice:SetEndAlpha(0)
          ice:SetDieTime(0.375)
          ice:SetColor(210, 245, 255)
        end
      end

      if self.ent and IsValid(self.ent) and self.ent:GetOwner():GetActiveWeapon() == self.ent then
        local Vector1 = self:GetTracerShootPos(self.ent:GetPos(), self.ent, 1)

        for i = 1, 2 do
          ice = self.em:Add("effects/rollerglow", Vector1)
          local vec = VectorRand():GetNormal():Angle():Forward() * math.Rand(-25, 25)
          ice:SetPos(Vector1 + vec)
          ice:SetVelocity(vec * -1)
          ice:SetStartSize(20)
          ice:SetStartAlpha(0)
          ice:SetRoll(math.Rand(-2, 2))
          ice:SetRollDelta(math.Rand(-2, 2))
          ice:SetEndSize(0)
          ice:SetEndAlpha(130)
          ice:SetDieTime(0.75)
          ice:SetColor(210, 245, 255)
        end

        return true
      end
    end

    function EFFECT:Render()
      if IsValid(self.ent) and self.ent.dt.firing and IsValid(self.ent:GetOwner()) then
        local pos = self.ent:GetOwner():GetShootPos()
        local ang = self.ent:GetOwner():GetAimVector()
        local tdat = {}
        tdat.start = pos
        tdat.endpos = pos + (ang * 1024)
        tdat.filter = self.ent:GetOwner()
        local tr = util.TraceLine(tdat)
        local Vector1 = self:GetTracerShootPos(tr.StartPos, self.ent, 1)
        local Vector2 = tr.HitPos
        render.SetMaterial(self.Laser)
        render.DrawBeam(Vector1, Vector2, 7.5, 0, 0, Color(210, 245, 255, 255))

        return true
      end

      if not self.ent or not self.ent:GetOwner():GetActiveWeapon() == self.ent then return false end
    end

    effects.Register(EFFECT, "zeroxone_ice_beam_hit", true)
    local EFFECT2 = {}

    function EFFECT2:Init(data)
      local pos = data:GetStart()
      self.em = ParticleEmitter(pos)

      for i = 1, 6 do
        local ice = self.em:Add("effects/fleck_glass" .. math.random(1, 3), pos)
        ice:SetPos(pos)
        ice:SetVelocity(VectorRand() * 256)
        ice:SetStartSize(30)
        ice:SetStartAlpha(255)
        ice:SetRoll(math.Rand(-2, 2))
        ice:SetRollDelta(math.Rand(-2, 2))
        ice:SetEndSize(0)
        ice:SetEndAlpha(0)
        ice:SetDieTime(0.75)
        ice:SetGravity(Vector(0, 0, -1000))
        ice:SetColor(255, 255, 255)
        ice:SetCollide(true)
      end

      self.em:Finish()
    end

    function EFFECT2:Think()
      return false
    end

    function EFFECT2:Render()
      return false
    end

    effects.Register(EFFECT2, "zeroxone_IceBreak", true)
    local EFFECT3 = {}

    function EFFECT3:Init(data)
      local pos = data:GetStart()
      self.em = ParticleEmitter(pos)

      for i = 1, 10 do
        local tab = {"particle/smokesprites_0016", "particle/smokesprites_0015", "particle/smokesprites_0014", "particle/smokesprites_0013", "particle/smokesprites_0012", "particle/smokesprites_0011", "particle/smokesprites_0010", "particle/smokesprites_0009", "particle/smokesprites_0008", "particle/smokesprites_0007", "particle/smokesprites_0006", "particle/smokesprites_0005", "particle/smokesprites_0004", "particle/smokesprites_0003", "particle/smokesprites_0002", "particle/smokesprites_0001"}

        local ice = self.em:Add(table.Random(tab), pos)
        ice:SetPos(pos)
        ice:SetVelocity(VectorRand() * 768)
        ice:SetStartSize(0)
        ice:SetStartAlpha(255)
        ice:SetRoll(math.Rand(-2, 2))
        ice:SetRollDelta(math.Rand(-2, 2))
        ice:SetEndSize(125)
        ice:SetEndAlpha(0)
        ice:SetDieTime(0.75)
        ice:SetColor(135, 230, 255)
      end

      self.em:Finish()
    end

    function EFFECT3:Think()
      return false
    end

    function EFFECT3:Render()
      return false
    end

    effects.Register(EFFECT3, "zeroxone_areaboom", true)
  end
end

local self = self

hook.Add("EntityTakeDamage", "BreakIce", function(ent, dmg)
  local inflictor = dmg:GetInflictor()
  local attacker = dmg:GetAttacker()
  local amount = dmg:GetDamage()

  if ent.Breakhp then
    if dmg:GetDamageType() < 2 then
      amount = amount * 0.06

      if IsValid(attacker) then
        local dam = dmg
        dam:SetDamage(amount * 0.15)
        attacker:TakeDamageInfo(dam)
      end
    end

    if ent.Breakhp then
      ent.Breakhp = ent.Breakhp - amount * 3.5

      if ent.Breakhp <= 0 then
        DestroyIcething(ent)
      end
    end
  end
end)