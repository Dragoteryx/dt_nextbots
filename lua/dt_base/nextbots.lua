-- Debug --

local DEBUG_NEXTBOTS = DT_Lib.ConVar("dt_base_debug_nextbots", "0")

function DT_Base.DebugNextBots()
  return GetConVar("developer"):GetBool()
    and DEBUG_NEXTBOTS:GetBool()
end

-- Register --

local DEFAULT_KILLICON = {
  icon = "HUD/killicons/default",
  color = Color(255, 80, 0, 255)
}

function DT_Base.AddNextBot(ENT)
  local class = string.Replace(ENT.Folder, "entities/", "")
  if ENT.PrintName == nil or ENT.Category == nil then return false end

  -- precache models
  if istable(ENT.Models) then
    for _, model in ipairs(ENT.Models) do
      if not isstring(model) then continue end
      util.PrecacheModel(model)
    end
  end

  -- resources
  if SERVER then
    resource.AddFile("materials/entities/"..class..".png")
  end

  -- language
  if CLIENT then
    language.Add(class, ENT.PrintName)
  end

  -- killicon
  if CLIENT then
    ENT.Killicon = ENT.Killicon or DEFAULT_KILLICON
    killicon.Add(class, ENT.Killicon.icon, ENT.Killicon.color)
  end

  -- add to lists
  if ENT.Spawnable ~= false then
    local NPC = {
      Name = ENT.PrintName,
      Category = ENT.Category,
      Class = class,
    }
    list.Set("NPC", class, NPC)
    --list.Set("DT/Nextbots", class, NPC)
  end

  return true
end