-- WHAT ARE YOU DOING HERE?????

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
    -- misc
    self:AddCallback("OnAngleChange", function(_, ang)
      self:SetAngles(Angle(0, ang.y, 0))
    end)
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    self:AddFlags(FL_OBJECT + FL_NPC)
    self:SetUseType(SIMPLE_USE)
    self:SetBloodColor(self.BloodColor)
    self.VJ_AddEntityToSNPCAttackList = true
    self.vFireIsCharacter = true
  else self:SetIK(true) end
end
function ENT:__DT_PostInitialize()

end

function ENT:Think() end
function ENT:__DT_PreThink()
  -- update physics shadow
  local phys = self:GetPhysicsObject()
  if IsValid(phys) then
    phys:UpdateShadow(self:GetPos(), self:GetAngles(), 0)
  end
end
function ENT:__DT_PostThink()

end

function ENT:OnRemove() end
function ENT:__DT_PreRemove()

end
function ENT:__DT_PostRemove()

end

if SERVER then

  ENT.__DT_UseEvents = {}

  function ENT:Use() end
  function ENT:__DT_Use(...)
    local args, n = DT_Lib.Pack(...)
    table.insert(self.__DT_UseEvents, {args, n})
  end

  function ENT:OnLandOnGround() end
  function ENT:__DT_OnLandOnGround()
    self:InvalidatePath()
  end

  function ENT:OnTraceAttack() end
  function ENT:__DT_OnTraceAttack(_, _, tr)
    self.__DT_TraceAttack = tr
  end

  ENT.__DT_DmgEvents = {}

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
      if self:OnFatalDamage(dmginfo, tr) == true then
        self.__DT_DownDmg = DT_Lib.DamageInfo(dmginfo)
        self.__DT_DownDmg.TraceAttack = tr
        self.__DT_TraceAttack = nil
        self.__DT_IsDown = true
        dmginfo:ScaleDamage(0)
        self:SetHealth(1)
      else
        dmginfo:ScaleDamage(0)
        self:SetHealth(0)
      end
    elseif dmginfo:GetDamage() > 0 then
      local ldmginfo = DT_Lib.DamageInfo(dmginfo)
      ldmginfo.TraceAttack = tr
      self.__DT_TraceAttack = nil
      table.insert(self.__DT_DmgEvents, ldmginfo)
    end
  end

  function ENT:OnKilled() end
  function ENT:__DT_OnKilled(dmginfo)
    self:SetHealth(0)
    self:OnDeath(dmginfo, self.__DT_TraceAttack)
    self.__DT_DeathDmg = DT_Lib.DamageInfo(dmginfo)
    self.__DT_DeathDmg.TraceAttack = self.__DT_TraceAttack
    self.__DT_TraceAttack = nil
    self.__DT_IsDead = true
  end

  function ENT:OnDeath(dmginfo, tr)
    self:DT_AddDeathNotice(dmginfo:GetAttacker(), dmginfo:GetInflictor())
  end

  function ENT:AfterDeath(dmginfo, tr)
    if self.RagdollOnDeath then
      self:BecomeRagdoll(dmginfo)
    else self:Remove() end
  end

  -- SLVBase compatibility
  if file.Exists("autorun/slvbase", "LUA") then
    function ENT:PercentageFrozen() return 0 end
  end

  -- Call OnRagdoll
  hook.Add("CreateEntityRagdoll", "DT/OnRagdoll", function(ent, ragdoll)
    if ent.DT_NextBot then ent:OnRagdoll(ragdoll) end
  end)

  function ENT:OnAnimEvent() end
  function ENT:HandleAnimEvent() end
  function ENT:__DT_HandleAnimEvent(event, _, _, _, options)
    self:OnAnimEvent(options, event, self:GetPos(), self:GetAngles())
  end

else

  function ENT:__DT_PreDraw()
    if DT_Base.DebugNextBots() then
      local mins, maxs = self:GetCollisionBounds()
      render.DrawWireframeBox(
        self:GetPos(), Angle(0, 0, 0),
        mins, maxs, DT_Lib.CLR_WHITE, true
      )
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