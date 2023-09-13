ENT.Base = "dt_base_nextbot"
ENT.DT_NextBot = true

-- Info --
ENT.PrintName = "Text NextBot"
ENT.Category = "DT NextBots"
ENT.MaxHealth = 100
ENT.HealthRegen = 0
ENT.Height = 72
ENT.Width = 10
ENT.BloodColor = BLOOD_COLOR_RED
ENT.RagdollOnDeath = true
ENT.Models = {
	"models/player/gman_high.mdl"
}

-- AI --
ENT.Faction = "default"
ENT.Omniscient = false
ENT.MeleeAttackRange = 50
ENT.RangeAttackRange = 0
ENT.ApproachEnemyRange = 50
ENT.AvoidEnemyRange = 0

-- Animations --
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN_FAST
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Crouching --
ENT.EnableCrouching = true
ENT.CrouchIdleAnimation = ACT_HL2MP_IDLE_CROUCH
ENT.CrouchWalkAnimation = ACT_HL2MP_WALK_CROUCH
ENT.CrouchRunAnimation = ACT_HL2MP_WALK_CROUCH

-- Climbing
ENT.EnableClimbing = false

-- Possession --
ENT.EnablePossession = true
ENT.PossessionPrompt = true

if SERVER then
	function ENT:Initialize()
		self:SetEnemy(Entity(1))
		self:DT_SetPlayerColor(Color(
			math.random(255),
			math.random(255),
			math.random(255)
		))
	end

	function ENT:DoUse()
		self:PlaySequenceAndWait("taunt_dance", {
			cancelOnDamage = true
		})
	end

	function ENT:DoTakeDamage()
		self:PlaySequence("gesture_wave"):Await()
	end

	function ENT:DoDeath()
		self:PlayActivityAndMove(ACT_GMOD_DEATH)
	end

end

AddCSLuaFile()
DT_NextBots.AddNextBot(ENT)