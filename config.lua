if( not Nameplates ) then return end

local Config = Nameplates:NewModule("Config")
local L = NameplatesLocals

local SML, registered, options, config, dialog

function Config:OnInitialize()
	config = LibStub("AceConfig-3.0")
	dialog = LibStub("AceConfigDialog-3.0")
	
	SML = LibStub:GetLibrary("LibSharedMedia-3.0")
	SML:Register(SML.MediaType.STATUSBAR, "BantoBar", "Interface\\Addons\\Nameplates\\images\\banto")
	SML:Register(SML.MediaType.STATUSBAR, "Smooth",   "Interface\\Addons\\Nameplates\\images\\smooth")
	SML:Register(SML.MediaType.STATUSBAR, "Perl",     "Interface\\Addons\\Nameplates\\images\\perl")
	SML:Register(SML.MediaType.STATUSBAR, "Glaze",    "Interface\\Addons\\Nameplates\\images\\glaze")
	SML:Register(SML.MediaType.STATUSBAR, "Charcoal", "Interface\\Addons\\Nameplates\\images\\Charcoal")
	SML:Register(SML.MediaType.STATUSBAR, "Otravi",   "Interface\\Addons\\Nameplates\\images\\otravi")
	SML:Register(SML.MediaType.STATUSBAR, "Striped",  "Interface\\Addons\\Nameplates\\images\\striped")
	SML:Register(SML.MediaType.STATUSBAR, "LiteStep", "Interface\\Addons\\Nameplates\\images\\LiteStep")
	SML:Register(SML.MediaType.STATUSBAR, "Nameplates Default", "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
end

-- GUI
local function set(info, value)
	local arg1, arg2, arg3 = string.split(".", info.arg)
	if( tonumber(arg2) ) then arg2 = tonumber(arg2) end
	
	if( arg2 and arg3 ) then
		Nameplates.db.profile[arg1][arg2][arg3] = value
	elseif( arg2 ) then
		Nameplates.db.profile[arg1][arg2] = value
	else
		Nameplates.db.profile[arg1] = value
	end
	
	Nameplates:Reload()
end

local function get(info)
	local arg1, arg2, arg3 = string.split(".", info.arg)
	if( tonumber(arg2) ) then arg2 = tonumber(arg2) end
		
	if( arg2 and arg3 ) then
		return Nameplates.db.profile[arg1][arg2][arg3]
	elseif( arg2 ) then
		return Nameplates.db.profile[arg1][arg2]
	else
		return Nameplates.db.profile[arg1]
	end
end

local function setNumber(info, value)
	set(info, tonumber(value))
end

-- Return all registered SML textures
local textures = {}
function Config:GetTextures()
	for k in pairs(textures) do textures[k] = nil end

	for _, name in pairs(SML:List(SML.MediaType.STATUSBAR)) do
		textures[name] = name
	end
	
	return textures
end

-- Return all registered SML fonts
local fonts = {}
function Config:GetFonts()
	for k in pairs(fonts) do fonts[k] = nil end

	for _, name in pairs(SML:List(SML.MediaType.FONT)) do
		fonts[name] = name
	end
	
	return fonts
end

local fontBorders = {[""] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = L["Thick outline"], ["MONOCHROME"] = L["Monochrome"]}

local function loadOptions()
	options = {}
	options.type = "group"
	options.name = "Nameplates"
	
	options.args = {}
	options.args.general = {
		type = "group",
		order = 1,
		name = L["General"],
		get = get,
		set = set,
		handler = Config,
		args = {
			bars = {
				order = 1,
				type = "group",
				inline = true,
				name = L["Bars"],
				args = {
					barName = {
						order = 4,
						type = "select",
						name = L["Bar texture"],
						values = "GetTextures",
						arg = "barTexture",
					},
				},
			},
			text = {
				order = 2,
				type = "group",
				inline = true,
				name = L["Cast/Health text"],
				args = {
					health = {
						order = 1,
						type = "select",
						name = L["Health text display"],
						desc = L["Style of display for health bar text."],
						values = {["none"] = L["None"], ["minmax"] = L["Min / Max"], ["deff"] = L["Deficit"], ["percent"] = L["Percent"]},
						arg = "healthType",
					},
					cast = {
						order = 2,
						type = "select",
						name = L["Cast text display"],
						desc = L["Style of display for cast bar text."],
						values = {["crtmax"] = L["Current / Max"], ["none"] = L["None"], ["crt"] = L["Current"], ["percent"] = L["Percent"], ["timeleft"] = L["Time left"]},
						arg = "castType",
					},
					name = {
						order = 3,
						type = "select",
						name = L["Font name"],
						desc = L["Font name for the health bar text."],
						values = "GetFonts",
						arg = "text.name",
					},
					type = {
						order = 4,
						type = "range",
						name = L["Font size"],
						min = 1, max = 20, step = 1,
						set = setNumber,
						arg = "text.size",
					},
					border = {
						order = 5,
						type = "select",
						name = L["Font border"],
						values = fontBorders,
						arg = "text.border",
					},
				},
			},
			name = {
				order = 4,
				type = "group",
				inline = true,
				name = L["Name text"],
				args = {
					name = {
						order = 1,
						type = "select",
						name = L["Font name"],
						desc = L["Font name for the actual name text above name plate bars."],
						values = "GetFonts",
						arg = "name.name",
					},
					type = {
						order = 2,
						type = "range",
						name = L["Font size"],
						min = 1, max = 20, step = 1,
						set = setNumber,
						arg = "name.size",
					},
					border = {
						order = 3,
						type = "select",
						name = L["Font border"],
						values = fontBorders,
						arg = "name.border",
					},
				},
			},
			level = {
				order = 5,
				type = "group",
				inline = true,
				name = L["Level text"],
				args = {
					name = {
						order = 1,
						type = "select",
						name = L["Font name"],
						desc = L["Font name for the level text."],
						values = "GetFonts",
						arg = "level.name",
					},
					type = {
						order = 2,
						type = "range",
						name = L["Font size"],
						min = 1, max = 20, step = 1,
						set = setNumber,
						arg = "level.size",
					},
					border = {
						order = 3,
						type = "select",
						name = L["Font border"],
						values = fontBorders,
						arg = "level.border",
					},
				},
			},
		},
	}
	-- DB Profiles
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Nameplates.db)
	options.args.profile.order = 2
