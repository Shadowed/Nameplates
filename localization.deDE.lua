if( GetLocale() ~= "deDE" ) then
	return
end

NameplatesLocals = setmetatable({
}, {__index = NameplatesLocals})