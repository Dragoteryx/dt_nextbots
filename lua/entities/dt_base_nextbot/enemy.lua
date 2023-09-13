-- Check if the nextbot has an enemy
function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end

if CLIENT then

  -- Get the current enemy
  function ENT:GetEnemy()
    return self:GetNW2Entity("DT/Enemy")
  end

else

  -- Get the current enemy
  function ENT:GetEnemy()
    local enemy = self:GetNW2Entity("DT/Enemy")
    if IsValid(enemy) then
      if self:IsInMemory(enemy) then return enemy
      else return self:UpdateEnemy() end
    elseif self.__DT_HadEnemy then
      return self:UpdateEnemy()
    else return NULL end
  end

  -- Set the current enemy
  function ENT:SetEnemy(enemy)
    self.__DT_Enemy = enemy
    self:UpdateEnemy()
  end

  local function CompareEnemies(self, enemy1, enemy2)
    -- todo
  end

  local function FetchEnemy(self)
    local enemy
    for _, ent in ipairs(self:GetHostiles()) do
      if not enemy or CompareEnemies(self, ent, enemy) then
        enemy = ent
      end
    end
    return enemy
  end

  -- Update the current enemy
  function ENT:UpdateEnemy()
    if not self:IsPossessed() then
      local enemy = self.__DT_Enemy
      if not IsValid(enemy) then
        enemy = self:OnUpdateEnemy()
          or FetchEnemy(self)
      end
      if IsValid(enemy) then
        self:SetNW2Entity("DT/Enemy", enemy)
        self.__DT_HadEnemy = true
        return enemy
      end
    end
    self:SetNW2Entity("DT/Enemy", NULL)
    self.__DT_HadEnemy = false
    return NULL
  end

end