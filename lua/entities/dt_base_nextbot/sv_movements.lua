local ALLOW_CLIMBING = GetConVar("nb_allow_climbing")
local ALLOW_JUMPING = GetConVar("nb_allow_gap_jumping")
local ALLOW_AVOIDING = GetConVar("nb_allow_avoiding")

-- Misc --

function ENT:IsJumpingEnabled()
  return self.loco:GetJumpGapsAllowed()
    and ALLOW_JUMPING:GetBool()
end

function ENT:SetJumpingEnabled(enabled)
  self.loco:SetJumpGapsAllowed(enabled)
end

-- Running/Crouching --

function ENT:IsRunning()
  if self:IsPossessed() then
    local ply = self:GetPossessor()
    return ply:KeyDown(IN_SPEED)
  else
    local area = self:GetLastKnownArea()
    if IsValid(area) then
      if area:HasAttributes(NAV_MESH_RUN) then return true end
      if area:HasAttributes(NAV_MESH_WALK) then return false end
    end
    return self:ShouldRun()
  end
end

function ENT:IsCrouchingEnabled()
  return tobool(self.EnableCrouching)
end

function ENT:SetCrouchingEnabled(enabled)
  self.EnableCrouching = enabled
end

function ENT:IsCrouching()
  if not self:IsCrouchingEnabled() then
    return false
  elseif self:IsPossessed() then
    local ply = self:GetPossessor()
    return ply:KeyDown(IN_DUCK)
  else
    local area = self:GetLastKnownArea()
    if IsValid(area) then
      if area:HasAttributes(NAV_MESH_CROUCH) then return true end
      if area:HasAttributes(NAV_MESH_STAND) then return false end
    end
    return self:ShouldCrouch()
  end
end

-- Unstuck --

local NORTH = Vector(999999999, 0)
local EAST = Vector(0, 999999999)
local SOUTH = -NORTH
local WEST = -EAST

local function CollisionHulls(self, distance)
  if not isnumber(distance) then distance = 1 end
  local mins, maxs = self:GetCollisionBounds()
  local radius = math.sqrt((math.abs(mins.x) ^ 2) * 2) / 2 + distance
  mins.x = mins.x / 2
  mins.y = mins.y / 2
  maxs.x = maxs.x / 2
  maxs.y = maxs.y / 2
  local debug = DT_NextBots.DebugNextBots() and 0.275 or nil
  local function Trace(x, y)
    return self:DT_TraceHull({
      direction = Vector(x, y):GetNormalized() * radius,
      step = true, mins = mins, maxs = maxs,
      debug = debug
    })
  end
  return Trace(1, -1),
    Trace(1, 1),
    Trace(-1, -1),
    Trace(-1, 1)
end

function ENT:IsStuck()
  return self:GetVelocity():IsZero()
    and self.loco:IsAttemptingToMove()
end

function ENT:Unstuck()
  while true do
    if not ALLOW_AVOIDING:GetBool() then return end
    local nw, ne, sw, se = CollisionHulls(self, 5)
    local hit = 0
    if nw.Hit then hit = hit + 1 end
    if ne.Hit then hit = hit + 1 end
    if sw.Hit then hit = hit + 1 end
    if se.Hit then hit = hit + 1 end
    if hit == 3 then
      if sw.Hit and nw.Hit and ne.Hit then self.loco:Approach(SOUTH + EAST, 1)
      elseif nw.Hit and ne.Hit and se.Hit then self.loco:Approach(SOUTH + WEST, 1)
      elseif se.Hit and sw.Hit and nw.Hit then self.loco:Approach(NORTH + EAST, 1)
      elseif ne.Hit and se.Hit and sw.Hit then self.loco:Approach(NORTH + WEST, 1) end
    elseif hit == 2 then
      if nw.Hit and ne.Hit then self.loco:Approach(SOUTH, 1)
      elseif sw.Hit and se.Hit then self.loco:Approach(NORTH, 1)
      elseif nw.Hit and sw.Hit then self.loco:Approach(EAST, 1)
      elseif ne.Hit and se.Hit then self.loco:Approach(WEST, 1)
      else return false end
    elseif hit == 1 then
      if nw.Hit then self.loco:Approach(SOUTH + EAST, 1)
      elseif ne.Hit then self.loco:Approach(SOUTH + WEST, 1)
      elseif sw.Hit then self.loco:Approach(NORTH + EAST, 1)
      elseif se.Hit then self.loco:Approach(NORTH + WEST, 1) end
    else return hit == 0 end
    if coroutine.yield(DT_NextBots.YIELD_ALL_EVENTS) then return end
  end
end

function ENT:DoUnstuck()
  self:Unstuck()
end

-- Climbing --

function ENT:IsClimbingEnabled()
  return self.loco:GetClimbAllowed()
    and ALLOW_CLIMBING:GetBool()
end

function ENT:SetClimbingEnabled(enabled)
  self.loco:SetClimbAllowed(enabled)
end

function ENT:CanClimbLadders()
  return self:IsClimbingEnabled()
    and tobool(self.ClimbLadders)
end

function ENT:SetCanClimbLadders(enabled)
  self.ClimbLadders = enabled
end

function ENT:CanClimbLedges()
  return self:IsClimbingEnabled()
    and tobool(self.ClimbLedges)
end

function ENT:SetCanClimbLedges(enabled)
  self.ClimbLedges = enabled
end