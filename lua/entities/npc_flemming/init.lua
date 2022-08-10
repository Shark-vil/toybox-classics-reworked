AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel("models/humans/group01/male_04.mdl")
  util.PrecacheSound("npc/zombie/zo_attack2.wav")
  self.IsBob = true
  self.Width = self:BoundingRadius() * 1
  self.Speed = 200
  self.Swinged = false
  self.SwingedVoice = false
  self.SwingTimer = 0
  self.VoiceTimer = 0
  self:SetHealth(math.random(92220, 112220))
  self:ManipulateBoneScale(self:LookupBone("ValveBiped.Bip01_Head1"), Vector(2, 2, 2))
end

function ENT:Think()
  self:FindEnemy()
  --self:DidHit()
  self:Hit()

  if self.SwingTimer ~= 0 and self.SwingTimer < CurTime() then
    self.SwingTimer = 0
    --print("Finished.")
    self.Swinged = false
    self.SwingedVoice = false
    self:StartActivity(ACT_RUN)
    self.Speed = 200
    self.loco:SetDesiredSpeed(200)

    return
  end

  --self:StartActivity( ACT_RUN )
  if self.Swinged == true and self.SwingTimer == 0 then
    self.loco:FaceTowards(self:GetNWEntity("enemy"):GetPos())
    --self:SetAngles(Angle(self:GetAngles().p, self:GetNWEntity("enemy"):GetPos():Angle().yaw, self:GetAngles().r))
    self.Speed = 0
    self.loco:SetDesiredSpeed(0)
    self:StartActivity(ACT_IDLE)
    self:ResetSequenceInfo()
    self:ResetSequence("swing")
    self:SetPlaybackRate(3)
    self:EmitSound("vo/npc/male01/hi0" .. math.random(1, 2) .. ".wav")
    self.SwingTimer = CurTime() + self:SequenceDuration()
  end
end

function ENT:RunBehaviour()
  while true do
    if self.Swinged == false then
      self:StartActivity(ACT_RUN)
      self:Move()
      self:EmitSound("vo/npc/male01/hi0" .. math.random(1, 2) .. ".wav")
    end

    coroutine.wait(2)
  end
end

function ENT:Hit()
  local players = player.GetAll()

  for k, v in ipairs(players) do
    local distance = v:GetPos():Distance(self:GetPos())

    if distance < 40 and v:Alive() and self.Swinged == false then
      self.Swinged = true
      v:EmitSound("Flesh.ImpactHard")
      v:TakeDamage(1, self, self)
    elseif distance > 40 then
      self.SwingedVoice = false

      if math.random(1, 3) == 2 and self:Eyes() and self.VoiceTimer ~= 0 and self.VoiceTimer < CurTime() then
        self:EmitSound("vo/npc/male01/hi0" .. math.random(1, 2) .. ".wav")
        self.VoiceTimer = 0
      elseif self.VoiceTimer == 0 then
        self.VoiceTimer = CurTime() + 1
      end
    end
  end
end

function ENT:Move()
  if not IsValid(self:GetNWEntity("enemy")) then return end
  local enemy = self:GetNWEntity("enemy")
  self.loco:SetDesiredSpeed(self.Speed or 200)
  local path = Path("Follow")
  path:Compute(self, enemy:GetPos())
  if not path:IsValid() then return end

  while path:IsValid() and IsValid(enemy) do
    if path:GetAge() > 0.1 then
      path:Compute(self, enemy:GetPos())
    end

    path:Update(self)

    --path:Draw()
    if self.loco:IsStuck() then
      self:HandleStuck()

      return
    end

    coroutine.yield()
  end

  return
end

function ENT:Eyes()
  if not IsValid(self:GetNWEntity("enemy")) then return end
  local enemy = self:GetNWEntity("enemy")
  if not enemy:Alive() then return true end
  local ViewEnt = enemy:GetViewEntity()
  --if ViewEnt == self.Victim and not self:HasVictimLOS() then return false end
  local fov = enemy:GetFOV()
  local Disp = self:GetPos() - ViewEnt:GetPos()
  local Dist = Disp:Length()
  local MaxCos = math.abs(math.cos(math.acos(Dist / math.sqrt(Dist * Dist + self.Width * self.Width)) + fov * (math.pi / 180)))
  Disp:Normalize()
  if Disp:Dot(ViewEnt:EyeAngles():Forward()) > MaxCos then return true end

  return false
end

function ENT:FindEnemy()
  local players = player.GetAll()
  local distance = 9999
  local target = players[1]

  for k, v in ipairs(players) do
    local distanceplayer = v:GetPos():Distance(self:GetPos())

    if distance > distanceplayer then
      distance = distanceplayer
      target = v
    end
  end

  --print(player:Nick().." is the closest!")
  self:SetNWEntity("enemy", target)

  return target
end

function ENT:OnRemove()
  local flemming = ents.Create(self:GetClass())
  if not IsValid(self) then return end -- doesn't exist!
  if not IsValid(flemming) then return end
  flemming:SetPos(self:GetPos())
  flemming:SetAngles(self:GetAngles())
  flemming:SetMaterial(self:GetMaterial())
  flemming:SetColor(self:GetColor())
  flemming:SetName(self:GetName())
  flemming:SetModel(self:GetModel())
  flemming:SetNoDraw(true)

  timer.Simple(10, function()
    -- you won fair and square, guess i'm gone!
    if isentity(flemming) and IsValid(flemming) then
      flemming:SetNoDraw(false)
      flemming:Activate()
      flemming:Spawn()
    end
  end)
end