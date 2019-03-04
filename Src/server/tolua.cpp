#include "tolua.h"
#include <iostream>
#include <cstdlib>
#include <ctime>
#include "Common.h"
#include "Util.h"
#include "Log.h"
#include "Network/Network.h"

#include "aulistensock.h"
#include "config_struct.h"
#include "config_module.h"
#include "connsocket.h"
#include "gdata.h"
#include "msgpackager.h"
#include "modulemanager.h"
#include "mysql_module.h"
#include "memcached_module.h"
#include "oper_member.h"
#include "robots.h"
#include "robotthread.h"
#include "sockmgr.h"
#include "servermap.h"
#include "timer.h"

namespace Au
{

	bool RegisterModule(int moduleid)
	{
		bool ret = true;
		Au::ModuleBase *tmb = NULL;
		tmb = Au::ModuleManager::getSingletonPtr()->RegisterModule(moduleid);
		if (NULL==tmb)
			ret = false;
		return ret;
	}

	bool StartModule(int moduleid, int threadnum)
	{
		bool ret = true;
		Au::ModuleBase *tmb = Au::ModuleManager::getSingleton()[moduleid];
		if (tmb->CreateThreads(threadnum))
			ret = tmb->Start();
		
		return ret;
	}

	Au::ConnSocket* ConnectToServer(std::string server_name)
	{
		if (0==server_name.length())
			return NULL;
		Au::ConnSocket *tcs = NULL;
		string server_ip  ;
		string server_port;
		std::string self_account;
		int self_key = -1;
		NetworkInfo *self_ni = NULL;
		NetworkInfo *server_ni = NULL;
		Au::ConfigManager *tmm = dynamic_cast<Au::ConfigManager*>(Au::ModuleManager::getSingleton()[CONFIG_MODULE]);
		if (NULL==tmm)
			return NULL;
		self_ni = tmm->GetNetworkInfo(Au::Launcher::s_nodename);
	
		if (NULL==self_ni)
		{
			return NULL;
		}
		self_key = atoi(self_ni->_key.c_str());
		self_account = self_ni->_key;

		if (-1==self_key)
		{
			Log.outError("Got the key failured.\n");
			return NULL;
		}

		if (NULL==(server_ni=tmm->GetNetworkInfo(server_name)))
		{
			Log.outError("Get NetworkInfo failured, ConncetToServer Failured.\n");
			return NULL;
		}
		server_ip = server_ni->_ip;
		server_port = server_ni->_port;

		tcs = ConnectTCPSocket<Au::ConnSocket>(server_ip.c_str(), atoi(server_port.c_str()));
		if (NULL!=tcs && tcs->IsConnected())
		{
			LoginMsg tlm;
			tlm.msgLen = sizeof(LoginMsg);
			tlm.msgID = 0;
			tlm.playerID = (unsigned int)tcs->GetFd();
			tlm.key = 0;//标识是一般服务器的连接
			memset(tlm.accountID, 0, MAX_ACCOUNT_ID_SIZE);
			printf("%s:%d Got the key:%s\n", __FUNCTION__, __LINE__, self_account.c_str());
			memcpy(tlm.accountID, self_account.c_str(), self_account.length());
			tcs->Send((const uint8*)&tlm, tlm.msgLen);
			Log.outString("%p Connect Successed, then send the authentication msg.\n", tcs);

		}
		else
		{
			if (NULL==tcs)
			{
				Log.outError("tcs is null.\n");
			}
			Log.outError("Connect Server failured.\n");
		}
		return tcs;

	}

	void Listen()
	{
		string ip;
		string port;
		Au::ConfigManager *tcf = NULL;
		NetworkInfo *tni = NULL;
		ListenSocket<Au::AuListenSock> *listensock = NULL;
		tcf = dynamic_cast<Au::ConfigManager*>(Au::ModuleManager::getSingleton()[CONFIG_MODULE]);
		if (NULL==tcf)
		{
			Log.outError("Get ConfigManager failured.\n");
			return ;
		}
		tni = tcf->GetNetworkInfo(Au::Launcher::s_nodename);
		if (NULL==tni)
			return ;

		ip = tni->_ip;
		port = tni->_port;

		if (ip=="" || port=="")
			return ;
		listensock = new ListenSocket<Au::AuListenSock>(ip.c_str(), (unsigned int)atoi(port.c_str()));
		if (listensock->IsOpen())
		{
			Log.outString("%s:%d Listen Successed.\n", __FUNCTION__, __LINE__);
		}
		else
		{
			Log.outError("%s:%d\n", __FUNCTION__, __LINE__);
			return ;
		}
#ifdef WIN32
		ThreadPool.ExecuteTask(listensock);
#endif
	}

