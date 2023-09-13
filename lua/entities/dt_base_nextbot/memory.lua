DT_NextBots.OmniscienceOverride = DT_Core.ConVar("dt_base_ai_omniscience", "0")

-- Returns true if the nextbot is omniscient
function ENT:IsOmniscient()
  return DT_NextBots.OmniscienceOverride:GetBool()
    or self:GetNW2Bool("DT/Omniscient")
end

if SERVER then
  ENT.__DT_Memory = {}

  -- Set the current omniscience level
  function ENT:SetOmniscient(omniscient)
    self:SetNW2Bool("DT/Omniscient", omniscient)
  end

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
    else return nil end
  end

  function ENT:LastMemoryUpdate(ent)
    local memory = self.__DT_Memory[ent]
    if memory then return memory.Time
    elseif self:IsOmniscient() then
      self:UpdateMemory(ent)
      return CurTime()
    else return nil end
  end

end