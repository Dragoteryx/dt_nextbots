local PLY = FindMetaTable("Player")

function PLY:DT_GetPossessing()
  return self:GetNW2Entity("DT/Possessing")
end

function PLY:DT_IsPossessing()
  return IsValid(self:DT_GetPossessing())
end

if SERVER then

  function PLY:DT_StopPossessing()
    local nb = self:DT_GetPossessing()
    if IsValid(nb) then nb:StopPossession() end
  end

end