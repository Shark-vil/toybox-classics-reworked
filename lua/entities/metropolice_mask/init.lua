AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self.Entity:SetModel("models/BarneyHelmet_faceplate.mdl")
  self.Entity:PhysicsInitBox(Vector(-4, -4, -4), Vector(4, 4, 4))
  self.Entity:SetCollisionBounds(Vector(-4, -4, -4), Vector(4, 4, 4))

  if IsValid(self:GetPhysicsObject()) then
    self:GetPhysicsObject():Wake()
  end
end

local function Combine(c)
  return c == CLASS_COMBINE or c == CLASS_COMBINE_GUNSHIP or c == CLASS_SCANNER or c == CLASS_MANHACK or c == CLASS_METROPOLICE or c == CLASS_MILITARY or c == CLASS_COMBINE_HUNTER
end

local function Resistance(c)
  return c == CLASS_PLAYER_ALLY or c == CLASS_PLAYER_ALLY_VITAL or c == CLASS_CITIZEN_PASSIVE or c == CLASS_CITIZEN_REBEL or c == CLASS_VORTIGAUNT or c == CLASS_HACKED_ROLLERMINE
end

local function CheckCop(ent)
  for k, v in ipairs(player.GetAll()) do
    if (not v.IsCop) or (not ent:IsNPC()) then return end
    local c = ent:Classify()

    if Combine(c) then
      ent:AddEntityRelationship(v, D_LI, 99)
    elseif Resistance(c) then
      ent:AddEntityRelationship(v, D_HT, 99)
    end
  end
end

local function CheckRebel(ent)
  for k, v in ipairs(player.GetAll()) do
    if not ent:IsNPC() then return end
    local c = ent:Classify()

    if Combine(c) then
      ent:AddEntityRelationship(v, D_HT, 99)
    elseif Resistance(c) then
      ent:AddEntityRelationship(v, D_LI, 99)

      --print("resistance")
      if ent:GetEnemy() == v then
        ent:SetEnemy(NULL)
      end
    end
  end
end

function ENT:Use(activator, caller)
  if not activator:IsPlayer() then return end

  if activator.IsCop then
    self:Remove()

    return
  end

  activator.IsCop = true
  activator["MPMask"] = {}
  activator["MPMask"].UserModel = activator:GetModel()
  activator["MPMask"].HadPistol = true
  activator["MPMask"].HadCrowbar = false
  activator:SetModel("models/player/police.mdl")

  if not activator:HasWeapon("weapon_pistol") then
    activator:Give("weapon_pistol")
    activator["MPMask"].HadPistol = false
  end

  if activator:HasWeapon("weapon_crowbar") then
    activator:StripWeapon("weapon_crowbar")
    activator["MPMask"].HadCrowbar = true
  end

  activator:Give("weapon_stunstick")
  activator:SelectWeapon("weapon_stunstick")
  activator:SetupHands()
  self:Remove()

  for k, v in ipairs(ents.GetAll()) do
    CheckCop(v)
  end
end

function ENT:SpawnFunction(ply, tr)
  if not tr.Hit then return end
  local SpawnPos = tr.HitPos + tr.HitNormal * 16
  local ent = ents.Create(ClassName)
  ent:SetPos(SpawnPos)
  ent:SetAngles(ply:GetAngles() * -1)
  ent:Spawn()
  ent:Activate()
  undo.Create("metropolice_mask")
  undo.AddEntity(ent)
  undo.SetPlayer(ply)

  undo.AddFunction(function(undo)
    --print("1")
    if not undo.Owner.IsCop then return end
    --print("2")
    undo.Owner.IsCop = nil

    for k, v in ipairs(ents.GetAll()) do
      CheckRebel(v)
    end

    undo.Owner:SetModel(undo.Owner["MPMask"].UserModel)
    undo.Owner:SetupHands()
    undo.Owner:StripWeapon("weapon_stunstick")

    if not undo.Owner["MPMask"].HadPistol then
      undo.Owner:StripWeapon("weapon_pistol")
    end

    if undo.Owner["MPMask"].HadCrowbar then
      undo.Owner:Give("weapon_crowbar")
    end
  end)

  undo.Finish()

  return ent
end

hook.Add("PlayerDeathSound", "MPMask", function(ply)
  if ply.IsCop then
    ply:EmitSound("NPC_MetroPolice.Die")
    net.Start("ToyBoxReworked_MPMask")
    net.Broadcast()

    for k, v in ipairs(ents.GetAll()) do
      CheckRebel(v)
    end

    return true
  end
end)

--  The EntityTakeDamage hook is incomplete. I will probably have to rework my sentence system to make it shared in order to add more sentences.
hook.Add("EntityTakeDamage", "MPMask", function(ent, dmginfo)
  if not ent.IsCop then return end
  if CurTime() < (ent["MPMask"].NPS or 0) then return end
  local ratio = (ent:Health() - dmginfo:GetDamage()) / ent:GetMaxHealth()
  if ratio < 0 then return end
  ent:EmitSound("npc/metropolice/pain" .. math.random(1, 3) .. ".wav", 100)
  ent["MPMask"].NPS = CurTime() + 1.5
end)

hook.Add("PlayerSpawn", "MPMask", function(ply)
  if ply.IsCop then
    for k, v in ipairs(ents.GetAll()) do
      CheckRebel(v)
    end

    ply.IsCop = nil
  end
end)

hook.Add("PlayerFootstep", "MPMask", function(ply, pos, foot, sound, volume, rf)
  if not ply.IsCop then return end

  if ply:KeyDown(IN_SPEED) then
    if foot then
      ply:EmitSound("NPC_MetroPolice.RunFootstepRight")
    else
      ply:EmitSound("NPC_MetroPolice.RunFootstepLeft")
    end
  else
    if foot then
      ply:EmitSound("NPC_MetroPolice.FootstepRight")
    else
      ply:EmitSound("NPC_MetroPolice.FootstepLeft")
    end
  end

  return true
end)

hook.Add("OnEntityCreated", "MPMask", function(ent)
  CheckCop(ent)
end)

hook.Add("PlayerSetHandsModel", "MPMask", function(ply, hands)
  if not ply.IsCop then return end
  hands:SetModel("models/weapons/c_arms_combine.mdl")

  return true
end)