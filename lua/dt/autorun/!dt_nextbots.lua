DT_NextBots = DT_NextBots or {}

DT_Core.IncludeFolder("dt/nextbots")
DT_Core.IncludeFolder("dt/nextbots/structs")
DT_Core.IncludeFolder("dt/nextbots/metatables")

if SERVER then
	DT_Core.IncludeFolder("dt/nextbots/factions")
end