#ifndef _AU_SRC_SERVER_MYSQL_MODULE_H_
#define _AU_SRC_SERVER_MYSQL_MODULE_H_
#include "modulebase.h"
#include <vector>
#include "Network/Network.h"
#include "CThreads.h"
#include "QueueNlock.h"
#include "Database/DatabaseEnv.h"

namespace Au
{
	class MysqlModule:public ModuleBase
	{
	public:
		MysqlModule();
		~MysqlModule();
		 bool Init();
		 bool Destroy();
		 bool Start();
		 bool CreateThreads(int thread_nums);

		 bool DoWork();
	public://Lua Interface
		QueryResult* query( const char* cmd ); 
		bool queryQueue(const char* cmd);
		int queryGetSize(int sizetype);
		bool StartSqlQueue();
		void AddSqlQueue(const char *querystring);
		bool EndSqlQueue();
		QueryResult* GetWorldQueueResult();
	
		uint32 getDatateID(const char *strKey);
		void loadDatabaseID();
	public:
		FQueue<char *>		  _tquerys;
		
		FQueue<char*>		  _querysin;
		FQueue<QueryResult*>  _tqueryout;
		FQueue<QueryResult*>  _querysout;
		Database *_db;

		std::vector<CThread*> _mysqlthreads;

		//
		std::string SecurityIP;// "127.0.0.1";
		std::map<std::string, uint32> databaseIdDict;

		bool _dbinitflag;
	};

}

#endif 