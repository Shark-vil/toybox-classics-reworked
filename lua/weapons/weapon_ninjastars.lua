local ClassName = ClassName
SWEP.PrintName = "Ninja Stars"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.Category = "Toybox Classics"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Author = "Ghor"
SWEP.Contact = ""
SWEP.Purpose = "Hurting dudes."
SWEP.Instructions = "Primary Fire throws a shuriken overhead. Secondary Fire throws one from the side."
SWEP.ViewModel = "models/weapons/ghor/c_shuriken.mdl"
SWEP.WorldModel = "models/weapons/ghor/c_shuriken.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.beginidle = 0
SWEP.begindeploy = 0

local function safeanim(pl, anim)
  if IsValid(pl) then
    pl:SetAnimation(anim)
  end
end

function SWEP:SetupWeaponHoldTypeForAI(t)
  self.ActivityTranslateAI = {}
  self.ActivityTranslateAI[ACT_IDLE] = ACT_IDLE_PISTOL
  self.ActivityTranslateAI[ACT_IDLE_ANGRY] = ACT_IDLE_ANGRY_PISTOL
  self.ActivityTranslateAI[ACT_RANGE_ATTACK1] = ACT_MELEE_ATTACK_SWING
  self.ActivityTranslateAI[ACT_RELOAD] = ACT_RELOAD_PISTOL
  self.ActivityTranslateAI[ACT_WALK_AIM] = ACT_WALK_AIM_PISTOL
  self.ActivityTranslateAI[ACT_RUN_AIM] = ACT_RUN_AIM_PISTOL
  self.ActivityTranslateAI[ACT_GESTURE_RANGE_ATTACK1] = ACT_GESTURE_RANGE_ATTACK1
  self.ActivityTranslateAI[ACT_RELOAD_LOW] = ACT_RELOAD_LOW
  self.ActivityTranslateAI[ACT_RANGE_ATTACK1_LOW] = ACT_RANGE_ATTACK_PISTOL_LOW
  self.ActivityTranslateAI[ACT_COVER_LOW] = ACT_COVER_PISTOL_LOW
  self.ActivityTranslateAI[ACT_RANGE_AIM_LOW] = ACT_RANGE_AIM_PISTOL_LOW
  self.ActivityTranslateAI[ACT_GESTURE_RELOAD] = ACT_GESTURE_RELOAD_PISTOL
end

function SWEP:SetVMAnimation(anim)
  self:SendWeaponAnim(anim)
  local vm = self:GetOwner():GetViewModel()

  if not IsValid(vm) then
    self.beginidle = 0
    self.begindeploy = 0

    return
  end

  local ctime = CurTime()

  if (anim == ACT_VM_PRIMARYATTACK) or (anim == ACT_VM_SECONDARYATTACK) then
    local sub = 0

    if self.WussMode then
      sub = 0.5
    else
      sub = 0.3
    end

    if anim == ACT_VM_PRIMARYATTACK then
      self.begindeploy = ctime + vm:SequenceDuration() - 1.3 - sub
      self:SetWeaponHoldType("grenade")
      self:CallOnClient("SetWeaponHoldType", "grenade")
    else
      self.begindeploy = ctime + vm:SequenceDuration() - 0.4 - sub
      self:SetWeaponHoldType("slam")
      self:CallOnClient("SetWeaponHoldType", "slam")
    end

    self:SetNextPrimaryFire(self.begindeploy + 0.1)
    self:SetNextSecondaryFire(self.begindeploy + 0.1)
    self.beginidle = 0
  elseif anim == ACT_VM_DEPLOY then
    local divisor = 1

    if self.WussMode then
      self:GetOwner():GetViewModel():SetPlaybackRate(2)
      divisor = 2
    end

    local sequenceend = ctime + vm:SequenceDuration() / divisor
    self:SetNextPrimaryFire(sequenceend)
    self:SetNextSecondaryFire(sequenceend)
    self.beginidle = ctime + vm:SequenceDuration() / divisor
    self.begindeploy = 0
    self:SetWeaponHoldType("knife")
    self:CallOnClient("SetWeaponHoldType", "knife")
  else
    self.beginidle = ctime + vm:SequenceDuration()
  end
end

function SWEP:Initialize()
  self:SetWeaponHoldType("knife")

  if SERVER then
    self:SetNPCFireRate(0.5)
    self:SetNPCMinBurst(3)
    self:SetNPCMaxBurst(3)
    self:SetNPCMinRest(3)
    self:SetNPCMaxRest(3)
  end
end

function SWEP:Equip(owner)
  self:SetAnimation(ACT_IDLE)

  if owner:IsNPC() then
    self:SetWeaponHoldType("grenade")
  end
end

function SWEP:NPCShoot_Primary(ShootPos, ShootDir)
  local proj = ents.Create("ghor_shuriken")
  proj:SetOwner(self:GetOwner())
  proj:SetPos(ShootPos)
  proj:SetAngles(ShootDir:Angle())
  proj:Spawn()
  proj:GetPhysicsObject():SetVelocity(ShootDir * 1000)
  self:EmitSound("npc/zombie/claw_miss1.wav")
  self:SetAnimation(ACT_IDLE)
  self:SetPlaybackRate(0)

  return proj
end

function SWEP:SetupDataTables()
  self:DTVar("Bool", 0, "wmhide")
  self:NetworkVar("Float", 1, "NextReload")
end

function SWEP:Reload()
end

function SWEP:Think()
  local ctime = CurTime()

  if (self.beginidle ~= 0) and (self.beginidle < ctime) then
    self:SetVMAnimation(ACT_VM_IDLE)
  end

  if (self.begindeploy ~= 0) and (self.begindeploy < ctime) then
    self:SetVMAnimation(ACT_VM_DEPLOY)
  end

  if SERVER then
    if self:GetNextPrimaryFire() < ctime then
      self.dt.wmhide = false
    end
  end
