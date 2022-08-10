AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Toybox Classics"
ENT.PrintName = "Quest"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
  if SERVER then
    self.Entity:SetModel("models/props_junk/watermelon01.mdl")
    self:SetNoDraw(true)
    self:DrawShadow(false)
  end
end

if SERVER then
  function ENT:SpawnFunction(ply, tr)
    if IsValid(ents.FindByClass("questv2")[1]) then return end
    if not tr.Hit then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create(ClassName)
    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()
    ent.NPCS = {}
    ply:SetNWInt("Time", 0)
    ply:SetNWInt("Nyaned", 0)
    ply:SetNWInt("Quest_nyan", 0)
    ply:SetNWInt("nyaaaaa", 0)
    ply:SetNWInt("NyaRemoved", 0)
    ply:ConCommand("Quest_Book")

    for i = 1, 2 do
      local ShopCrew = ents.Create("npc_citizen")

      ShopCrew:SetModel(table.Random({"models/Humans/Group02/Female_01.mdl", "models/Humans/Group02/Female_02.mdl", "models/Humans/Group02/Female_03.mdl", "models/Humans/Group02/Female_04.mdl", "models/Humans/Group02/Female_06.mdl", "models/Humans/Group02/Female_07.mdl", "models/Humans/Group02/Male_01.mdl", "models/Humans/Group02/Male_02.mdl", "models/Humans/Group02/Male_03.mdl", "models/Humans/Group02/Male_04.mdl", "models/Humans/Group02/Male_05.mdl", "models/Humans/Group02/Male_06.mdl", "models/Humans/Group02/Male_07.mdl"}))

      ShopCrew:SetPos(ply:GetPos() + Vector(math.random(70, 100), math.random(70, 100), 0))
      ShopCrew:Spawn()
      ShopCrew:Activate()

      ShopCrew:Give(table.Random({"weapon_smg1", "weapon_rpg", "weapon_ar2"}))

      ShopCrew:AddEntityRelationship(ply, table.Random({D_ER, D_HT, D_FR, D_LI, D_NU}), 99)

      ShopCrew:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND, CAP_OPEN_DOORS, CAP_ANIMATEDFACE, CAP_TURN_HEAD, CAP_USE_SHOT_REGULATOR, CAP_AIM_GUN))
      ShopCrew:PlayScene("scenes/npc/female01/overhere01.vcd")
      table.insert(ent.NPCS, ShopCrew)
    end

    return ent
  end
end

function ENT:OnRemove()
  if not self.NPCS then return end

  for k, v in ipairs(self.NPCS) do
    if IsValid(v) then
      v:Remove()
    end
  end
end

if CLIENT then
  function ENT:Draw()
  end
end

local Quest = {}

