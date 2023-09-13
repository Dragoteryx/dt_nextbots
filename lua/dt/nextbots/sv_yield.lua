DT_NextBots.YIELD_DONT_UPDATE_ANIM = 2^0
DT_NextBots.YIELD_DONT_DIE = 2^1
DT_NextBots.YIELD_DOWN_EVENTS = 2^2
DT_NextBots.YIELD_DAMAGE_EVENTS = 2^3
DT_NextBots.YIELD_USE_EVENTS = 2^4
DT_NextBots.YIELD_ANIM_EVENTS = 2^5

DT_NextBots.YIELD_ALL_EVENTS = bit.bor(
	DT_NextBots.YIELD_DOWN_EVENTS,
	DT_NextBots.YIELD_DAMAGE_EVENTS,
	DT_NextBots.YIELD_USE_EVENTS,
	DT_NextBots.YIELD_ANIM_EVENTS
)

DT_NextBots.YIELD_DWN_DMG_EVENTS = bit.bor(
	DT_NextBots.YIELD_DOWN_EVENTS,
	DT_NextBots.YIELD_DAMAGE_EVENTS
)

function DT_NextBots.YieldFlags(tbl)
	local flags = 0
	if tbl.updateAnimation == false then flags = flags + DT_NextBots.YIELD_DONT_UPDATE_ANIM end
	if tbl.cancelOnDeath == false then flags = flags + DT_NextBots.YIELD_DONT_DIE end
	if tbl.cancelOnDowned then flags = flags + DT_NextBots.YIELD_DOWN_EVENTS end
	if tbl.cancelOnDamage then flags = flags + DT_NextBots.YIELD_DAMAGE_EVENTS end
	if tbl.cancelOnUse then flags = flags + DT_NextBots.YIELD_USE_EVENTS end
	if tbl.canceOnAnimEvent then flags = flags + DT_NextBots.YIELD_ANIM_EVENTS end
	return flags
end