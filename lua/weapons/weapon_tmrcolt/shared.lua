SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "TMAR Colt Pythons"
SWEP.ViewModel = "models/weapons/v_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip1 = true
SWEP.BobScale = 0.2
SWEP.SwayScale = 0.1
SWEP.UseHands = false
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Cooldown = 0.4
SWEP.Secondary.ClipSize = 6
SWEP.Secondary.DefaultClip = 6
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReloadTime = 0
SWEP.ReloadSecondTime = 0

if CLIENT then
  SWEP.ReloadingClientside = false
end

local alphap = 0
local alphas = 0
local rotation = 0
local position = 0
local position2 = 0
local lerpv_p = 0
local lerpv_s = 0

local MatSurfacePropTranslate = {
  [MAT_ANTLION] = util.GetSurfaceIndex("antlion"),
  [MAT_BLOODYFLESH] = util.GetSurfaceIndex("bloodyflesh"),
  [MAT_CONCRETE] = util.GetSurfaceIndex("concrete"),
  [MAT_DIRT] = util.GetSurfaceIndex("dirt"),
  [MAT_FLESH] = util.GetSurfaceIndex("flesh"),
  [MAT_GRATE] = util.GetSurfaceIndex("metalgrate"),
  [MAT_ALIENFLESH] = util.GetSurfaceIndex("alienflesh"),
  [MAT_CLIP] = util.GetSurfaceIndex("player_control_clip"),
  [MAT_PLASTIC] = util.GetSurfaceIndex("plastic"),
  [MAT_METAL] = util.GetSurfaceIndex("metal"),
  [MAT_SAND] = util.GetSurfaceIndex("sand"),
  [MAT_FOLIAGE] = util.GetSurfaceIndex("foliage"),
  [MAT_COMPUTER] = util.GetSurfaceIndex("computer"),
  [MAT_SLOSH] = util.GetSurfaceIndex("water"),
  [MAT_TILE] = util.GetSurfaceIndex("tile"),
  [MAT_VENT] = util.GetSurfaceIndex("metalvent"),
  [MAT_WOOD] = util.GetSurfaceIndex("wood"),
  [MAT_GLASS] = util.GetSurfaceIndex("glass")
}

function SWEP:Initialize()
  self:SetWeaponHoldType("duel")

  if CLIENT then
    self.CModel_W2 = ClientsideModel(self.WorldModel)
    self.CModel_W2:AddEffects(bit.bor(EF_NOSHADOW, EF_NODRAW))
  end
end

function SWEP:Deploy()
  if IsValid(self:GetOwner():GetViewModel(1)) then
    self:GetOwner():GetViewModel(1):SetWeaponModel(self.ViewModel, self)
  end

  self:SendViewModelAnim(ACT_VM_DRAW, 1, 4)
  self:SendViewModelAnim(ACT_VM_DRAW, 0, 4)

  return true
end

function SWEP:SetupDataTables()
  self:NetworkVar("Bool", 0, "Reloading")
  self:NetworkVar("Bool", 0, "PrimaryReloading")
  self:NetworkVar("Bool", 0, "SecondaryReloading")
  self:NetworkVar("Int", 0, "BloodType") -- thanks multiplayer
end

function SWEP:PrimaryAttack()
  local self = self.Weapon
  local clip1 = self:Clip1()
  local clip2 = self:Clip2()
  local gun = 0
  if self:GetReloading() then return false end

  if clip2 > clip1 then
    gun = 1
  elseif (clip1 == 0) or (clip1 == -1) then
    return
  end

  --Right
  if gun == 0 then
    self:SetClip1(clip1 - 1)
  else --Left
    self:SetClip2(clip2 - 1)
  end

  local owner = self:GetOwner()
  local tr = self:GetTrace()

  if tr.Hit then
    if IsValid(tr.Entity) and SERVER then
      local dmg = DamageInfo()
      dmg:SetAttacker(self:GetOwner())
      dmg:SetInflictor(self)
      dmg:SetDamageType(DMG_BULLET)
      dmg:SetDamage(16)
      dmg:SetDamagePosition(tr.HitPos)
      dmg:SetDamageForce(tr.Normal * 18000)
      tr.Entity:TakeDamageInfo(dmg)
    end

    self:ImpactEffect(tr, DMG_BULLET)
  end

  if gun == 0 then
    self:SendViewModelAnim(ACT_VM_PRIMARYATTACK, 0)
  else
    self:SendViewModelAnim(ACT_VM_PRIMARYATTACK, 1)
  end

  owner:SetAnimation(PLAYER_ATTACK1)
  self:EmitSound(Sound("Weapon_357.Single"))
  self:SetNextPrimaryFire(CurTime() + self.Primary.Cooldown)
