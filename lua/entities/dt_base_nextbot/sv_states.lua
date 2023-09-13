function ENT:State_Spawn()
  self:DoSpawn()
  if self:IsPossessed() then return self.State_Possession
  elseif self:IsAIDisabled() then return self.State_AI_Disabled
  else return self.State_AI end
end

function ENT:State_Possession()
  local started = false
  while true do
    if self:IsPossessed() then
      if not started then
        self:DoPossessionStart()
        started = true
      end
      self:DoPossession()
    elseif self:IsAIDisabled() then return self.State_AI_Disabled
    else return self.State_AI end
  end
end

function ENT:State_AI_Disabled()
  while true do
    if self:IsPossessed() then return self.State_Possession
    elseif not self:IsAIDisabled() then return self.State_AI
    else coroutine.yield(DT_NextBots.YIELD_ALL_EVENTS) end
  end
end

function ENT:State_AI()
  if self:IsPossessed() then return self.State_Possession
  elseif self:IsAIDisabled() then return self.State_AI_Disabled
  elseif self:HasEnemy() then return self.State_AI_Search
  else return self.State_AI_Idle end
end

function ENT:State_AI_Combat()
  local started = false
  while true do
    if self:IsPossessed() then return self.State_Possession end
    if self:IsAIDisabled() then return self.State_AI_Disabled end
    if not self:HasEnemy() then return self.State_AI_Idle end
    if not started then
      self:DoStartCombat(self:GetEnemy())
      started = true
    end
    if self:DoCombat(self:GetEnemy()) == false then
      return self.State_AI_Search
    end
  end
end

function ENT:State_AI_Search()
  local started = false
  while true do
    if self:IsPossessed() then return self.State_Possession end
    if self:IsAIDisabled() then return self.State_AI_Disabled end
    if not self:HasEnemy() then return self.State_AI_Idle end
    if self:SkipSearch() then return self.State_AI_Combat end
    if not started then
      self:DoStartSearch(self:GetEnemy())
      started = true
    end
    local res = self:DoSearch(self:GetEnemy())
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
  while true do
    if self:IsPossessed() then return self.State_Possession end
    if self:IsAIDisabled() then return self.State_AI_Disabled end
    if self:HasEnemy() then return self.State_AI_Search end
    local doIdle = started and self.DoIdle or self.DoStartIdle
    started = true
    doIdle(self)
  end
end