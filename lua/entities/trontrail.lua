AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = true
ENT.Category = "Toybox Classics"
ENT.PrintName = "TRON Trail"
ENT.Author = "mahalis"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.MaxTrailLength = 2000
ENT.TrailBaseLength = 100
ENT.MaxTrailHistory = 120
ENT.TrailHeight = 50

function ENT:SaveCurrentPosition()
  self.CurrentPositionIndex = self.CurrentPositionIndex + 1

  if self.CurrentPositionIndex > self.MaxTrailHistory then
    self.CurrentPositionIndex = 1
  end

  self.OldPositions[self.CurrentPositionIndex] = self:GetPos()
  self.OldUps[self.CurrentPositionIndex] = self:GetUp()
end

function ENT:UpdateTrail()
  local pos = self:GetPos()

  if #self.OldPositions < 3 then
    self:SaveCurrentPosition()
  else
    local index = self.CurrentPositionIndex - 1
    local prevIndex = self.CurrentPositionIndex - 2

    if index <= 0 then
      index = index + #self.OldPositions
    end

    if prevIndex <= 0 then
      prevIndex = prevIndex + #self.OldPositions
    end

    local lastPos = self.OldPositions[index]
    local lastSegmentDirection = (lastPos - self.OldPositions[prevIndex]):GetNormal()
    local toLastPos = pos - lastPos

    if (toLastPos:GetNormal():Dot(lastSegmentDirection) < (0.98 + math.Clamp(1 - (40 / toLastPos:Length()), 0, 1) * 0.02) and pos:Distance(lastPos) > 10) or pos:Distance(lastPos) > 250 then
      self:SaveCurrentPosition()
    else -- no position change? well... check the velocity. maybe we bounced off of something.
      if self.LastVelocity:Length() > 1 then
        if self:GetVelocity():GetNormal():Dot(self.LastVelocity:GetNormal()) < 0.9 then
          self:SaveCurrentPosition()
        elseif self:GetUp():Dot(self.LastUp) < 0.85 then
          -- or maybe we're rotating.
          self:SaveCurrentPosition()
        end
      end
    end
  end

  self.LastVelocity = self:GetVelocity()
  self.LastUp = self:GetUp()
end

local KillDelay
local DeathResolution

if SERVER then
  KillDelay = 0.1
  DeathResolution = 3
  ENT.LastKilledTime = 0
  trailShouldDissolveEntities = CreateConVar("tron_trail_dissolvethings", "1")
  trailShouldKillPlayers = CreateConVar("tron_trail_killplayers", "1")
end

local ribbonMat
local trailMat
local baseMat
local allowedColors

if CLIENT then
  ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
  ribbonMat = Material("effects/lighttrail_warp")
  trailMat = Material("effects/lighttrail")

  baseMat = CreateMaterial("RibbonBase", "UnlitGeneric", {
    ["$basetexture"] = "particle/particle_square_gradient",
    ["$additive"] = 1,
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$nocull"] = 1,
    ["$overbrightfactor"] = 16
  })

  allowedColors = {Vector(1, .6, .6), Vector(1, .8, .6), Vector(1, 1, .6), Vector(.8, 1, .6), Vector(.6, 1, .8), Vector(.6, .8, 1), Vector(.8, .6, 1), Vector(1, .6, .8), Vector(.8, .9, 1)}
end

