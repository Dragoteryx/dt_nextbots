ENT.Base = "base_nextbot"
ENT.DT_NextBot = true

-- Misc --
ENT.Category = ""
ENT.MaxHealth = 100
ENT.HealthRegen = 0
ENT.Height = 72
ENT.Width = 10
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = true
ENT.PreloadModels = true
ENT.Models = {
	"models/Kleiner.mdl"
}

-- AI --
ENT.MeleeAttackRange = 50
ENT.RangeAttackRange = 0
ENT.ApproachEnemyRange = 50
ENT.AvoidEnemyRange = 0
ENT.SightRange = 5000
ENT.SightAngle = 90

-- Relationships
ENT.Faction = DT_NextBots.FACTION_DEFAULT
ENT.Tags = {}

-- Animations --
ENT.IdleAnimation = ACT_IDLE
ENT.IdleAnimRate = 1
ENT.WalkAnimation = ACT_WALK
ENT.WalkAnimRate = 1
ENT.RunAnimation = ACT_RUN
ENT.RunAnimRate = 1
ENT.JumpAnimation = ACT_JUMP
ENT.JumpAnimRate = 1

-- Crouching --
ENT.EnableCrouching = false
ENT.CrouchIdleAnimation = ACT_CROUCHIDLE
ENT.CrouchIdleAnimRate = 1
ENT.CrouchWalkAnimation = ACT_WALK_CROUCH
ENT.CrouchWalkAnimRate = 1
ENT.CrouchRunAnimation = ACT_RUN_CROUCH
ENT.CrouchRunAnimRate = 1

-- Climbing
ENT.EnableClimbing = false
ENT.ClimbLadders = false
ENT.ClimbLaddersMinHeight = 0
ENT.ClimbLaddersMaxHeight = math.huge
ENT.ClimbLedges = false
ENT.ClimbLedgesMinHeight = 0
ENT.ClimbLedgesMaxHeight = math.huge

-- Possession --
ENT.EnablePossession = false
ENT.PossessionPrompt = true

if SERVER then

	-- Called when the nextbot spawns
	function ENT:Initialize() end
	function ENT:DoSpawn() end

	-- Called every tick
	function ENT:Think() end
	function ENT:DoThink() end
	function ENT:DoPossessionThink() end

	-- Called when a player uses the nextbot
	function ENT:Use() end
	function ENT:DoUse() end

	-- Called when the nextbot is in combat
	function ENT:DoStartCombat(enemy) end
	function ENT:DoCombat(enemy)
		self:MoveTowards(enemy:GetPos())
	end

	function ENT:DoMeleeAttack(enemy) end
	function ENT:DoRangeAttack(enemy) end

	-- Called when the nextbot is searching an enemy
	function ENT:DoStartSearch(enemy) end
	function ENT:DoSearch(enemy)
		if self:IsAbleToSee(enemy) then return true end
		self:MoveTowards(enemy:GetPos())
		-- todo: move to last know pos

	end

	-- Called when the nextbot has no enemy
	function ENT:DoStartIdle() end
	function ENT:DoIdle()
		coroutine.yield(DT_NextBots.YIELD_ALL_EVENTS)
	end

	function ENT:ShouldRun()
		return self:IsInCombat()
	end

	function ENT:ShouldCrouch()
		return false
	end

	-- Called when the nextbot is possessed by a player
	function ENT:OnPossessionBinds(binds) end
	function ENT:DoPossessionBinds(binds) end
	function ENT:DoPossessionStart() end
	function ENT:DoPossessionEnd() end

	-- Called when the nextbot takes damage
	function ENT:OnTakeDamage(dmginfo, tr) end
	function ENT:DoTakeDamage(dmginfo, tr) end
	function ENT:OnFatalDamage(dmginfo, tr) end

	-- Called when the nextbot dies/is down
	function ENT:DoDeath(dmginfo, tr) end
	function ENT:DoDowned(dmginfo, tr) end
	function ENT:OnRagdoll(ragdoll) end

	function ENT:OnAnimChange(old, new) end
	function ENT:OnKill(ent, dmginfo) end

end

AddCSLuaFile()
DT_Core.IncludeFile("ai.lua")
DT_Core.IncludeFile("enemy.lua")
DT_Core.IncludeFile("internals.lua")
DT_Core.IncludeFile("memory.lua")
DT_Core.IncludeFile("metatables.lua")
DT_Core.IncludeFile("possession.lua")
DT_Core.IncludeFile("sv_animations.lua")
DT_Core.IncludeFile("sv_movements.lua")
DT_Core.IncludeFile("sv_pathfinding.lua")
DT_Core.IncludeFile("sv_relationships.lua")
DT_Core.IncludeFile("sv_senses.lua")
DT_Core.IncludeFile("sv_states.lua")
DT_Core.IncludeFile("sv_thread.lua")