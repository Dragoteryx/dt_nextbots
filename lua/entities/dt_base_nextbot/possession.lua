-- Get the player possessing this nextbot
function ENT:GetPossessor()
	return self:GetNW2Entity("DT/Possessor")
end

-- Check if a player is possessing this nextbot
function ENT:IsPossessed()
	return IsValid(self:GetPossessor())
end

if SERVER then

	-- Set the player possessing this nextbot
	function ENT:SetPossessor(ply)
		if self:IsPossessed() then self:StopPossession() end
		if IsValid(ply) and ply:IsPlayer() then
			if ply:DT_IsPossessing() then ply:DT_StopPossessing() end
			self:SetNW2Entity("DT/Possessor", ply)
			ply:SetNW2Entity("DT/Possessing", self)
			
		end
	end

	-- Stop possessing this nextbot
	function ENT:StopPossession()
		if not self:IsPossessed() then return end
		local ply = self:GetPossessor()

	end

	function ENT:DoPossession()
		self:DoPossessionMove(self.__DT_PossessionInputs)
		self:DoPossessionBinds(self.__DT_PossessionInputs)
	end

	function ENT:DoStartPossession()

	end

else

	-- Check if the client is possessing this nextbot
	function ENT:IsPossessedByLocalPlayer()
		return self:GetPossessor() == LocalPlayer()
	end

end