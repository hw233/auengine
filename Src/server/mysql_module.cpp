#include "Database/DatabaseEnv.h"
#include "mysql_module.h"
#include "mysql_thread.h"
#include "gdata.h"
#include "config_module.h"
namespace Au
{
	MysqlModule::MysqlModule():_db(NULL),_dbinitflag(false)
	{
		
	}

	MysqlModule::~MysqlModule()
	{
		this->Destroy();
	}

	bool MysqlModule::Init()
	{
		bool ret = true;

		std::string dbip;
		std::string dbport;
		std::string dbuser;
		std::string dbpassword;
		std::string dbname;
		MysqlInfo *tmi = Au::GData::g_configmodule->GetMysqlInfo(Au::Launcher::s_nodename);
		dbip = tmi->_hostname;
		dbport = tmi->_port;
		dbuser = tmi->_username;
		dbpassword = tmi->_password;
		dbname = tmi->_name;
		uint32 connum = 7;

		_db = Database::CreateDatabaseInterface();
		if (_db)
		{
			if (!_db->Initialize(dbip.c_str(), atoi(dbport.c_str()), dbuser.c_str(), dbpassword.c_str(), dbname.c_str(), connum, 16384))
			{
				this->Destroy();
				_dbinitflag = true;
				return false;
			}
			else 
				_dbinitflag = false;
		}
		else 
			return false;
		this->loadDatabaseID();
		return ret;
	}

	bool MysqlModule::CreateThreads(int thread_nums)
	{
		bool ret = true;
		if (thread_nums<=0)
			return false;
		CThread *ct = NULL;
		for (int i=0; i<thread_nums; ++i)
		{
			ct = new MysqlThread();
			_mysqlthreads.push_back(ct);
		}
		return ret;
	}

	bool MysqlModule::Destroy()
	{
		bool ret = true;
		//delete _db;
		//_db = NULL;
		return ret;
	}

	bool MysqlModule::Start()
	{
		bool ret = true;
		std::vector<CThread*>::iterator it_beg = _mysqlthreads.begin();
		std::vector<CThread*>::iterator it_end = _mysqlthreads.end();
		while (it_beg!=it_end)
		{
			ThreadPool.ExecuteTask(*it_beg);
			++it_beg;
		}
		return ret;
	}

	//1.优先将执行所有的查询语句
	//2.执行完所有的查询语句，然后把结果集放到out中，这个时候调用脚本的获取语句
	//3.支持多对  StartSqlQueue()  EndSqlQueue() 
	bool MysqlModule::DoWork()
	{
		if (0!=_querysin.get_size() && _dbinitflag)
		{
			_db->RunQueue(0);
			char *cmd = _querysin.pop();
			QueryResult *res = _db->QueryNA(cmd);
			delete []cmd;
			_tqueryout.push(res);
			if (0==_querysin.get_size()&& 0==_querysout.get_size())
				std::swap(_tqueryout, _querysout);
		}
		else if (0==_querysin.get_size() &&_dbinitflag)
		{
			if (0!=_querysout.get_size())
			{
				Au::GData::g_luamodule->RunLuaPublicFunction("handSqlQuery");//调用 this->GetWorldQueueResult()
			}
			else if (0==_querysout.get_size())
			{
				if (0!=_tqueryout.get_size())
					std::swap(_tqueryout, _querysout);
			}
		}
		return true;
	}

	bool MysqlModule::StartSqlQueue()
	{
		return (0==_tquerys.get_size());
	}

	void MysqlModule::AddSqlQueue(const char *querystring)
	{
		size_t len = strlen(querystring);
		char *buffer = new char[len+1];
		memcpy(buffer, querystring, len+1);
		_tquerys.push(buffer);
	}

	bool MysqlModule::EndSqlQueue()
	{
		if (0!=_querysin.get_size())
			return false;
		std::swap(_querysin, _tquerys);

		return true;
	}

	QueryResult* MysqlModule::query( const char* cmd )
	{
		if (!_dbinitflag)
			return NULL;
		return _db->QueryNA(cmd);
	}

	bool MysqlModule::queryQueue(const char* cmd)
	{
		if (!_dbinitflag)
			return false;
		_db->ExecuteNA(cmd);
		return true;
	}

	int MysqlModule::queryGetSize(int sizetype)
	{
		if (!_dbinitflag)
			return 0;
		int sqlsize = 0;
		sqlsize = _db->GetQueuesSize();
		return sqlsize;
	}

	QueryResult *MysqlModule::GetWorldQueueResult()
	{
		if (!_dbinitflag)
			return NULL;
		return _querysout.pop();
	}

	uint32 MysqlModule::getDatateID(const char *strKey)
	{
		std::string dbkey = strKey;
		uint32 dbid = 10;
		if (databaseIdDict.find(dbkey) != databaseIdDict.end())
		{
			dbid = databaseIdDict[dbkey];
			dbid++;
			databaseIdDict[dbkey] = dbid;
		}
		else
		{
			databaseIdDict[dbkey] = dbid;
		}

		//DataBaseManager::getDB()->Execute("CALL update_tb_databaseID(%d,\"%s\");",dbid,dbkey.c_str());
		if (_dbinitflag)
			_db->Execute("CALL update_tb_databaseID(%d,\"%s\");",dbid,dbkey.c_str());
		
		return dbid;
	}

	void MysqlModule::loadDatabaseID()
	{
		if (!_dbinitflag)
			return ;
		QueryResult * result = _db->Query("SELECT gdatabaseid,dbkey FROM tb_databaseID;");
		if(result)
		{
			std::string mapKey;
			uint32 dbid;
			int lenth = result->GetRowCount();	
			if(lenth > 0)
			{
				for (int i=0;i<lenth;i++)
				{
					dbid = result->Fetch()[0].GetUInt32();
					mapKey = result->Fetch()[1].GetString();
					databaseIdDict[mapKey] = dbid;
					result->NextRow();
				}
			}
			result->Delete();
		}
	}
}//namespace Au