end

function SWEP:SecondaryAttack()
  return false
end

function SWEP:Reload()
  --self:SetPrimaryReloading(false)
  if not SERVER then return end
  if self:Clip1() == 6 and self:Clip2() == 6 then return false end
  if self.ReloadTime ~= 0 then return false end

  if self:Clip1() < 6 then
    self:SetClip1(-1)
    self:SendViewModelAnim(ACT_VM_RELOAD, 0, 3)
    self.ReloadTime = CurTime() + 0.9
    self:SetPrimaryReloading(true)
    self:SetSecondaryReloading(false)
    self:SetReloading(true)
    self:GetOwner():DoReloadEvent()

    if self:Clip2() < 6 then
      self:SetSecondaryReloading(false)
      self:SetClip2(-1)
    end
  end
end

function SWEP:Holster()
  if not IsValid(self) then return end
  if not IsValid(self:GetOwner()) then return end
  if not IsValid(self:GetOwner():GetViewModel()) then return end
  local viewmodel1 = self:GetOwner():GetViewModel(1)
  local viewmodel2 = self:GetOwner():GetViewModel(0)

  if IsValid(viewmodel1) then
    viewmodel1:SetWeaponModel(self.ViewModel, nil)
  end

  -- only tested with bots, might not work on real players?
  if CLIENT and IsValid(viewmodel2) then
    for i = 0, viewmodel2:GetBoneCount() - 1 do
      viewmodel2:ManipulateBonePosition(i, Vector(0, 0, 0))
      viewmodel2:ManipulateBoneScale(i, Vector(1, 1, 1))
      viewmodel2:ManipulateBoneAngles(i, Angle(0, 0, 0))
    end

    for i = 0, viewmodel1:GetBoneCount() - 1 do
      viewmodel1:ManipulateBonePosition(i, Vector(0, 0, 0))
      viewmodel1:ManipulateBoneScale(i, Vector(1, 1, 1))
      viewmodel1:ManipulateBoneAngles(i, Angle(0, 0, 0))
    end

    self:BulletScale(0, true, true, true, true, true, true)
    self:BulletScale(1, true, true, true, true, true, true)
  end

  return true
end

function SWEP:Think()
  if SERVER then
    if self.ReloadTime ~= 0 and self.ReloadTime < CurTime() then
      self:SetPrimaryReloading(false)
      self.ReloadTime = 0

      if self:Clip2() == 6 then
        self:SetReloading(false)
      end

      --self:SendViewModelAnim(ACT_VM_IDLE, 1)
      --self:SendViewModelAnim(ACT_VM_IDLE, 0)
      self:SetClip1(6)

      if self:Clip2() == -1 then
        self:SetSecondaryReloading(true)
        self:SendViewModelAnim(ACT_VM_RELOAD, 1, 3)
        self.ReloadSecondTime = CurTime() + 0.9
      end
    end

    if self.ReloadSecondTime ~= 0 and self.ReloadSecondTime < CurTime() then
      self:SetReloading(false)
      --self:SendViewModelAnim(ACT_VM_IDLE, 1)
      self:SetClip2(6)
      self.ReloadSecondTime = 0
      self:SetSecondaryReloading(false)
    end
  end
end