if SERVER then
  Quest.LvlXP = {
    {
      MyXP = 1321,
      Lvl = 1,
      MoneyEarned = 400,
      GetHealth = 110,
    },
    {
      MyXP = 3421,
      Lvl = 2,
      MoneyEarned = 700,
      GetHealth = 120,
    },
    {
      MyXP = 5532,
      Lvl = 3,
      MoneyEarned = 900,
      GetHealth = 130,
    },
    {
      MyXP = 7532,
      Lvl = 4,
      MoneyEarned = 1000,
      GetHealth = 140,
    },
    {
      MyXP = 8532,
      Lvl = 5,
      MoneyEarned = 1400,
      GetHealth = 150,
    },
    {
      MyXP = 9732,
      Lvl = 6,
      MoneyEarned = 1700,
      GetHealth = 160,
    },
    {
      MyXP = 11322,
      Lvl = 7,
      MoneyEarned = 1843,
      GetHealth = 170,
    },
    {
      MyXP = 14532,
      Lvl = 8,
      MoneyEarned = 2212,
      GetHealth = 180,
    },
    {
      MyXP = 20532,
      Lvl = 9,
      MoneyEarned = 2500,
      GetHealth = 190,
    },
    {
      MyXP = 30532,
      Lvl = 10,
      MoneyEarned = 3000,
      GetHealth = 200,
    },
  }

  Quest.Forbidden = {"weapon_rpg", "weapon_frag"}

  hook.Add("PlayerSpawnSWEP", "Quest_NoCheating", function(ply, class, wep)
    if not IsValid(ents.FindByClass("questv2")[1]) then return end

    if class == "tb_ak47" or class == "tb_deagle" or class == "tb_fiveseven" or class == "tb_glock" or class == "tb_m4" or class == "tb_mp5" or class == "tb_para" or class == "tb_pumpshotgun" or class == "tb_tmp" or class == "tb_mac10" then
      ply:ChatPrint("You Cheater I shall tell Turtle :O, type /Shop to buy!")

      return false
    end
  end)

  hook.Add("PlayerGiveSWEP", "Quest_NoCheating", function(ply, class, wep)
    if not IsValid(ents.FindByClass("questv2")[1]) then return end

    if class == "tb_ak47" or class == "tb_deagle" or class == "tb_fiveseven" or class == "tb_glock" or class == "tb_m4" or class == "tb_mp5" or class == "tb_para" or class == "tb_pumpshotgun" or class == "tb_tmp" or class == "tb_mac10" then
      ply:ChatPrint("You Cheater I shall tell Turtle :O, type /Shop to buy!")

      return false
    end
  end)

  function Quest:Add(description, info, xp, min, max, ply)
    description = description or ""
    info = info or ""
    min = tonumber(min)
    max = tonumber(max)
    xp = tostring(xp)
    ply = ply or NULL

    if ply ~= NULL and ply:GetNWInt(info, 0) >= min and ply:GetNWInt(info, 0) <= max and not table.HasValue(Quest.Forbidden, ply:GetActiveWeapon():GetClass()) and ply:Alive() then
      if info:find("Quest_NPC") then
        net.Start("ToyBoxReworked_Quest_NPC")
        net.WriteString(description)
        net.WriteInt(max, 13)
        net.Send(ply)
      end

      ply:SetNWInt(info, ply:GetNWInt(info, 0) + 1)
      ply:SetFrags(ply:GetNWInt(info, 0))

      if ply:GetNWInt(info, 0) == 0 then
        ply:SetNWInt(info, ply:GetNWInt(info, 0) + 1)
      end

      for k, v in ipairs(Quest.LvlXP) do
        if ply:GetNWInt("XP") >= v.MyXP and ply:GetNWInt("Lvl", 0) ~= v.Lvl then
          ply:SetNWInt("Lvl", v.Lvl)
          ply:SetNWInt("MoneyEarned", ply:GetNWInt("MoneyEarned") + v.MoneyEarned)
          ply:SetHealth(v.GetHealth)
          print("Cool!")
        end
      end
    end

    if ply:Alive() and ply ~= NULL and ply:GetNWInt(info, 0) == max and not table.HasValue(Quest.Forbidden, ply:GetActiveWeapon():GetClass()) then
      ply:ChatPrint("Gave you an reward of : " .. xp .. " XP! for doing the quest, " .. description .. "!")
      ply:SetNWInt("Done_Quest_" .. info, 1)
      ply:SetNWInt("XP", ply:GetNWInt("XP") + xp)
    end
  end

  function StartQuest()
    if not IsValid(ents.FindByClass("questv2")[1]) then return end

    return "[Quest] " .. _G["gmod"].GetGamemode()["Name"]
  end

  hook.Add("GetGameDescription", "Quest", StartQuest)

  -- Requires Hds46's gnome at https://steamcommunity.com/sharedfiles/filedetails/?id=950713693
  hook.Add("EntityTakeDamage", "Quest_Gnome", function(ent, dmginfo)
    if ent:GetClass() == "sent_friendgnome" and dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_DIRECT) then
      if ent.HP == 1 then
        Quest:Add("Kill 5 Gnomes", "Quest_Gnome", 1000, 0, 5, dmginfo:GetAttacker())
      end
    end
  end)

  hook.Add("OnNPCKilled", "_Quest", function(victim, killer, weapon)
    if not IsValid(ents.FindByClass("questv2")[1]) then return end

    if killer:GetClass() == "player" then
      Quest:Add("Kill 10 monsters", "Quest_NPC", 1400, 0, 10, killer)
      Quest:Add("Kill 20 monsters", "Quest_NPC", 400, 10, 20, killer)
      Quest:Add("Kill 40 monsters", "Quest_NPC", 600, 20, 40, killer)
      Quest:Add("Kill 60 monsters", "Quest_NPC", 800, 40, 60, killer)
      Quest:Add("Kill 80 monsters", "Quest_NPC", 1000, 60, 80, killer)
      Quest:Add("Kill 100 monsters", "Quest_NPC", 1200, 80, 100, killer)
      Quest:Add("Kill 200 monsters", "Quest_NPC", 2400, 100, 200, killer)
      Quest:Add("Kill 400 monsters", "Quest_NPC", 4800, 200, 400, killer)
      Quest:Add("Kill 600 monsters", "Quest_NPC", 9600, 400, 600, killer)
      Quest:Add("Kill 1200 monsters", "Quest_NPC", 19200, 600, 1200, killer)
      Quest:Add("Kill 2400 monsters", "Quest_NPC", 38400, 1200, 2400, killer)
    end
  end)

  local NoSpmTime = 0

  function PlayerUse(ply, ent)
    if not IsValid(ents.FindByClass("questv2")[1]) then return end

    if CurTime() >= NoSpmTime then
      if ent:GetClass() == "npc_citizen" then
        ply:ConCommand("Quest_Shop")
      end

      NoSpmTime = CurTime() + 1
    end
  end

  hook.Add("PlayerUse", "Npc", PlayerUse)

  hook.Add("PlayerSay", "Achievement_Quest", function(ply, txt)
    if not IsValid(ents.FindByClass("questv2")[1]) then return end

    if math.random(1, 10) == txt then
      Quest:Add("Achievement", "Quest_Achievement", 120, 0, 1, ply)

      return "#winning"
    end

    if (txt:sub(1, 12) == "/achievement") and ply:GetNWInt("Done_Quest_Quest_Achivement") == 0 then
      BroadcastLua([[chat.AddText(Color(255,0,0),"]] .. ply:Nick() .. [[ Just won the #winning achivement!")]])
      Quest:Add("Achivement_winning", "Quest_Achievement", 120, 0, 1, ply)

      return "#winning"
    elseif txt:lower():find("/achievement") and ply:GetNWInt("Done_Quest_Quest_Achievement") == 1 then
      return "#winning"
    end

    if txt:sub(1, 10) == "/nyanstart" then
      ply:SetNWInt("Time", 0)
      ply:SetNWInt("Nyaned", 1)
      ply:SetNWInt("Quest_nyan", 0)
      ply:SetNWInt("nyaaaaa", 0)
      ply:SetNWInt("NyaRemoved", 0)
      ply:ConCommand("Nyan_Love")

      return "~~Nyan"
    end

    if txt:sub(1, 9) == "/nyanstop" then
      ply:ConCommand("Nyan_stop")

      return "~~Nyaned"
    end

    if txt:sub(1, 5) == "/shop" or txt:sub(1, 5) == "/Shop" then
      ply:ConCommand("Quest_Shop")

      return "[Looking at the Shop Menu]"
    end

    if txt:sub(1, 11) == "/Quest_Book" or txt:sub(1, 11) == "/quest_book" or txt:sub(1, 5) == "/Book" or txt:sub(1, 5) == "/book" then
      ply:ConCommand("Quest_Book")

      return "[Looking at the Book Menu]"
    end
  end)

  local Nyaning = 0

  hook.Add("Tick", "NyanStart", function()
    if not IsValid(ents.FindByClass("questv2")[1]) then return end

    for k, ply in ipairs(player.GetAll()) do
      if ply:GetNWInt("Nyaned", 0) == 1 and ply:GetNWInt("Time", 0) == 100 and ply:GetNWInt("NyaRemoved", 0) then
        ply:SetNWInt("NyaRemoved", 1)
        ply:SendLua([[DHtml:Remove()]])
        ply:SendLua([[FrameOpen = false]])

        return
      end

      if ply:GetNWInt("Nyaned", 0) == 1 and ply:GetNWInt("Time", 0) <= 99 then
        if CurTime() >= Nyaning then
          ply:SetNWInt("Time", ply:GetNWInt("Time", 0) + 1)
          Nyaning = CurTime() + 1
        end
      end
    end
  end)

  concommand.Add("Nyanedd", function(ply)
    if ply:GetNWInt("Time", 0) >= 100 and ply:GetNWInt("nyaaaaa", 0) == 0 then
      Quest:Add("Go threw 100 Nyans", "Quest_nyan", 3840, 0, 1, ply)
      ply:SetNWInt("nyaaaaa", 1)
    end
  end)

  concommand.Add("Nyan_stop", function(ply)
    ply:SetNWInt("Time", 0)
    ply:SetNWInt("Nyaned", 0)
    ply:SetNWInt("Quest_nyan", 0)
    ply:SetNWInt("nyaaaaa", 0)
    ply:SetNWInt("NyaRemoved", 0)
    ply:SendLua([[DHtml:Remove()]])
    ply:SendLua([[FrameOpen = false]])
  end)

  local Col = Col or Color(255, 0, 0)
  local Truncate = Truncate or nil

  function HasCSS()
    return IsMounted("cstrike")
  end

  local Shop = {
    {
      name = "Trail",
      price = 1000,
      func = function(ply, c, Col)
        Truncate = util.SpriteTrail(ply, 0, Col, false, 15, 1, 4, 1 / (15 + 1) * 0.5, "trails/plasma.vmt")
      end,
    },
  }

  local ShopWeapon = {
    {
      name = "Weapon",
      price = 1500,
      func = function(ply, n, ark)
        if not HasCSS() then
          ply:ChatPrint("Sorry you don't have Counter-strike Source!")

          return
        else
          ply:Give(ark)
        end
      end,
    },
  }

  local RefreshTime = 0
  local choosewep = choosewep or ""

  concommand.Add("shop_buy", function(ply, cmd, args)
    if CurTime() >= RefreshTime then
      for k, v in ipairs(Shop) do
        if string.find(tostring(args[1]), v["name"]) and ply:GetNWInt("MoneyEarned", 0) >= v["price"] then
          if tostring(args[2]) == "Red" then
            if Truncate then
              SafeRemoveEntity(Truncate)
            end

            timer.Simple(0.1, function()
              v["func"](ply, nil, Color(255, 0, 0))
            end)

            ply:SetNWInt("MoneyEarned", ply:GetNWInt("MoneyEarned") - v.price)
          elseif tostring(args[2]) == "Blue" then
            if Truncate then
              SafeRemoveEntity(Truncate)
            end

            timer.Simple(0.1, function()
              v["func"](ply, nil, Color(0, 0, 255))
            end)

            ply:SetNWInt("MoneyEarned", ply:GetNWInt("MoneyEarned") - v.price)
          elseif tostring(args[2]) == "Green" then
            if Truncate then
              SafeRemoveEntity(Truncate)
            end

            timer.Simple(0.1, function()
              v["func"](ply, nil, Color(0, 255, 0))
            end)

            ply:SetNWInt("MoneyEarned", ply:GetNWInt("MoneyEarned") - v.price)
          end
        end
      end

      for k, v in ipairs(ShopWeapon) do
        if string.find(tostring(args[1]), v["name"]) and ply:GetNWInt("MoneyEarned", 0) >= v["price"] then
          if args[2] == "Ak47" then
            choosewep = "tb_ak47"
          elseif args[2] == "M4A1" then
            choosewep = "tb_m4"
          elseif args[2] == "Deagle" then
            choosewep = "tb_deagle"
          elseif args[2] == "FiveSeven" then
            choosewep = "tb_fiveseven"
          elseif args[2] == "Glock" then
            choosewep = "tb_glock"
          elseif args[2] == "Mac10" then
            choosewep = "tb_mac10"
          elseif args[2] == "Mp5" then
            choosewep = "tb_mp5"
          elseif args[2] == "Machine Gun" then
            choosewep = "tb_para"
          elseif args[2] == "ShotGun" then
            choosewep = "tb_pumpshotgun"
          elseif args[2] == "Tmp" then
            choosewep = "tb_tmp"
          end

          print(args[1], args[2])

          if string.find(args[2], "Ammo") and ply:GetNWInt("MoneyEarned", 0) >= v["price"] + 300 and ply:GetWeapon("tb_ak47") or ply:GetWeapon("tb_m4") or ply:GetWeapon("tb_deagle") or ply:GetWeapon("tb_fiveseven") or ply:GetWeapon("tb_glock") or ply:GetWeapon("tb_mac10") or ply:GetWeapon("tb_mp5") or ply:GetWeapon("tb_para") or ply:GetWeapon("tb_pumpshotgun") or ply:GetWeapon("tb_tmp") then
            ply:GiveAmmo(100, "smg1")
            ply:GiveAmmo(100, "Pistol")
            ply:SetNWInt("MoneyEarned", ply:GetNWInt("MoneyEarned") - 300)
          end

          v["func"](ply, nil, choosewep)

          if HasCSS() and ply:GetWeapon("tb_ak47") or ply:GetWeapon("tb_m4") or ply:GetWeapon("tb_deagle") or ply:GetWeapon("tb_fiveseven") or ply:GetWeapon("tb_glock") or ply:GetWeapon("tb_mac10") or ply:GetWeapon("tb_mp5") or ply:GetWeapon("tb_para") or ply:GetWeapon("tb_pumpshotgun") or ply:GetWeapon("tb_tmp") then
            ply:SetNWInt("MoneyEarned", ply:GetNWInt("MoneyEarned") - v["price"])
          end
        end
      end

      RefreshTime = CurTime() + 1
    end
  end)
