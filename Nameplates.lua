--[[ 
	Nameplates, Mayen/Selari (Horde) from Illidan (US) PvP
]]

Nameplates = LibStub("AceAddon-3.0"):NewAddon("Nameplates", "AceEvent-3.0", "AceHook-3.0")

local frames = {}
local SML

function Nameplates:OnInitialize()
	self.defaults = {
		profile = {
			textureName = "Nameplates Default",
			bindings = false,
			hideHealth = false,
			hideCast = false,
			hideElite = false,
			name = { name = "Friz Quadrata TT", size = 12, border = "", shadowEnabled = false, shadowColor = { r = 0, g = 0, b = 0, a = 1 }, x = 0, y = 0 },
			level = { name = "Friz Quadrata TT", size = 11, border = "", shadowEnabled = false, shadowColor = { r = 0, g = 0, b = 0, a = 1 }, x = 0, y = 0  },
			text = { healthType = "percent", castType = "crtmax", name = "Friz Quadrata TT", size = 8, border = "OUTLINE", shadowEnabled = false, shadowColor = { r = 0, g = 0, b = 0, a = 1 }, x = 0, y = 0  },
		},
	}

	self.db = LibStub:GetLibrary("AceDB-3.0"):New("NameplatesDB", self.defaults)
	self.revision = tonumber(string.match("$Revision$", "(%d+)") or 1)
	

	SML = LibStub:GetLibrary("LibSharedMedia-3.0")
end

function Nameplates:SetupFontString(text, type)
	-- No idea why this is needed
	if( not text.SetFont ) then
		return
	end
	
	local config = self.db.profile[type]	
	text:SetFont(SML:Fetch(SML.MediaType.FONT, config.name), config.size, config.border)
	
	-- Set shadow
	if( config.shadowEnabled ) then
		if( not text.NPOriginalShadow ) then
			local x, y = text:GetShadowOffset()
			local r, g, b, a = text:GetShadowColor()
			
			text.NPOriginalShadow = { r = r, g = g, b = b, a = a, y = y, x = x }
		end
		
		text:SetShadowColor(config.shadowColor.r, config.shadowColor.g, config.shadowColor.b, config.shadowColor.a)
		text:SetShadowOffset(config.x, config.y)
		
	-- Restore original
	elseif( text.NPOriginalShadow ) then
		text:SetShadowColor(text.NPOriginalShadow.r, text.NPOriginalShadow.g, text.NPOriginalShadow.b, text.NPOriginalShadow.a)
		text:SetShadowOffset(text.NPOriginalShadow.x, text.NPOriginalShadow.y)
		text.NPOriginalShadow = nil
	end
end

function Nameplates:SetupHiding(texture, type)
	if( self.db.profile[type] ) then
		texture:Hide()
	end
end

function Nameplates:OnShow(frame)
	local threatGlow, healthBorder, castBorder, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, mobIcon = frame:GetParent():GetRegions()

	-- Health bar
	frame:SetStatusBarTexture(SML:Fetch(SML.MediaType.STATUSBAR, self.db.profile.textureName))
		
	-- Font string config
	self:SetupFontString(frame.NPText, "text")
	self:SetupFontString(nameText, "name")
	self:SetupFontString(levelText, "level")
	
	-- Hide borders
	self:SetupHiding(healthBorder, "hideHealth")
	self:SetupHiding(castBorder, "hideCast")
	self:SetupHiding(mobIcon, "hideElite")
end

function Nameplates:HealthOnValueChanged(frame, value)
	local maxValue = select(2, frame:GetMinMaxValues())
	if( self.db.profile.text.healthType == "minmax" ) then
		frame.NPText:SetFormattedText("%d / %d", value, maxValue)	
	elseif( self.db.profile.text.healthType == "deff" ) then
		value = maxValue - value
		if( value > 0 ) then
			frame.NPText:SetFormattedText("-%d", value)
		else
			frame.NPText:SetText("")
		end
	elseif( self.db.profile.text.healthType == "percent" ) then
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
	
	if( self.db.profile.text.castType == "crtmax" ) then
		frame.NPText:SetFormattedText("%.2f / %.2f", value, maxValue)
	elseif( self.db.profile.text.castType == "crt" ) then
		frame.NPText:SetFormattedText("%.2f", value)
	elseif( self.db.profile.text.castType == "percent" ) then
		frame.NPText:SetFormattedText("%d%%", value / maxValue)
	elseif( self.db.profile.text.castType == "timeleft" ) then
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
-- 1 = Threat glow, is the mob attacking you, or almost not etc
-- 2 = Health bar/level border
-- 3 = Border for the casting bar
-- 4 = Spell icon for the casting bar
-- 5 = Glow around the health bar when hovering over
-- 6 = Name text
-- 7 = Level text
-- 8 = Skull icon if the mob/player is 10 or more levels higher then you
-- 9 = Raid icon when you're close enough to the mob/player to see the name plate
-- 10 = Elite icon

local function hookFrames(...)
	local self = Nameplates
	for i=1, select("#", ...) do
		local frame = select(i, ...)
		local region = frame:GetRegions()
		if( not frames[frame] and not frame:GetName() and region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash" ) then
			frames[frame] = true

			local health, cast = frame:GetChildren()
			
			self:CreateText(health)
			self:HookScript(health, "OnValueChanged", "HealthOnValueChanged")
			self:HookScript(health, "OnShow", "OnShow")
			self:HealthOnValueChanged(health, health:GetValue())
			self:OnShow(health)

			self:CreateText(cast)
			self:HookScript(cast, "OnValueChanged", "CastOnValueChanged")
			self:HookScript(cast, "OnShow", "OnShow")
			self:CastOnValueChanged(cast, cast:GetValue())
			self:OnShow(health)
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