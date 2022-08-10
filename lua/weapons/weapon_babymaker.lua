AddCSLuaFile()

if CLIENT then
  language.Add("weapon_babymaker", "baby_maker")
  language.Add("Undone_Baby", "Undone Baby")
end

-- Basic Stuff
SWEP.PrintName = "baby_maker"
SWEP.ClassName = "baby_maker"
SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.UseHands = true
-- Settings
SWEP.HoldType = "smg"
SWEP.Weight = 5 -- 
SWEP.AutoSwitchTo = true -- 
SWEP.AutoSwitchFrom = false -- 
SWEP.Spawnable = true -- 
SWEP.AdminSpawnable = false -- 
SWEP.Category = "Toybox Classics"

--SWEP.AutoReload		= false		-- 
SWEP.VElements = {
  ["Nozzle"] = {
    type = "Model",
    model = "models/Items/combine_rifle_ammo01.mdl",
    bone = "ValveBiped.base",
    rel = "",
    pos = Vector(0.15, -0.663, 8.626),
    angle = Angle(0, 0, -2.056),
    size = Vector(0.497, 0.497, 0.497),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["BabyBaby"] = {
    type = "Model",
    model = "models/props_c17/doll01.mdl",
    bone = "ValveBiped.base",
    rel = "",
    pos = Vector(-0.905, -0.53, 2.882),
    angle = Angle(169.742, 0, -90),
    size = Vector(0.611, 0.611, 0.611),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  }
}

SWEP.WElements = {
  ["models/props_c17/doll01.mdl"] = {
    type = "Model",
    model = "models/props_c17/doll01.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(9.005, 0, -6.276),
    angle = Angle(170, -90, 0),
    size = Vector(0.485, 0.485, 0.485),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["Nozzlel"] = {
    type = "Model",
    model = "models/Items/combine_rifle_ammo01.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(13.512, 1.399, -6.808),
    angle = Angle(-1.545, -90, -102.776),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  },
  ["Glow"] = {
    type = "Model",
    model = "models/Effects/combineball.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    rel = "",
    pos = Vector(16.406, 2.13, -7.433),
    angle = Angle(-8.832, 0, 0),
    size = Vector(0.165, 0.165, 0.165),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
  }
}

-- Weapon info
SWEP.Author = "Ramificate" -- 
SWEP.Contact = "Indian tech support" -- 
SWEP.Purpose = "Turn props into babies" -- 
SWEP.Instructions = "Left click to change prop into a baby" -- 
-- Primary fire settings
SWEP.Primary.Sound = "/weapons/airboat/airboat_gun_energy1.wav" --	
SWEP.Primary.Damage = -1 -- 
SWEP.Primary.NumShots = 0 -- 
SWEP.Primary.Recoil = 0.6 -- 
SWEP.Primary.Cone = 0 -- 
SWEP.Primary.Delay = 0.7 -- 
SWEP.Primary.ClipSize = 100 -- 
SWEP.Primary.DefaultClip = 500 -- 
SWEP.Primary.Tracer = 0 -- 
SWEP.Primary.Force = 100 -- 
SWEP.Primary.TakeAmmoPerBullet = 1 -- 
SWEP.Primary.Automatic = true -- 
SWEP.Primary.Ammo = "smg1" --			 --
-- Secondary fire settings
SWEP.Secondary.Ammo = false

-- 
-- 
function SWEP:Initialize()
  -- other initialize code goes here
  self:SetHoldType(self.HoldType)

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

function SWEP:ShootBullet(damage, num_bullets, aimcone)
  local bullet = {}
  bullet.Num = num_bullets
  bullet.Src = self:GetOwner():GetShootPos() -- Source
  bullet.Dir = self:GetOwner():GetAimVector() -- Dir of bullet
  bullet.Spread = Vector(aimcone, aimcone, 0) -- Aim Cone
  bullet.Tracer = 1 -- Show a tracer on every x bullets 
  bullet.TracerName = "ToolTracer" -- what Tracer Effect should be used
  bullet.Force = 1 -- Amount of force to give to phys objects
  bullet.Damage = damage
  bullet.AmmoType = "Pistol"

  bullet.Callback = function(attacker, tr, dmginfo)
    if SERVER and IsValid(tr.Entity) and tr.Entity:GetModel() ~= "models/props_c17/doll01.mdl" and isstring(tr.Entity:GetModel()) then
      local ent = tr.Entity
      local baby = ents.Create("prop_physics")
      local velocity = ent:GetVelocity()
      baby:SetModel("models/props_c17/doll01.mdl")
      baby:SetOwner(attacker)
      baby:SetPos(ent:GetPos() + Vector(0, 0, 15))
      baby:SetAngles(Vector(math.random(-180, 181), math.random(-180, 181), math.random(-180, 181)):Angle())
      baby:Spawn()
      baby:GetPhysicsObject():SetVelocity(velocity)
      baby:SetKeyValue("physdamagescale", "500")
      undo.Create("Baby")
      undo.AddEntity(baby)
      undo.SetPlayer(attacker)
      undo.Finish()
      ent:Remove()
    end
  end

  self:GetOwner():FireBullets(bullet)
  self:ShootEffects()
end

-- 
function SWEP:PrimaryAttack()
  if not self:CanPrimaryAttack() then return end -- 
  self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- 
  self:GetOwner():MuzzleFlash() -- 
  self:GetOwner():SetAnimation(PLAYER_ATTACK1) -- 
  self.Weapon:EmitSound(Sound(self.Primary.Sound)) -- 
  self:GetOwner():ViewPunch(Angle(-self.Primary.Recoil, 0, 0))
  self:ShootBullet(0, 1, 0)
  self:TakePrimaryAmmo(1)
  self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
end

function SWEP:Think()
end

function SWEP:Reload()
  self:DefaultReload(ACT_VM_RELOAD) --
end

function SWEP:Deploy()
  self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

  return true
end

function SWEP:Holster()
  return true
end

function SWEP:OnRemove()
  self:Holster()
end