function SWEP:ViewModelDrawn(vm)
  local viewmodel_left = self:GetOwner():GetViewModel(1)
  local viewmodel_right = self:GetOwner():GetViewModel(0)
  -- some bad code but i really don't care right now
  -- big hacks below, beware!
  -- angles is 5, -10, -45
  -- position is -5, -5, 15
  self:notahack()
  viewmodel_right:ManipulateBoneAngles(viewmodel_right:LookupBone("Arm"), rotation)
  viewmodel_right:ManipulateBonePosition(viewmodel_right:LookupBone("Arm"), position)
  viewmodel_left:ManipulateBoneAngles(viewmodel_left:LookupBone("Arm"), secondary_rotation)
  viewmodel_left:ManipulateBonePosition(viewmodel_left:LookupBone("Arm"), secondary_position)

  --if self:GetOwner():GetActiveWeapon() == self then
  for i = 0, viewmodel_left:GetBoneCount() - 1 do
    if string.sub(viewmodel_left:GetBoneName(i), 1, 7) == "Bip01_L" then
      viewmodel_left:ManipulateBoneScale(i, Vector(0, 0, 0))
      viewmodel_left:ManipulateBonePosition(i, Vector(-3000, -3000, -3000))
    end
  end

  for i = 0, viewmodel_right:GetBoneCount() - 1 do
    if string.sub(viewmodel_right:GetBoneName(i), 1, 7) == "Bip01_L" then
      viewmodel_right:ManipulateBoneScale(i, Vector(0, 0, 0))
      viewmodel_right:ManipulateBonePosition(i, Vector(-3000, -3000, -3000))
    end
  end

  --viewmodel_left:ManipulateBonePosition(viewmodel_left:LookupBone("Bip01_L_UpperArm"), Vector(0, math.huge, 0))
  --viewmodel_right:ManipulateBonePosition(viewmodel_right:LookupBone("Bip01_L_UpperArm"), Vector(0, math.huge, 0))
  --end
  if self:Clip1() ~= -1 and alphap ~= 0 then
    render.SetMaterial(Material("effects/yellowflare"))
    render.DrawSprite(viewmodel_right:GetBonePosition(viewmodel_right:LookupBone("Cylinder")), 4, 4, Color(255, 255, 255, alphap))
  end

  if self:Clip2() ~= -1 and alphas ~= 0 then
    render.SetMaterial(Material("effects/yellowflare"))
    render.DrawSprite(viewmodel_left:GetBonePosition(viewmodel_left:LookupBone("Cylinder")), 4, 4, Color(255, 255, 255, alphas))
  end

  if self:Clip1() == -1 then
    self:BulletScale(0, false, false, false, false, false, false)
  end

  if self:Clip2() == -1 then
    self:BulletScale(1, false, false, false, false, false, false)
  end

  if self:Clip1() == 6 then
    self:BulletScale(0, true, true, true, true, true, true)
  elseif self:Clip1() == 5 then
    self:BulletScale(0, false, false, true, true, true, true)
  elseif self:Clip1() == 4 then
    self:BulletScale(0, false, false, false, true, true, true)
  elseif self:Clip1() == 3 then
    self:BulletScale(0, false, false, false, false, true, true)
  elseif self:Clip1() == 2 then
    self:BulletScale(0, false, false, false, false, false, true)
  elseif self:Clip1() == 1 then
    self:BulletScale(0, false, false, false, false, false, false)
  elseif self:Clip1() == 0 then
    self:BulletScale(0, false, false, false, false, false, false)
  end

  if self:Clip2() == 6 then
    self:BulletScale(1, true, true, true, true, true, true)
  elseif self:Clip2() == 5 then
    self:BulletScale(1, false, false, true, true, true, true)
  elseif self:Clip2() == 4 then
    self:BulletScale(1, false, false, false, true, true, true)
  elseif self:Clip2() == 3 then
    self:BulletScale(1, false, false, false, false, true, true)
  elseif self:Clip2() == 2 then
    self:BulletScale(1, false, false, false, false, false, true)
  elseif self:Clip2() == 1 then
    self:BulletScale(1, false, false, false, false, false, false)
  elseif self:Clip2() == 0 then
    self:BulletScale(1, false, false, false, false, false, false)
  end
end

-- todo done? maybe... edit: i guess so, but this is less hacky then what you have shouldve seen!
function SWEP:notahack()
  if self:Clip1() == -1 then
    if lerpv_p < 1 then
      lerpv_p = lerpv_p + 0.1
    end
  else
    if lerpv_p > -0.1 then
      lerpv_p = lerpv_p - 0.1
    end
  end

  if self:Clip2() == -1 then
    if lerpv_s < 1 then
      lerpv_s = lerpv_s + 0.1
    end
  else
    if lerpv_s > -0.1 then
      lerpv_s = lerpv_s - 0.1
    end
  end

  if self:Clip1() == -1 then
    alphap = 255
  else
    if alphap > 0 then
      alphap = alphap - 5
    end
  end

  if self:Clip2() == -1 then
    alphas = 255
  else
    if alphas > 0 then
      alphas = alphas - 5
    end
  end

  if lerpv_p < 0 then
    lerpv_p = 0
  end

  if lerpv_s < 0 then
    lerpv_s = 0
  end

  rotation = LerpAngle(lerpv_p, Angle(0, 0, 0), Angle(5, -10, -45))
  position = LerpVector(lerpv_p, Vector(0, 0, 0), Vector(-5, -5, 15))
  secondary_rotation = LerpAngle(lerpv_s, Angle(0, 0, 0), Angle(5, -10, -45))
  secondary_position = LerpVector(lerpv_s, Vector(0, 0, 0), Vector(-5, -5, 15))
