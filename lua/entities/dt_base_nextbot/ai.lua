--- True if AI disabled
function ENT:IsAIDisabled()
  return GetConVar("ai_disabled"):GetBool()
    or self:GetNW2Bool("DT/AIDisabled")
end

if SERVER then

  -- Disable/enable the nextbot's AI
  function ENT:SetAIDisabled(disabled)
    self:SetNW2Bool("DT/AIDisabled", disabled)
  end

  -- Returns true if the nextbot is in combat
  function ENT:IsInCombat()
    return self:GetState() == self.State_AI_Combat
  end

  -- Returns true if the nextbot is searching an enemy
  function ENT:IsSearching()
    return self:GetState() == self.State_AI_Search
  end

  function ENT:SkipSearch()
    return self:IsOmniscient()
  end

  -- Returns true if the nextbot is idle
  function ENT:IsIdle()
    return self:GetState() == self.State_AI_Idle
  end

  function ENT:IsDead()
    return self.__DT_IsDead or false
  end

  function ENT:IsDown()
    return self.__DT_IsDown or false
  end

end