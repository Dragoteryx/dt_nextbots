local ENT = FindMetaTable("Entity")
local NB = FindMetaTable("NextBot")

if SERVER then

  local GetVelocity = ENT.GetVelocity
  function ENT:GetVelocity(...)
    if self.DT_NextBot then
      return self.loco:GetVelocity()
    else return GetVelocity(self, ...) end
  end

  local SetVelocity = ENT.SetVelocity
  function ENT:SetVelocity(vec, ...)
    if self.DT_NextBot then
      if vec.z > 0 then self:DT_Jump(1) end
      self.loco:SetVelocity(vec)
    else return SetVelocity(self, vec, ...) end
  end

  local GetGravity = ENT.GetGravity
  function ENT:GetGravity(...)
    if self.DT_NextBot then
      return self.loco:GetGravity()
    else return GetGravity(self, ...) end
  end

  local SetGravity = ENT.SetGravity
  function ENT:SetGravity(gravity, ...)
    if self.DT_NextBot then
      self.loco:SetGravity(gravity)
    else return SetGravity(self, gravity, ...) end
  end

  local BecomeRagdoll = NB.BecomeRagdoll
  function NB:BecomeRagdoll(dmginfo, ...)
    if self.DT_NextBot then
      return self:DT_BecomeRagdoll(dmginfo)
    else return BecomeRagdoll(self, dmginfo, ...) end
  end

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

end