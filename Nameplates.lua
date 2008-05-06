--[[ 
	Nameplates, Mayen/Amarand (Horde) from Icecrown (US) PvE
]]

Nameplates = LibStub("AceAddon-3.0"):NewAddon("Nameplates", "AceEvent-3.0", "AceHook-3.0")

local frames = {}
local SML

function Nameplates:OnInitialize()
	self.defaults = {
		profile = {
			healthType = "percent",
			castType = "crtmax",

			barTexture = "Nameplates Default",

			name = { name = "Friz Quadrata TT", size = 12, border = "" },
			level = { name = "Friz Quadrata TT", size = 11, border = "" },
			text = { name = "Friz Quadrata TT", size = 8, border = "OUTLINE" },
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("NameplatesDB", self.defaults)
	self.revision = tonumber(string.match("$Revision: 692 $", "(%d+)") or 1)
	

	SML = LibStub:GetLibrary("LibSharedMedia-3.0")
end

function Nameplates:OnShow(frame)
	frame:SetStatusBarTexture(SML:Fetch(SML.MediaType.STATUSBAR, self.db.profile.barTexture))
	frame.NPText:SetFont(SML:Fetch(SML.MediaType.FONT, self.db.profile.text.name), self.db.profile.text.size, self.db.profile.text.border)
		
	local _, _, _, _, nameText, levelText = frame:GetParent():GetRegions()
	nameText:SetFont(SML:Fetch(SML.MediaType.FONT, self.db.profile.name.name), self.db.profile.name.size, self.db.profile.name.border)
	levelText:SetFont(SML:Fetch(SML.MediaType.FONT, self.db.profile.level.name), self.db.profile.level.size, self.db.profile.level.border)
end

function Nameplates:HealthOnValueChanged(frame, value)
	local _, maxValue = frame:GetMinMaxValues()

	
	if( self.db.profile.healthType == "minmax" ) then
		if( maxValue == 100 ) then
			frame.NPText:SetFormattedText("%d%% / %d%%", value, maxValue)	
		else

			frame.NPText:SetFormattedText("%d / %d", value, maxValue)	
		end
	elseif( self.db.profile.healthType == "deff" ) then
		value = maxValue - value
		if( value > 0 ) then
			if( maxValue == 100 ) then
				frame.NPText:SetFormattedText("-%d%%", value)
			else

				frame.NPText:SetFormattedText("-%d", value)
			end
		else

			frame.NPText:SetText("")
		end
	elseif( self.db.profile.healthType == "percent" ) then
		frame.NPText:SetFormattedText("%d%%", value / maxValue * 100)
	else
		frame.NPText:SetText("")
	end
end

function Nameplates:CastOnValueChanged(frame, value)
	local minValue, maxValue = frame:GetMinMaxValues()
	
	if( value >= maxValue or value == 0 ) then
		frame.NPText:SetText("")
		return
	end
	
	-- Quick hack stolen from old NP, I need to fix this up
	maxValue = maxValue - value + ( value - minValue )
	value = math.floor(((value - minValue) * 100) + 0.5) / 100
	
	if( self.db.profile.castType == "crtmax" ) then
		frame.NPText:SetFormattedText("%.2f / %.2f", value, maxValue)
	elseif( self.db.profile.castType == "crt" ) then
		frame.NPText:SetFormattedText("%.2f", value)
	elseif( self.db.profile.castType == "percent" ) then
		frame.NPText:SetFormattedText("%d%%", value / maxValue)
	elseif( self.db.profile.castType == "timeleft" ) then
		frame.NPText:SetFormattedText("%.2f", maxValue - value)
	else
		frame.NPText:SetText("")
	end

end

function Nameplates:CreateText(frame)
	frame.NPText = frame:CreateFontString(nil, "ARTWORK")
	frame.NPText:SetFont(SML:Fetch(SML.MediaType.FONT, self.db.profile.text.name), self.db.profile.text.size, self.db.profile.text.border)
	frame.NPText:SetPoint("CENTER", frame, "CENTER", 5, 0)
end

-- REGIONS
-- 1 = Health bar/level border
-- 2 = Border for the casting bar
-- 3 = Spell icon for the casting bar
-- 4 = Glow around the health bar when hovering over
-- 5 = Name text
-- 6 = Level text
-- 7 = Skull icon if the mob/player is 10 or more levels higher then you
-- 8 = Raid icon when you're close enough to the mob/player to see the name plate
local function hookFrames(...)
	local self = Nameplates
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		local region = frame:GetRegions()
		if( not frames[frame] and not frame:GetName() and region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" ) then
			frames[frame] = true

			local healthBorder, castBorder, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon = frame:GetRegions()
			local health, cast = frame:GetChildren()
			
			self:CreateText(health)
			self:HookScript(health, "OnValueChanged", "HealthOnValueChanged")
			self:HookScript(health, "OnShow", "OnShow")
			self:HealthOnValueChanged(health, health:GetValue())

			self:CreateText(cast)
			self:HookScript(cast, "OnValueChanged", "CastOnValueChanged")
			self:HookScript(cast, "OnShow", "OnShow")
			self:CastOnValueChanged(cast, cast:GetValue())
		end
	end
end

local numChildren = -1
local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function(self, elapsed)
	if( WorldFrame:GetNumChildren() ~= numChildren ) then
		numChildren = WorldFrame:GetNumChildren()
		hookFrames(WorldFrame:GetChildren())
	end
end)

function Nameplates:Reload()
	for frame in pairs(frames) do
		local health, cast = frame:GetChildren()

		self:OnShow(health)
		self:HealthOnValueChanged(health, health:GetValue())

		self:OnShow(cast)
		self:CastOnValueChanged(cast, cast:GetValue())
	end
end

function Nameplates:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Nameplates|r: " .. msg)
end