end

function SWEP:BulletScale(viewmodelselect, bullet1, bullet2, bullet3, bullet4, bullet5, bullet6)
  local viewmodel = self:GetOwner():GetViewModel(viewmodelselect)
  if not IsValid(viewmodel) or SERVER or not viewmodel:LookupBone("Bullet1") then return end

  if bullet1 == true then
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet1"), Vector(1, 1, 1))
  else
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet1"), Vector(0, 0, 0))
  end

  if bullet2 == true then
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet2"), Vector(1, 1, 1))
  else
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet2"), Vector(0, 0, 0))
  end

  if bullet3 == true then
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet3"), Vector(1, 1, 1))
  else
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet3"), Vector(0, 0, 0))
  end

  if bullet4 == true then
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet4"), Vector(1, 1, 1))
  else
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet4"), Vector(0, 0, 0))
  end

  if bullet5 == true then
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet5"), Vector(1, 1, 1))
  else
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet5"), Vector(0, 0, 0))
  end

  if bullet6 == true then
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet6"), Vector(1, 1, 1))
  else
    viewmodel:ManipulateBoneScale(viewmodel:LookupBone("Bullet6"), Vector(0, 0, 0))
  end
end

--[[357 BONES:
0	Base
1	Bip01_L_UpperArm
2	Bip01_L_Forearm
3	Bip01_L_Hand
4	Bip01_L_Finger4
5	Bip01_L_Finger41
6	Bip01_L_Finger42
7	Bip01_L_Finger3
8	Bip01_L_Finger31
9	Bip01_L_Finger32
10	Bip01_L_Finger2
11	Bip01_L_Finger21
12	Bip01_L_Finger22
13	Bip01_L_Finger1
14	Bip01_L_Finger11
15	Bip01_L_Finger12
16	Bip01_L_Finger0
17	Bip01_L_Finger01
18	Bip01_L_Finger02
19	Arm
20	Hand
21	Python
22	__INVALIDBONE__
23	Cylinder_release
24	Cylinder
25	Bullet1
26	Bullet2
27	Bullet3
28	Bullet4
29	Bullet5
30	Bullet6]]
function SWEP:ImpactEffect(tr, dmgtype)
  local edata = EffectData()
  edata:SetOrigin(tr.HitPos)

  if tr.HitWorld then
    edata:SetNormal(((-tr.Normal) + (VectorRand() * 0.2)):GetNormalized())
    util.Effect("ManhackSparks", edata)
    sound.Play(Sound("FX_RicochetSound.Ricochet"), tr.HitPos)

    return
  end

  local ent = tr.Entity
  if ent == NULL then return end
  edata:SetNormal(tr.HitNormal)
  edata:SetHitBox(tr.HitBox)
  edata:SetEntity(ent)
  edata:SetDamageType(dmgtype)
  local decoy = {} -- cleaning up old code that had no purpose and had errors in mp
  decoy.Num = 1
  decoy.Src = self:GetOwner():GetShootPos()
  decoy.Dir = self:GetOwner():GetAimVector()
  decoy.Spread = Vector(0, 0, 0)
  decoy.Tracer = 0
  decoy.Force = 0
  decoy.Damage = 0
  decoy.AmmoType = ""
  self:FireBullets(decoy)
end

--taken from gmod wiki, don't really know howto do dual weapons, sorry :(
function SWEP:SendViewModelAnim(act, index, rate)
  if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
  local vm = self:GetOwner():GetViewModel(index)
  if not IsValid(vm) then return end
  local seq = vm:SelectWeightedSequence(act)
  if seq == -1 then return end
  vm:SendViewModelMatchingSequence(seq)
  vm:SetPlaybackRate(rate or 1)
end

function SWEP:GetTrace()
  local owner = self:GetOwner()
  local trace = {}
  trace.mask = MASK_SHOT
  trace.mins = Vector(-2, -2, -2)
  trace.maxs = Vector(2, 2, 2)
  trace.filter = owner
  trace.start = owner:GetShootPos()
  trace.endpos = trace.start + (owner:GetAimVector() * 8192)

  return util.TraceHull(trace)
end

function SWEP:OnDrop()
  self:Holster()
end

function SWEP:OnRemove()
  self:Holster()
end