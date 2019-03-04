--ReloadLua.lua
ReloadLua = {}

--置空文件操作
function ReloadLua:setNull_files()
--	package.loaded["Config.Build.TEST"]  = nil
end

--重新加载文件操作
function ReloadLua:reload_files()
--	require "resource.script.server.Config.Build.TEST"
end

--只针对一些静态数据的更改操作
--对配置重加载操作
function ReloadLua:World_Reload_Files()
	self:setNull_files()
	self:reload_files()
end