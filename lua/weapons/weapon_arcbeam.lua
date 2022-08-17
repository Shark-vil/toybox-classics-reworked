AddCSLuaFile()
SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Arc Beam"

list.Add("NPCUsableWeapons", {
  class = "weapon_arcbeam",
  title = "Arc Beam"
})

if CLIENT then
  language.Add("weapon_arcbeam", "Arc beam")
end

local ClassName = ClassName
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Author = "Ghor"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Hold down Primary Fire to release a beam of energy!"
SWEP.ViewModel = "models/Weapons/c_superphyscannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.UseHands = true

if dodebug then
  SWEP.WorldModel = "models/weapons/w_irifle.mdl"
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HeatTime = 0
SWEP.Heat = 0
SWEP.LastThink = 0
SWEP.Range = 350

function SWEP:GetCapabilities()
  return bit.bor(CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1, CAP_MOVE_SHOOT)
end

local function SoldierAnims(self)
  self.ActivityTranslateAI = {}
  self.ActivityTranslateAI[ACT_IDLE] = ACT_IDLE
  self.ActivityTranslateAI[ACT_IDLE_ANGRY] = ACT_IDLE_ANGRY
  self.ActivityTranslateAI[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_AR2
  self.ActivityTranslateAI[ACT_RELOAD] = ACT_RELOAD
  self.ActivityTranslateAI[ACT_WALK_AIM] = ACT_WALK_AIM_RIFLE
  self.ActivityTranslateAI[ACT_RUN_AIM] = ACT_RUN_AIM_RIFLE
  self.ActivityTranslateAI[ACT_GESTURE_RANGE_ATTACK1] = ACT_GESTURE_RANGE_ATTACK1
  self.ActivityTranslateAI[ACT_RELOAD_LOW] = ACT_RELOAD_LOW
  self.ActivityTranslateAI[ACT_RANGE_ATTACK1_LOW] = ACT_RANGE_ATTACK_AR2_LOW
  self.ActivityTranslateAI[ACT_COVER_LOW] = ACT_COVER_LOW
  self.ActivityTranslateAI[ACT_RANGE_AIM_LOW] = ACT_RANGE_AIM_AR2_LOW
  self.ActivityTranslateAI[ACT_GESTURE_RELOAD] = ACT_GESTURE_RELOAD
  self.ActivityTranslateAI[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_AR2
  self.ActivityTranslateAI[ACT_RELOAD] = ACT_RELOAD
  self.ActivityTranslateAI[ACT_IDLE_ANGRY] = ACT_IDLE_ANGRY
  self.ActivityTranslateAI[ACT_WALK] = ACT_WALK_RIFLE
  self.ActivityTranslateAI[ACT_IDLE_RELAXED] = ACT_IDLE_SMG1
  -------------------------------
  self.ActivityTranslateAI[ACT_IDLE_STIMULATED] = ACT_IDLE_ANGRY_SHOTGUN
  self.ActivityTranslateAI[ACT_IDLE_AGITATED] = ACT_IDLE_ANGRY_SMG1
  self.ActivityTranslateAI[ACT_WALK_RELAXED] = ACT_WALK_EASY
  self.ActivityTranslateAI[ACT_WALK_STIMULATED] = ACT_WALK_RIFLE
  self.ActivityTranslateAI[ACT_WALK_AGITATED] = ACT_WALK_AIM_RIFLE
  self.ActivityTranslateAI[ACT_RUN_RELAXED] = ACT_RUN_RIFLE
  self.ActivityTranslateAI[ACT_RUN_STIMULATED] = ACT_RUN_RIFLE
  self.ActivityTranslateAI[ACT_RUN_AGITATED] = ACT_RUN_AIM_RIFLE
  self.ActivityTranslateAI[ACT_IDLE_AIM_RELAXED] = ACT_IDLE_SMG1
  self.ActivityTranslateAI[ACT_IDLE_AIM_STIMULATED] = ACT_IDLE_AIM_RIFLE
  self.ActivityTranslateAI[ACT_IDLE_AIM_AGITATED] = ACT_IDLE_ANGRY_SMG1
  self.ActivityTranslateAI[ACT_WALK_AIM_RELAXED] = ACT_WALK_RIFLE
  self.ActivityTranslateAI[ACT_WALK_AIM_STIMULATED] = ACT_WALK_AIM_RIFLE
  self.ActivityTranslateAI[ACT_WALK_AIM_AGITATED] = ACT_WALK_AIM_RIFLE
  self.ActivityTranslateAI[ACT_RUN_AIM_RELAXED] = ACT_RUN_RIFLE
  self.ActivityTranslateAI[ACT_RUN_AIM_STIMULATED] = ACT_RUN_RIFLE
  self.ActivityTranslateAI[ACT_RUN_AIM_AGITATED] = ACT_RUN_AIM_RIFLE
  self.ActivityTranslateAI[ACT_WALK_AIM] = ACT_WALK_AIM_RIFLE
  self.ActivityTranslateAI[ACT_WALK_CROUCH] = ACT_WALK_CROUCH_RIFLE
  self.ActivityTranslateAI[ACT_WALK_CROUCH_AIM] = ACT_WALK_CROUCH_AIM_RIFLE
  self.ActivityTranslateAI[ACT_RUN] = ACT_RUN
  self.ActivityTranslateAI[ACT_RUN_AIM] = ACT_RUN_AIM_RIFLE
  self.ActivityTranslateAI[ACT_RUN_CROUCH] = ACT_RUN_CROUCH_RIFLE
  self.ActivityTranslateAI[ACT_RUN_CROUCH_AIM] = ACT_RUN_CROUCH_AIM_RIFLE
  self.ActivityTranslateAI[ACT_GESTURE_RANGE_ATTACK1] = ACT_GESTURE_RANGE_ATTACK_AR2
  self.ActivityTranslateAI[ACT_COVER_LOW] = ACT_COVER_SMG1_LOW
  self.ActivityTranslateAI[ACT_RANGE_AIM_LOW] = ACT_RANGE_AIM_AR2_LOW
  self.ActivityTranslateAI[ACT_RANGE_ATTACK1_LOW] = ACT_RANGE_ATTACK_SMG1_LOW
  self.ActivityTranslateAI[ACT_RELOAD_LOW] = ACT_RELOAD_SMG1_LOW
  --self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ]             = ACT_RANGE_ATTACK_AR2
  --for k,v in pairs(self.ActivityTranslateAI) do
  --  self.ActivityTranslateAI[k] = ACT_RANGE_ATTACK1
  --end
end

function SWEP:Reload()
end

function SWEP:Initialize()
  self.LastThink = CurTime()
  self:SetHoldType("physgun")
  self:SetSkin(1)

  if SERVER then
    self:SetNPCFireRate(0.05)
    self:SetNPCMinBurst(1)
    self:SetNPCMaxBurst(1)
    self:SetNPCMinRest(0.05)
    self:SetNPCMaxRest(0.05)
  end
end

local function soldierfix(ent, timerid)
  if IsValid(ent) and ent:GetActiveWeapon():IsValid() then
    --ent:SetSchedule(96)
    local eyepos = ent:GetAttachment(ent:LookupAttachment("eyes")).Pos

    if IsValid(ent:GetEnemy()) then
      local dirvec = ent:GetEnemy():GetPos() + ent:GetEnemy():OBBCenter() - eyepos

      if dirvec:Length() > ent:GetActiveWeapon().Range then
        ent:GetActiveWeapon().ActivityTranslateAI[ACT_RANGE_ATTACK1] = ACT_RUN_AIM_RIFLE
        ent:SetSchedule(SCHED_CHASE_ENEMY)
        print("MOVE!")
      else
        ent:GetActiveWeapon().ActivityTranslateAI[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_AR2
        ent:GetActiveWeapon():NPCShoot_Primary(eyepos, dirvec:Normalize())
      end
    end
  else
    timer.Remove(timerid)
  end
end

function SWEP:DoSoldierFix()
  if self:GetOwner():IsNPC() then
    self:SetWeaponHoldType("smg")
  end

  if IsValid(self:GetOwner()) and self:GetOwner():GetClass() == "npc_combine_s" then
    self.SetupWeaponHoldTypeForAI = SoldierAnims
    self:SetupWeaponHoldTypeForAI()
    --self:SetWeaponHoldType("ar2")
    local id = "arc_csolfix_" .. self:GetOwner():EntIndex()

    timer.Create(id, 2, 0, function()
      if IsValid(self) then
        soldierfix(self:GetOwner(), id)
      end
    end)
  end
end

function SWEP:Equip(pl)
  if not pl:IsPlayer() then
    self:DoSoldierFix()
    self:SetupWeaponHoldTypeForAI("smg")

    return
  end
end

function SWEP:SetupDataTables()
  self:DTVar("Float", 0, "Heat")
end

function SWEP:Think()
  if not IsValid(self:GetOwner()) then return end

  if self:GetOwner():KeyDown(IN_ATTACK) then
    self:TurnOn()
  end

  if self:GetOwner():KeyDown(IN_ATTACK) and (self.HeatTime ~= 0) then
    self.dt.Heat = math.min(10, CurTime() - self.HeatTime)
  elseif self.dt and self.dt.Heat then
    self.dt.Heat = math.max(0, self.dt.Heat - (CurTime() - self.LastThink) * 2)
  end

  if self.MouseDown and IsFirstTimePredicted() and not self:GetOwner():KeyDown(IN_ATTACK) then
    self:TurnOff()
  end

  if SERVER and self:GetHeat() == 10 then
    local edata = EffectData()
    edata:SetOrigin(self:GetOwner():GetShootPos())
    util.Effect("Explosion", edata, nil, true)
    util.BlastDamage(self, self:GetOwner(), self:GetOwner():GetShootPos(), 200, 130)
    self:Remove()
  end

  self.LastThink = CurTime()
end

function SWEP:GetHeat()
  if not IsValid(self) then return end

  return self.dt.Heat
end

function SWEP:PrimaryAttack()
end

SWEP.LastNPCShoot = 0

local function checkifshouldstayon(wep)
  if IsValid(wep) then
    if not IsValid(wep:GetOwner()) or not wep:GetOwner():IsNPC() or (wep.LastNPCShoot + 1 < CurTime()) then
      wep:TurnOff()
    elseif IsValid(wep.Beam) and (wep.Beam.dt.endent ~= NULL) and (wep.Beam.dt.endent ~= wep:GetOwner():GetEnemy()) then
      local en = wep:GetOwner():GetEnemy()

      if not IsValid(ent) or wep:GetPos():Distance(en:GetPos() + en:OBBCenter()) > wep.Range then
        wep:TurnOff()
      else
        wep.Beam.dt.endent = en
        timer.Simple(0.05, checkifshouldstayon, wep)
      end
    else
      timer.Simple(0.05, checkifshouldstayon, wep)
    end
  end
end

--messing around with this
function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
  if not IsValid(self:GetOwner()) or not IsValid(self:GetOwner():GetEnemy()) then return end
  local en = self:GetOwner():GetEnemy()
  local enpos = en:GetPos() + en:OBBCenter()
  local dist = ShootPos:Distance(enpos)

  if dist > self.Range then
    self:GetOwner():SetSchedule(SCHED_CHASE_ENEMY)

    return
  elseif dist < 80 then
    self:GetOwner():SetSchedule(SCHED_RUN_FROM_ENEMY_MOB)

    return
  end

  self.LastNPCShoot = CurTime()
  self:TurnOn()
end

function SWEP:TurnOff()
  if SERVER and IsValid(self.Beam) then
    self.Beam:Kill()
    self.Beam = NULL
  end

  self.MouseDown = false
  self.HeatTime = 0
end

function SWEP:TurnOn()
  if not IsValid(self) then return end

  if not self.MouseDown then
    if SERVER and not IsValid(self.Beam) then
      self.Beam = ents.Create("ghor_arcbeam")
      self.Beam:SetOwner(self)
      self.Beam.Range = self.Range
      self.Beam:Spawn()
      self.Beam:SetPos(self:GetPos())
      self.HeatTime = CurTime() - self:GetHeat()

      if IsValid(self:GetOwner()) and self:GetOwner():IsNPC() then
        checkifshouldstayon(self)
      end
    end

    self.MouseDown = true
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  end
end

function SWEP:SecondaryAttack()
end

function SWEP:Holster()
  if self:GetOwner():IsPlayer() and self:GetOwner():KeyDown(IN_ATTACK) then return false end
  self:TurnOff()

  return true
end

if CLIENT then
  -- local shinymat = Material("models/shiny")
  local vmat = Material("models/weapons/V_physcannon/v_superphyscannon_sheet")
  local wmat = Material("models/weapons/W_physics/w_physics_sheet2")
  local vec_illum = Vector(0.25, 0.25, 0.25)
  local vec_white = Vector(1, 1, 1)
  local wepcolor = Color(128, 128, 255)
  local icontex = surface.GetTextureID("sprites/scav_lightning")

  hook.Add("PreDrawViewModel", "arcbeam", function(vm, pl, wep)
    if not IsValid(wep) then return end

    if wep:GetClass() == ClassName then
      --SetMaterialOverride(shinymat)
      local heat = wep:GetHeat()
      heat = math.max(heat - 5, 0) * 3

      if heat > 7 then
        heat = heat + (CurTime() * 4 - math.floor(CurTime() * 4)) * 62
        render.SuppressEngineLighting(true)
      end

      local baseillum = 0.25

      if pl:KeyDown(IN_ATTACK) then
        baseillum = 6.75
      end

      vec_illum.x = heat / 2 + baseillum
      vec_illum.y = heat / 20 + baseillum
      vec_illum.z = heat / 20 + baseillum
      vmat:SetVector("$selfillumtint", vec_illum)
      render.SetColorModulation(1 + heat, 1 + heat / 2, 1 + heat / 2)
    end
  end)

  hook.Add("PostDrawViewModel", "arcbeam", function(vm, pl, wep)
    if wep:GetClass() == ClassName then
      --SetMaterialOverride(shinymat)
      render.SetColorModulation(1, 1, 1)
      render.SuppressEngineLighting(false)
      vmat:SetVector("$selfillumtint", vec_white)
    end
  end)

  local beamglowmat2 = Material("sprites/blueglow2")

  function SWEP:DrawWorldModel()
    local heat = self:GetHeat()
    heat = math.max(heat - 5, 0) * 3

    if heat > 7 then
      heat = heat + (CurTime() * 4 - math.floor(CurTime() * 4)) * 62
      render.SuppressEngineLighting(true)
    end

    render.SetColorModulation(1 + heat, 1 + heat / 2, 1 + heat / 2)
    local baseillum = 0.25

    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetOwner():KeyDown(IN_ATTACK) then
      baseillum = 6.75
    end

    vec_illum.x = heat / 2 + baseillum
    vec_illum.y = heat / 20 + baseillum
    vec_illum.z = heat / 20 + baseillum
    wmat:SetVector("$selfillumtint", vec_illum)
    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
    render.SuppressEngineLighting(false)
    render.SetMaterial(beamglowmat2)
    local posang = self:GetAttachment(1)
    local radius = (1 + math.abs(math.sin(CurTime() * 4))) * 4
    render.DrawSprite(posang.Pos, radius, radius, color_white)
    wmat:SetVector("$selfillumtint", vec_white)
  end

  local warningcolor = Color(255, 0, 0, 128)

  function SWEP:DrawHUD()
    local heat = self:GetHeat()

    if heat > 7 then
      surface.SetFont("HUDNumber5")
      local sizex, sizey = surface.GetTextSize("!")
      surface.SetTextPos(ScrW() / 2 - sizex / 2, ScrH() / 2 - sizey / 2)
      warningcolor.a = (CurTime() - math.floor(CurTime())) * 128
      surface.SetTextColor(warningcolor)
      surface.DrawText("!")
    end
  end

  function SWEP:DrawWeaponSelection(x, y, w, h, a)
    local size = math.min(w, h)
    surface.SetDrawColor(wepcolor)
    surface.SetTexture(icontex)
    surface.DrawTexturedRect(x + w / 2 - size / 2 + math.sin(CurTime() * 7) * 24, y + h / 2 - size / 2, size, size, CurTime() * -360)
  end

  killicon.Add("ghor_arcbeam", "sprites/scav_lightning", wepcolor)

  surface.CreateFont("HUDNumber5", {
    font = "Trebuchet MS",
    size = 45,
    weight = 800
  })
end