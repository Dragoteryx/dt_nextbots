local MIXIN = DT_Core.Mixin("dt_base_nextbot")

function MIXIN:Initialize(init, ...)
  self:__DT_PreInitialize(...)
  local res = init(self, ...)
  self:__DT_PostInitialize(...)
  return res
end

function MIXIN:Think(think, ...)
  self:__DT_PreThink(...)
  local res = think(self, ...)
  self:__DT_PostThink(...)
  return res
end

function MIXIN:OnRemove(onRemove, ...)
  self:__DT_PreRemove(...)
  local res = onRemove(self, ...)
  self:__DT_PostRemove(...)
  return res
end

if SERVER then

  function MIXIN:Use(use, ...)
    local res = use(self, ...)
    self:__DT_Use(...)
    return res
  end

  function MIXIN:OnLandOnGround(onLandOnGround, ...)
    local res = onLandOnGround(self, ...)
    self:__DT_OnLandOnGround(...)
    return res
  end

  function MIXIN:OnTraceAttack(onTraceAttack, ...)
    local res = onTraceAttack(self, ...)
    self:__DT_OnTraceAttack(...)
    return res
  end

  function MIXIN:OnInjured(onInjured, ...)
    local res = onInjured(self, ...)
    self:__DT_OnInjured(...)
    return res
  end

  function MIXIN:OnKilled(onKilled, ...)
    local res = onKilled(self, ...)
    self:__DT_OnKilled(...)
    return res
  end

  function MIXIN:OnTakeDamage(onTakeDamage, ...)
    if not self.__DT_AllowOnTakeDamage then return end
    return onTakeDamage(self, ...)
  end

  function MIXIN:HandleAnimEvent(handleAnimEvent, ...)
    local res = self:__DT_HandleAnimEvent(...)
    local res2 = handleAnimEvent(self, ...)
    return res or res2
  end

else

  function MIXIN:Draw(draw, ...)
    self:__DT_PreDraw(...)
    local res = draw(self, ...)
    self:__DT_PostDraw(...)
    return res
  end

  function MIXIN:FireAnimationEvent(fireAnimationEvent, ...)
    local res = self:__DT_FireAnimationEvent(...)
    local res2 = fireAnimationEvent(self, ...)
    return res or res2
  end

end

return MIXIN