function ENT:Initialize()
  self.OldPositions = {}
  self.OldUps = {}
  self.CurrentPositionIndex = 0
  self.LastVelocity = Vector(0, 0, 0)
  self.LastUp = Vector(0, 0, 1)

  if SERVER then
    self:SetModel("models/props_trainstation/trainstation_post001.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local dissolver = ents.Create("env_entity_dissolver")
    dissolver:SetKeyValue("magnitude", "0")
    dissolver:SetKeyValue("dissolvetype", "1")
    self:DeleteOnRemove(dissolver)
    self.Dissolver = dissolver
    local phy = self:GetPhysicsObject()

    if phy:IsValid() then
      phy:SetMass(100)
    end
  else
    self:SetRenderBoundsWS(Vector(-10000, -10000, -10000), Vector(10000, 10000, 10000))
    self:SetModelScale(0.9)
    trailMat:SetInt("$overbrightfactor", 4)
    self:DrawShadow(false)
  end
end

function ENT:Think()
  self:NextThink(CurTime() + 0.03)
  self:UpdateTrail()

  if SERVER then
    if not trailShouldDissolveEntities:GetBool() and not trailShouldKillPlayers:GetBool() then return end

    if #self.OldPositions > 1 and CurTime() > self.LastKilledTime + KillDelay then
      self.LastKilledTime = CurTime()
      local totalLength = 0
      local trd = {}

      trd.filter = {self, self:GetParent()}

      --trd.maxs = Vector(1, 1, self.TrailHeight / 2)
      --trd.mins = trd.maxs * -1
      local crossedEntities = {}
      local crossedPlayers = {}

      for i = 0, #self.OldPositions - 2, 2 do
        if totalLength > self.MaxTrailLength then break end
        local index = self.CurrentPositionIndex - i
        local midIndex = index - 1
        local prevIndex = index - 2

        if index <= 0 then
          index = index + #self.OldPositions
        end

        if midIndex <= 0 then
          midIndex = midIndex + #self.OldPositions
        end

        if prevIndex <= 0 then
          prevIndex = prevIndex + #self.OldPositions
        end

        local pos1 = i == 0 and self:GetPos() or self.OldPositions[index]
        local midPos = self.OldPositions[midIndex]
        local pos2 = self.OldPositions[prevIndex]
        local up1 = (i == 0 and self:GetUp() or self.OldUps[index]) * self.TrailHeight
        local up2 = self.OldUps[prevIndex] * self.TrailHeight
        local segment = pos2 - pos1
        local segmentLength = (pos2 - midPos):Length() + (midPos - pos1):Length()

        if totalLength + segmentLength > self.MaxTrailLength then
          local segmentFraction = (self.MaxTrailLength - totalLength) / segmentLength
          pos2 = pos1 + segment * segmentFraction
          up2 = up1 * (1 - segmentFraction) + up2 * segmentFraction
        end

        totalLength = totalLength + segmentLength

        if totalLength > self.TrailBaseLength and (segmentLength > 8 or up1:Dot(up2) < 0.8) then
          for j = 0, DeathResolution do
            trd.start = pos1 + up1 * j / DeathResolution
            trd.endpos = pos2 + up2 * j / DeathResolution
            local trace = util.TraceHull(trd)
            local ent = trace.Entity

            if trace.HitNonWorld and IsValid(ent) and ((ent:IsPlayer() and trailShouldKillPlayers:GetBool()) or (not ent:IsPlayer() and trailShouldDissolveEntities:GetBool())) and trace.HitPos:Distance(self:GetPos()) > self.TrailBaseLength then
              trd.filter[#trd.filter + 1] = ent

              if ent:IsPlayer() then
                crossedPlayers[#crossedPlayers + 1] = ent
              else
                crossedEntities[#crossedEntities + 1] = ent
              end
            end
          end
        end
      end

      if #crossedEntities > 0 then
        for _, ent in ipairs(crossedEntities) do
          ent:SetName("tron_tobedissolved")

          if ent:IsVehicle() and IsValid(ent:GetDriver()) then
            local pl = ent:GetDriver()

            if trailShouldKillPlayers:GetBool() then
              if IsValid(self:GetOwner()) then
                util.BlastDamage(self, self:GetOwner(), pl:LocalToWorld(pl:OBBCenter()), 1, 500)
              else
                pl:Kill()
              end
            else -- just force 'em out of the vehicle
              pl:ExitVehicle()
            end
          end
        end

        self.Dissolver:Fire("Dissolve", "tron_tobedissolved")
      end

      if #crossedPlayers > 0 and trailShouldKillPlayers:GetBool() then
        for _, pl in ipairs(crossedPlayers) do
          if IsValid(self:GetOwner()) then
            util.BlastDamage(self, self:GetOwner(), pl:LocalToWorld(pl:OBBCenter()), 1, 500)
          else
            pl:Kill()
          end
        end
      end
    end
  end

  return true
end

function ENT:Draw()
  self:DrawModel()
  if #self.OldPositions < 2 then return end
  render.UpdateRefractTexture()
  render.SetMaterial(ribbonMat)
  self:DrawTrailComponent()
  local r = self:GetColor().r
  local g = self:GetColor().g
  local b = self:GetColor().b
  local a = self:GetColor().a
  r = r / 255
  g = g / 255
  b = b / 255
  -- figure out which of the allowed colors it's closest to
  local closestColor = allowedColors[#allowedColors]
  local closestColorDistance = 3

  for _, c in ipairs(allowedColors) do
    local colorDistance = math.abs(r - c.x) + math.abs(g - c.y) + math.abs(b - c.z)

    if colorDistance < closestColorDistance then
      closestColor = c
      closestColorDistance = colorDistance
    end
  end

  trailMat:SetVector("$color", closestColor)
  render.SetMaterial(trailMat)
  self:DrawTrailComponent()
  local basePos = self:GetPos() - self:GetUp() * self.TrailHeight * 0.05
  local baseUp = self:GetUp() * self.TrailHeight * 1.1
  --local baseDirection = (self.OldPositions[self.CurrentPositionIndex] - self:GetPos()):GetNormal()
  local baseDirection = Vector(0, 0, 0)
  local accumulatedLength = 0

  for i = 0, #self.OldPositions - 2 do
    local index = self.CurrentPositionIndex - i
    local prevIndex = self.CurrentPositionIndex - i - 1

    if index <= 0 then
      index = index + #self.OldPositions
    end

    if prevIndex <= 0 then
      prevIndex = prevIndex + #self.OldPositions
    end

    local pos1 = i == 0 and self:GetPos() or self.OldPositions[index]
    local pos2 = self.OldPositions[prevIndex]
    local segment = pos2 - pos1
    local segmentLength = segment:Length()

    if accumulatedLength + segment:Length() > 10 then
      local segmentFraction = (10 - accumulatedLength) / segmentLength
      pos2 = pos1 + segment * segmentFraction
      segment = pos2 - pos1
    end

    baseDirection = baseDirection + segment
    accumulatedLength = accumulatedLength + segmentLength
    if accumulatedLength > 10 then break end
  end

  baseDirection:Normalize()
  render.SetMaterial(baseMat)

  for i = 1, 3 do
    render.DrawQuad(basePos - baseDirection * 10, basePos + baseDirection * 40, basePos + baseUp + baseDirection * 40, basePos + baseUp - baseDirection * 10)
  end
end

function ENT:DrawTrailComponent()
  local up = Vector(0, 0, self.TrailHeight / 2)
  local totalLength = 0

  for i = 0, #self.OldPositions - 2 do
    if totalLength > self.MaxTrailLength then break end
    local index = self.CurrentPositionIndex - i
    local prevIndex = self.CurrentPositionIndex - i - 1

    if index <= 0 then
      index = index + #self.OldPositions
    end

    if prevIndex <= 0 then
      prevIndex = prevIndex + #self.OldPositions
    end

    local pos1 = i == 0 and self:GetPos() or self.OldPositions[index]
    local pos2 = self.OldPositions[prevIndex]
    local up1 = (i == 0 and self:GetUp() or self.OldUps[index]) * self.TrailHeight
    local up2 = self.OldUps[prevIndex] * self.TrailHeight
    local segment = pos2 - pos1
    local segmentLength = segment:Length()

    if totalLength + segmentLength > self.MaxTrailLength then
      local segmentFraction = (self.MaxTrailLength - totalLength) / segmentLength
      pos2 = pos1 + segment * segmentFraction
      up2 = up1 * (1 - segmentFraction) + up2 * segmentFraction
    end

    totalLength = totalLength + segmentLength
    render.DrawQuad(pos1 + up1, pos2 + up2, pos2, pos1)
  end
end

function ENT:SpawnFunction(ply, tr)
  local t = ents.Create(ClassName)
  t:SetPos(tr.HitPos + tr.HitNormal * 20)

  if IsValid(ply) then
    t.Owner = ply
  end

  t:Spawn()

  return t
end