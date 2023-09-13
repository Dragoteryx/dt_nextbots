function ENT:GetPath()
  if self.__DT_Path == nil then
    self.__DT_Path = Path("Follow")
  end
  return self.__DT_Path
end

function ENT:InvalidatePath()
  self:GetPath():Invalidate()
end

function ENT:PathGenerator()
  return function(area, from, ladder, _, length)
    if not IsValid(from) then return 0 end
    if not self.loco:IsAreaTraversable(area) then return -1 end
    if IsValid(ladder) then
      if not self:CanClimbLadders() then return -1 end
      if area == ladder:GetBottomArea() then
        return -1
      else
        local height = ladder:GetLength()
        if height < self.ClimbLaddersMinHeight then return -1 end
        if height > self.ClimbLaddersMaxHeight then return -1 end
        return from:GetCostSoFar() + height
      end
    else
      local dist = length > 0 and length
        or from:GetCenter():Distance(area:GetCenter())
      local height = from:ComputeAdjacentConnectionHeightChange(area)
      if height > self.loco:GetStepHeight() then
        if not self:CanClimbLedges() then return -1 end
        if height < self.ClimbLedgesMinHeight then return -1 end
        if height > self.ClimbLedgesMaxHeight then return -1 end
      elseif -height > self.loco:GetDeathDropHeight() then
        return -1
      end
      return from:GetCostSoFar() + dist
    end
  end
end

local function ShouldCompute(path, pos)
  if not IsValid(path) then return true end
  local segments = #path:GetAllSegments()
  if path:GetAge() < segments * 0.1 then return false end
  return path:LastSegment().pos ~= pos
end

function ENT:MoveTowards(pos)
  if isentity(pos) then pos = pos:GetPos() end
  if navmesh.IsLoaded() then
    local area = navmesh.GetNearestNavArea(pos)
    if IsValid(area) then pos = area:GetClosestPointOnArea(pos) end
    local path = self:GetPath()
    if ShouldCompute(path, pos) then
      path:Compute(self, pos, self:PathGenerator())
    end
    if IsValid(path) then
      local goal = path:GetCurrentGoal()
      if goal.type == 2 then
        self.loco:Approach(goal.pos, 1)
        self.loco:FaceTowards(goal.pos)
        if self:IsStuck() then
          self:DoUnstuck()
        end
      elseif goal.type == 4 then
        local ladder = goal.ladder
        local ladderBottom = ladder:GetBottom()
        self.loco:Approach(ladderBottom, 1)
        self.loco:FaceTowards(ladderBottom)
        if self:GetRangeTo(ladderBottom) < 50 then
          self:SetPos(ladder:GetTop())
        end
      else
        path:Update(self)
        if self:IsStuck() then
          self:DoUnstuck()
        end
      end
    end
  else
    self.loco:Approach(pos, 1)
    self.loco:FaceTowards(pos)
    if self:IsStuck() then
      self:DoUnstuck()
    end
  end

  return not coroutine.yield(DT_NextBots.YIELD_ALL_EVENTS)
end