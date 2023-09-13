local ENT = FindMetaTable("Entity")

local TAGS = {
	npc_antlion = { antlion = true, animal = true },
}

function ENT:DT_HasRelationshipTag(tag)
	local class = string.match(tag, "^class%([%w_]+%)$")
	if class then return self:GetClass() == class
	elseif self.DT_NextBot then
		
	elseif self:IsPlayer() then
		if tag == "player" then return true end
		local team = string.match(tag, "^team%([%d]+%)$")
		if team then return self:Team() == tonumber(team)
		else return false end
	elseif self.IsVJBaseSNPC then
		

	elseif TAGS[self:GetClass()] then
		return TAGS[self:GetClass()][tag] or false
	else return false end
		--[[local class = self:GetClass()
		local tags = { ["class(" .. class .. ")"] = true }
		if self:IsPlayer() then
			tags["team(" .. self:Team() .. ")"] = true
		elseif self.IsVJBaseSNPC then
			for _, faction in ipairs(self.VJ_NPC_CLASS) do
				tags[string.lower(faction)] = true
			end
		elseif TAGS[class] then
			for _, faction in ipairs(TAGS[class]) do
				tags[faction] = true
			end
		end
		return tags
	end]]
end