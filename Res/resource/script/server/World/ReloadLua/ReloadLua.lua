--ReloadLua.lua
ReloadLua = {}

--�ÿ��ļ�����
function ReloadLua:setNull_files()
--	package.loaded["Config.Build.TEST"]  = nil
end

--���¼����ļ�����
function ReloadLua:reload_files()
--	require "resource.script.server.Config.Build.TEST"
end

--ֻ���һЩ��̬���ݵĸ��Ĳ���
--�������ؼ��ز���
function ReloadLua:World_Reload_Files()
	self:setNull_files()
	self:reload_files()
end