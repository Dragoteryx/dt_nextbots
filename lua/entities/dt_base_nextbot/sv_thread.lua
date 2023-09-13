ENT.__DT_ParallelThreads = {}
ENT.__DT_ThreadActions = {
  important = {},
  skippable = {}
}

function ENT:GetState()
  return self.__DT_State
end

-- Called to start the coroutine
-- Don't overwrite this unless you know what you are doing
function ENT:BehaveStart()
  self.__DT_State = self.State_Spawn
  self.BehaveThread = coroutine.create(function(...)
    while true do
      self.__DT_State = self:__DT_State()
    end
  end)
end

function ENT:YieldThread(flags)
  return coroutine.yield(flags or DT_NextBots.YIELD_ALL_EVENTS)
end

-- Returns true if the code is executing in the nextbot's main thread
function ENT:InMainThread()
  return self.BehaveThread ~= nil
    and coroutine.status(self.BehaveThread) == "running"
end

-- Returns true if the code is executing in one of the nextbot's parallel threads
function ENT:InParallelThread()
  return DT_Core.Ipairs(self.__DT_ParallelThreads):Any(function(thread)
    return coroutine.status(thread) == "running"
  end)
end

function ENT:ParallelThread(func, ...)
  local args, n = DT_Core.Pack(...)
  return DT_Core.Promise(function(resolve, reject)
    table.insert(self.__DT_ParallelThreads, coroutine.create(function()
      local ok, res = pcall(function() func(self, DT_Core.Unpack(args, n)) end)
      if ok then resolve(res)
      else reject(res) end
    end))
  end)
end

-- Called to update the coroutine
-- Don't overwrite this either
function ENT:BehaveUpdate()
  if coroutine.status(self.BehaveThread) ~= "dead" then
    local ok, res = coroutine.resume(self.BehaveThread, false)
    if not ok then ErrorNoHalt(self, " Error: ", res, "\n")
    else
      local flags = res
      if flags == nil then flags = 0 end
      if istable(flags) then flags = DT_NextBots.YieldFlags(flags) end
      if not isnumber(flags) then
        return ErrorNoHalt(self, " Error: invalid yield value (", flags, ")\n")
      end

      if bit.band(flags, DT_NextBots.YIELD_DONT_UPDATE_ANIM) == 0 then
        local anim, rate = self:OnAnimationUpdate()
        rate = isnumber(rate) and math.max(0.01, rate) or 1
        if isnumber(anim) then
          if anim ~= self:GetActivity() then
            self:StartActivity(anim)
          end
        elseif isstring(anim) then
          local seq = self:LookupSequence(anim)
          if seq == -1 then return end
          if seq ~= self:GetSequence() then
            self:StartSequence(seq)
          end
        else return end
        local speed = self:GetSequenceGroundSpeed(self:GetSequence())
        if speed <= 0 then
          self:SetPlaybackRate(rate)
          self.loco:SetDesiredSpeed(1)
        else
          local current = self:GetVelocity():Length()
          self:SetPlaybackRate(current / speed)
          self.loco:SetDesiredSpeed(speed * rate)
        end
      end

      if #self.__DT_ThreadActions.important > 0
      or #self.__DT_ThreadActions.skippable > 0 then
        local BehaveThread = self.BehaveThread
        self.BehaveThread = coroutine.create(function()
          local now = CurTime()
          local failedActions = {}
          while #self.__DT_ThreadActions.important > 0 do
            local event = table.remove(self.__DT_ThreadActions.important, 1)
            if not event(flags) then table.insert(failedActions, event) end
          end
          self.__DT_ThreadActions.important = failedActions
          while #self.__DT_ThreadActions.skippable > 0 do
            table.remove(self.__DT_ThreadActions.skippable, 1)(flags)
          end
          self.BehaveThread = BehaveThread
          ok, res = coroutine.resume(BehaveThread, CurTime() > now)
          if ok then return res
          else error(res) end
        end)
      end
    end
  end

  local remove = {}
  for id, thread in pairs(self.__DT_ParallelThreads) do
    local status = coroutine.status(thread)
    if status == "suspended" then
      coroutine.resume(thread)
    elseif status == "dead" then
      table.insert(remove, id)
    end
  end

  for _, id in ipairs(remove) do
    self.__DT_ParallelThreads[id] = nil
  end
end