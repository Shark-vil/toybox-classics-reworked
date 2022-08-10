AddCSLuaFile()
require("glon")

if CLIENT then
  language.Add("weapon_pixelsword", "Pixel Weapon")
end

SWEP.PrintName = "Pixel Weapon"
SWEP.Author = "Thermadyle"
SWEP.ViewModel = "models/weapons/c_arms_animations.mdl"
SWEP.WorldModel = ""
SWEP.SwingDelay = 0.5
SWEP.Range = 64
SWEP.Damage = 16
SWEP.SwingSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.HitSound = "weapons/crossbow/hitbod%s.wav"
SWEP.Pixels = {}
SWEP.PixelWeapon = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Primary.Ammo = false
SWEP.Secondary.Ammo = false
SWEP.Spawnable = true
SWEP.Category = "Toybox Classics"

function SWEP:Initialize()
  self:SetHoldType("melee")

  for i = 1, 32 do
    self.Pixels[i] = {}
  end
end

function SWEP:PrimaryAttack()
  if (self.NextAttack or 0) < CurTime() then
    self.NextAttack = CurTime() + self.SwingDelay
    self:PlaySound(self.SwingSound)

    if SERVER then
      net.Start("ToyBoxReworked_pixel_weapon_swing")
      net.Send(self:GetOwner())
    end

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)

    local pl = self:GetOwner()
    local tr = pl:GetEyeTraceNoCursor()
    local ent = tr.Entity
    if not tr.HitPos or not IsValid(ent) then return end
    local dist = tr.HitPos:Distance(pl:GetShootPos())

    if dist <= self.Range then
      self:PlaySound(self.HitSound, math.random(1, 2))

      if SERVER then
        ent:TakeDamage(self.Damage, pl)
      end

      if ent:IsNPC() then
        local blood = EffectData()
        blood:SetOrigin(tr.HitPos)
        util.Effect("BloodImpact", blood)
      end
    end
  end
end

function SWEP:PlaySound(str, num)
  str = string.format(str, num or "")
  self:EmitSound(str)
end

function SWEP:SecondaryAttack()
end

if SERVER then
  function SWEP:Reload()
    net.Start("ToyBoxReworked_pixel_weapon_menu")
    net.WriteInt(self.Damage - 128, 32)
    net.WriteFloat(self.SwingDelay)
    net.Send(self:GetOwner())
  end

  local function SetDamage(pl, _, args)
    local damage = tonumber(args[1])

    if damage then
      local wep = pl:GetActiveWeapon()
      if not IsValid(wep) then return end
      if not wep.PixelWeapon then return end
      wep.Damage = damage
    end
  end

  concommand.Add("pixel_weapon_damage", SetDamage)

  local function SetSwingDelay(pl, _, args)
    local delay = tonumber(args[1])

    if delay then
      local wep = pl:GetActiveWeapon()
      if not IsValid(wep) then return end
      if not wep.PixelWeapon then return end
      wep.SwingDelay = delay
      wep.NextAttack = 0
    end
  end

  concommand.Add("pixel_weapon_swingdelay", SetSwingDelay)
