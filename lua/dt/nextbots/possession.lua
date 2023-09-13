properties.Add("DT/PossessNextBot", {
	MenuLabel = "Possess",
	Order = 1000,
	MenuIcon = "icon16/controller.png",
	Filter = function(_, ent, _)
		if not ent.DT_NextBot then return false end
		if not ent.EnablePossession then return false end
		if not ent.PossessionPrompt then return false end
		return true
	end,
	Action = function(self, ent, _)
		self:MsgStart()
		net.WriteEntity(ent)
		self:MsgEnd()
	end,
	Receive = function(_, _, ply)
		local ent = net.ReadEntity()
		ent:SetPossessor(ply)
		DT_Core.NetSender("DT/PossessNextBotNotif")
			:WriteEntity(ent)
			:WriteBool(hook.Run("DT/PossessNextBot", ply, ent) ~= false)
			:Send(ply)
	end
})

if SERVER then
	util.AddNetworkString("DT/PossessNextBotNotif")

	hook.Add("DT/PossessNextBot", "DT/BuiltInPossessionCriterias", function(ply, _)
		if not ply:Alive() then return false end
	end)

else

	net.Receive("DT/PossessNextBotNotif", function()
		local ent = net.ReadEntity()
		if net.ReadBool() then
			local phrase = string.Replace(language.GetPhrase("dt_nextbots.possession.ok"), "$NEXTBOT", ent.PrintName)
			notification.AddLegacy(phrase, NOTIFY_HINT, 5)
			surface.PlaySound("buttons/lightswitch2.wav")
		else
			local phrase = string.Replace(language.GetPhrase("dt_nextbots.possession.ko"), "$NEXTBOT", ent.PrintName)
			notification.AddLegacy(phrase, NOTIFY_ERROR, 5)
			surface.PlaySound("buttons/button10.wav")
		end
	end)

end