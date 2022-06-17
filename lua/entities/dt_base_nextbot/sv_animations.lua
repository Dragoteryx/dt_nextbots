local NB = FindMetaTable("NextBot")

local GetActivity = NB.GetActivity
function NB:GetActivity(...)
  if self.DT_NextBot then
    return self:GetSequenceActivity(self:GetSequence())
  else return GetActivity(self, ...) end
end

local StartActivity = NB.StartActivity
function NB:StartActivity(act, ...)
  if self.DT_NextBot then
    local seq = self:SelectWeightedSequence(act)
    if seq ~= -1 then self:StartSequence(seq) end
  else return StartActivity(self, act, ...) end
end

function ENT:StartSequence(seq)
  local old = self:GetSequence()
  self:SetSequence(seq)
  self:ResetSequenceInfo()
  self:SetCycle(0)
  if old ~= seq then
    self:OnAnimChange(old, seq)
  end
end

-- Plays a sequence and yields the coroutine until it is over
-- The 1st argument must be either a sequence or a table of sequences
-- The 2nd argument is either the playback rate or a list of options:
-- * rate: the playback rate of the sequence
-- * gravity: whether or not the nextbot should be affected by gravity
-- * cancelOn___: see YieldCoroutine
-- The 3rd argument is a function that will be called while the sequence is playing
-- Returning anything from this function will end the animation prematurely
function ENT:PlaySequenceAndWait(seq, options, func, ...)
  if isfunction(options) then return self:PlaySequenceAndWait(seq, {}, options, func, ...) end
  if isnumber(options) then return self:PlaySequenceAndWait(seq, {rate = options}, func, ...) end
  if isbool(options) then return self:PlaySequenceAndWait(seq, {gravity = options}, func, ...) end
  if istable(seq) then seq = seq[math.random(#seq)] end
  if isstring(seq) then seq = self:LookupSequence(seq) end
  if not isnumber(seq) or seq == -1 then return false end
  if options == nil then options = {} end
  if options.rate == nil then options.rate = 1 end
  if options.gravity == nil then options.gravity = true end
  self:StartSequence(seq)
  self:SetPlaybackRate(options.rate)
  local previousCycle = -1
  while true do
    local cycle = self:GetCycle()
    if self:GetSequence() ~= seq
    or previousCycle >= cycle then
      return true, nil
    end
    previousCycle = cycle
    if isfunction(func) then
      local res = func(self, ...)
      if res ~= nil then
        return true, res
      end
    end
    if not options.gravity then
      self:DT_OpposeGravity()
    end
    if self:YieldNoUpdate(options) then
      return false, nil
    end
  end
end

function ENT:PlayActivityAndWait(act, ...)
  local seq = self:SelectWeightedSequence(act)
  return self:PlaySequenceAndWait(seq, ...)
end

function ENT:PlayAnimationAndWait(anim, ...)
  if isnumber(anim) then return self:PlayActivityAndWait(anim, ...)
  else return self:PlaySequenceAndWait(anim, ...) end
end

function ENT:PlaySequenceAndMove(seq, options, func, ...)
  if isfunction(options) then return self:PlaySequenceAndMove(seq, {}, options, func, ...) end
  if isnumber(options) then return self:PlaySequenceAndMove(seq, {rate = options}, func, ...) end
  if isbool(options) then return self:PlaySequenceAndMove(seq, {gravity = options}, func, ...) end
  if istable(seq) then seq = seq[math.random(#seq)] end
  if isstring(seq) then seq = self:LookupSequence(seq) end
  if not isnumber(seq) or seq == -1 then return false end
  if options == nil then options = {} end
  local previousCycle = 0
  return self:PlaySequenceAndWait(seq, options, function(_, ...)
    local cycle = self:GetCycle()
    local ok, vec, ang = self:GetSequenceMovement(seq, previousCycle, cycle)
    previousCycle = cycle
    if ok then
      vec = vec*self:GetModelScale()
      vec = vec*(options.multiply or 1)
      vec:Rotate(self:GetAngles())
      self:SetAngles(self:GetAngles() + ang)
      local vel = vec/engine.TickInterval()
      if options.gravity then
        local x, y = vel:Unpack()
        local z = self:GetVelocity().z
        self:SetVelocity(Vector(x, y, z))
      else self:SetVelocity(vel) end
      if self:IsOnGround() then
        local trX = self:DT_TraceHull({direction = Vector(vec.x, 0, 0), step = true})
        local trY = self:DT_TraceHull({direction = Vector(0, vec.y, 0), start = trX.HitPos, step = true})
        local trZ = self:DT_TraceHull({direction = Vector(0, 0, vec.z), start = trY.HitPos, step = true})
        self:SetPos(trZ.HitPos)
      end
    end
    if isfunction(func) then
      return func(self, ...)
    end
  end, ...)
end

function ENT:PlayActivityAndMove(act, ...)
  local seq = self:SelectWeightedSequence(act)
  return self:PlaySequenceAndMove(seq, ...)
end

function ENT:PlayAnimationAndMove(anim, ...)
  if isnumber(anim) then return self:PlayActivityAndMove(anim, ...)
  else return self:PlaySequenceAndMove(anim, ...) end
end

-- Called to pick which animation to play, and its speed
function ENT:OnAnimationUpdate()
  if not self:IsOnGround() then return self.JumpAnimation, self.JumpAnimRate
  elseif self:IsCrouching() then
    if self:GetVelocity():IsZero() then return self.CrouchIdleAnimation, self.CrouchIdleAnimRate
    elseif self:IsRunning() then return self.CrouchRunAnimation, self.CrouchRunAnimRate
    else return self.CrouchWalkAnimation, self.CrouchWalkAnimRate end
  else
    if self:GetVelocity():IsZero() then return self.IdleAnimation, self.IdleAnimRate
    elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
    else return self.WalkAnimation, self.WalkAnimRate end
  end
end

-- Update the nextbot's animation
function ENT:UpdateAnimation()
  local anim, rate = self:OnAnimationUpdate()
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
  rate = isnumber(rate) and math.max(0.01, rate) or 1
  local speed = self:GetSequenceGroundSpeed(self:GetSequence())
  if speed <= 0 then
    self:SetPlaybackRate(rate)
    self.loco:SetDesiredSpeed(1)
  else
    local current = self:GetVelocity():Length()
    self:SetPlaybackRate(current/speed)
    self.loco:SetDesiredSpeed(speed*rate)
  end
end

function ENT:BodyUpdate()
  self:FrameAdvance()
  if self:LookupPoseParameter("move_yaw") ~= -1 then
    local forward = self:GetForward():Angle().y
    local velocity = self:GetVelocity():Angle().y
    local yaw = math.AngleDifference(velocity, forward)
    self:SetPoseParameter("move_yaw", yaw)
  end
  if self:LookupPoseParameter("move_x") ~= -1
  and self:LookupPoseParameter("move_y") ~= -1 then
    local vel = self:GetVelocity()
    local dir = Vector(vel.x, vel.y, 0):GetNormal() * vel:Length()
    local x, y = (self:GetAngles()-dir:Angle()):Forward():Unpack()
    self:SetPoseParameter("move_x", x)
    self:SetPoseParameter("move_y", y)
  end
end