end

-- Slash commands
SLASH_NAMEPLATES1 = "/nameplates"
SLASH_NAMEPLATES2 = "/np"
SLASH_NAMEPLATES3 = "/nameplate"
SlashCmdList["NAMEPLATES"] = function(msg)
	if( not registered ) then
		if( not options ) then
			loadOptions()
		end

		config:RegisterOptionsTable("Nameplates", options)
		dialog:SetDefaultSize("Nameplates", 600, 500)
		registered = true
	end

	dialog:Open("Nameplates")
end

-- Add the general options + profile, we don't add spells/anchors because it doesn't support sub cats
local register = CreateFrame("Frame", nil, InterfaceOptionsFrame)
register:SetScript("OnShow", function(self)
	self:SetScript("OnShow", nil)
	loadOptions()

	config:RegisterOptionsTable("Nameplates-Bliz", {
		name = "Nameplates",
		type = "group",
		args = {
			help = {
				type = "description",
				name = string.format("Nameplates r%d is a basic nameplate modifier.", Nameplates.revision or 0),
			},
		},
	})
	
	dialog:SetDefaultSize("Nameplates-Bliz", 600, 400)
	dialog:AddToBlizOptions("Nameplates-Bliz", "Nameplates")
	
	config:RegisterOptionsTable("Nameplates-General", options.args.general)
	dialog:AddToBlizOptions("Nameplates-General", options.args.general.name, "Nameplates")

	config:RegisterOptionsTable("Nameplates-Profile", options.args.profile)
	dialog:AddToBlizOptions("Nameplates-Profile", options.args.profile.name, "Nameplates")
end)