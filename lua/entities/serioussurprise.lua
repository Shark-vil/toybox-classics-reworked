AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Serious Surprise"
ENT.Spawnable = true
ENT.Category = "Toybox Classics"

-- There's going to be the most flaws in this one as the original code is unreadable to me and everyone I know
function ENT:Initialize()
  self:SetModel("models/props_lab/monitor02.mdl")

  if SERVER then
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
  end

  self.Created = CurTime()

  if CLIENT then
    self.NextFlicker = self.Created + 5
    self.FlickerSpacing = 0.2
  end

  if SERVER then
    if not navmesh.GetAllNavAreas()[1] then
      self:GetNWEntity("owner", self):PrintMessage(HUD_PRINTTALK, "There is no navmesh on the map! Create one by doing nav_generate in console!")
      local explosion = ents.Create("env_explosion")
      explosion:SetPos(self:GetPos() + self:OBBCenter())
      explosion:Spawn()
      explosion:Fire("explode")
      self:Remove()
    end
  end
end

function ENT:CheckOwner()
  if self:GetNWFloat("wave") ~= 0 then return end
  --if CLIENT then return end
  local ply = self:GetNWEntity("owner", self)
  if not IsValid(ply) then return end

  local tracefull = util.TraceLine({
    start = ply:EyePos(),
    endpos = self:GetPos(),
    filter = {ply},
    ignoreworld = false
  })

  if tracefull.HitWorld then
    self:SetNWFloat("wave", 1)

    for k, v in ipairs(player.GetAll()) do
      if not playedSound then
        v:EmitSound("vo/npc/male01/uhoh.wav", 100, 81.2)
        playedSound = true
      end
    end
  end
end

function ENT:SpawnKamikaze()
  if not SERVER or self:GetNWFloat("spawntimer") > CurTime() or self:GetNWFloat("wave") ~= 1 then return end
  local navmesh = table.Random(navmesh.GetAllNavAreas())

  if navmesh:IsUnderwater() then
    self:SpawnKamikaze()

    return
  end

  local pos = navmesh:GetRandomPoint()
  --if util.QuickTrace(self:GetOwner():EyePos(), pos, {self:GetOwner()}).HitPos:Distance(pos) > 5 then
  debugoverlay.Line(Vector(0, 0, 0), pos, 1, Color(0, 255, 0), false)
  self:SetNWFloat("spawntimer", CurTime() + 3)
  local kamikaze = ents.Create("npc_kamikaze")
  kamikaze:SetPos(pos)
  kamikaze:Spawn()
  kamikaze:Activate()
  kamikaze:SetOwner(self)
  --end
end

function ENT:SpawnFunction(ply, tr)
  if not tr.Hit then return end
  local SpawnPos = tr.HitPos + tr.HitNormal * 16

  for k, v in ipairs(player.GetAll()) do
    v:Give("weapon_tmrcolt")
  end

  ply:SelectWeapon("weapon_tmrcolt")
  local ent = ents.Create(ClassName)
  ent:SetPos(SpawnPos)
  ent:SetNWEntity("owner", ply)
  ent:Spawn()
  ent:Activate()
  ent:GetPhysicsObject():Wake()

  return ent
end

function ENT:Think()
  if CLIENT then
    if CurTime() >= self.NextFlicker then
      self.NextFlicker = CurTime() + self.FlickerSpacing
      self.FlickerSpacing = self.FlickerSpacing * 0.9
      self.LogoOn = math.random(0, 1) == 1
    end
  end

  if SERVER then end --print(self:GetOwner())
  self:CheckOwner()
  self:SpawnKamikaze()
end

function ENT:OnRemove()
  if SERVER and navmesh.GetAllNavAreas()[1] then
    for k, v in ipairs(player.GetAll()) do
      v:PrintMessage(HUD_PRINTTALK, "Your score: " .. self:GetNWFloat("score"))
      v:PrintMessage(HUD_PRINTCENTER, "Your score: " .. self:GetNWFloat("score"))
    end

    for k, v in ipairs(ents.FindByClass("npc_kamikaze")) do
      if v:GetNWEntity("owner", self) == self then
        v:Remove()
      end
    end
  end
end

if CLIENT then
  local tex = surface.GetTextureID("ghor/sam_bomb")
  --local screenpos = Vector(9.7260, -8.6541, 22.2902)
  local screenpos = Vector(10.1260, -8.6541, 22.5202)
  --local screenpos = Vector(11.8173, -8.9121, 11.1186)
  --local screenpos = Vector(11.7173, -8.9121, 11.1186)
  local color_white = Color(255, 255, 255, 255)
  local color_logo = Color(200, 200, 200, 200)

  function ENT:Draw()
    self:DrawModel()
    if not self.LogoOn then return end
    local ang = self:GetAngles()
    local up = ang:Up()
    local rt = ang:Right()
    local fw = ang:Forward()
    ang:RotateAroundAxis(up, 90)
    ang:RotateAroundAxis(rt, -83)
    local pos = self:LocalToWorld(screenpos)
    cam.Start3D2D(pos, ang, 0.1)
    surface.SetDrawColor(color_logo)
    surface.SetTexture(tex)
    surface.DrawTexturedRect(38, 20, 96, 96)
    cam.End3D2D()
  end
end

hook.Add("PlayerDeath", "Kamikaze_PlayerDeath", function()
  local dead = 1 -- hack to get around 1st player not being counted

  for k, v in ipairs(player.GetAll()) do
    if not v:Alive() then
      dead = dead + 1
    end
  end

  if dead == player.GetCount() then
    for k, v in ipairs(ents.FindByClass("serioussurprise")) do
      v:Remove()
    end
  end
end)