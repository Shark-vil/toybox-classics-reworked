if SERVER then
  AddCSLuaFile("shared.lua")
  SWEP.Weight = 5
  SWEP.AutoSwitchTo = false
  SWEP.AutoSwitchFrom = false
end

if CLIENT then
  SWEP.DrawAmmo = true
  SWEP.DrawCrosshair = false
  SWEP.ViewModelFOV = 82
  SWEP.ViewModelFlip = true
  SWEP.CSMuzzleFlashes = true

  -- This is the font thats used to draw the death icons
  surface.CreateFont("CSKillIcons", {
    font = "csd",
    size = ScreenScale(30)
  })

  surface.CreateFont("CSSelectIcons", {
    font = "csd",
    size = ScreenScale(60)
  })
end

SWEP.Author = "Counter-Strike"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
-- Note: This is how it should have worked. The base weapon would set the category
-- then all of the children would have inherited that.
-- But a lot of SWEPS have based themselves on this base (probably not on purpose)
-- So the category name is now defined in all of the child SWEPS.
--SWEP.Category			= "Counter-Strike"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 40
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.15
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

--[[---------------------------------------------------------
---------------------------------------------------------]]
function SWEP:Initialize()
  if SERVER then
    self:SetNPCMinBurst(30)
    self:SetNPCMaxBurst(30)
    self:SetNPCFireRate(0.01)
  end

  self:SetWeaponHoldType(self.HoldType)
  self.Weapon:SetNetworkedBool("Ironsights", false)
end

--[[---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------]]
function SWEP:Reload()
  self.Weapon:DefaultReload(ACT_VM_RELOAD)
  self:SetIronsights(false)
end

--[[---------------------------------------------------------
   Think does nothing
---------------------------------------------------------]]
function SWEP:Think()
end

--[[---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------]]
function SWEP:PrimaryAttack()
  self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
  self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
  if not self:CanPrimaryAttack() then return end
  -- Play shoot sound
  self.Weapon:EmitSound(self.Primary.Sound)
  -- Shoot the bullet
  self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
  -- Remove 1 bullet from our clip
  self:TakePrimaryAmmo(1)
  if self:GetOwner():IsNPC() then return end
  -- Punch the player's view
  self:GetOwner():ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))

  -- In singleplayer this function doesn't get called on the client, so we use a networked float
  -- to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
  -- send the float.
  if (game.SinglePlayer() and SERVER) or CLIENT then
    self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
  end
end

--[[---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------]]
function SWEP:CSShootBullet(dmg, recoil, numbul, cone)
  numbul = numbul or 1
  cone = cone or 0.01
  local bullet = {}
  bullet.Num = numbul
  bullet.Src = self:GetOwner():GetShootPos() -- Source
  bullet.Dir = self:GetOwner():GetAimVector() -- Dir of bullet
  bullet.Spread = Vector(cone, cone, 0) -- Aim Cone
  bullet.Tracer = 4 -- Show a tracer on every x bullets 
  bullet.Force = 5 -- Amount of force to give to phys objects
  bullet.Damage = dmg
  self:GetOwner():FireBullets(bullet)
  self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation
  self:GetOwner():MuzzleFlash() -- Crappy muzzle light
  self:GetOwner():SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation
  if self:GetOwner():IsNPC() then return end

  -- CUSTOM RECOIL !
  if (game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT and IsFirstTimePredicted()) then
    local eyeang = self:GetOwner():EyeAngles()
    eyeang.pitch = eyeang.pitch - recoil
    self:GetOwner():SetEyeAngles(eyeang)
  end
end

--[[---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------]]
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
  draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
  -- try to fool them into thinking theyre playing a Tony Hawks game
  draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2 + math.Rand(-4, 4), y + tall * 0.2 + math.Rand(-14, 14), Color(255, 210, 0, math.Rand(10, 120)), TEXT_ALIGN_CENTER)
  draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2 + math.Rand(-4, 4), y + tall * 0.2 + math.Rand(-9, 9), Color(255, 210, 0, math.Rand(10, 120)), TEXT_ALIGN_CENTER)
