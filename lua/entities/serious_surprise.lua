AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Serious Surprise"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = false
ENT.Category = "Toybox Classics"

if CLIENT then
  ENT.NextFlicker = 0
  ENT.FlickerSpacing = 0.2
end

--=================================================================================//
--
--	Entity List structure
--
--		A structure containing a table of entities that automatically updates
--			itself whenever one if its entities is removed. Handy.
--			
--
--=================================================================================//
if not _G.Ghor then
  _G.Ghor = {} --A namespace to prevent conflicts, which are likely to happen with simple structures like this one.
end

--Dont run this if the system is already initialized!
if not _G.Ghor.CreateEntList then
  local EntList = {}
  EntList.__index = EntList
  --[[
		function EntList:__len()
			return #self.Items;
		end
		
		function EntList:__index(key)
			if (type(key) == "number") then
				return self.Items[key];
			elseif self[key] then
				return self[key];
			else
				return EntList[key];
			end
		end
		]]
  local TableBindsByEntity = {}

  local function OnEntityRemoved(ent)
    local boundLists = TableBindsByEntity[ent]

    for _, v in ipairs(boundLists) do
      v:RemoveEntity(ent)
    end

    table.Empty(boundLists)
    TableBindsByEntity[ent] = nil
  end

  --Track this entity.
  function EntList:AddEntity(ent)
    if not table.HasValue(self.Items, ent) then
      table.insert(self.Items, ent)

      if not TableBindsByEntity[ent] then
        TableBindsByEntity[ent] = {}
      end

      table.insert(TableBindsByEntity[ent], self)
    end

    ent:CallOnRemove("Ghor.EntityListRemove", OnEntityRemoved)
  end

  --This entity is no longer of interest to us. Stop tracking it.
  function EntList:RemoveEntity(ent)
    for i, entCompare in ipairs(self.Items) do
      if ent == entCompare then
        table.remove(self.Items, i)

        return
      end
    end
  end

  function EntList:Clean()
    local items = self.Items
    local count = #items
    local i = 1

    while i <= count do
      if not ValidEntity(items[i]) then
        table.remove(items, i)
        count = count - 1
        i = i - 1
      end

      i = i + 1
    end
  end

  function EntList:KillEntities()
    local items = self.Items
    local count = #items

    for i = 1, count do
      local ent = items[1]
      self:RemoveEntity(ent)
      ent:Remove()
    end
  end

  --Destructor
  function EntList:Remove()
    --Remove any references to us for use in entity removal callbacks.
    for _, ent in ipairs(self.Items) do
      for i, listCompare in ipairs(TableBindsByEntity[ent]) do
        if self == listCompare then
          table.remove(TableBindsByEntity, i)
          break
        end
      end
    end

    table.Empty(self.Items)
    table.Empty(self)
  end

  --Constructor
  function _G.Ghor.CreateEntList()
    local self = {}
    setmetatable(self, EntList)
    self.Items = {}

    return self
  end
end

local CreateKamikaze

