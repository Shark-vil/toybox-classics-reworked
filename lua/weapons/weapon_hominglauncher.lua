AddCSLuaFile()

if CLIENT then
  killicon.Add("sent_hmissile", "kill_seeker_new", Color(255, 80, 0, 255))
  killicon.Add("weapon_stinger", "kill_seeker_new", Color(255, 80, 0, 255))
  SWEP.PrintName = "Homing Missile Launcher"
  SWEP.Slot = 4
  SWEP.SlotPos = 3
  SWEP.DrawAmmo = true
  SWEP.DrawCrosshair = false

  function SWEP:DrawHUD()
    if self:GetNWEntity("target"):IsValid() then
      local ent = self:GetNWEntity("target")
      surface.SetDrawColor(20, 215, 25, 205)
      local size = math.max(math.min(ent:BoundingRadius() * 1.2 - math.min(60 * (self:GetPos() - ent:GetPos()):Length() / 16000, 25), 70), 20)

      if (self:GetPos() - ent:GetPos()):Length() / 16000 < 0.012 then
        size = ent:BoundingRadius() * 2 + 50
      end

      local offset = size / 2
      surface.DrawOutlinedRect(-offset + ent:LocalToWorld(ent:OBBCenter()):ToScreen().x, -offset + ent:LocalToWorld(ent:OBBCenter()):ToScreen().y, size, size)
    else
      surface.SetDrawColor(220, 25, 25, 145)
      surface.DrawOutlinedRect(ScrW() / 2 - 30, ScrH() / 2 - 30, 60, 60)
      surface.DrawLine(ScrW() / 2 - 13, ScrH() / 2, ScrW() / 2 + 13, ScrH() / 2)
      surface.DrawLine(ScrW() / 2, ScrH() / 2 - 13, ScrW() / 2, ScrH() / 2 + 13)
      local tr = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))

      if tr.HitNonWorld then
        local size = math.max(math.min(tr.Entity:BoundingRadius() * 1.2 - math.min(60 * tr.Fraction, 25), 70), 16)

        if tr.Fraction < 0.012 then
          size = tr.Entity:BoundingRadius() * 2 + 50
        end

        local offset = size / 2
        surface.DrawOutlinedRect(-offset + tr.Entity:LocalToWorld(tr.Entity:OBBCenter()):ToScreen().x, -offset + tr.Entity:LocalToWorld(tr.Entity:OBBCenter()):ToScreen().y, size, size)
      end
    end

    local entities = ents.FindByClass("sent_hmissile")
    local entscr
    local entvel

    for _, ent in ipairs(entities) do
      if ent:GetOwner() == self:GetOwner() then
        surface.SetDrawColor(250, 245, 35, 195)
        entscr = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
        if not entscr.visible then break end
        entvel = (ent:LocalToWorld(ent:OBBCenter()) + ent:GetVelocity() * 0.2):ToScreen()
        size = 10
        offset = size / 2
        surface.DrawOutlinedRect(-offset + entscr.x, -offset + entscr.y, size + math.random(-3, 3), size + math.random(-3, 3))
        surface.DrawLine(entscr.x, entscr.y, entvel.x, entvel.y)
      end
    end
  end

  function SWEP:GetViewModelPosition(pos, ang)
    --    local vec = Vector(1,6.7,0) --3.7)
    --    vec:Rotate((ang:Right()*-1):Angle())
    --    pos = pos + vec
    --pos.y = pos.y+ang:Up()*3
    --pos = pos:Rotate(self:GetOwner():EyeAngles())
    ang = (ang:Forward() + Vector(0, 0, 0.15)):Angle()

    return pos, ang
  end
end

if SERVER then
  SWEP.Weight = 5
  SWEP.AutoSwitchTo = false
  SWEP.AutoSwitchFrom = false

  function SWEP:Equip(NewOwner)
    NewOwner:GiveAmmo(6, "RPG_round")
  end
end

SWEP.Author = "FinDude"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Launches homing missiles. Right click to lock on target. Reload to clear target."
SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "rpg"
local ShootSound = Sound("weapons/rpg/rocketfire1.wav")
local FailSound = Sound("player/suit_denydevice.wav")

function SWEP:Initialize()
  self:SetNWEntity("target", nil)
  self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Reload()
  if self.Weapon:Clip1() == 0 then
    self.Weapon:DefaultReload(ACT_VM_RELOAD)
  else
    self:SetNWEntity("target", nil)
  end
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
  if not self:GetNWEntity("target"):IsValid() or not self:CanPrimaryAttack() then
    self:EmitSound(FailSound)

    return
  end

  local effectdata = EffectData()
  effectdata:SetOrigin(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 65)
  effectdata:SetNormal(self:GetOwner():GetAimVector())
  effectdata:SetMagnitude(18)
  effectdata:SetScale(2)
  effectdata:SetRadius(52)
  util.Effect("WheelDust", effectdata)
  self:EmitSound(ShootSound)
  self:ShootEffects(self)
  -- The rest is only done on the server
  if not SERVER then return end
  local ent = ents.Create("sent_hmissile")
  if not ent:IsValid() then return end
  ent:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 55)
  ent:SetAngles(self:GetOwner():GetAimVector():Angle())
  ent:SetVelocity(self:GetOwner():GetAimVector() * 750)
  ent:SetNWEntity("target", self:GetNWEntity("target"))
  ent:SetNWInt("activ", CurTime() + 0.8)
  ent:SetNWInt("det", CurTime() + 10)
  util.SpriteTrail(ent, 0, Color(190, 190, 190), false, 4, 15, 5, 1 / 16 * 0.5, "trails/smoke.vmt")
  ent:SetOwner(self:GetOwner())
  --print(self:GetOwner())
  --print(ent:GetOwner())
  ent:Spawn()
  -- ent:Fire("kill",1,9)
  self:SetNextPrimaryFire(CurTime() + 0.3)
  self:TakePrimaryAmmo(1)
  self:GetOwner():ViewPunch(Angle(-6, 0, 4))
end

--[[---------------------------------------------------------
    SecondaryAttack
---------------------------------------------------------]]
function SWEP:SecondaryAttack()
  local tr = self:GetOwner():GetEyeTrace()
  if tr.HitWorld then return end
  ent = tr.Entity
  self:SetNWEntity("target", ent)
end

--[[---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------]]
function SWEP:ShouldDropOnDie()
  return false
end