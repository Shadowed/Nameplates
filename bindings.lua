local Binding = Nameplates:NewModule("Bindings", "AceEvent-3.0")
local L = NameplatesLocals
local updateQueued

-- The reason we hijack this as a button instead of hooking the Show* functions is mainly sanity, it's just easier to do this
function Binding:OnInitialize()
	if( not self.enemyBinding ) then
		self.enemyBinding = CreateFrame("Button", "NPEnemyBinding")
		self.enemyBinding:SetScript("OnMouseDown", self.EnemyBindings)
	end

	if( not self.friendlyBinding ) then
		self.friendlyBinding = CreateFrame("Button", "NPFriendlyBinding")
		self.friendlyBinding:SetScript("OnMouseDown", self.FriendlyBindings)
	end

	if( not self.allBinding ) then
		self.allBinding = CreateFrame("Button", "NPAllBinding")
		self.allBinding:SetScript("OnMouseDown", self.AllBindings)
	end

	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	self:UPDATE_BINDINGS()
end

-- Update bindings since it was changed in combat
function Binding:PLAYER_REGEN_ENABLED()
	if( updateQueued ) then
		updateQueued = nil
		self:UPDATE_BINDINGS()
	end
end

function Binding:SetupBindings(frame, ...)
	ClearOverrideBindings(frame)
	
	for i=1, select("#", ...) do
		SetOverrideBindingClick(frame, false, (select(i, ...)), frame:GetName())
	end
end

-- Update our override bindings
function Binding:UPDATE_BINDINGS()
	if( InCombatLockdown() ) then
		updateQueued = true
		return
	end
	
	self:SetupBindings(self.enemyBinding, GetBindingKey("NAMEPLATES"))
	self:SetupBindings(self.friendlyBinding, GetBindingKey("FRIENDNAMEPLATES"))
	self:SetupBindings(self.allBinding, GetBindingKey("ALLNAMEPLATES"))
end

-- Toggle Messages
function Binding:EnemyBindings()
	RunBinding("NAMEPLATES")

	if( Nameplates.db.profile.bindings ) then
		if( GetCVarBool("nameplateShowEnemies") and not GetCVarBool("nameplateShowFriends") ) then
			Nameplates:Print(L["Enemy player/npc name plates are now visible."])
		else
			Nameplates:Print(L["Enemy player/npc name plates are now hidden."])
		end
	end
end

function Binding:FriendlyBindings()
	RunBinding("FRIENDNAMEPLATES")

	if( Nameplates.db.profile.bindings ) then
		if( GetCVarBool("nameplateShowFriends") and not GetCVarBool("nameplateShowEnemies") ) then
			Nameplates:Print(L["Friendly player/npc name plates are now visible."])
		else
			Nameplates:Print(L["Friendly player/npc name plates are now hidden."])
		end
	end
end

function Binding:AllBindings()
	RunBinding( "ALLNAMEPLATES" )

	if( Nameplates.db.profile.bindings ) then
		if( GetCVarBool("nameplateShowEnemies") and GetCVarBool("nameplateShowFriends") ) then
			Nameplates:Print(L["All name plates are now visible."])
		else
			Nameplates:Print(L["All name plates are now hidden."])
		end
	end
end
