AddCSLuaFile()

if CLIENT then
  language.Add("weapon_rocketbow", "Rocketbow")
  language.Add("electromissile", "Rhino Missile")
end

SWEP.Category = "Toybox Classics"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.PrintName = "Rocketbow"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
SWEP.UseHands = true
SWEP.DrawWeaponInfoBox = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.ViewModelBoneMods = {
  ["ValveBiped.bolt"] = {
    scale = Vector(0.009, 0.009, 0.009),
    pos = Vector(0, 0, 0),
    angle = Angle(0, 0, 0)
  }
}

SWEP.VElements = {
  ["rocket"] = {
    type = "Model",
    model = "models/Weapons/W_missile_closed.mdl",
    bone = "ValveBiped.bolt",
    rel = "",
    pos = Vector(0, 0, 10),
    angle = Angle(90, 0, 0),
    size = Vector(1, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  }
}

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "RPG_Round"
SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
SWEP.Primary.Delay = 0.5
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ZoomInSound = Sound("Weapon_SniperRifle.Special1")
SWEP.ZoomOutSound = Sound("Weapon_SniperRifle.Special2")
SWEP.Zoomed = false

function SWEP:Initialize()
  self:SetHoldType("crossbow")

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

function SWEP:Holster()
  if CLIENT and IsValid(self:GetOwner()) then
    local vm = self:GetOwner():GetViewModel()

    if IsValid(vm) then
      self:ResetBonePositions(vm)
    end
  end

  self.Zoomed = false

  return true
end

function SWEP:CanReload()
  if self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
    if self:Clip1() == 0 then return true end
  end

  return false
end

function SWEP:Think()
  if self.NeedsReload then
    self:Reload()
  end
end

function SWEP:Reload()
  self.NeedsReload = false
  self:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:CanPrimaryAttack()
  if self.Weapon:Clip1() <= 0 then
    self:Reload()

    return false
  end

  return true
end

function SWEP:CanSecondaryAttack()
  return true
end

function SWEP:OnRemove()
  self:Holster()
end

function SWEP:ShootRocket()
  if CLIENT then return end
  local rocket = ents.Create("cbow_rocket")
  if not IsValid(rocket) then return end
  rocket:Spawn()
  rocket:SetPos(self:GetOwner():EyePos())
  rocket:SetAngles(self:GetOwner():EyeAngles())
  rocket:SetOwner(self:GetOwner())

  if SERVER and IsValid(rocket:GetPhysicsObject()) then
    rocket:GetPhysicsObject():EnableGravity(false)
    rocket:GetPhysicsObject():SetBuoyancyRatio(0)
    rocket:GetPhysicsObject():EnableDrag(false)
    rocket:GetPhysicsObject():AddVelocity(self:GetOwner():GetAimVector() * 2000)
  end

  rocket.Inflictor = self
  rocket.Attacker = self:GetOwner()
  util.SpriteTrail(rocket, 0, Color(190, 190, 190), false, 6, 18, 0.3, 10, "trails/smoke.vmt")
end

function SWEP:PrimaryAttack()
  if not self:CanPrimaryAttack() then return end
  self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
  self:ShootRocket()
  self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
  self:TakePrimaryAmmo(1)
  self:GetOwner():ViewPunch(Angle(math.Rand(4, 5), math.Rand(-1, 1), 0))
  self:EmitSound(self.Primary.Sound)
  self:GetOwner():SetAnimation(PLAYER_ATTACK1)

  if self:Clip1() == 0 then
    self.NeedsReload = true
  end
end

function SWEP:SecondaryAttack()
  if self.Zoomed then
    self:GetOwner():SetFOV(0, 0.1)
    self:EmitSound(self.ZoomInSound)
    self.Zoomed = false
  else
    self:GetOwner():SetFOV(50, 0.1)
    self:EmitSound(self.ZoomOutSound)
    self.Zoomed = true
  end
end

net.Receive("ToyBoxReworked_ExplodeDynamicLight", function()
  local dlight = DynamicLight(net.ReadFloat())

  if dlight then
    dlight.Pos = net.ReadVector()
    dlight.r = 255
    dlight.g = 150
    dlight.b = 0
    dlight.Brightness = 1
    dlight.Size = 512
    dlight.Decay = 2048
    dlight.DieTime = CurTime() + 1
  end
end)

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
--[[0	ValveBiped.Bip01_Spine4
1	ValveBiped.Bip01_L_Clavicle
2	ValveBiped.Bip01_L_UpperArm
3	ValveBiped.Bip01_L_Forearm
4	ValveBiped.Bip01_L_Hand
5	ValveBiped.Bip01_L_Finger4
6	ValveBiped.Bip01_L_Finger41
7	ValveBiped.Bip01_L_Finger42
8	ValveBiped.Bip01_L_Finger3
9	ValveBiped.Bip01_L_Finger31
10	ValveBiped.Bip01_L_Finger32
11	ValveBiped.Bip01_L_Finger2
12	ValveBiped.Bip01_L_Finger21
13	ValveBiped.Bip01_L_Finger22
14	ValveBiped.Bip01_L_Finger1
15	ValveBiped.Bip01_L_Finger11
16	ValveBiped.Bip01_L_Finger12
17	ValveBiped.Bip01_L_Finger0
18	ValveBiped.Bip01_L_Finger01
19	ValveBiped.Bip01_L_Finger02
20	ValveBiped.Bip01_R_Clavicle
21	ValveBiped.Bip01_R_UpperArm
22	ValveBiped.Bip01_R_Forearm
23	ValveBiped.Bip01_R_Hand
24	ValveBiped.Bip01_R_Finger4
25	ValveBiped.Bip01_R_Finger41
26	ValveBiped.Bip01_R_Finger42
27	ValveBiped.Bip01_R_Finger3
28	ValveBiped.Bip01_R_Finger31
29	ValveBiped.Bip01_R_Finger32
30	ValveBiped.Bip01_R_Finger2
31	ValveBiped.Bip01_R_Finger21
32	ValveBiped.Bip01_R_Finger22
33	ValveBiped.Bip01_R_Finger1
34	ValveBiped.Bip01_R_Finger11
35	ValveBiped.Bip01_R_Finger12
36	ValveBiped.Bip01_R_Finger0
37	ValveBiped.Bip01_R_Finger01
38	ValveBiped.Bip01_R_Finger02
39	ValveBiped.Base
40	ValveBiped.Crossbow_base
41	ValveBiped.bowr1
42	ValveBiped.bowl1
43	ValveBiped.bowr2
44	ValveBiped.bowl2
45	ValveBiped.pull
46	ValveBiped.bolt


1:
		id	=	1
		name	=	spark
2:
		id	=	2
		name	=	bolt_start
3:
		id	=	3
		name	=	bolt_end

]]