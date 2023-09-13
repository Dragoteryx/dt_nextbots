DT_NextBots.PossessionInputs = DT_Core.CreateStruct()

-- Get the nextbot that owns this PossessionInputs object
function DT_NextBots.PossessionInputs.__index:GetNextBot()
	return self.__NextBot
end

-- Get the player possessing the nextbot, or NULL
function DT_NextBots.PossessionInputs.__index:GetPossessor()
	return self:GetNextBot():GetPossessor()
end

-- Returns true if the player just pressed a key
-- This uses the IN enum, for something that uses the KEY enum use the ButtonPressed method
function DT_NextBots.PossessionInputs.__index:KeyPressed(key)
	return self:GetPossessor():KeyPressed(key)
end

-- Returns true if the player is holding a key
-- This uses the IN enum, for something that uses the KEY enum use the ButtonDown method
function DT_NextBots.PossessionInputs.__index:KeyDown(key)
	return self:GetPossessor():KeyDown(key)
end

-- Returns true if the player was holding a key last tick
-- This uses the IN enum, for something that uses the KEY enum use the ButtonDownLast method
function DT_NextBots.PossessionInputs.__index:KeyDownLast(key)
	return self:GetPossessor():KeyDownLast(key)
end

-- Returns true if the player just released a key (IN enum)
-- This uses the IN enum, for something that uses the KEY enum use the ButtonReleased method
function DT_NextBots.PossessionInputs.__index:KeyReleased(key)
	return self:GetPossessor():KeyReleased(key)
end

-- Returns true if the player just pressed a key
-- This uses the KEY enum, for something that uses the IN enum use the KeyPressed method
function DT_NextBots.PossessionInputs.__index:ButtonPressed(key)
	return self:GetPossessor():DT_ButtonPressed(key)
end

-- Returns true if the player is holding a key
-- This uses the KEY enum, for something that uses the IN enum use the KeyDown method
function DT_NextBots.PossessionInputs.__index:ButtonDown(key)
	return self:GetPossessor():DT_ButtonDown(key)
end

-- Returns true if the player was holding a key last tick
-- This uses the KEY enum, for something that uses the IN enum use the KeyDownLast method
function DT_NextBots.PossessionInputs.__index:ButtonDownLast(key)
	return self:GetPossessor():DT_ButtonDownLast(key)
end

-- Returns true if the player just released a key (IN enum)
-- This uses the KEY enum, for something that uses the IN enum use the KeyReleased method
function DT_NextBots.PossessionInputs.__index:ButtonReleased(key)
	return self:GetPossessor():DT_ButtonReleased(key)
end

-- Returns true if the player is trying to move forward
function DT_NextBots.PossessionInputs.__index:IsMovingForward()
	return self:KeyDown(IN_FORWARD) and not self:KeyDown(IN_BACK)
end

-- Returns true if the player is trying to move back
function DT_NextBots.PossessionInputs.__index:IsMovingBack()
	return self:KeyDown(IN_BACK) and not self:KeyDown(IN_FORWARD)
end

-- Returns true if the player is trying to move left
function DT_NextBots.PossessionInputs.__index:IsMovingLeft()
	return self:KeyDown(IN_LEFT) and not self:KeyDown(IN_RIGHT)
end

-- Returns true if the player is trying to move right
function DT_NextBots.PossessionInputs.__index:IsMovingRight()
	return self:KeyDown(IN_RIGHT) and not self:KeyDown(IN_LEFT)
end

-- Returns true if the player is trying to move in any direction
function DT_NextBots.PossessionInputs.__index:IsMoving()
	return self:IsMovingForward() or self:IsMovingBack()
		or self:IsMovingLeft() or self:IsMovingRight()
end

-- Returns true if the player is trying to jump
function DT_NextBots.PossessionInputs.__index:IsJumping()
	return self:KeyDown(IN_JUMP)
end

-- Returns true if the player is trying to run
function DT_NextBots.PossessionInputs.__index:IsRunning()
	return self:KeyDown(IN_RUN)
end

-- Returns true if the player is trying to crouch
function DT_NextBots.PossessionInputs.__index:IsCrouching()
	return self:KeyDown(IN_DUCK)
end

-- Returns true if the player is trying to attack (left click)
function DT_NextBots.PossessionInputs.__index:IsAttacking()
	return self:KeyDown(IN_ATTACK)
end

-- Returns true if the player is trying to attack (right click)
function DT_NextBots.PossessionInputs.__index:IsAttacking2()
	return self:KeyDown(IN_ATTACK2)
end

-- Returns true if the player is trying to attack (middle click)
function DT_NextBots.PossessionInputs.__index:IsAttacking3()
	return self:KeyDown(IN_ATTACK3)
end

-- Returns true if the player is trying to reload
function DT_NextBots.PossessionInputs.__index:IsReloading()
	return self:KeyDown(IN_RELOAD)
end
