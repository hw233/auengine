#ifndef _DATABASE_H
#define _DATABASE_H

#include <string>
#include "../Threading/Queue.h"
#include "../CallBack.h"

using namespace std;
class QueryResult;
class QueryThread;
class Database;

struct DatabaseConnection
{
	Mutex Busy;
};

struct SERVER_DECL AsyncQueryResult
{
	QueryResult* result;
	char* query;
};

class SERVER_DECL AsyncQuery
{
		friend class Database;
		SQLCallbackBase* func;
		vector<AsyncQueryResult> queries;
		Database* db;
	public:
		AsyncQuery(SQLCallbackBase* f) : func(f) {}
		~AsyncQuery();
		void AddQuery(const char* format, ...);
		void Perform();
		AU_INLINE void SetDB(Database* dbb) { db = dbb; }
};

class SERVER_DECL QueryBuffer
{
		vector<char*> queries;
	public:
		friend class Database;
		void AddQuery(const char* format, ...);
		void AddQueryNA(const char* str);
		void AddQueryStr(const string & str);
};

class SERVER_DECL Database : public CThread
{
		friend class QueryThread;
		friend class AsyncQuery;
	public:
		Database();
		virtual ~Database();

		/************************************************************************/
		/* Thread Stuff                                                         */
		/************************************************************************/
		bool run();

		/************************************************************************/
		/* Virtual Functions                                                    */
		/************************************************************************/
		virtual bool Initialize(const char* Hostname, unsigned int port,
		                        const char* Username, const char* Password, const char* DatabaseName,
		                        uint32 ConnectionCount, uint32 BufferSize) = 0;

		virtual void Shutdown() = 0;

		virtual QueryResult* Query(const char* QueryString, ...);
		virtual QueryResult* QueryNA(const char* QueryString);
		virtual QueryResult* FQuery(const char* QueryString, DatabaseConnection* con);
		virtual void FWaitExecute(const char* QueryString, DatabaseConnection* con);
		virtual bool WaitExecute(const char* QueryString, ...);//Wait For Request Completion
		virtual bool WaitExecuteNA(const char* QueryString);//Wait For Request Completion
		virtual bool Execute(const char* QueryString, ...);
		virtual bool ExecuteNA(const char* QueryString);
		virtual bool ExecuteNAIndex(const char* QueryString,int index);

		// Initialized on load: Database::Database() : CThread()
		bool ThreadRunning;

		AU_INLINE const string & GetHostName() { return mHostname; }
		AU_INLINE const string & GetDatabaseName() { return mDatabaseName; }
		AU_INLINE const uint32 GetQueueSize() { return queries_queue.get_size(); }
		AU_INLINE const uint32 GetQueuesSize() {
			int lenth = 0;
			int tsize;
			tsize = queries_queue.get_size();
			lenth = lenth + tsize;
			tsize = queries_queue1.get_size();
			lenth = lenth + tsize;
			tsize = queries_queue2.get_size();
			lenth = lenth + tsize;
			tsize = queries_queue3.get_size();
			lenth = lenth + tsize;
			tsize = queries_queue4.get_size();
			lenth = lenth + tsize;
			tsize = queries_queue5.get_size();
			lenth = lenth + tsize;
			return lenth; 
		}

		virtual string EscapeString(string Escape) = 0;
		virtual void EscapeLongString(const char* str, uint32 len, stringstream & out) = 0;
		virtual string EscapeString(const char* esc, DatabaseConnection* con) = 0;

		void QueueAsyncQuery(AsyncQuery* query);
		void EndThreads();
		bool RunQueue(int index = 0);
		void thread_proc_query();
		void FreeQueryResult(QueryResult* p);
		void StartThreads();

		DatabaseConnection* GetFreeConnection();

		void PerformQueryBuffer(QueryBuffer* b, DatabaseConnection* ccon);
		void AddQueryBuffer(QueryBuffer* b);

		static Database* CreateDatabaseInterface();
		static void CleanupLibs();

		virtual bool SupportsReplaceInto() = 0;
		virtual bool SupportsTableLocking() = 0;

	protected:

		// spawn threads and shizzle
		void _Initialize();
		
		virtual void _BeginTransaction(DatabaseConnection* conn) = 0;
		virtual void _EndTransaction(DatabaseConnection* conn) = 0;

		// actual query function
		virtual bool _SendQuery(DatabaseConnection* con, const char* Sql, bool Self) = 0;
		virtual QueryResult* _StoreQueryResult(DatabaseConnection* con) = 0;

		////////////////////////////////
		FQueue<QueryBuffer*> query_buffer;

		////////////////////////////////
		FQueue<char*> queries_queue;
		FQueue<char*> queries_queue1;
		FQueue<char*> queries_queue2;
		FQueue<char*> queries_queue3;
		FQueue<char*> queries_queue4;
		FQueue<char*> queries_queue5;
		DatabaseConnection** Connections;

		uint32 _counter;
		///////////////////////////////

		int32 mConnectionCount;

		// For reconnecting a broken connection
		string mHostname;
		string mUsername;
		string mPassword;
		string mDatabaseName;
		uint32 mPort;

		QueryThread* qt;
};


class SERVER_DECL QueryResult
{ 
	static Field* s_field;
	public:
		QueryResult(uint32 fields, uint32 rows) : mFieldCount(fields), mRowCount(rows), mCurrentRow(NULL) {}
		virtual ~QueryResult() {}

		virtual bool NextRow() = 0;
		void Delete() { delete this; }

		AU_INLINE Field* Fetch() { return mCurrentRow; }
		AU_INLINE Field* GetFieldFromCount(uint32 i){
			if (i >= mFieldCount)
			{
				s_field->SetValue((char*)"0");
				Log.outError("Error Occur Arg: sql data Error In function GetFieldFromCount(%d).",i);
				return s_field;
			}
			return &(mCurrentRow[i]);
		}
		AU_INLINE uint32 GetFieldCount() const { return mFieldCount; }
		AU_INLINE uint32 GetRowCount() const { return mRowCount; }

	protected:
		uint32 mFieldCount;
		uint32 mRowCount;
		Field* mCurrentRow;
};


class SERVER_DECL QueryThread : public CThread
{
		friend class Database;
		Database* db;
	public:
		QueryThread(Database* d) : CThread(), db(d) {}
		~QueryThread();
		bool run();
};

#endif
