local NB = FindMetaTable("NextBot")

ENT.__DT_InSight = {}

local IsAbleToSee = NB.IsAbleToSee
function NB:IsAbleToSee(ent, ...)
  if self.DT_NextBot then
    return self.__DT_InSight[ent] or false
  else return IsAbleToSee(self, ent, ...) end
end