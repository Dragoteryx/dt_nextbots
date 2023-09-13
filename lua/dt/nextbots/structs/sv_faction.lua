DT_NextBots.Faction = DT_Core.CreateStruct()

function DT_NextBots.Faction:__tostring()
	local id = self:GetId()
	if isstring(id) then
		return "Faction [id: " .. id .. "]"
	else
		return "Faction [no id]"
	end
end

function DT_NextBots.Faction.__index:GetId()
	local factions = list.GetForEdit("DT/Factions")
	for id, faction in pairs(factions) do
		if faction == self then return id end
	end
end

function DT_NextBots.Faction.__index:GetDefaultRelationship()
	return self.DefaultRelationship or D_NU
end

function DT_NextBots.Faction.__index:SetDefaultRelationship(default)
	self.DefaultRelationship = default
end