end

if CLIENT then
  FrameOpen = FrameOpen or false

  concommand.Add("Nyan_Love", function(ply)
    if ply:GetNWInt("nyaaaaa", 0) == 1 then return end
    if FrameOpen == true then return end
    DHtml = vgui.Create("HTML", DermaFr)
    DHtml:SetPos(ScrW() / 14 - 80, ScrH() / 12 - 40)
    DHtml:SetSize(600, 500)
    DHtml:OpenURL("http://nyan.cat")
    FrameOpen = true
  end)

  local monsters = monsters or 0
  local description = description or "Kill some monsters"

  net.Receive("ToyBoxReworked_Quest_NPC", function()
    description = net.ReadString()
    monsters = net.ReadInt(13)
  end)

  hook.Add("HUDPaint", "Quest", function()
    if not IsValid(ents.FindByClass("questv2")[1]) then return end
    surface.SetFont("DermaDefault")
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(ScrW() / 10 - 100, ScrH() / 1 - 98)
    surface.DrawText(description .. " [Need to kill: " .. string.format("%d", monsters) .. "] Current: " .. LocalPlayer():GetNWInt("Quest_NPC", 0) .. " Kills")
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(ScrW() / 10 - 100, ScrH() / 1 - 118)
    surface.DrawText("Nyan for 100 seconds You've Currently Nyaned for " .. LocalPlayer():GetNWInt("Time", 0) .. " Seconds!")

    if LocalPlayer():GetNWInt("Time", 0) == 100 then
      LocalPlayer():ConCommand("Nyanedd")
    end
  end)

  local Shop = {}

  concommand.Add("Quest_Shop", function()
    Shop.Main = vgui.Create("DFrame")
    Shop.Main:SetPos(50, 50)
    Shop.Main:SetSize(800, 500)
    Shop.Main:SetTitle("Quest Shop")
    Shop.Main:SetBackgroundBlur(true)
    Shop.Main:SizeToContents()

    Shop.Main.Paint = function()
      draw.RoundedBox(8, 0, 0, Shop.Main:GetWide(), Shop.Main:GetTall(), Color(0, 0, 0, 150))
      draw.RoundedBox(4, 10, 30, Shop.Main:GetWide() - 20, Shop.Main:GetTall() / 1.100, Color(255, 255, 0, 180))
    end

    Shop.Main:MakePopup()

    function Shop:Add(name, item, price, posw, posh, height, space, col, func)
      name = vgui.Create("DButton", Shop.Main)
      item = tostring(item)
      col = col or ""
      space = tonumber(space) or 0

      if string.find(item, "XP") then
        name:SetText(item .. price)
      elseif string.find(item, "Money") then
        name:SetText(item .. price)
      else
        name:SetText(item .. " Cost: " .. price)
      end

      name:SetSize(110 + #item + space, height)
      name:SetPos(posw, posh)

      if func == true then
        name.DoClick = function()
          if col and col ~= "" then
            RunConsoleCommand("shop_buy", item, col)
          else
            local wep = string.gsub(item, "Weapon ", "")
            RunConsoleCommand("shop_buy", item, wep)
          end
        end
      end
    end

    Shop:Add(Shop.Button1, "XP: ", LocalPlayer():GetNWInt("XP"), 20, 40, 30, "", false)
    Shop:Add(Shop.Button1, "Money: ", LocalPlayer():GetNWInt("MoneyEarned"), 140, 40, 30, "", false)
    Shop:Add(Shop.Button1, "Trail Red", 1000, 20, 80, 30, 0, "Red", true)
    Shop:Add(Shop.Button1, "Trail Blue", 1000, 20, 120, 30, 0, "Blue", true)
    Shop:Add(Shop.Button1, "Trail Green", 1000, 20, 160, 30, 0, "Green", true)
    Shop:Add(Shop.Button1, "Weapon Ak47", 1500, 150, 80, 30, 20, nil, true)
    Shop:Add(Shop.Button1, "Weapon M4A1", 1500, 150, 120, 30, 20, "", true)
    Shop:Add(Shop.Button1, "Weapon Deagle", 1500, 150, 160, 30, 20, "", true)
    Shop:Add(Shop.Button1, "Weapon FiveSeven", 1500, 150, 200, 30, 30, "", true)
    Shop:Add(Shop.Button1, "Weapon Glock", 1500, 150, 240, 30, 20, "", true)
    Shop:Add(Shop.Button1, "Weapon Mac10", 1500, 150, 280, 30, 20, "", true)
    Shop:Add(Shop.Button1, "Weapon Mp5", 1500, 150, 320, 30, 20, "", true)
    Shop:Add(Shop.Button1, "Weapon Machine Gun", 1500, 150, 360, 30, 40, "", true)
    Shop:Add(Shop.Button1, "Weapon ShotGun", 1500, 150, 400, 30, 20, "", true)
    Shop:Add(Shop.Button1, "Weapon Tmp", 1500, 150, 440, 30, 20, "", true)
    Shop:Add(Shop.Button1, "CSS Ammo", 300, 262, 40, 30, 20, "", true)
  end)

  concommand.Add("Quest_Book", function()
    local QuestPage = vgui.Create("DFrame")
    QuestPage:SetPos(50, 50)
    QuestPage:SetSize(ScrW() / 2, ScrH() / 1.4)
    QuestPage:SetTitle("Quest Book")
    QuestPage:SizeToContents()
    QuestPage:MakePopup()

    QuestPage.Paint = function()
      draw.RoundedBox(8, 0, 0, QuestPage:GetWide(), QuestPage:GetTall(), Color(255, 0, 255, 150))
      draw.RoundedBox(4, 10, 30, QuestPage:GetWide() - 20, QuestPage:GetTall() / 1.100, Color(255, 172, 212, 180))
      draw.DrawText("Quest Book", "ScoreboardText", 50, 50, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
      draw.DrawText([[Chat Achivements
                Kill 5 Gnomes achivement - Requested By (S141) SGT.Roach117
                Nyan Nya Nyaned Requested by Sir Pew Pew Pew
                Added lvl'ing up and Money based on lvl up Requested by sonofzombie and Sir Pew Pew Pew
                Added A Shop to buy stuff Requested by sonofzombie
                Health changes on level requested by shawn.t.cat nip
                Kill NPCS Achievement
                Fixed infinite money and XP on last level
                Added More trails to shop
                Fixed /nyanstart stop working after you finished watching it
                More to come!
                /---------------/
                In Chat Type
                /---------------/
                /nyanstart 
                /---------------/
                - To start it
                /---------------/
                /nyanstop 
                /---------------/
                - To stop it
                /---------------/
                Or in console
                /---------------/
                Nyan_stop
                /---------------/
                - To stop it
                /---------------/]], "ScoreboardText", ScrW() / 4.5, 60, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end
  end)
end