	unsigned int GetSockfdByServerName(std::string server_name)
	{
		std::map<int , ServerSockNode>::iterator iter_beg = Au::ConfigManager::s_servermap.begin();
		std::map<int , ServerSockNode>::iterator iter_end = Au::ConfigManager::s_servermap.end();
		while (iter_end!=iter_beg)
		{
			if (iter_beg->second._servername==server_name)
			{
				if (iter_beg->second._sockfd==AU_VALIDE_SOCKET_FD)
				{
					Log.outError("%s not connected.\n", server_name.c_str());
					return AU_VALIDE_SOCKET_FD;
				}
				else
					return iter_beg->second._sockfd;
			}
			++iter_beg;
		}
		return AU_VALIDE_SOCKET_FD;
	}

	//Robots
	void CreateRobots(int robot_num)
	{
		for (int i=0; i<robot_num; ++i)
		{
			CreateOneRobot();
		}
	}

	void CreateOneRobot()
	{
		Au::ConnSocket *tcs = NULL;
		tcs = ConnectToServer("Server");
		if (NULL!=tcs && tcs->IsConnected())
		{
			Log.outString("Robot Connect Successed.\n");
		}
		else
		{
			Log.outError("Robot Connect Failured.\n");
		}
	}

	void RobotStart()
	{
		if (!Au::GData::g_robotmodule)
		{
			Log.outError("RobotModule didn't registered.\n");
			return ;
		}
		Au::GData::g_robotmodule->Start();
		Log.outString("Robot Start Successed.\n");
	}

	int ValidateConnect(unsigned int sockid,const char* accountID)
	{
		return Au::SockMgr::getSingleton().ValidateSocket(sockid, accountID);
	}

	//DBoperator
	QueryResult* query(const char *cmd)
	{
		if (NULL==Au::GData::g_mysqlmodule)
		{
			Log.outError("Has MYSQL MODULE registered?\n");
			return NULL;
		}
		
		return Au::GData::g_mysqlmodule->query(cmd);
		
	}
		
	bool queryQueue(const char *cmd)
	{
		bool ret = true;
		if (NULL==Au::GData::g_mysqlmodule)
		{
			Log.outError("Has MYSQL MODULE registered?\n");
			return false;
		}
		Au::GData::g_mysqlmodule->queryQueue(cmd);
		return ret;
	}

	int queryGetSize(int sizetype)
	{
		if (NULL==Au::GData::g_mysqlmodule)
		{
			Log.outError("Has MYSQL MODULE registered?\n");
			return 0;
		}
		return Au::GData::g_mysqlmodule->queryGetSize(sizetype);
	}
	
	void StartSqlQueue()
	{
		if (NULL==Au::GData::g_mysqlmodule)
		{
			Log.outError("Has MYSQL MODULE registered?\n");
			return ;
		}

		Au::GData::g_mysqlmodule->StartSqlQueue();
		
	}

	void EndSqlQueue()
	{
		if (NULL==Au::GData::g_mysqlmodule)
		{
			Log.outError("Has MYSQL MODULE registered?\n");
			return ;
		}
		Au::GData::g_mysqlmodule->EndSqlQueue();

	}
	
	void AddSqlQueue(const char* QueryString)
	{
		if (NULL==Au::GData::g_mysqlmodule)
		{
			Log.outError("Has MYSQL MODULE registered?\n");
			return ;
		}
		Au::GData::g_mysqlmodule->AddSqlQueue(QueryString);

	}

