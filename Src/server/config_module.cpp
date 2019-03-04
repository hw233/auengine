#include <iostream>
#include <stdio.h>
#include <string.h>
#include "config_module.h"
#include <algorithm>
#include "tinyxml.h"
#include "Log.h"
#include "modulebase.h"
#include "safe_tech.hpp"
#include "Singleton.h"
#include "launcher.h"

initialiseSingleton(Au::ConfigManager);

namespace Au
{
	ConfigManager::ConfigManager()
	{
		_xmlplus = NULL;
	}

	ConfigManager::~ConfigManager()
	{
		
	}

	bool ConfigManager::Init()
	{
		ChunkInfo tci1;
		ChunkInfo tci2;
		ChunkInfo tci3;
		_chunksinfo[CHUNK_1] = tci1;
		_chunksinfo[CHUNK_2] = tci2;
		_chunksinfo[CHUNK_3] = tci3;
		return true;
	}

	bool ConfigManager::Start()
	{
		return true;
	}

	bool ConfigManager::CreateThreads(int n)
	{
		return true;
	}

	bool ConfigManager::Destroy()
	{
		return true;
	}
	
	bool ConfigManager::LoadConfig(const char *filepath)
	{
		bool ret = true;;
		 _xmlplus = new XmlPlus(filepath);
		if (!_xmlplus->isGood())
		{
			//Log.outError("LoadConfig faiured.\n"); 
			SAFE_RELEASE(_xmlplus);
			return false;
		}

		if (!this->LoadChunk1Info())
		{
			SAFE_RELEASE(_xmlplus);
			return false;
		}
		if (!this->LoadChunk2Info())
		{
			SAFE_RELEASE(_xmlplus);
			return false;
		}
		if (!this->LoadChunk3Info())
		{
			SAFE_RELEASE(_xmlplus);
			return false;
		}

		this->ShowConfig();
		if (!Au::ConfigManager::LoadLuaMsgConfig(_chunksinfo[Au::Launcher::s_nodename]._luainfo._msgconfigfilepath.c_str()))
		{
			SAFE_RELEASE(_xmlplus);
			return false;
		}
		if (!this->ObtainServerKeyMap())
		{
			SAFE_RELEASE(_xmlplus);
			return false;
		}
		SAFE_RELEASE(_xmlplus);
		return ret;
	}

	TiXmlNode* ConfigManager::GetChunkElement(const char *chunk_name)
	{
		TiXmlNode *chunknode = NULL;		
		chunknode = _xmlplus->getRootElement()->FirstChild(chunk_name);
		return chunknode;
	}

	TiXmlNode* ConfigManager::EnterNode(TiXmlNode *node, const char* subnodename)
	{
		if (NULL==node)
			return NULL;
		if (strcmp(subnodename,"")==0)
			return node->FirstChild();
		TiXmlNode *sub = node->FirstChild();
		while (sub)
		{
			if (strcmp(sub->ToElement()->Value(), subnodename)==0)
				return sub;
			sub = sub->NextSibling();
		}
		return sub;
	}

	bool ConfigManager::LoadLuaInfo(TiXmlNode *node, LuaEngineInfo &lei)
	{
		bool ret = true;
		if (NULL==node)
			return false;
		TiXmlNode *tnode = node->FirstChildElement();
		while (tnode)
		{
			if (0==strcmp(tnode->Value(), LUAENGINE_ENTRANCELUAFILE_NODE))
				lei._entrance_luafile = std::string(tnode->ToElement()->GetText());
			else if (0==strcmp(tnode->Value(), LUAENGINE_INITENGINEFUNC_NODE))
				lei._initenginefunc = std::string(tnode->ToElement()->GetText());
			else if (0==strcmp(tnode->Value(), LUAENGINE_MESSAGECONFIGFILEPATH_NODE))
				lei._msgconfigfilepath = std::string(tnode->ToElement()->GetText());
			else if (0==strcmp(tnode->Value(), LUAENGINE_SCRIPTINITFUNC_NODE))
				lei._scriptinitfunc = std::string(tnode->ToElement()->GetText());
			tnode = tnode->NextSibling();
		}
		return ret;
	}

