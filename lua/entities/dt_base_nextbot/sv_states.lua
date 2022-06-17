--- @alias DT_Base.State fun(nb: DT_Base.NextBot): fun(): DT_Base.State

function ENT:State_Spawn()
  return function()
    self:DoSpawn()
    if self:IsPossessed() then return self.State_Possessed
    elseif self:IsAIDisabled() then return self.State_AI_Disabled
    else return self.State_AI end
  end
end

function ENT:State_Possessed()
  local started = false
  return function()
    if self:IsPossessed() then
      local doPossession = started and self.DoPossession or self.DoStartPossession
      started = true
      doPossession(self)
    elseif self:IsAIDisabled() then return self.State_AI_Disabled
    else return self.State_AI end
  end
end

function ENT:State_AI_Disabled()
  return function()
    if self:IsPossessed() then return self.State_Possesed
    elseif not self:IsAIDisabled() then return self.State_AI end
  end
end

function ENT:State_AI()
  return function()
    if self:IsPossessed() then return self.State_Possessed
    elseif self:IsAIDisabled() then return self.State_AI_Disabled
    elseif self:HasEnemy() then return self.State_AI_Search
    else return self.State_AI_Idle end
  end
end

function ENT:State_AI_Combat()
  local started = false
  return function()
    if self:IsPossessed() then return self.State_Possessed end
    if self:IsAIDisabled() then return self.State_AI_Disabled end
    if not self:HasEnemy() then return self.State_AI_Idle end
    local doCombat = started and self.DoCombat or self.DoStartCombat
    started = true
    if doCombat(self, self:GetEnemy()) == false then
      return self.State_AI_Search
    end
  end
end

function ENT:State_AI_Search()
  local started = false
  return function()
    if self:IsPossessed() then return self.State_Possessed end
    if self:IsAIDisabled() then return self.State_AI_Disabled end
    if not self:HasEnemy() then return self.State_AI_Idle end
    if self:IsFullyOmniscient() then return self.State_AI_Combat end
    local doSearch = started and self.DoSearch or self.DoStartSearch
    started = true
    local res = doSearch(self, self:GetEnemy())
    if res == true then
      return self.State_AI_Combat
    elseif res == false then
      self:ClearMemory()
      return self.State_AI_Idle
    end
  end
end

function ENT:State_AI_Idle()
  local started = false
  return function()
    if self:IsPossessed() then return self.State_Possessed end
    if self:IsAIDisabled() then return self.State_AI_Disabled end
    if self:HasEnemy() then return self.State_AI_Search end
    local doIdle = started and self.DoIdle or self.DoStartIdle
    started = true
    doIdle(self)
  end
end