--- @return DT_Base.State
function ENT:GetState()
  return self.__DT_State
end

-- Called to start the coroutine.
-- Don't overwrite this unless you know what you are doing.
function ENT:BehaveStart()
  self.__DT_State = self.State_Spawn
  self.__DT_StateBehave = self:State_Spawn()
  self:BehaveRestart()
end

function ENT:BehaveRestart()
  self.BehaveThread = coroutine.create(function()
    while true do
      local newState = self.__DT_StateBehave()
      if isfunction(newState) then
        self.__DT_State = newState
        self.__DT_StateBehave = newState(self)
      end
      self:YieldCoroutine({
        alwaysCancel = true
      })
    end
  end)
end

function ENT:BehaveKill()
  self.BehaveThread = nil
end

-- Called to update the coroutine.
-- Don't overwrite this either.
function ENT:BehaveUpdate()
  if self.BehaveThread then
    if coroutine.status(self.BehaveThread) ~= "dead" then
      local ok, res = coroutine.resume(self.BehaveThread)
      if not ok then ErrorNoHalt(self, " Error: ", res, "\n")
      elseif res == "restart" then self:BehaveRestart()
      elseif res == "kill" then self:BehaveKill() end
    else self.BehaveThread = nil end
  end
end

-- Returns true if the code is
-- executing in the nextbot's own coroutine
function ENT:InCoroutine()
  return self.BehaveThread ~= nil
    and coroutine.status(self.BehaveThread) == "running"
end

--- @class DT_Base.YieldOptions
--- @field cancelOnDeath boolean? @Cancels the coroutine when the nextbot dies (defaults to true)
--- @field cancelOnDown boolean? @Cancels the coroutine when the nextbot is down
--- @field cancelOnDamage boolean? @Cancels the coroutine when the nextbot takes damage
--- @field cancelOnUse boolean? @Cancels the coroutine when the nextbot is used by a player
--- @field cancelOnThink boolean? @Cancels the coroutine when the nextbot thinks
--- @field alwaysCancel boolean? @Sets every other field to true

--- Yields the coroutine and updates the animation.
--- Returns **true** if the coroutine was cancelled.
--- @param options? DT_Base.YieldOptions @Options for the coroutine
--- @return boolean
function ENT:YieldCoroutine(options)
  self:UpdateAnimation()
  return self:YieldNoUpdate(options)
end

--- Yields the coroutine but does not update the animation.
--- Returns **true** if the coroutine was cancelled.
--- @param options? DT_Base.YieldOptions @Options for the coroutine
--- @return boolean
function ENT:YieldNoUpdate(options)
  if options == nil then options = {} end
  if options.cancelOnDeath == nil then options.cancelOnDeath = true end
  local now = CurTime()
  if options.alwaysCancel
  or options.cancelOnDeath
  or options.cancelOnDamage then
    if self.__DT_DeathDmg then
      local ldmginfo = self.__DT_DeathDmg
      local tr = self.__DT_DeathDmg.TraceAttack
      self.__DT_DeathDmg = nil
      self:DoDeath(ldmginfo:ToUserdata(), tr)
      self:AfterDeath(ldmginfo:ToUserdata(), tr)
      coroutine.yield("kill")
    end
  end
  if options.alwaysCancel
  or options.cancelOnDown
  or options.cancelOnDamage then
    if self.__DT_DownDmg then
      local dmginfo = self.__DT_DownDmg:ToUserdata()
      local tr = self.__DT_DownDmg.TraceAttack
      self.__DT_DownDmg = nil
      self:DoDowned(dmginfo, tr)
      self.__DT_IsDown = false
      if CurTime() > now then
        self.__DT_DmgEvents = {}
        self.__DT_UseEvents = {}
        return true
      end
    end
  end
  if options.alwaysCancel
  or options.cancelOnThink then
    self:DoThink()
    if self:IsPossessed() then self:DoPossessionThink() end
    if CurTime() > now then
      self.__DT_DmgEvents = {}
      self.__DT_UseEvents = {}
      return true
    end
  end
  if options.alwaysCancel
  or options.cancelOnDamage then
    while #self.__DT_DmgEvents > 0 do
      local ldmginfo = table.remove(self.__DT_DmgEvents, 1)
      local dmginfo = ldmginfo:ToUserdata()
      local tr = ldmginfo.TraceAttack
      self:DoTakeDamage(dmginfo, tr)
      if CurTime() > now then
        self.__DT_DmgEvents = {}
        self.__DT_UseEvents = {}
        return true
      end
    end
  end
  if options.alwaysCancel
  or options.cancelOnUse then
    while #self.__DT_UseEvents > 0 do
      local useEvent = table.remove(self.__DT_UseEvents, 1)
      local args, n = useEvent[1], useEvent[2]
      self:DoUse(DT_Lib.Unpack(args, n))
      if CurTime() > now then
        self.__DT_DmgEvents = {}
        self.__DT_UseEvents = {}
        return true
      end
    end
  end
  self.__DT_DmgEvents = {}
  self.__DT_UseEvents = {}
  coroutine.yield()
  return false
end