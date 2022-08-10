include("shared.lua")
language.Add("metropolice_mask", "Metropolice Mask")
language.Add("Undone_metropolice_mask", "Undone Metropolice Mask")

local UnitNames = {"defender", "hero", "jury", "king", "line", "patrol", "quick", "roller", "stick", "tap", "union", "victor", "xray", "yellow", "vice"}

local Numbers = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

local overwatch = "npc/overwatch/radiovoice/"
local On = "on3"
local Off = "off2"
local LostSignal = "lostbiosignalforunit"
local RADIO_OFF = 0
local RADIO_ONHOLD = 1
local RADIO_ENABLED = 2
local RADIO_ON = 3
local RADIO_DAMAGEREPORT = 4
local copradio = {}
copradio.Queue = {}
copradio.Duration = 0
copradio.State = RADIO_OFF
copradio.NextThink = 0

copradio.Enable = function(self, delay)
  if self.State > RADIO_OFF then return end
  self.State = RADIO_ONHOLD

  timer.Simple(delay, function()
    self.State = RADIO_ENABLED
  end)
end

copradio.Disable = function(self)
  self.State = RADIO_OFF
end

copradio.Add = function(self, sound)
  table.insert(self.Queue, sound)
end

copradio.Pause = function(self, n)
  n = n or 1

  for i = 1, n do
    table.insert(self.Queue, "_comma")
  end
end

copradio.Decrement = function(self)
  self.Queue[1] = nil

  for i = 1, #self.Queue do
    self.Queue[i - 1] = self.Queue[i]
  end

  self.Queue[#self.Queue] = nil
end

local function ToRadio(u)
  copradio:Add(Numbers[u + 1])
end

net.Receive("ToyBoxReworked_MPMask", function()
  copradio:Enable(3.4)
  copradio:Add(table.Random(UnitNames))
  ToRadio(math.random(0, 9))
  copradio:Pause()
end)

hook.Add("Think", "MPMask", function()
  if not (copradio.State > RADIO_ONHOLD) then return end
  if not (CurTime() > copradio.NextThink) then return end
  local path

  if #copradio.Queue == 0 then
    path = overwatch .. Off
    copradio:Disable()
  elseif copradio.State == RADIO_ENABLED then
    path = overwatch .. On
    copradio.State = RADIO_ON
  elseif copradio.State == RADIO_ON then
    path = overwatch .. LostSignal
    copradio.State = RADIO_DAMAGEREPORT
  elseif copradio.State == RADIO_DAMAGEREPORT then
    path = overwatch .. copradio.Queue[1]
    copradio:Decrement()
  end

  path = path .. ".wav"
  LocalPlayer():EmitSound(path, 80)
  copradio.NextThink = CurTime() + SoundDuration(path)
end)