end

local IRONSIGHT_TIME = 0.25

--[[---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------]]
function SWEP:GetViewModelPosition(pos, ang)
  if not self.IronSightsPos then return pos, ang end
  local bIron = self.Weapon:GetNetworkedBool("Ironsights")

  if bIron ~= self.bLastIron then
    self.bLastIron = bIron
    self.fIronTime = CurTime()

    if bIron then
      self.SwayScale = 0.3
      self.BobScale = 0.1
    else
      self.SwayScale = 1.0
      self.BobScale = 1.0
    end
  end

  local fIronTime = self.fIronTime or 0
  if not bIron and fIronTime < CurTime() - IRONSIGHT_TIME then return pos, ang end
  local Mul = 1.0

  if fIronTime > CurTime() - IRONSIGHT_TIME then
    Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

    if not bIron then
      Mul = 1 - Mul
    end
  end

  local Offset = self.IronSightsPos

  if self.IronSightsAng then
    ang = ang * 1
    ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * Mul)
    ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * Mul)
    ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
  end

  local Right = ang:Right()
  local Up = ang:Up()
  local Forward = ang:Forward()
  pos = pos + Offset.x * Right * Mul
  pos = pos + Offset.y * Forward * Mul
  pos = pos + Offset.z * Up * Mul

  return pos, ang
end

--[[---------------------------------------------------------
	SetIronsights
---------------------------------------------------------]]
function SWEP:SetIronsights(b)
  self.Weapon:SetNetworkedBool("Ironsights", b)
end

SWEP.NextSecondaryAttack = 0

--[[---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------]]
function SWEP:SecondaryAttack()
  if not self.IronSightsPos then return end
  if self.NextSecondaryAttack > CurTime() then return end
  bIronsights = not self.Weapon:GetNetworkedBool("Ironsights", false)
  self:SetIronsights(bIronsights)
  self.NextSecondaryAttack = CurTime() + 0.3
end

--[[---------------------------------------------------------
	DrawHUD
	
	Just a rough mock up showing how to draw your own crosshair.
	
---------------------------------------------------------]]
function SWEP:DrawHUD()
  -- No crosshair when ironsights is on
  if self.Weapon:GetNetworkedBool("Ironsights") then return end
  local x, y

  -- If were drawing the local player, draw the crosshair where theyre aiming,
  -- instead of in the center of the screen.
  if self:GetOwner() == LocalPlayer() and self:GetOwner():ShouldDrawLocalPlayer() then
    local tr = util.GetPlayerTrace(self:GetOwner())
    tr.mask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX)
    local trace = util.TraceLine(tr)
    local coords = trace.HitPos:ToScreen()
    x, y = coords.x, coords.y
  else
    x, y = ScrW() / 2.0, ScrH() / 2.0
  end

  local scale = 10 * self.Primary.Cone
  -- Scale the size of the crosshair according to how long ago we fired our weapon
  local LastShootTime = self.Weapon:GetNetworkedFloat("LastShootTime", 0)
  scale = scale * (2 - math.Clamp((CurTime() - LastShootTime) * 5, 0.0, 1.0))
  surface.SetDrawColor(0, 255, 0, 255)
  -- Draw an awesome crosshair
  local gap = 40 * scale
  local length = gap + 20 * scale
  surface.DrawLine(x - length, y, x - gap, y)
  surface.DrawLine(x + length, y, x + gap, y)
  surface.DrawLine(x, y - length, x, y - gap)
  surface.DrawLine(x, y + length, x, y + gap)
end

--[[---------------------------------------------------------
	onRestore
	Loaded a saved game (or changelevel)
---------------------------------------------------------]]
function SWEP:OnRestore()
  self.NextSecondaryAttack = 0
  self:SetIronsights(false)
end