#ifndef _TOLUA_H_
#define _TOLUA_H_
#include <string>
#include "connsocket.h"
#include "mysql_module.h"
#include "MemCacheClient.h"
#include "timer.h"

namespace Au
{


	int ValidateConnect(unsigned int sockid,const char* accountID);

	bool RegisterModule(int moduleid);
	bool StartModule(int moduleid, int threadnum=1);
	Au::ConnSocket* ConnectToServer(std::string server_name);
	void Listen();

	unsigned int GetSockfdByServerName(std::string server_name);

}

namespace Au
{
	void CreateRobots(int robot_num);
	void CreateOneRobot();
	void RobotStart();
}

namespace Au
{
	QueryResult* query( const char* cmd ); 
	bool queryQueue(const char* pszCommand);
	int queryGetSize(int sizetype);

	void StartSqlQueue();
	void EndSqlQueue();
	void AddSqlQueue(const char* QueryString);

	QueryResult* GetWorldQueueResult();
	uint32 getDatateID(const char* strKey);

}

namespace Au
{
	void MemcachedAdd(std::string key, char *value, int value_len);
	void MemcachedSet(std::string key, char *value, int value_len);
	void MemcachedReplace(std::string key, char *new_value, int value_len);
	void MemcachedAppend(std::string key, char *value, int value_len);
	void MemcachedPrepend(std::string key, char *value, int value_len);
	void MemcachedIncrement(std::string key, int diff);
	void MemcachedDecrement(std::string key, int diff);
	void MemcachedDel(std::string key);	
	std::string MemcachedGet(std::string key, int icount = 1);

}

namespace Au
{
	int GetConnSocks();
}


namespace Au
{
	int nowTime();

}

namespace Au
{
	int	auRand();
	int bitAddState(int state, int pos);
	int bitDelState(int state, int pos);
	int bitCheckState(int state, int pos);
	void initRandSeek();
}

#endif