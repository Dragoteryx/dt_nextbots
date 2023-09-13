DT_NextBots.Faction = DT_Core.Struct()

function DT_NextBots.Faction:__new()
	self.__Allies = {}
	self.__Enemies = {}
	self.__Fears = {}
end