if SERVER then
  ENT.Score = 0
  local playedSound = false

  function CreateKamikaze(self)
    if not playedSound then
      for k, v in ipairs(player.GetAll()) do
        Entity(1):EmitSound("vo/npc/male01/uhoh.wav", 100, 81.2)
        playedSound = true
      end

      local npc = ents.Create("npc_kamikaze")
      if npc == NULL then return NULL end
      npc:SetPos(self.m_vPos)
      npc:SetKeyValue("squadname", "serioussurprise_kamikaze")
      npc.Spawner = self.m_pOwner.Owner
      --npc.RunSpeed = 750;
      npc:Spawn()

      if SinglePlayer() then
        npc:UpdateEnemyMemory(Entity(1), Entity(1):GetPos())
      end

      return npc
    end

    hook.Add("OnNPCKilled", "SeriousSurpriseNPCDead", function(ent, attacker, inflictor)
      if ent.IsKamikaze and IsValid(ent.Spawner) then
        ent.Spawner.Score = ent.Spawner.Score + 1
      end
    end)

    hook.Add("PlayerDeath", "SeriousSurpriseEnd", function(pl, inflictor, attacker)
      for k, v in ipairs(ents.FindByClass("npc_kamikaze")) do
        v:Remove()
      end
    end)
  end

  function ENT:Initialize()
    self:SetModel("models/props_lab/monitor02.mdl")

    --self:SetModel("models/props_lab/monitor01a.mdl");
    if SERVER then
      self:PhysicsInit(SOLID_VPHYSICS)
    end

    self.Created = CurTime()

    if CLIENT then
      self.NextFlicker = self.Created + 5
    end

    if SERVER then
      self.EntPropagator = Ghor.EntPropagator.CreateEntPropagator()
      self.EntPropagator.Owner = self
      self.EntPropagator.m_iSeedCap = 30
      self.EntPropagator.m_iEntityLimit = 30
      local seed = self.EntPropagator:CreateSeed(vector_origin)
      seed.SpawnEntity = CreateKamikaze
      seed:SetBBox(Vector(-18, -18, 0), Vector(18, 18, 72))
      seed.m_flSpawnDelay = 3
      seed.m_flJumpLength = 600
      seed.m_flGroundDropDistance = 8000
      --seed.m_flRange = 400;
      seed.m_flPenaltyRange = 160
      seed.m_bSimpleVis = true
      self.EntPropagator:AddHitchhiker(seed, Entity(1))
      self.EntPropagator:RemoveSeed(seed)
      local wave = self.EntPropagator:CreateWave()
      wave:SetWaveInterval(10)
      wave:SetWaveIntervalBounds(6, 10)
      wave:SetWaveIntervalModifier(-0.5)
      wave:SetDuration(10)
      wave:SetDurationBounds(10, 16)
      wave:SetDurationModifier(0.5)
      wave:SetTicketResupply(5)
      wave:SetTicketResupplyModifier(1)
      wave:SetTicketResupplyBounds(5, 60)
      wave:SetMaxTicketCount(22)
      wave:SetAvailableSeeds(self.EntPropagator.m_t_pSeeds, 0)
    end
  end

  function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    ply:Give("weapon_tmrcolt")
    ply:SelectWeapon("weapon_tmrcolt")
    local ent = ents.Create(ClassName)
    ent:SetPos(SpawnPos)
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
    else
      self.EntPropagator:Think()
    end
  end

  --Some funnyman somewhere is setting HUD_PRINTTALK/HUD_PRINTCENTER to a string value.
  if type(HUD_PRINTTALK) ~= "number" then
    ErrorNoHalt("HUD_PRINTTALK is incorrect. Should equal 3, was " .. HUD_PRINTTALK)
    HUD_PRINTTALK = 3
  end

  if type(HUD_PRINTTALK) ~= "number" then
    ErrorNoHalt("HUD_PRINTCENTER is incorrect: Should equal 4, was" .. HUD_PRINTCENTER)
    HUD_PRINTTALK = 4
  end

  function ENT:OnRemove()
    if SERVER then
      self.EntPropagator:OnRemove()

      for k, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "Your score: " .. self.Score)
        v:PrintMessage(HUD_PRINTCENTER, "Your score: " .. self.Score)
      end
    end
  end

  if CLIENT then
    local tex = surface.GetTextureID("ghor/sam_bomb")
    --local screenpos = Vector(9.7260, -8.6541, 22.2902);
    local screenpos = Vector(10.1260, -8.6541, 22.5202)
    --local screenpos = Vector(11.8173, -8.9121, 11.1186);
    --local screenpos = Vector(11.7173, -8.9121, 11.1186);
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
      surface.SetFont("ConsoleText")
      --surface.SetTextColor(color_red);
      --surface.SetTextPos(13,0);
      --surface.DrawText("GET SERIOUS");
      cam.End3D2D()
    end
  end

  if not Ghor then
    Ghor = {} --Namespace to prevent conflicts
  end

  if CLIENT then
  elseif not Ghor.EntPropagator then
    --Nothing
    Ghor.EntPropagator = {}
    local shuffleBuffer = {}

    local function ShuffledKeys(tab, results)
      table.CopyFromTo(tab, shuffleBuffer)
      local count = table.getn(shuffleBuffer)

      if results then
        table.Empty(results)
      else
        results = {}
      end

      for k, v in pairs(tab) do
        table.insert(results, math.random(1, #results + 1), k)
      end

      return results
    end

    local function ShuffledValues(tab, results)
      table.CopyFromTo(tab, shuffleBuffer)
      local count = table.getn(shuffleBuffer)

      if results then
        table.Empty(results)
      else
        results = {}
      end

      for k, v in pairs(tab) do
        table.insert(results, math.random(1, #results + 1), v)
      end

      return results
    end

    --A spawning pattern that describes how an entity propagator should handle spawning.
    local Wave = {}
    Wave.__index = Wave

    --===============================================
    -- Enum
    --===============================================
    if not Ghor.Enum then
      Ghor.Enum = {}
    end

    Ghor.Enum["WAVELOCATION_RANDOM"] = 0
    Ghor.Enum["WAVELOCATION_PERSISTENT"] = 1
    Ghor.Enum["WAVELOCATION_PERSISTENT_DELEGATEONLY"] = 2
    Ghor.Enum["WAVELOCATION_FORCED"] = 3
    local WAVELOCATION_RANDOM = _G.Ghor.Enum["WAVELOCATION_RANDOM"]
    local WAVELOCATION_PERSISTENT = _G.Ghor.Enum["WAVELOCATION_PERSISTENT"]
    local WAVELOCATION_PERSISTENT_DELEGATEONLY = _G.Ghor.Enum["WAVELOCATION_PERSISTENT_DELEGATEONLY"]
    local WAVELOCATION_FORCED = _G.Ghor.Enum["WAVELOCATION_FORCED"]
    --===============================================
    -- Member values
    --===============================================
    Wave.m_bActive = false
    Wave.m_iWaveCount = 0 --The number of times we are allowed to spawn. 0 is endless.
    Wave.m_flNextSpawn = 0 --The next time we get to spawn an entity.
    Wave.m_flCompletionTime = 0
    Wave.m_iTicketCount = 0
    Wave.m_iMaxTicketCount = 0
    Wave.m_flNextTicket = 0
    Wave.m_t_pAvailableSeeds = 0
    Wave.m_pSpawnSeed = nil
    Wave.m_flWaveTime = 0 --When our next wave begins.
    Wave.m_flWaveInterval = 0 --How long to wait between our waves.
    Wave.m_flIntervalModify = 0 --How much time to add to/subtract from our respawn time after we finish spawning each wave.
    Wave.m_flMinWaveInterval = 0 --The minimum time between spawns.
    Wave.m_flMaxWaveInterval = 0 --The maximum time between spawns.
    Wave.m_iTicketResupply = 0 --The number of spawn tickets we want to provide for spawning.
    Wave.m_iTicketResupplyModify = 0 --How much to add to/subtract from our per-wave ticket count after we finish spawning each wave.
    Wave.m_iMinTicketResupply = 0 --The minimum number of tickets we can use.
    Wave.m_iMaxTicketResupply = 0 --The maximum number of tickets we can use.
    Wave.m_flDuration = 0 --The amount of time over which a wave takes place. 0 instantaneously spawns the whole wave.
    Wave.m_flDurationModify = 0 --How much to add/subtract to our per-wave duration after we finish spawning each wave.
    Wave.m_flMinDuration = 0 --The minimum duration of this wave.
    Wave.m_flMaxDuration = 0 --The maximum duration of this wave.

    --===============================================
    -- Constructor
    --===============================================
    function _G.Ghor.EntPropagator.CreateWave()
      local self = {}
      setmetatable(self, Wave)

      return self
    end

    --===============================================
    -- Member functions
    --===============================================
    -------------------------------------------------
    -- Update
    -------------------------------------------------
    function Wave:IsActive()
      return self.m_bActive
    end

    function Wave:Begin()
      self.m_bActive = true
      self.m_flCompletionTime = CurTime() + self.m_flDuration

      --self.m_flWaveTime = self.m_flCompletionTime + self.m_flWaveInterval;
      if self.m_iTicketResupply > 1 then
        self.m_flTicketInterval = self.m_flDuration / self.m_iTicketResupply
        self.m_flNextTicket = CurTime() + self.m_flTicketInterval
      else
        self.m_flNextTicket = 0
        self:AddTicketCount(1)
      end

      if (self.m_pSpawnType == WAVELOCATION_PERSISTENT) or (self.m_pSpawnType == WAVELOCATION_PERSISTENT_DELEGATEONLY) then
        self:SelectSeed()
      end
    end

    function Wave:CanSpawn()
      return self.m_iTicketCount > 0
    end

    function Wave:Spawn()
      local spawntype = self.m_iSpawnType
      local seed = self.m_pSpawnSeed or NULL

      if spawntype == WAVELOCATION_RANDOM then
        seed = self:SelectSeed()
        if not seed then return NULL end --No seeds were ready to spawn.

        if not seed:IsValid() then
          self:CleanAvailableSeeds()
          --if (#self.m_t_pAvailableSeeds == 0) then //Something happened, and we ran out of seeds.
          --end

          return NULL
        end
      else
        if not seed:IsValid() then return NULL end

        if spawntype == WAVELOCATION_PERSISTENT_DELEGATEONLY then
          self:AddTicketCount(-1)

          return seed:DelegateSpawn()
        end
      end

      if not seed:IsValid() then return NULL end
      self:AddTicketCount(-1)
      local ent

      if seed:CanSpawn() then
        ent = seed:PerformSpawn()
      else
        ent = seed:DelegateSpawn()
      end

      return ent
    end

    function Wave:Update()
      local ctime = CurTime()

      if (not self.m_bActive) and (self.m_flWaveTime <= ctime) then
        self:Begin()
      end

      if self.m_bActive then
        if self.m_flNextTicket <= ctime then
          self:AddTicketCount(1)
          self.m_flNextTicket = CurTime() + self.m_flTicketInterval
        end

        if self.m_flCompletionTime <= ctime then
          self:End()
        end
      end
    end

    function Wave:End()
      self.m_bActive = false
      --print("Ending wave of duration "..self.m_flDuration.." at time "..CurTime().."/"..self.m_flCompletionTime);
      self.m_flWaveTime = CurTime() + self.m_flWaveInterval
      --Progress the wave attributes.
      self.m_flWaveInterval = math.Clamp(self.m_flWaveInterval + self.m_flIntervalModify, self.m_flMinWaveInterval, self.m_flMaxWaveInterval)
      self.m_iTicketResupply = math.Clamp(self.m_iTicketResupply + self.m_iTicketResupplyModify, self.m_iMinTicketResupply, self.m_iMaxTicketResupply)
      self.m_flDuration = math.Clamp(self.m_flDuration + self.m_flDurationModify, self.m_flMinDuration, self.m_flMaxDuration)
    end

    -------------------------------------------------
    -- Seeds
    -------------------------------------------------
    function Wave:SetAvailableSeeds(seeds, spawntype)
      self.m_t_pAvailableSeeds = seeds
      self.m_iSpawnType = spawntype

      if (spawntype ~= WAVELOCATION_RANDOM) and (not table.HasValue(seeds, self.m_pSpawnSeed)) then
        self:SelectSeed()
      end
    end

    function Wave:CleanAvailableSeeds()
      local seeds = self.m_t_pAvailableSeeds
      local count = #seeds

      while i < count do
        if not seeds[i]:IsValid() then
          table.remove(seeds, i)
          i = i - 1
          count = count - 1
        end

        i = i + 1
      end
    end

    local shuffledSeeds = {}

    function Wave:SelectSeed()
      ShuffledValues(self.m_t_pAvailableSeeds, shuffledSeeds)

      for k, v in pairs(shuffledSeeds) do
        if v:IsValid() and v:CanSpawn() then
          self.m_pSpawnSeed = v

          return v
        end
      end
    end

    -------------------------------------------------
    -- Remaining waves
    -------------------------------------------------
    function Wave:SetWaveCount(count)
      self.m_iWaveCount = count
    end

    function Wave:GetWaveCount()
      return self.m_iWaveCount()
    end

    -------------------------------------------------
    -- Wave times
    -------------------------------------------------
    --Setters
    function Wave:SetNextWaveTime(time)
      self.m_flWaveTime = time
    end

    function Wave:SetWaveInterval(interval)
      self.m_flWaveInterval = interval
    end

    function Wave:SetWaveIntervalModifier(modifier)
      self.m_flIntervalModify = modifier
    end

    function Wave:SetWaveIntervalBounds(min, max)
      if min then
        self.m_flMinWaveInterval = min
      end

      if max then
        self.m_flMaxWaveInterval = max
      end
    end

    --Getters
    function Wave:GetNextWaveTime()
      return self.m_flWaveInterval
    end

    function Wave:GetWaveInterval()
      return self.m_flWaveInterval
    end

    function Wave:GetWaveIntervalModifier()
      return self.m_flIntervalModify
    end

    function Wave:GetWaveIntervalMin()
      return self.m_flWaveIntervalMin
    end

    function Wave:GetWaveIntervalMax()
      return self.m_flWaveIntervalMax
    end

    -------------------------------------------------
    -- Tickets
    -------------------------------------------------
    --Setters
    function Wave:SetTicketResupply(tickets)
      self.m_iTicketResupply = tickets
    end

    function Wave:SetTicketResupplyModifier(modifier)
      self.m_iTicketResupplyModify = modifier
    end

    function Wave:SetTicketResupplyBounds(min, max)
      if min then
        self.m_iMinTicketResupply = min
      end

      if max then
        self.m_iMaxTicketResupply = max
      end
    end

    function Wave:SetMaxTicketCount(max)
      self.m_iMaxTicketCount = max
    end

    function Wave:SetTicketCount(count)
      self.m_iTicketCount = math.Clamp(count, 0, self.m_iMaxTicketCount)
    end

    function Wave:AddTicketCount(amt)
      self.m_iTicketCount = math.Clamp(self.m_iTicketCount + amt, 0, self.m_iMaxTicketCount)
    end

    --Getters
    function Wave:GetTicketResupply()
      return self.m_TicketResupply
    end

    function Wave:GetTicketResupplyModifier()
      return self.m_iTicketResupplyModify
    end

    function Wave:GetTicketResupplyMin()
      return self.m_iMinTicketResupply
    end

    function Wave:GetTicketResupplyMax()
      return self.m_iMaxTicketResupply
    end

    function Wave:GetTicketCount()
      return self.m_iTicketCount
    end

    function Wave:GetMaxTicketCount()
      return self.m_iMaxTicketCount
    end

    -------------------------------------------------
    -- Duration
    -------------------------------------------------
    --Setters
    function Wave:SetDuration(duration)
      self.m_flDuration = duration
    end

    function Wave:SetDurationModifier(modifier)
      self.m_flDurationModify = modifier
    end

    function Wave:SetDurationBounds(min, max)
      if min then
        self.m_flMinDuration = min
      end

      if max then
        self.m_flMaxDuration = max
      end
    end

    --Getters
    function Wave:GetDuration()
      return self.m_flDuration
    end

    function Wave:GetDurationModifier()
      return self.m_flDurationModify
    end

    function Wave:GetDurationMin()
      return self.m_flMinDuration
    end

    function Wave:GetDurationMax()
      return self.m_flMaxDuration
    end

    local EntPropagator = {}
    EntPropagator.__index = EntPropagator
    EntPropagator.m_flNextThink = 0
    EntPropagator.m_iEntityLimit = 0
    EntPropagator.m_iSpawnTicketCap = 0
    EntPropagator.m_iSpawnTickets = 0
    EntPropagator.m_iSeedCap = 0
    EntPropagator.m_iSeedCount = 0
    EntPropagator.m_flHitchhikerReady = 0
    EntPropagator.m_flSeedsReady = 0

    function EntPropagator:UpdateHitchhikers()
      local ctime = CurTime()
      local seeds = self.m_t_pSeeds
      local hitchhikers = self.m_t_pHitchhikers
      local hitchhikerCount = #hitchhikers
      local i = 1

      if hitchhikerCount > 0 then
        local earliestSpawnable = hitchhikers[1].m_flBeginSpawnable + hitchhikers[1].m_flSpawnDelay

        while hitchhikerCount >= i do
          local seed = hitchhikers[i]

          if IsValid(seed.m_hEntity) then
            if seed.m_flBeginSpawnable <= ctime then
              seed.m_flBeginSpawnable = ctime + seed.m_flSpawnDelay
              local pos = seed.m_hEntity:LocalToWorld(seed.m_hEntity:OBBCenter())

              if pos:Distance(seed.m_vStartPos) > seed.m_flPenaltyRange then
                seed.m_vStartPos = pos
                local newseed = seed:Propagate()
                newseed:SetPos(pos)
                local travelresult = newseed:Travel()
                newseed.m_hEntity = NULL

                --debugoverlay.Sphere(newseed.m_vPos, 12, 8, color_white, true);
                if not travelresult then
                  self:RemoveSeed(newseed)
                end
              end
            end
          else
            table.remove(hitchhikers, i)
            i = i - 1
            hitchhikerCount = hitchhikerCount - 1
          end

          i = i + 1

          if seed.m_flBeginSpawnable < earliestSpawnable then
            earliestSpawnable = seed.m_flBeginSpawnable
          end
        end

        self.m_flHitchhikerReady = earliestSpawnable
      end
    end

    function EntPropagator:Think()
      local ctime = CurTime()
      local seeds = self.m_t_pSeeds

      if self.m_flHitchhikerReady <= ctime then
        self:UpdateHitchhikers()
      end

      --Time-Based Expiration
      --[[
			local seedcount = #seeds;
			local i = 1;
			while (seedcount > i) do
				if (seeds[i].m_flExpiration <= ctime) then
					self:RemoveSeed(seeds[i]);
					i = i-1;
					seedcount = seedcount-1;
				end
				i = i+1;
			end
			]]
      --Actual spawning
      local entCount = #self.m_pSpawnedEntities.Items
      local entLimit = self.m_iEntityLimit

      for k, v in pairs(self.m_t_pWaves) do
        v:Update()

        if entCount < entLimit then
          while v:CanSpawn() do
            local ent = v:Spawn()

            if IsValid(ent) then
              self.m_pSpawnedEntities:AddEntity(ent)
              entCount = #self.m_pSpawnedEntities.Items
            else
              break
            end
          end
        end
      end

      return true
    end

    function EntPropagator:AddHitchhiker(seed, host)
      --local template = table.Copy(seed);
      local template = {}
      setmetatable(template, Ghor.EntPropagator.Seed)

      for k, v in pairs(seed) do
        template[k] = v
      end

      template.m_vStartPos = seed:GetPos()
      template.m_hEntity = host
      table.insert(self.m_t_pHitchhikers, template)

      if template.m_flBeginSpawnable < self.m_flHitchhikerReady then
        self.m_flHitchhikerReady = template.m_flBeginSpawnable
      end
    end

    function EntPropagator:CreateWave()
      local wave = Ghor.EntPropagator.CreateWave()
      table.insert(self.m_t_pWaves, wave)

      return wave
    end

    function EntPropagator:RemoveWave(wave)
      local waves = self.m_t_pWaves

      for k, v in ipairs(waves) do
        if v == wave then
          table.remove(waves, k)
          v:Remove()

          return
        end
      end
    end

    function EntPropagator:CreateSeed(pos)
      if self.m_iSeedCap == 0 then return end

      --Bump out the least favorable if we are at the limit.
      if #self.m_t_pSeeds >= self.m_iSeedCap then
        local lowestFavorability = self.m_t_pSeeds[1].m_flFavorability
        local leastFavorable = self.m_t_pSeeds[1]

        for k, v in ipairs(self.m_t_pSeeds) do
          if v.m_flFavorability < lowestFavorability then
            lowestFavorability = v.m_flFavorability
            leastFavorable = v
          end
        end

        self:RemoveSeed(leastFavorable)
      end

      local seed = Ghor.EntPropagator.CreateSeed(self.m_t_pSeeds, self, pos)

      return seed
    end

    function EntPropagator:RemoveSeed(seed)
      local seeds = self.m_t_pSeeds

      for k, v in ipairs(seeds) do
        if v == seed then
          table.remove(seeds, k)
          v:Remove()

          return
        end
      end
    end

    function EntPropagator:OnRemove()
      for k, v in ipairs(self.m_t_pSeeds) do
        v:Remove()
      end

      self.m_pSpawnedEntities:KillEntities()
    end

    function Ghor.EntPropagator.CreateEntPropagator()
      local self = {}
      setmetatable(self, EntPropagator)
      self.m_t_pSeeds = {}
      self.m_pSpawnedEntities = Ghor.CreateEntList()
      self.m_t_pWaves = {}
      self.m_t_pHitchhikers = {}

      return self
    end

    local Seed = {}
    Seed.__index = Seed
    Ghor.EntPropagator.Seed = Seed
    local pairs = pairs
    local Vector = Vector
    local CurTime = CurTime
    local setmetatable = setmetatable
    local table_insert = table.insert
    local table_remove = table.remove
    local table_HasValue = table.HasValue
    local table_Empty = table.Empty
    local util_TraceLine = util.TraceLine
    local util_TraceHull = util.TraceHull
    local math_abs = math.abs
    Seed.m_t_Container = nil
    Seed.m_pOwner = nil
    Seed.m_flBaseRange = 140 --Handy for getting spawn areas with many neighboring nodes. Nodes with higher favorability will increase in range, allowing them to delegate spawning to their neighbors if they are busy.
    Seed.m_flRange = 140
    Seed.m_flPenaltyRange = 40
    Seed.m_flJumpLength = 80
    Seed.m_iBounces = 3
    Seed.m_flMaxTimeForReward = 30
    Seed.m_flGroundDropDistance = 0
    Seed.m_flSpawnDelay = 20
    Seed.m_flFavorability = 2
    Seed.m_bValid = true
    Seed.m_hEntity = NULL
    Seed.m_flExpiration = 0
    Seed.m_vWorldCenter = nil
    Seed.m_bSimpleVis = true

    function Ghor.EntPropagator.CreateSeed(container, owner, pos)
      local self = {}
      setmetatable(self, Seed)
      table_insert(container, self)
      self.m_t_Container = container
      self.m_pOwner = owner
      self.m_t_flSeedDistances = {}
      self.m_t_SeedsWithinRangeOf = {}
      self.m_vPos = Vector(0, 0, 0)
      self.m_vMins = Vector(0, 0, 0)
      self.m_vMaxs = Vector(0, 0, 0)
      self.m_vWorldCenter = Vector(0, 0, 0)
      self.m_flBeginSpawnable = CurTime()
      self:SetPos(pos)
      self.m_flExpiration = CurTime() + 30

      return self
    end

    function Seed:UpdateWorldCenter()
      local center = self.m_vWorldCenter
      local pos = self.m_vPos
      local mins = self.m_vMins
      local maxs = self.m_vMaxs
      center.x = pos.x + ((mins.x + maxs.x) / 2)
      center.y = pos.y + ((mins.y + maxs.y) / 2)
      center.z = pos.z + ((mins.z + maxs.z) / 2)
    end

    local function GetSpawnableSeedsFromKeys(seeds, results)
      if results then
        table_Empty(results)
      else
        results = {}
      end

      for seed, v in pairs(seeds) do
        if seed:CanSpawn() then
          table_insert(results, seed)
        end
      end

      return results
    end

    local function GetSpawnableSeedsFromValues(seeds, results)
      if results then
        table_Empty(results)
      else
        results = {}
      end

      for k, seed in pairs(seeds) do
        if seed:CanSpawn() then
          table_insert(results, seed)
        end
      end

      return results
    end

    function Seed:SetPos(pos)
      local mypos = self.m_vPos
      mypos.x = pos.x
      mypos.y = pos.y
      mypos.z = pos.z
      self:UpdatePosition()
    end

    function Seed:UpdatePosition()
      self:UpdateWorldCenter()

      for otherSeed, distance in pairs(self.m_t_flSeedDistances) do
        self:UpdateRelationship(otherSeed)
      end

      self:AddSeeds()
    end

    function Seed:GetPos()
      return self.m_vPos * 1
    end

    function Seed:WritePosToVec(dest)
      local mypos = self.m_vPos
      dest.x = mypos.x
      dest.y = mypos.y
      dest.z = mypos.z
    end

    function Seed:EnterRange(otherSeed, distance)
      if otherSeed.m_t_flSeedDistances[self] then
        return
      else
        otherSeed.m_t_flSeedDistances[self] = distance
        table_insert(self.m_t_SeedsWithinRangeOf, otherSeed)
      end
    end

    function Seed:ExitRange(otherSeed)
      if otherSeed:IsValid() and (not otherSeed.m_t_flSeedDistances[self]) then return end

      for k, v in pairs(self.m_t_SeedsWithinRangeOf) do
        if v == otherSeed then
          table_remove(self.m_t_SeedsWithinRangeOf, k)
          break
        end
      end

      if otherSeed:IsValid() then
        otherSeed.m_t_flSeedDistances[self] = nil
      end
    end

    function Seed:UpdateRelationship(otherSeed)
      local seedsWithinRangeOf = self.m_t_SeedsWithinRangeOf
      local seedDistances = self.m_t_flSeedDistances
      local otherSeedsWithinRangeOf = otherSeed.m_t_SeedsWithinRangeOf
      local otherSeedDistances = otherSeed.m_t_flSeedDistances

      --Check our own range first.
      do
        local distance = self:GetDistanceInRange(otherSeed)

        -- in range
        if distance then
          seedDistances[otherSeed] = distance
        else --Out of range. We can assume that we are exiting this range, since it would only be in our list if it was previously in-range.
          otherSeed:ExitRange(self) --Inform the other seed that it has exited our range.
        end
      end

      --Now we check the range of the other seed.
      --Only update the other seed if were in its list of nearby seeds.
      if otherSeedDistances[self] then
        local distance = otherSeed:GetDistanceInRange()

        if distance then
          otherSeedDistances[self] = distance
        else
          self:ExitRange(otherSeed)
        end
      end
    end

    function Seed:SetRange(flRange)
      self.m_flRange = flRange

      --our range has shrunk, only notify seeds that were within our range
      if flRange < self.m_flRange then
        for otherSeed, distance in pairs(self.m_t_flSeedDistances) do
          if distance > flRange then
            self:UpdateRelationship(otherSeed)
          end
        end
      else --our range has grown, search for new seeds to add
        self:AddSeeds()
      end
    end

    function Seed:SetPenaltyRange(flPenaltyRange)
      self.m_flPenaltyRange = flPenaltyRange
    end

    function Seed:DestroySeedgraph()
      for otherSeed, distance in pairs(self.m_t_flSeedDistances) do
        otherSeed:ExitRange(self)
      end

      for k, otherSeed in pairs(self.m_t_SeedsWithinRangeOf) do
        self:ExitRange(otherSeed)
      end
    end

    function Seed:AddSeeds()
      local seedDistances = self.m_t_flSeedDistances

      for k, otherSeed in pairs(self.m_t_Container) do
        if (otherSeed ~= self) and (not seedDistances[otherSeed]) then
          local distance = self:GetDistanceInRange(otherSeed)

          if distance then
            otherSeed:EnterRange(self)
          end
        end
      end
    end

    function Seed:AddToSeeds()
      for k, otherSeed in pairs(self.m_t_Container) do
        if (otherSeed ~= self) and (not otherSeed.m_t_flSeedDistances[self]) then
          local distance = otherSeed:GetDistanceInRange(self)

          if distance then
            self:EnterRange(otherSeed)
          end
        end
      end
    end

    function Seed:GetDistanceInRange(otherSeed)
      local range = self.m_flRange
      local pos = self.m_vPos
      local otherpos = otherSeed.m_vPos

      if (math_abs(pos.x - otherpos.x) <= range) and (math_abs(pos.y - otherpos.y) <= range) and (math_abs(pos.z - otherpos.z) <= range) then
        local distance = pos:Distance(otherpos)
        if distance <= range then return distance end
      end

      return nil
    end

    function Seed:CanSpawn()
      local ctime = CurTime()
      --Don't spawn if we've already spawned too recently.
      if self.m_flBeginSpawnable > ctime then return false end
      --Test if the spawn area is clear
      if not self:TestHullUnobstructed() then return false end --The hull is obstructed, we cant spawn here right now.

      --Test if the spawn area cant be seen.
      if SinglePlayer() then
        if self:TestVis(Entity(1)) then return false end --The player can see us, we cant spawn here right now.
      else
        for _, pl in ipairs(player.GetAll()) do
          if self:TestVis(pl) then return false end --A player can see us, we cant spawn here right now.
        end
      end

      return true
    end

    function Seed:DelegateSpawning()
      for k, v in pairs(self.m_t_flSeedDistances) do
        if k:CanSpawn() then
          local ent = k:PerformSpawn()

          if IsValid(ent) then
            self.m_flExpiration = CurTime() + 45

            return ent
          end
        end
      end

      return NULL
    end

    function Seed:PerformSpawn()
      local ctime = CurTime()
      local reward = 1 - ((ctime - self.m_flBeginSpawnable) / self.m_flMaxTimeForReward) -- A fraction based on how much time we had remaining to get a spawn reward.
      local range = self.m_flRange

      if range ~= 0 then
        --We should kick any seeds invading our personal space in the teeth by docking favorability from them.
        for seed, distance in pairs(self.m_t_flSeedDistances) do
          if (distance ~= 0) and (distance <= self.m_flPenaltyRange) then
            seed:AddFavorability(-(1 - (distance / range)) * 3)
          end
        end
      end

      local ent = self:SpawnEntity()
      self.m_pOwner:AddHitchhiker(self, ent)
      self.m_flBeginSpawnable = ctime + self.m_flSpawnDelay
      self.m_flNextThink = self.m_flBeginSpawnable
      self:AddFavorability(-1 + (reward * 2)) --We lose favorability each time we spawn, but also gain back favorability based on how quickly we were able to spawn.
      self.m_flExpiration = CurTime() + 50

      return ent
    end

    function Seed:Propagate()
      local child = self.m_pOwner:CreateSeed(self.m_vPos)
      child:SetBBox(self.m_vMins, self.m_vMaxs)
      child.m_flBeginSpawnable = CurTime() + self.m_flSpawnDelay
      child.m_flBaseRange = self.m_flBaseRange
      child.m_flPenaltyRange = self.m_flPenaltyRange
      child.m_flGroundDropDistance = self.m_flGroundDropDistance
      child.m_flSpawnDelay = self.m_flSpawnDelay
      child.m_flJumpLength = self.m_flJumpLength
      child.m_hEntity = self.m_hEntity
      child.m_vStartPos = self:GetPos()
      child.SpawnEntity = self.SpawnEntity

      return child
    end

    function Seed:AddFavorability(amt)
      self.m_flFavorability = self.m_flFavorability + amt
      --if (self.m_flFavorability <= 0) then
      --	self.m_bValid = false;
      --end
    end

    function Seed:SetBBox(mins, maxs)
      local mymins = self.m_vMins
      local mymaxs = self.m_vMaxs
      mymins.x = mins.x
      mymins.y = mins.y
      mymins.z = mins.z
      mymaxs.x = maxs.x
      mymaxs.y = maxs.y
      mymaxs.z = maxs.z
      self:UpdateWorldCenter()
    end

    local visTrace = {}
    visTrace.mask = MASK_OPAQUE
    local posTrace = {}
    posTrace.mask = MASK_SOLID
    local downTraceVec = Vector(0, 0, -1)
    local traceEnd = Vector()

    function Seed:WriteWorldBBoxCorner(dest, corner)
      local pos = self.m_vPos
      local mins = self.m_vMins
      local maxs = self.m_vMaxs
      dest.x = pos.x + (((corner == 0) and mins.x) or maxs.x)
      dest.y = pos.y + (((corner == 0) and mins.y) or maxs.y)
      dest.z = pos.z + (((corner == 0) and mins.z) or maxs.z)
    end

    local function BBoxVis(self)
      visTrace.endpos = traceEnd

      for i = 0, 7 do
        self:WriteWorldBBoxCorner(traceEnd, i)
        local tr = util_TraceLine(visTrace)
        if not tr.Hit then return true end
      end

      return false
    end

    function Seed:TestVis(ent)
      --Simple PVS test first
      if ent:VisibleVec(self.m_vPos) then
        --Trace from the entitys center/eye to our bbox corners for vis.
        if ent:IsPlayer() then
          visTrace.start = ent:GetShootPos()
        else
          visTrace.start = ent:LocalToWorld(ent:OBBCenter())
        end

        visTrace.filter = ent

        if self.m_bSimpleVis then
          visTrace.endpos = self.m_vWorldCenter
          local tr = util.TraceLine(visTrace)

          return not tr.Hit
        end

        return BBoxVis(self)
      end

      return false
    end

    local function DropHullToGround(pos, maxdistance, mins, maxs)
      local oldmask = posTrace.mask
      posTrace.mask = bit.bor(MASK_SOLID, CONTENTS_WATER)
      local minZ = mins.z
      local maxZ = maxs.z
      mins.z = 0
      maxs.z = 0
      posTrace.start = pos
      downTraceVec.z = -maxdistance
      posTrace.endpos = downTraceVec
      posTrace.mins = mins
      posTrace.maxs = maxs
      local tr = util_TraceHull(posTrace)
      mins.z = minZ
      maxs.z = maxZ
      posTrace.mask = oldmask
      if tr.HitSky or tr.HitNoDraw or (tr.MatType == MAT_SLOSH) then return nil end --spawning on water/sky/clip is not allowed.
      if tr.Hit then return tr.HitPos end --debugoverlay.Line(pos, tr.HitPos, 8, color_white, false);

      return nil
    end

    function Seed:Travel()
      local pos = self.m_vPos
      local length = self.m_flJumpLength
      posTrace.mins = self.m_vMins
      posTrace.maxs = self.m_vMaxs

      if IsValid(self.m_hEntity) then
        posTrace.filter = self.m_hEntity
      end

      for i = 0, self.m_iBounces do
        posTrace.start = pos
        local endpos = VectorRand()
        endpos.x = (endpos.x * length) + pos.x
        endpos.y = (endpos.y * length) + pos.y
        endpos.z = (endpos.z * length) + pos.z
        posTrace.endpos = endpos
        local tr = util_TraceHull(posTrace)
        --debugoverlay.Line(pos, tr.HitPos, 8, color_white, false);
        pos = tr.HitPos
      end

      if self.m_flGroundDropDistance ~= 0 then
        local groundPos = DropHullToGround(pos, self.m_flGroundDropDistance, self.m_vMins, self.m_vMaxs)
        posTrace.filter = nil

        if groundPos then
          self.m_vPos = groundPos
          self:UpdatePosition()

          return true
        end

        self:UpdatePosition()

        return false
      end

      posTrace.filter = nil
      self:UpdatePosition()

      return true
    end

    function Seed:TestHullUnobstructed()
      local mins = self.m_vMins
      local maxs = self.m_vMaxs
      local minZ = mins.z
      local maxZ = maxs.z
      local pos = self.m_vPos
      local posZ = pos.z
      pos.z = pos.z + minZ
      mins.z = 0
      maxs.z = 0
      posTrace.mins = mins
      posTrace.maxs = maxs
      posTrace.start = pos
      traceEnd.x = pos.x
      traceEnd.y = pos.y
      traceEnd.z = posZ + maxZ
      posTrace.endpos = traceEnd
      local tr = util_TraceHull(posTrace)
      mins.z = minZ
      maxs.z = maxZ
      pos.z = posZ

      return not tr.Hit
    end

    function Seed:IsValid()
      return self.m_bValid == true
    end

    function Seed:Remove()
      self:DestroySeedgraph()
      table_Empty(self)
      self.m_bValid = false
    end
  end
end