DT_Base.OmniscienceOverride = DT_Lib.ConVar("dt_base_ai_omniscience_override", "0")
DT_Base.OmniscienceLevel = DT_Lib.ConVar("dt_base_ai_omniscience_level", "2")

-- Returns the current omniscience level
function ENT:GetOmniscienceLevel()
  if DT_Base.OmniscienceOverride:GetBool() then
    return DT_Base.OmniscienceLevel:GetInt()
  else
    return self:GetNW2Int("DT/OmniscienceLevel", DT_Base.OMNISCIENCE_OFF)
  end
end

-- Returns true if the nextbot is omniscient
function ENT:IsOmniscient()
  return self:GetOmniscienceLevel() ~= DT_Base.OMNISCIENCE_OFF
end

-- Returns true if the nextbot is partially omniscient
function ENT:IsPartiallyOmniscient()
  return self:GetOmniscienceLevel() == DT_Base.OMNISCIENCE_PARTIAL
end

-- Returns true if the nextbot is fully omniscient
function ENT:IsFullyOmniscient()
  return self:GetOmniscienceLevel() == DT_Base.OMNISCIENCE_FULL
end

if SERVER then

  -- Set the current omniscience level
  function ENT:SetOmniscienceLevel(level)
    self:SetNW2Int("DT/OmniscienceLevel", level)
  end

  function ENT:SetPartiallyOmniscient(omniscient)
    self:SetOmniscienceLevel(omniscient
      and DT_Base.OMNISCIENCE_PARTIAL
      or DT_Base.OMNISCIENCE_OFF)
  end

  function ENT:SetFullyOmniscient(omniscient)
    self:SetOmniscienceLevel(omniscient
      and DT_Base.OMNISCIENCE_FULL
      or DT_Base.OMNISCIENCE_OFF)
  end

  ENT.__DT_Memory = {}

  function ENT:UpdateMemory(ent, pos)
    self.__DT_Memory[ent] = {
      Pos = pos or ent:GetPos(),
      Time = CurTime()
    }
  end

  function ENT:ClearMemory(ent)
    if ent then self.__DT_Memory[ent] = nil
    else self.__DT_Memory = {} end
  end

  function ENT:IsInMemory(ent)
    local memory = self.__DT_Memory[ent]
    if memory then return true
    elseif self:IsOmniscient() then
      self:UpdateMemory(ent)
      return true
    else return false end
  end

  function ENT:LastKnownPos(ent)
    local memory = self.__DT_Memory[ent]
    if memory then return memory.Pos
    elseif self:IsOmniscient() then
      self:UpdateMemory(ent)
      return ent:GetPos()
    end
  end

  function ENT:LastMemoryUpdate(ent)
    local memory = self.__DT_Memory[ent]
    if memory then return memory.Time
    elseif self:IsOmniscient() then
      self:UpdateMemory(ent)
      return CurTime()
    end
  end

end