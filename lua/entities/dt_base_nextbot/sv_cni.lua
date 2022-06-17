ENT.CNI = 1

function ENT:CNI_IsControlledByPlayer()
  return self:IsPossessed()
end

function ENT:CNI_GetControllingPlayer()
  return self:GetPossessor()
end

function ENT:CNI_GetEnemy()
  return self:GetEnemy()
end