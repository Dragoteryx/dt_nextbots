local MIXIN = DT_Lib.Mixin("dt_base_nextbot")

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
    self:__DT_Use(...)
    return use(self, ...)
  end

  function MIXIN:OnLandOnGround(onLandOnGround, ...)
    self:__DT_OnLandOnGround(...)
    return onLandOnGround(self, ...)
  end

  function MIXIN:OnTraceAttack(onTraceAttack, ...)
    self:__DT_OnTraceAttack(...)
    return onTraceAttack(self, ...)
  end

  function MIXIN:OnInjured(onInjured, ...)
    self:__DT_OnInjured(...)
    return onInjured(self, ...)
  end

  function MIXIN:OnKilled(onKilled, ...)
    self:__DT_OnKilled(...)
    return onKilled(self, ...)
  end

  function MIXIN:OnTakeDamage(onTakeDamage, ...)
    if not self.__DT_AllowOnTakeDamage then return end
    return onTakeDamage(self, ...)
  end

  function MIXIN:HandleAnimEvent(handleAnimEvent, ...)
    self:__DT_HandleAnimEvent(...)
    return handleAnimEvent(self, ...)
  end

else

  function MIXIN:Draw(draw, ...)
    self:__DT_PreDraw(...)
    local res = draw(self, ...)
    self:__DT_PostDraw(...)
    return res
  end

  function MIXIN:FireAnimationEvent(fireAnimationEvent, ...)
    self:__DT_FireAnimationEvent(...)
    return fireAnimationEvent(self, ...)
  end

end

return MIXIN