end

function SWEP:CreateShuriken()
  local proj = ents.Create("ghor_shuriken")
  proj:SetOwner(self:GetOwner())
  proj:SetPos(self:GetOwner():GetShootPos())
  proj:SetAngles(self:GetOwner():EyeAngles())
  proj:Spawn()
  self:EmitSound("npc/zombie/claw_miss1.wav")

  if self.WussMode then
    util.SpriteTrail(proj, 0, color_pink, true, 2, 0, 3, 0.25, "trails/love.vmt")
    proj.WussMode = true
  end

  return proj
end

function SWEP:ShurikenPrimary()
  if not IsValid(self) or not IsValid(self:GetOwner()) then return end
  local proj = self:CreateShuriken()
  local ang = self:GetOwner():EyeAngles()
  ang:RotateAroundAxis(self:GetOwner():GetAimVector(), 90)
  proj:SetAngles(ang)
  local ang2 = self:GetOwner():EyeAngles()
  local right = ang2:Right()
  local up = ang2:Up()
  proj:SetPos(self:GetOwner():GetShootPos() + right * 2 + up * 1)
  proj:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector() * 1000 + Vector(0, 0, 200) + self:GetOwner():GetVelocity())
  self.dt.wmhide = true
  self:SetWeaponHoldType("knife")
  self:CallOnClient("SetWeaponHoldType", "knife")
end

function SWEP:ShurikenSecondary()
  if not IsValid(self) or not IsValid(self:GetOwner()) then return end
  local proj = self:CreateShuriken()
  local ang2 = self:GetOwner():EyeAngles()
  local right = ang2:Right()
  local up = ang2:Up()
  proj:SetPos(self:GetOwner():GetShootPos() - right * 3 - up * 3)
  proj:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector() * 1500 + self:GetOwner():GetVelocity())
  self.dt.wmhide = true
  self:SetWeaponHoldType("knife")
  self:CallOnClient("SetWeaponHoldType", "knife")
end

function SWEP:PrimaryAttack()
  self:SetVMAnimation(ACT_VM_PRIMARYATTACK)

  if SERVER then
    timer.Simple(0.7, function()
      if not IsValid(self) then return end
      self:ShurikenPrimary()
    end)

    timer.Simple(0.5, function()
      if not IsValid(self) then return end
      safeanim(self:GetOwner(), PLAYER_ATTACK1)
    end)
  end
end

function SWEP:SecondaryAttack()
  self:SetVMAnimation(ACT_VM_SECONDARYATTACK)

  if SERVER then
    timer.Simple(0.4, function()
      if not IsValid(self) then return end
      self:ShurikenSecondary()
    end)

    timer.Simple(0.2, function()
      if not IsValid(self) then return end
      safeanim(self:GetOwner(), PLAYER_ATTACK1)
    end)
  end
end

function SWEP:OnRemove()
  if CLIENT then
    self:StopMusic()
  end
end

function SWEP:Holster()
  if CLIENT then
    self:StopMusic()
  end

  return true
end

function SWEP:Deploy()
  self:SetVMAnimation(ACT_VM_DEPLOY)

  if SERVER and self.WussMode then
    self:CallOnClient("StartMusic", "")
  end
end

function SWEP:DrawWorldModel()
  if not self.dt.wmhide then
    self:DrawModel()
  end
end

function SWEP:SetWussMode(state)
  state = tobool(state)

  if SERVER then
    self:CallOnClient("SetWussMode", tostring(state))
  else
    self.DrawCrosshair = state

    if state then
      self:StartMusic()
    else
      self:StopMusic()
    end
  end

  self.WussMode = state
end

if CLIENT then
  local musicpanel

  function SWEP:StartMusic()
    if not IsValid(musicpanel) then
      musicpanel = vgui.Create("HTML")
      musicpanel:OpenURL("https://www.youtube.com/embed/6_5nFS5xxJU?playlist=6_5nFS5xxJU&autoplay=1&loop=1&rel=0&controls=0&showinfo=0&nohtml5=1") -- will be fixed when chromium rolls around
      musicpanel:SetVisible(false)
    end
  end

  function SWEP:StopMusic()
    if IsValid(musicpanel) then
      musicpanel:Remove()
    end
  end

  local coltab = {}
  coltab["$pp_colour_addr"] = 0.5
  coltab["$pp_colour_addg"] = 0.2
  coltab["$pp_colour_addb"] = 0.4
  coltab["$pp_colour_mulr"] = 0
  coltab["$pp_colour_mulg"] = 0
  coltab["$pp_colour_mulb"] = 0
  coltab["$pp_colour_colour"] = 1
  coltab["$pp_colour_contrast"] = 1
  coltab["$pp_colour_brightness"] = 0

  function SWEP:DrawHUD()
    if self.WussMode then
      DrawColorModify(coltab)
      --DrawBloom(0.61,1.15,9.38,9.13,1,2,255/255,128/255,5/255)
    end
  end
end

if CLIENT then
  local wepcolor = Color(255, 0, 0, 200)
  local icontex = surface.GetTextureID("HUD/shuriken")

  function SWEP:DrawWeaponSelection(x, y, w, h, a)
    local radius = math.min(w, h)
    surface.SetDrawColor(wepcolor)
    surface.SetTexture(icontex)
    surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, radius, radius, CurTime() * -360)
  end

  killicon.Add("ghor_shuriken", "HUD/shuriken", wepcolor)
end

function SWEP:Reload()
  if self:GetNextReload() < CurTime() and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_SPEED) then
    self:SetWussMode(not self.WussMode)
    self:SetNextReload(CurTime() + 1)
  end
end