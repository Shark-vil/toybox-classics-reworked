include("shared.lua")
language.Add("goodbye", "Goodbye")
surface.CreateFont("Arial", {})

net.Receive("ToyBoxReworked_GoodbyePack", function()
  local ent = net.ReadEntity()
  if not IsValid(ent) then return end
  ent.Packed = net.ReadInt(32)
end)

net.Receive("ToyBoxReworked_GoodbyeDie", function()
  local ent = net.ReadEntity()
  if not IsValid(ent) then return end
  LocalPlayer().Dramatic = true
  LocalPlayer().DramaticTime = CurTime()
  LocalPlayer().DramaticEnt = ent
  LocalPlayer().DramaticMusic = CreateSound(LocalPlayer(), "goodbye/farwell.mp3")
  LocalPlayer().DramaticMusic:Play()
  --holy shit this is the worst code ever, but i don't give a damn - its 5am
  LocalPlayer().Messages = {}

  local function DramaticMsg(msg)
    if not LocalPlayer().Messages then return end

    local message = {
      Message = msg,
      Time = CurTime()
    }

    table.insert(LocalPlayer().Messages, message)
  end

  DramaticMsg("After so many bouncy entities...")

  timer.Simple(3, function()
    DramaticMsg("We're compelled to leave ToyBox.")
  end)

  timer.Simple(6, function()
    DramaticMsg("Waiting, we'll be there...")
  end)

  timer.Simple(9, function()
    DramaticMsg("For when the ToyBox goes multiplayer.")
  end)

  timer.Simple(12, function()
    DramaticMsg("That will be the day...")
  end)

  timer.Simple(15, function()
    DramaticMsg("Until then.  This is our goodbye. :(")
  end)
end)

net.Receive("ToyBoxReworked_GoodbyeDieRemove", function()
  LocalPlayer().Dramatic = false
  LocalPlayer().DramaticEnt = nil

  if LocalPlayer().DramaticMusic then
    LocalPlayer().DramaticMusic:Stop()
    LocalPlayer().DramaticMusic = nil
  end

  LocalPlayer().Messages = nil
end)

hook.Add("CalcView", "DramaticCalcView", function(ply, pos, ang, fov)
  if IsValid(ply.DramaticEnt) then
    local pos = ply.DramaticEnt:GetPos() + Vector(0, 0, 10)
    local dist = 150
    local center = pos
    local offset = center + ang:Forward() * -dist

    local tr = util.TraceLine({
      start = center,
      endpos = offset,
      filter = ply.DramaticEnt
    })

    if tr.Fraction < 1 then
      dist = dist * tr.Fraction
    end

    return {
      ["origin"] = center + (ang:Forward() * -dist * 0.95),
      ["angles"] = Angle(ang.p + 2, ang.y, ang.r)
    }
  end
end)

hook.Add("HUDShouldDraw", "DramaticHUDHide", function(name)
  if LocalPlayer().Dramatic then
    local HiddenHud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudCrosshair", "CHudWeapon", "CHudChat"}

    for _, v in ipairs(HiddenHud) do
      if name == v then return false end
    end
  end
end)

hook.Add("HUDPaint", "DramaticHUD", function()
  if LocalPlayer().Dramatic then
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, ScrW(), 150)
    surface.DrawRect(0, ScrH() - 150, ScrW(), 150)

    if LocalPlayer().Messages then
      for k, v in ipairs(LocalPlayer().Messages) do
        local timer = CurTime() - v.Time

        if timer > 3 then
          timer = 3
        end

        if v.Time + 3 > CurTime() then
          timer = v.Time + 3 - CurTime()
        end

        local c = Color(250, 255, 255, 255 * timer)

        if c.a <= 0 then
          c.a = 0
        end

        draw.SimpleTextOutlined(v.Message, "Arial", ScrW() / 2, (ScrH() / 2) + 150, c, 1, 1, 1, Color(0, 0, 0, c.a))

        if v.Time + 3 < CurTime() then
          table.remove(LocalPlayer().Messages, k)
        end
      end
    end
  end
end)

hook.Add("RenderScreenspaceEffects", "DramaticEffects", function()
  if LocalPlayer().Dramatic then
    DrawColorModify{
      ["$pp_colour_addr"] = 0,
      ["$pp_colour_addg"] = (10 / 255) * 4,
      ["$pp_colour_addb"] = (30 / 255) * 4,
      ["$pp_colour_brightness"] = -.25,
      ["$pp_colour_contrast"] = 1.5,
      ["$pp_colour_colour"] = .32,
      ["$pp_colour_mulr"] = 0,
      ["$pp_colour_mulg"] = 0,
      ["$pp_colour_mulb"] = 0
    }

    DrawBloom(.75, 1, .65, .65, 3, 0, 0, 72 / 255, 1)
  end
end)