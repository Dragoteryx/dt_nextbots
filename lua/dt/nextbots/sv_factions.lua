DT_NextBots.Faction = DT_Core.CreateStruct()

function DT_NextBots.Faction:__new()
	self.__Allies = {}
	self.__Enemies = {}
	self.__Fears = {}
end