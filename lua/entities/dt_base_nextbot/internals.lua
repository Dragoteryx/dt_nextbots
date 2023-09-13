-- here be dragons

function ENT:Initialize() end
function ENT:__DT_PreInitialize()
  if SERVER then
    -- model
    self:SetModel(self.Models[math.random(#self.Models)])
    local height = math.abs(self.Height)
    local width = math.abs(self.Width)
    self:SetCollisionBounds(
      Vector(-width, -width, 0),
      Vector(width, width, height)
    )
    -- stats
    self:SetHealth(self.MaxHealth)
    self:SetMaxHealth(self.MaxHealth)
    -- physics
    self:PhysicsInitShadow()
    self:AddCallback("PhysicsCollide", function(_, data)
      --
    end)
    -- locomotion
    self:SetClimbingEnabled(self.EnableClimbing)
    self:SetJumpingEnabled(self.EnableJumping)
    self.loco:SetAvoidAllowed(false)
    -- possession
    self.__DT_PossessionInputs = DT_NextBots.PossessionInputs.__raw()
    self.__DT_PossessionInputs.__NextBot = self
    -- misc
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:AddCallback("OnAngleChange", function(_, ang)
      self:SetAngles(Angle(0, ang.y, 0))
    end)
    -- hooks
    hook.Add("CreateEntityRagdoll", self, self.OnRagdoll)
    self:SetSurroundingBoundsType(BOUNDS_HITBOXES)
    self:AddFlags(FL_OBJECT + FL_NPC)
    self:SetUseType(SIMPLE_USE)
    self:SetBloodColor(self.BloodColor)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
  else self:SetIK(true) end
end
function ENT:__DT_PostInitialize()
  list.Add("DT/NextBots", self)
end

function ENT:Think() end
function ENT:__DT_PreThink()
  -- update physics shadow
  local phys = self:GetPhysicsObject()
  if IsValid(phys) then
    phys:UpdateShadow(self:GetPos(), self:GetAngles(), 0)
  end
end
function ENT:__DT_PostThink() end

function ENT:OnRemove() end
function ENT:__DT_PreRemove()

end
function ENT:__DT_PostRemove()
  table.RemoveByValue(list.GetForEdit("DT/Nextbots"), self)
end

if SERVER then

  function ENT:Use() end
  function ENT:__DT_Use(...)
    local args, n = DT_Core.Pack(...)
    table.insert(self.__DT_ThreadActions.skippable, function(flags)
      if bit.band(flags, DT_NextBots.YIELD_USE_EVENTS) ~= 0 then
        self:DoUse(DT_Core.Unpack(args, n))
      end
    end)
  end

  function ENT:OnLandOnGround() end
  function ENT:__DT_OnLandOnGround()
    self:InvalidatePath()
  end

  function ENT:OnTraceAttack() end
  function ENT:__DT_OnTraceAttack(_, _, tr)
    self.__DT_TraceAttack = tr
  end

  function ENT:OnInjured() end
  function ENT:__DT_OnInjured(dmginfo)
    local tr = self.__DT_TraceAttack
    self.__DT_AllowOnTakeDamage = true
    local res = self:OnTakeDamage(dmginfo, tr)
    self.__DT_AllowOnTakeDamage = false
    if isnumber(res) then dmginfo:SetDamage(res) end
    if res == true then dmginfo:ScaleDamage(0) end
    if self:IsDead() or self:IsDown() then
      self.__DT_TraceAttack = nil
      dmginfo:ScaleDamage(0)
    elseif dmginfo:GetDamage() >= self:Health() then
      if self:OnFatalDamage(dmginfo, tr) then
        self.__DT_TraceAttack = nil
        self.__DT_IsDown = true
        self:SetHealth(1)
        dmginfo:ScaleDamage(0)
        local ldmginfo = DT_Core.DamageInfo(dmginfo)
        table.insert(self.__DT_ThreadActions.important, function(flags)
          if bit.band(flags, DT_NextBots.YIELD_DWN_DMG_EVENTS) == 0 then return false end
          self:DoDowned(ldmginfo:ToCTakeDamageInfo(), tr)
          self.__DT_IsDown = false
          return true
        end)
      else
        dmginfo:ScaleDamage(0)
        self:SetHealth(0)
      end
    elseif dmginfo:GetDamage() > 0 then
      self.__DT_TraceAttack = nil
      local ldmginfo = DT_Core.DamageInfo(dmginfo)
      table.insert(self.__DT_ThreadActions.skippable, function(flags)
        if bit.band(flags, DT_NextBots.YIELD_DAMAGE_EVENTS) ~= 0 then
          self:DoTakeDamage(ldmginfo:ToCTakeDamageInfo(), tr)
        end
      end)
    end
  end

  function ENT:OnKilled() end
  function ENT:__DT_OnKilled(dmginfo)
    local tr = self.__DT_TraceAttack
    self.__DT_TraceAttack = nil
    self.__DT_IsDead = true
    self:SetHealth(0)
    self:OnDeath(dmginfo, tr)
    local ldmginfo = DT_Core.DamageInfo(dmginfo)
    table.insert(self.__DT_ThreadActions.important, function(flags)
      if bit.band(flags, DT_NextBots.YIELD_DONT_DIE) == 0
      or bit.band(flags, DT_NextBots.YIELD_DWN_DMG_EVENTS) ~= 0 then
        dmginfo = ldmginfo:ToCTakeDamageInfo()
        self:DoDeath(dmginfo, tr)
        self:AfterDeath(dmginfo, tr)
        return true
      else return false end
    end)
  end

  function ENT:OnDeath(dmginfo, _)
    self:DT_AddDeathNotice(dmginfo:GetAttacker(), dmginfo:GetInflictor())
  end

  function ENT:AfterDeath(dmginfo, _)
    if self.RagdollOnDeath then
      self:BecomeRagdoll(dmginfo)
    else self:Remove() end
  end

  -- SLVBase compatibility
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

  function ENT:OnAnimEvent() end
  function ENT:DoAnimEvent() end
  function ENT:HandleAnimEvent() end
  function ENT:__DT_HandleAnimEvent(event, _, _, _, options)
    local pos, ang = self:GetPos(), self:GetAngles()
    self:OnAnimEvent(options, event, pos, ang)
    table.insert(self.__DT_ThreadActions.skippable, function(flags)
      if bit.band(flags, DT_NextBots.YIELD_ANIM_EVENTS) ~= 0 then
        self:DoAnimEvent(options, event, pos, ang)
      end
    end)
  end

else

  function ENT:__DT_PreDraw()
    if DT_NextBots.DebugNextBots() then
      do
        local mins, maxs = self:GetSurroundingBounds()
        render.DrawWireframeBox(
          self:GetPos(), Angle(0, 0, 0),
          mins - self:GetPos(),
          maxs - self:GetPos(),
          DT_Core.CLR_BLUE, true
        )
      end

      do
        local mins, maxs = self:GetCollisionBounds()
        render.DrawWireframeBox(
          self:GetPos(), Angle(0, 0, 0),
          mins, maxs, DT_Core.CLR_WHITE, true
        )
      end
    end
  end
  function ENT:Draw()
    self:DrawModel()
  end
  function ENT:__DT_PostDraw() end

  function ENT:OnAnimEvent() end
  function ENT:FireAnimationEvent() end
  function ENT:__DT_FireAnimationEvent(pos, angle, event, name)
    self:OnAnimEvent(name, event, pos, angle)
  end

end