else
  local swing = 0
  local swingRadious = 5

  local function Swing()
    swing = swingRadious
  end
  net.Receive("ToyBoxReworked_pixel_weapon_swing", Swing)

  function SWEP:Think()
    if swing > -swingRadious then
      swing = swing - (FrameTime() * 50)
    else
      swing = -swingRadious
    end
  end

  function SWEP:DrawHUD()
    draw.SimpleText("Press R to open the menu to edit your weapon", "ChatFont", ScrW() / 2, ScrH() - 24, Color(220, 220, 220), TEXT_ALIGN_CENTER)
  end

  -- Draw
  local function DrawWeapon()
    local pl = LocalPlayer()
    local wep = pl:GetActiveWeapon()
    if not IsValid(wep) then return end
    if not wep.PixelWeapon then return end
    local eyeAng = pl:EyeAngles()
    local forward = eyeAng:Forward()
    local tr = pl:GetEyeTraceNoCursor()
    local back = 0

    if tr and tr.HitPos then
      local dist = tr.HitPos:Distance(pl:GetShootPos())
      back = 32 - math.Clamp(dist, 0, 32)
    end

    local swingValue = (swingRadious * swingRadious) - swing * swing
    local pos = pl:GetShootPos() + forward * ((32 + swingValue) - back) + eyeAng:Right() * (14 - swingValue / 2)
    local ang = eyeAng
    ang:RotateAroundAxis(forward, 90)
    ang:RotateAroundAxis(ang:Right(), 165 - swingValue - 180)
    ang:RotateAroundAxis(ang:Up(), 265 - (swingValue * 2))
    cam.Start3D(EyePos(), EyeAngles())
    cam.Start3D2D(pos, ang, 1)
    local lastCol

    for i = 1, 32 do
      for j = 1, 16 do
        if not wep.Pixels then continue end
        if not wep.Pixels[i] then continue end
        local col = wep.Pixels[i][j]
        if not col then continue end

        if lastCol ~= col then
          surface.SetDrawColor(col)
          lastCol = col
        end

        surface.DrawRect(-10 + i - 1, j - 1, 1, 1)
      end
    end

    cam.End3D2D()
    cam.End3D()
  end

  hook.Add("RenderScreenspaceEffects", "draw_weapon", DrawWeapon)

  local function DrawWep(pl)
    local wep = pl:GetActiveWeapon()
    if not IsValid(wep) then return end
    if not wep.PixelWeapon then return end
    local tr = pl:GetEyeTraceNoCursor()
    local back = 0

    if tr and tr.HitPos then
      local dist = tr.HitPos:Distance(pl:GetShootPos())
      back = 32 - math.Clamp(dist, 0, 32)
    end

    local swingValue = (swingRadious * swingRadious) - swing * swing
    local pos, ang = pl:GetBonePosition(pl:LookupBone("ValveBiped.Bip01_R_Hand"))
    pos = pos + ang:Forward() * 12 - ang:Right() * 5 - ang:Up() * 18
    --ang:RotateAroundAxis( forward, 90 )
    ang:RotateAroundAxis(ang:Right(), 295 - swingValue - 180)
    --ang:RotateAroundAxis( ang:Up(), -295 - ( swingValue * 2 ) )
    --cam.Start3D( EyePos(), EyeAngles() )
    cam.Start3D2D(pos, ang, 1)
    local lastCol

    for i = 1, 32 do
      for j = 1, 16 do
        if not wep.Pixels then continue end
        if not wep.Pixels[i] then continue end
        local col = wep.Pixels[i][j]
        if not col then continue end

        if lastCol ~= col then
          surface.SetDrawColor(col)
          lastCol = col
        end

        surface.DrawRect(-10 + i - 1, j - 1, 1, 1)
      end
    end

    cam.End3D2D()
    --cam.End3D()
  end

  hook.Add("PostPlayerDraw", "draw_weapon", DrawWep)

  -- Menu
  local function Menu()
    local dmg = net.ReadInt(32) + 128
    local swingDelay = net.ReadFloat()

    if not IsValid(PIXELSWORDMENU) then
      local pl = LocalPlayer()
      local wep = pl:GetActiveWeapon()

      if not IsValid(wep) or not wep.PixelWeapon then
        menu:SetVisible(false)

        return
      end

      local menu = vgui.Create("DFrame")
      local colorPnl = vgui.Create("DColorMixer", menu)
      --colorPnl:GetTable().AlphaBar:GetTable().imgBackground.Paint = function() end
      menu:SetSize(564, 600)
      menu:SetTitle("Edit the weapon")
      menu:Center()
      menu:MakePopup()
      local selectedColor
      local drawPnlHeight = menu:GetTall() - 32
      local drawPnl = vgui.Create("DPanel", menu)
      drawPnl:SetPos(5, 27)
      drawPnl:SetSize(drawPnlHeight / 2, drawPnlHeight)
      local width = drawPnl:GetWide() / 16
      local height = drawPnl:GetTall() / 32

      drawPnl.Think = function(self)
        local menuX, menuY = menu:GetPos()
        local x, y = self:GetPos()
        local pos = Vector(menuX - x, menuY - y)
        local x = math.floor(((gui.MouseX() - pos.x) + 5) / width)
        local y = math.floor(((gui.MouseY() - pos.y) - 37) / height)

        if x >= 1 and y >= 1 and x <= 16 and y <= 32 then
          if input.IsMouseDown(MOUSE_LEFT) then
            if input.IsKeyDown(KEY_C) then
              selectedColor = wep.Pixels[y][x]
            else
              if wep.Pixels[y] and wep.Pixels[x] and (selectedColor or colorPnl:GetColor()) then
                wep.Pixels[y][x] = selectedColor or colorPnl:GetColor()
              end
            end
          elseif input.IsMouseDown(MOUSE_RIGHT) then
            wep.Pixels[y][x] = nil
          end
        end
      end

      drawPnl.Paint = function(self)
        surface.SetDrawColor(Color(150, 150, 150))
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
        local lastCol

        for i = 1, 32 do
          for j = 1, 16 do
            if not wep.Pixels then continue end
            if not wep.Pixels[i] then continue end
            local col = wep.Pixels[i][j]
            if not col then continue end

            if lastCol ~= col then
              surface.SetDrawColor(col)
              lastCol = col
            end

            surface.DrawRect((j - 1) * width, (i - 1) * height, width, height)
          end
        end

        surface.SetDrawColor(Color(0, 0, 0))

        for i = 0, 31 do
          surface.DrawRect(0, i * height, drawPnl:GetWide(), 1)
        end

        for i = 0, 15 do
          surface.DrawRect(i * width, 0, 1, drawPnl:GetTall())
        end

        surface.DrawRect(drawPnl:GetWide() - 1, 0, 1, drawPnl:GetTall())
        surface.DrawRect(0, drawPnl:GetTall() - 1, drawPnl:GetWide(), 1)
        self:NoClipping(false)
        local x, y = self:CursorPos()
        surface.SetDrawColor(Color(0, 0, 0))
        surface.DrawRect(x + 10, y + 10, 18, 18)
        surface.SetDrawColor(selectedColor or colorPnl:GetColor())
        surface.DrawRect(x + 11, y + 11, 16, 16)
        self:NoClipping(true)
      end

      local width = menu:GetWide() - drawPnlHeight / 2 - 15
      colorPnl:SetPos(drawPnlHeight / 2 + 10, 27)
      colorPnl:SetSize(width + 37, width)
      local x = colorPnl:GetPos()
      local propertiesPnl = vgui.Create("DPanelList", menu)
      propertiesPnl:SetPos(x, colorPnl:GetTall() + 32)
      propertiesPnl:SetSize(width, 89)
      propertiesPnl:SetPadding(5)
      propertiesPnl:EnableVerticalScrollbar(true)
      propertiesPnl:SetSpacing(2)

      if game.SinglePlayer() then
        -- Damage
        local damage = vgui.Create("DNumSlider")
        damage:SetText("Damage")
        damage:SetValue(dmg)
        damage:SetDecimals(0)
        damage:SetMin(0)
        damage:SetMax(256)

        damage.OnValueChanged = function(_, val)
          RunConsoleCommand("pixel_weapon_damage", val)
        end

        propertiesPnl:AddItem(damage)
        -- Swing rate
        local swingrate = vgui.Create("DNumSlider")
        swingrate:SetText("Swing delay")
        swingrate:SetValue(swingDelay)
        swingrate:SetDecimals(1)
        swingrate:SetMin(0)
        swingrate:SetMax(10)

        swingrate.OnValueChanged = function(_, val)
          RunConsoleCommand("pixel_weapon_swingdelay", val)
        end

        propertiesPnl:AddItem(swingrate)
      end

      local _, y = propertiesPnl:GetPos()
      local filePnl = vgui.Create("DPanelList", menu)
      filePnl:SetPos(x, y + propertiesPnl:GetTall() + 5)
      filePnl:SetSize(width, 172)
      filePnl:SetPadding(5)
      filePnl:EnableVerticalScrollbar(true)
      filePnl:SetSpacing(2)

      local function RefreshFiles()
        if not IsValid(filePnl) then return end
        filePnl:Clear()
        local dir = "pixel_weapon/"
        local files = file.Find(dir .. "*.txt", "DATA")

        for i = 1, #files do
          local fileName = files[i]
          local name = string.Left(fileName, #fileName - 4)
          local pnl = vgui.Create("DPanel")
          pnl:SetHeight(20)
          local icon = vgui.Create("DImage", pnl)
          icon:SetPos(2, 2)
          icon:SetSize(16, 16)
          icon:SetImage("icon16/page.png")
          surface.SetFont("Default")
          local btn = vgui.Create("DButton", pnl)
          btn:SetPos(20, 1)
          btn:SetSize(surface.GetTextSize(name) + 5, 18)
          btn:SetText(name)
          btn.Paint = function() end

          btn.DoClick = function()
            local menu = DermaMenu()
            menu:AddOption("", function() end)

            menu:AddOption("Load", function()
              local data = file.Read(dir .. fileName)
              if not isstring(data) then return end
              local tabl = glon.decode(data)
              if not tabl then return end
              wep.Pixels = tabl
            end)

            menu:AddOption("Delete", function()
              file.Delete(dir .. fileName)
              pnl:Remove()
            end)

            menu:Open()
          end

          filePnl:AddItem(pnl)
        end
      end

      RefreshFiles()
      local btnPanel = vgui.Create("DPanelList", menu)
      btnPanel:SetPos(x, menu:GetTall() - 32)
      btnPanel:SetSize(width, 27)
      btnPanel:SetPadding(2)
      btnPanel:SetSpacing(2)
      btnPanel:EnableHorizontal(true)
      local save = vgui.Create("DButton")
      save:SetText("Save")

      save.DoClick = function()
        local menu = vgui.Create("DFrame")
        menu:SetSize(128, 96)
        menu:SetTitle("Save")
        menu:SetPos(ScrW() / 2 - 64, ScrH() - 126)
        menu:MakePopup()
        local text = vgui.Create("DLabel", menu)
        text:SetPos(6, 22)
        text:SetFont("Default")
        text:SetText("Enter name")
        local entry = vgui.Create("DTextEntry", menu)
        entry:SetPos(5, 42)
        entry:SetSize(menu:GetWide() - 10, 24)
        entry:RequestFocus()
        local btn = vgui.Create("DButton", menu)
        btn:SetPos(5, 71)
        btn:SetSize(menu:GetWide() - 10, 20)
        btn:SetText("Save")

        btn.DoClick = function()
          local data = glon.encode(wep.Pixels)
          if not isstring(data) then return end
          file.CreateDir("pixel_weapon")
          file.Write("pixel_weapon/" .. entry:GetValue() .. ".txt", data)
          print("Saved " .. entry:GetValue() .. " to data/pixel_weapon/" .. entry:GetValue() .. ".txt!")
          RefreshFiles()
          menu:Remove()
        end
      end

      local erase = vgui.Create("DButton")
      erase:SetText("Clear")

      erase.DoClick = function()
        local menu = DermaMenu()
        menu:AddOption("", function() end)

        menu:AddOption("Yes, clear everything", function()
          for i = 1, 32 do
            table.Empty(wep.Pixels[i])
          end
        end)

        menu:Open()
      end

      surface.SetFont("Default")
      local str = "Useful information"
      local useful = vgui.Create("DButton")
      useful:SetText(str)
      useful:SetWidth(surface.GetTextSize(str) + 15)

      useful.DoClick = function()
        local info = {"Right-Click to remove the specific part.", "Hold down C while left clicking to copy a color instead of replacing it.", "The alpha in the color mixer is not working."}

        for i = 1, #info do
          chat.AddText(Color(255, 255, 0), "Info: ", Color(220, 220, 220), info[i])
        end

        chat.PlaySound()
      end

      btnPanel:AddItem(save)
      btnPanel:AddItem(erase)
      btnPanel:AddItem(useful)
      PIXELSWORDMENU = menu
    else
      PIXELSWORDMENU:SetVisible(true)
    end
  end
  net.Receive("ToyBoxReworked_pixel_weapon_menu", Menu)
end