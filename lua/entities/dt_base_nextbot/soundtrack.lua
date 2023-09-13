if SERVER then
	util.AddNetworkString("DrGBasePlaySoundtrack")
	util.AddNetworkString("DrGBaseStopSoundtrack")

	function ENT:PlaySoundtrack(soundtrack)
		if isstring(soundtrack) then soundtrack = {loop = soundtrack} end
		net.Start("DrGBasePlaySoundtrack")
	end

	function ENT:StopSoundtrack()

	end

else

	local CURRENT_SOUNDTRACK = nil
	local SOUNDTRACK_QUEUE = {}

	function ENT:PlaySoundtrack(soundtrack)
		if isstring(soundtrack) then soundtrack = {loop = soundtrack} end
		CURRENT_SOUNDTRACK = CreateSound(Entity(0), soundName)
	end

end