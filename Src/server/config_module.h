#ifndef _AUENGINE_SRC_AUENGINE_CONFIG_MODULE_H_
#define _AUENGINE_SRC_AUENGINE_CONFIG_MODULE_H_
#include <map>
#include <vector>
#include <string>
#include "xmlplus.hpp"
#include "config_struct.h"
#include "Common.h"
#include "Singleton.h"
#include "launcher.h"
#include "messageconfig_reader.h"
#include "modulebase.h"

class TiXmlElement;
class XmlPlus;
namespace Au
{
class ConfigManager: public ModuleBase
{
public:
	ConfigManager();
	~ConfigManager();
	virtual bool Init();
	virtual bool Destroy();
	virtual bool Start();
	virtual bool CreateThreads(int n);
	bool LoadConfig(const char *filepath);
	

	//客户接口
public:
	MessageConfigReader* GetMessageConfig()
	{
		return &(ConfigManager::s_msgcfg);
	}
	
	LuaEngineInfo& GetLuaEngineInfo()
	{
		return _chunksinfo[Au::Launcher::s_nodename]._luainfo;
	}

	NetworkInfo* GetNetworkInfo(std::string server_name)
	{
		if (_chunksinfo.find(server_name)==_chunksinfo.end())
			return NULL;
		return  &(_chunksinfo[server_name]._networkinfo);
	}

	MemcachedInfo* GetMemcachedInfo(std::string server_name)
	{
		if (_chunksinfo.find(server_name)==_chunksinfo.end())
			return NULL;
		return &(_chunksinfo[server_name]._memcachedinfo);
	}
	MysqlInfo* GetMysqlInfo(std::string server_name)
	{
		if (_chunksinfo.find(server_name)==_chunksinfo.end())
			return NULL;
		return &(_chunksinfo[server_name]._mysqlinfo);
	}
	void ShowConfig();

private:
	bool LoadChunk1Info();
	bool LoadChunk2Info();
	bool LoadChunk3Info();
	bool LoadLuaMsgConfig(const char *filepath);
	bool ObtainServerKeyMap();
private:
	bool LoadLuaInfo(TiXmlNode *node, LuaEngineInfo&LEI);
	bool LoadNetWorkInfo(TiXmlNode *node, NetworkInfo &NI);
	bool LoadMemcachedInfo(TiXmlNode *node, MemcachedInfo &mi);
	bool LoadMysqlInfo(TiXmlNode *node, MysqlInfo &mi);
private:
	TiXmlNode* GetChunkElement(const char *chunk_name);
	TiXmlNode* EnterNode(TiXmlNode *node, const char* subnodename="");
	std::string GetEleText(TiXmlElement *elenode);
private:
	XmlPlus *_xmlplus;
	//std::string : chunk name
	std::map<std::string, ChunkInfo> _chunksinfo;
	
public:
	//value:key config by config file
	static MessageConfigReader s_msgcfg;
	static std::map<int , ServerSockNode> s_servermap;
};



}

#endif 