	QueryResult* GetWorldQueueResult()
	{
		if (NULL==Au::GData::g_mysqlmodule)
		{
			Log.outError("Has MYSQL MODULE registered?\n");
			return NULL;
		}
		return Au::GData::g_mysqlmodule->GetWorldQueueResult();
	}

	uint32 getDatateID(const char* strKey)
	{
		printf("shit\n");
		if (!Au::GData::g_mysqlmodule)
		{
			Log.outError("MysqlModule Didn't registered.\n");
			return 0;
		}
		return Au::GData::g_mysqlmodule->getDatateID(strKey);
	}

	//End DBoperator
	//Memcached.
	void MemcachedAdd(std::string key, char* value, int value_len)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_ADD;
		to.item.mKey = key;
		to.item.mData.WriteBytes((void *)value, value_len);
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			Au::GData::g_memcachedmodule->HandleOne(to);
	
	}

	void MemcachedSet(std::string key, char *value, int value_len)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_SET;
		to.item.mKey = key;
		to.item.mData.WriteBytes((void *)value, value_len);
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			//Au::GData::g_memcachedmodule->AddOper(to);
			Au::GData::g_memcachedmodule->HandleOne(to);

	}

	void MemcachedReplace(std::string key, char *value, int value_len)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_REPLACE;
		to.item.mKey = key;
		to.item.mData.WriteBytes((void *)value, value_len);
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			Au::GData::g_memcachedmodule->HandleOne(to);
	}

	void MemcachedAppend(std::string key, char *value, int value_len)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_APPEND;
		to.item.mKey = key;
		to.item.mData.WriteBytes((void *)value, value_len);
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			Au::GData::g_memcachedmodule->HandleOne(to);
	}

	void MemcachedPrepend(std::string key, char *value, int value_len)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_PREPEND;
		to.item.mKey = key;
		to.item.mData.WriteBytes((void *)value, value_len);
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			Au::GData::g_memcachedmodule->HandleOne(to);
	}

	void MemcachedIncrement(std::string key, int diff)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_INCREMENT;
		to.item.mKey = key;
		to.diff = (MemCacheClient::uint64_t)diff;
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			Au::GData::g_memcachedmodule->HandleOne(to);

	}

	void MemcachedDecrement(std::string key, int diff)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_DECREMENT;
		to.item.mKey = key;
		to.diff = (MemCacheClient::uint64_t)diff;
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			Au::GData::g_memcachedmodule->HandleOne(to);
	}

	void MemcachedDel(std::string key)
	{
		Oper to;
		to.opertype = MEMCACHED_OPER_DEL;
		to.item.mKey = key;
		if (NULL==Au::GData::g_memcachedmodule)
			Log.outError("Have you Register Memcached Module Successed?\n");
		else 
			Au::GData::g_memcachedmodule->HandleOne(to);
	}
	
	std::string MemcachedGet(std::string key, int icount)
	{
		std::string ret;
		if (NULL==Au::GData::g_memcachedmodule)
		{
			Log.outError("Have you Register Memcached Module Successed?\n");
		}
		else
			ret = Au::GData::g_memcachedmodule->Get(key, icount);
		return ret;
	}
	
	int GetConnSocks()
	{
		int cnt = -1;
		cnt = Au::SockMgr::getSingleton().GetConnSocks();
		return cnt;
	}

	int nowTime()
	{
		int nowtime =(int)time(NULL); 
		return nowtime;
	}


	void initRandSeek()
	{
		srand( (unsigned)time(NULL));
	}
	//随机数
	int auRand() 
	{ 
		int rrand = rand();
		srand( (unsigned)time(NULL) * rrand);
		return rrand;
	}
	//添加一个状态位
	int bitAddState(int state, int pos)
	{
		if (pos < 1 || pos > 32)
			return state;
		return state | (1 << (pos - 1));
	}
	//删除一个状态位
	int bitDelState(int state, int pos)
	{
		if (pos < 1 || pos > 32)
			return state;
		return state & (~(1 << (pos - 1)));
	}
	//检查一个状态位
	int bitCheckState(int state, int pos)
	{
		if (pos < 1 || pos > 32)
			return 0;
		int b = state & 1<< (pos - 1);
		int r = b?1:0;
		return r;
	}

}//namespace Au



