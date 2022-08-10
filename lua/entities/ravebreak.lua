AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"
ENT.PrintName = "Ravebreak Radio"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SpawnFunction(ply, tr)
  if not tr.Hit then return end
  local SpawnPos = tr.HitPos + tr.HitNormal * 5
  local ent = ents.Create(ClassName)
  ent:SetPos(SpawnPos)
  ent:Spawn()
  ent:Activate()
  ent:PhysWake()

  return ent
end

if SERVER then
  function ENT:Initialize()
    --resource.AddFile("sound/ravebreak.mp3")
    --but this is a toybox entity!
    self.Entity:SetModel("models/props_lab/citizenradio.mdl")
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:SetUseType(SIMPLE_USE)
  end

  function ENT:Use(pl)
    pl:ConCommand("ravebreak_now")
  end

  function ENT:OnRemove()
    RaveEnd(true)
  end

  function RaveCommand(pl, cmd, args)
    if not Raving then
      RaveBreak()
    else
      pl:ChatPrint("You're already raving dude!")
    end
  end

  concommand.Add("ravebreak_now", RaveCommand)

  function RaveBreak()
    net.Start("ToyBoxReworked_RaveBreak")
    net.Broadcast()
    Raving = true

    -- 1 second buildup
    timer.Simple(1, function()
      hook.Add("Think", "RaveThink", RaveThink)
    end)

    timer.Simple(24, function()
      RaveEnd(false)
    end)
  end

  function RaveEnd(stopsounds)
    if not Raving then return end
    hook.Remove("Think", "RaveThink")
    net.Start("ToyBoxReworked_RaveEnd")
    net.WriteBool(stopsounds)
    net.Broadcast()
    Raving = false
  end

  function RaveThink()
    for k, v in ipairs(player.GetAll()) do
      v:PrintMessage(HUD_PRINTCENTER, "RAVE BREAK!")
    end
  end
end

if CLIENT then
  ENT.DrawString = {"R", "A", "V", "E", "B", "R", "E", "A", "K", " ", " "}

  ENT.NextSwitch = 0

  function ENT:Initialize()
    language.Add(ClassName, "Ravebreak Radio")
  end

  function ENT:Draw()
    self:DrawModel()
    -- parts of this code come from the Time Box by Microosoft. Saves me the trouble of having to measure it out
    local TargetAngle = self:GetAngles()
    local TimePos = self:GetPos() + (self:GetForward() * 8.5) + (self:GetRight() * 5.4) + (self:GetUp() * 14.8)
    local BoxPos = self:GetPos() + (self:GetForward() * 8.4) + (self:GetRight() * 5.8) + (self:GetUp() * 15.5)
    TargetAngle:RotateAroundAxis(TargetAngle:Right(), -90)
    TargetAngle:RotateAroundAxis(TargetAngle:Up(), 90)
    cam.Start3D2D(BoxPos, TargetAngle, 0.25)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, 70, 15)
    cam.End3D2D()
    cam.Start3D2D(TimePos, TargetAngle, 0.25)

    for k, v in ipairs(self.DrawString) do
      if k > 8 then break end
      local col = Color(255, 0, 0, 255)
      local mod = k % 5

      if mod == 0 then
        col = Color(255, 255, 0, 255)
      elseif mod == 1 then
        col = Color(0, 0, 255, 255)
      elseif mod == 2 then
        col = Color(0, 255, 0, 255)
      elseif mod == 3 then
        col = Color(0, 255, 255, 255)
      end

      draw.DrawText(v, "Default", (k - 1) * 8, 0, col)
    end

    cam.End3D2D()
  end

  function ENT:Think()
    if self.NextSwitch < CurTime() then
      self.NextSwitch = CurTime() + 0.25
      local toswitch = self.DrawString[1]
      table.remove(self.DrawString, 1)
      table.insert(self.DrawString, toswitch)
    end
  end

  local RAVESOUND = "ravebreak.mp3"

  function RaveBreak()
    RunConsoleCommand("stopsounds")

    timer.Simple(0.1, function()
      surface.PlaySound(RAVESOUND)
    end)

    timer.Simple(1, function()
      hook.Add("RenderScreenspaceEffects", "RaveDraw", RaveDraw)
    end)
  end
  net.Receive("ToyBoxReworked_RaveBreak", RaveBreak)

  local lightCnt = 1
  local lastRaveUpdate = 0

  function RaveDraw()
    local MySelf = LocalPlayer()
    local ang = MySelf:EyeAngles()
    ang.p = 30 * math.sin((CurTime() % 2 * math.pi) * 5)
    MySelf:SetEyeAngles(ang)

    if lastRaveUpdate < CurTime() - 0.5 then
      lastRaveUpdate = CurTime()
      local last = lightCnt

      while last == lightCnt do
        lightCnt = math.random(1, #RaveColTab)
      end
    end

    DrawColorModify(RaveColTab[lightCnt])
  end

  function RaveEnd()
    if net.ReadBool() then
      RunConsoleCommand("stopsounds")
    end

    hook.Remove("RenderScreenspaceEffects", "RaveDraw")
  end
  net.Receive("ToyBoxReworked_RaveEnd", RaveEnd)

  RaveColTab = {
    {
      ["$pp_colour_addr"] = 0.05,
      ["$pp_colour_addg"] = 0,
      ["$pp_colour_addb"] = 0.05,
      ["$pp_colour_brightness"] = 0.1,
      ["$pp_colour_contrast"] = 1,
      ["$pp_colour_colour"] = 0,
      ["$pp_colour_mulr"] = 10,
      ["$pp_colour_mulg"] = 0,
      ["$pp_colour_mulb"] = 10
    },
    {
      ["$pp_colour_addr"] = 0,
      ["$pp_colour_addg"] = 0,
      ["$pp_colour_addb"] = 0.05,
      ["$pp_colour_brightness"] = 0.1,
      ["$pp_colour_contrast"] = 1,
      ["$pp_colour_colour"] = 0,
      ["$pp_colour_mulr"] = 0,
      ["$pp_colour_mulg"] = 0,
      ["$pp_colour_mulb"] = 20
    },
    {
      ["$pp_colour_addr"] = 0,
      ["$pp_colour_addg"] = 0.05,
      ["$pp_colour_addb"] = 0,
      ["$pp_colour_brightness"] = 0.1,
      ["$pp_colour_contrast"] = 1,
      ["$pp_colour_colour"] = 0,
      ["$pp_colour_mulr"] = 0,
      ["$pp_colour_mulg"] = 20,
      ["$pp_colour_mulb"] = 0
    },
    {
      ["$pp_colour_addr"] = 0.05,
      ["$pp_colour_addg"] = 0,
      ["$pp_colour_addb"] = 0,
      ["$pp_colour_brightness"] = 0.1,
      ["$pp_colour_contrast"] = 1,
      ["$pp_colour_colour"] = 0,
      ["$pp_colour_mulr"] = 20,
      ["$pp_colour_mulg"] = 0,
      ["$pp_colour_mulb"] = 0
    },
    {
      ["$pp_colour_addr"] = 0.05,
      ["$pp_colour_addg"] = 0.05,
      ["$pp_colour_addb"] = 0,
      ["$pp_colour_brightness"] = 0.1,
      ["$pp_colour_contrast"] = 1,
      ["$pp_colour_colour"] = 0,
      ["$pp_colour_mulr"] = 10,
      ["$pp_colour_mulg"] = 10,
      ["$pp_colour_mulb"] = 0
    }
  }
end