	bool ConfigManager::LoadNetWorkInfo(TiXmlNode *node, NetworkInfo &ni)
	{
		bool ret = true;
		if (NULL==node)
			return false;

		TiXmlElement *tnode = node->FirstChildElement();
		while(tnode)
		{	
			if (0==strcmp(tnode->ValueTStr().c_str(), NETWORK_KEY))
				ni._key = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), NETWORK_TYPE))
				ni._type = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), NETWORK_IP))
				ni._ip = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), NETWORK_PORT))
				ni._port = std::string(tnode->GetText());
			tnode = tnode->NextSiblingElement();
		}
		return ret;
	}
	
	bool ConfigManager::LoadMemcachedInfo(TiXmlNode *node, MemcachedInfo &mi)
	{
		bool ret = true;
		if (NULL==node)
			return false;
		TiXmlElement *tnode = node->FirstChildElement();
		while (tnode)
		{
			if (0==strcmp(tnode->ValueTStr().c_str(), MEMCACHED_TYPE))
				mi._type = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), MEMCACHED_NAME))
				mi._name = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), MEMCACHED_IP))
				mi._ip = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), MEMCACHED_PORT))
				mi._port = std::string(tnode->GetText());
			else
				return false;
			tnode = tnode->NextSiblingElement();
		}
		return ret;
	}

	bool ConfigManager::LoadMysqlInfo(TiXmlNode *node, MysqlInfo &mi)
	{
		bool ret = true;
		if (NULL==node)
			return false;
		TiXmlElement *tnode = node->FirstChildElement();
		while (tnode)
		{
			if (0==strcmp(tnode->ValueTStr().c_str(), MYSQL_HOSTNAME))
				mi._hostname = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), MYSQL_USERNAME))
				mi._username = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), MYSQL_PASSWORD))
				mi._password = this->GetEleText(tnode);
			else if (0==strcmp(tnode->ValueTStr().c_str(), MYSQL_NAME))
				mi._name = std::string(tnode->GetText());
			else if (0==strcmp(tnode->ValueTStr().c_str(), MYSQL_PORT))
				mi._port = std::string(tnode->GetText());
			else
				return false;
			tnode = tnode->NextSiblingElement();
		}
		return ret;
	}

	void ConfigManager::ShowConfig()
	{
//#define SHOW_CONFIG_INFO
#ifdef  SHOW_CONFIG_INFO
		printf("chunk:%s:\n",CHUNK_1);

		printf("LuaEngineInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_1]._luainfo._entrance_luafile.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._luainfo._initenginefunc.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._luainfo._msgconfigfilepath.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._luainfo._scriptinitfunc.c_str());

		printf("NetworkInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_1]._networkinfo._ip.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._networkinfo._key.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._networkinfo._port.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._networkinfo._type.c_str());
		printf("...\n");

		printf("MemcachedInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_1]._memcachedinfo._type.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._memcachedinfo._name.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._memcachedinfo._ip.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._memcachedinfo._port.c_str());
		printf("...\n");

		printf("MysqlInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_1]._mysqlinfo._hostname.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._mysqlinfo._username.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._mysqlinfo._password.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._mysqlinfo._name.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_1]._mysqlinfo._port.c_str());
		printf("...\n");



		printf("chunk:%s:\n",CHUNK_2);

		printf("LuaEngineInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_2]._luainfo._entrance_luafile.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_2]._luainfo._initenginefunc.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_2]._luainfo._msgconfigfilepath.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_2]._luainfo._scriptinitfunc.c_str());

		printf("NetworkInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_2]._networkinfo._ip.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_2]._networkinfo._key.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_2]._networkinfo._port.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_2]._networkinfo._type.c_str());
		printf("...\n");

		printf("chunk:%s:\n",(CHUNK_3));

		printf("LuaEngineInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_3]._luainfo._entrance_luafile.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_3]._luainfo._initenginefunc.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_3]._luainfo._msgconfigfilepath.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_3]._luainfo._scriptinitfunc.c_str());

		printf("NetworkInfo\n");
		printf("\t%s \n", _chunksinfo[CHUNK_3]._networkinfo._ip.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_3]._networkinfo._key.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_3]._networkinfo._port.c_str());
		printf("\t%s \n", _chunksinfo[CHUNK_3]._networkinfo._type.c_str());
		printf("...\n");
#endif

	}

	bool ConfigManager::LoadChunk1Info()
	{
		bool ret = true;
		TiXmlNode *father = this->GetChunkElement(CHUNK_1);
		TiXmlNode *chunknode = NULL;
		if (NULL!=father)
		{
			chunknode = this->EnterNode(father, LUA_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadLuaInfo(chunknode, _chunksinfo[CHUNK_1]._luainfo))
				return false;
			
			chunknode = this->EnterNode(father, NETWORK_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadNetWorkInfo(chunknode,_chunksinfo[CHUNK_1]._networkinfo))
				return false;
		
			chunknode = this->EnterNode(father, MEMCACHED_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadMemcachedInfo(chunknode, _chunksinfo[CHUNK_1]._memcachedinfo))
				return false;

			chunknode = this->EnterNode(father, MYSQL_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadMysqlInfo(chunknode, _chunksinfo[CHUNK_1]._mysqlinfo))
				return false;
		}
		return ret;
	}

	bool ConfigManager::LoadChunk2Info()
	{		
		bool ret = true;
		TiXmlNode *father = this->GetChunkElement(CHUNK_2);
		TiXmlNode *chunknode = NULL;
		if (NULL!=father)
		{
			chunknode = this->EnterNode(father, LUA_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadLuaInfo(chunknode, _chunksinfo[CHUNK_2]._luainfo))
				return false;
			chunknode = this->EnterNode(father, NETWORK_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadNetWorkInfo(chunknode,_chunksinfo[CHUNK_2]._networkinfo))
				return false;

		}
		return ret;
	}

	bool ConfigManager::LoadChunk3Info()
	{
		bool ret = true;
		TiXmlNode *father = this->GetChunkElement(CHUNK_3);
		TiXmlNode *chunknode = NULL;
		if (NULL!=father)
		{
			chunknode = this->EnterNode(father, LUA_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadLuaInfo(chunknode, _chunksinfo[CHUNK_3]._luainfo))
				return false;
			chunknode = this->EnterNode(father, NETWORK_INFO);
			if (NULL==chunknode)
			{
				return false;
			}
			if (!this->LoadNetWorkInfo(chunknode,_chunksinfo[CHUNK_3]._networkinfo))
				return false;

		}
		return ret;
	}

	bool ConfigManager::LoadLuaMsgConfig(const char *filepath)
	{
		return (ConfigManager::s_msgcfg.ReadConfig(filepath));
		ConfigManager::s_msgcfg.ShowAll();
	}

	bool ConfigManager::ObtainServerKeyMap()
	{
		
		if (_chunksinfo.end()!=_chunksinfo.find(CHUNK_1))
		{
			if (_chunksinfo[CHUNK_1]._networkinfo._key.length()!=0)
			{
				int key = -1;
				key = atoi(_chunksinfo[CHUNK_1]._networkinfo._key.c_str());
				//这个地方发布的时候要改成 >0 ，所有的服务器的key必须大于0， 0是留给玩家连接使用的。因为现在Robot被当做客户端配置key为0了
				if (key>=0)
				{
					if (ConfigManager::s_servermap.end()==ConfigManager::s_servermap.find(key))
					{
						ServerSockNode tssn;
						tssn._servername = CHUNK_1;
						ConfigManager::s_servermap[key] = tssn;
					}
					else
					{
						Log.outError("Different Server Used the same key:%d\n", key);
						return false;
					}
				}
				else
				{
					Log.outError("Can't use unpositive key:%d\n", key);
					return false;
				}
			}
		}

		if (_chunksinfo.end()!=_chunksinfo.find(CHUNK_2))
		{
			if (_chunksinfo[CHUNK_2]._networkinfo._key.length()!=0)
			{
				int key = -1;
				key = atoi(_chunksinfo[CHUNK_2]._networkinfo._key.c_str());
				if (key>=0)
				{
					if (ConfigManager::s_servermap.end()==ConfigManager::s_servermap.find(key))
					{
						ServerSockNode tssn;
						tssn._servername = CHUNK_2;
						ConfigManager::s_servermap[key] = tssn;
					}
					else
					{
						Log.outError("Different Server Used the same key:%d\n", key);
						return false;
					}
				}
				else
				{
					Log.outError("Can't use unpositive key:%d\n", key);
					return false;
				}
			}
		}

		if (_chunksinfo.end()!=_chunksinfo.find(CHUNK_3))
		{
			if (_chunksinfo[CHUNK_3]._networkinfo._key.length()!=0)
			{
				int key = -1;
				key = atoi(_chunksinfo[CHUNK_3]._networkinfo._key.c_str());
				if (key>=0) 
				{
					if (ConfigManager::s_servermap.end()==ConfigManager::s_servermap.find(key))
					{
						ServerSockNode tssn;
						tssn._servername = CHUNK_3;
						ConfigManager::s_servermap[key] = tssn;
					}
					else
					{
						Log.outError("Different Server Used the same key:%d\n", key);
						return false;
					}
				}
				else
				{
					Log.outError("Can't use unpositive key:%d\n", key);
					return false;
				}
			}
		}

		return true;
	}

	std::string ConfigManager::GetEleText(TiXmlElement *elenode)
	{
		if (elenode)
		{
			if (elenode->GetText())
				return std::string(elenode->GetText());
			else
				return std::string("");
		}
		else 
			return std::string("");
		return std::string("");
	}

	std::map<int, ServerSockNode> ConfigManager::s_servermap;
	MessageConfigReader ConfigManager::s_msgcfg;
	
}//namespace Au