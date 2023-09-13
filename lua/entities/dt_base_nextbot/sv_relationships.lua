function ENT:GetRelationship()
	return D_HT
end

function ENT:GetFactionId()
	if isstring(self.Faction) then
		return string.lower(self.Faction)
	else
		return "default"
	end
end

function ENT:SetFactionId(factionId)
	self.Faction = factionId
end

function ENT:GetFaction()
	return DT_NextBots.GetFaction(self:GetFactionId())
end

function ENT:SetFaction(faction)
	self:SetFactionId(faction:GetId())
end