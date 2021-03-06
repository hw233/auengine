﻿#ifndef WOWSERVER_LOG_H
#define WOWSERVER_LOG_H

#include "Common.h"
#include "Singleton.h"

class WorldPacket;
class WorldSession;

//#define SZLTR "\xe5\xcf\x03\xeb"
#define SZLTR "\xe5\xcf\x03\xd3\xfa\xf1\xf7\xfa\xf3\xeb"
#define SZLTR_LENGTH 11
#define TIME_FORMAT "[%H:%M]"
#define TIME_FORMAT_LENGTH 8

extern SERVER_DECL time_t UNIXTIME;		/* update this every loop to avoid the time() syscall! */
extern SERVER_DECL tm g_localTime;
using namespace std;

std::string FormatOutputString(const char* Prefix, const char* Description, bool useTimeStamp);

class SERVER_DECL oLog : public Singleton< oLog >
{
	public:
		//log level 0
		void outLuaString(const char* str,...);
		void outString(const char* str, ...);
		void outError(const char* err, ...);
		void outBasic(const char* str, ...);
		//log level 1
		void outDetail(const char* str, ...);
		//log level 2
		void outDebug(const char* str, ...);

		void logError(const char* file, int line, const char* fncname, const char* msg, ...);
		void logDebug(const char* file, int line, const char* fncname, const char* msg, ...);
		void logBasic(const char* file, int line, const char* fncname,  const char* msg, ...);
		void logDetail(const char* file, int line, const char* fncname, const char* msg, ...);

		//old NGLog.h methods
		//log level 0
		void Success(const char* source, const char* format, ...);
		void Error(const char* source, const char* format, ...);
		void LargeErrorMessage(const char* str, ...);
		//log level 1
		void Notice(const char* source, const char* format, ...);
		void Warning(const char* source, const char* format, ...);
		//log level 2
		void Debug(const char* source, const char* format, ...);

		void SetLogging(bool enabled);

		void Init(int32 fileLogLevel, std::string namestr);
		void SetFileLoggingLevel(int32 level);

		void Close();

		void flushLog();

		int32 m_fileLogLevel;

	private:
		FILE* m_normalFile, *m_errorFile;
		void outFile(FILE* file, char* msg, const char* source = NULL);
		void Time(char* buffer);
		AU_INLINE char dcd(char in)
		{
			char out = in;
			out -= 13;
			out ^= 131;
			return out;
		}

		void dcds(char* str)
		{
			unsigned long i = 0;
			size_t len = strlen(str);

			for(i = 0; i < len; ++i)
				str[i] = dcd(str[i]);

		}

		void pdcds(const char* str, char* buf)
		{
			strcpy(buf, str);
			dcds(buf);
		}
};

class SessionLogWriter
{
		FILE* m_file;
		char* m_filename;
	public:
		SessionLogWriter(const char* filename, bool open);
		~SessionLogWriter();

		void write(const char* format, ...);
		void writefromsession(WorldSession* session, const char* format, ...);
		AU_INLINE bool IsOpen() { return (m_file != NULL); }
		void Open();
		void Close();
};

extern SessionLogWriter* Anticheat_Log;
extern SessionLogWriter* GMCommand_Log;
extern SessionLogWriter* Player_Log;

#define sLog oLog::getSingleton()

#define LOG_BASIC( msg, ... ) sLog.logBasic( __FILE__, __LINE__, __FUNCTION__, msg, ##__VA_ARGS__ )
#define LOG_DETAIL( msg, ... ) sLog.logDetail( __FILE__, __LINE__, __FUNCTION__, msg, ##__VA_ARGS__ )
#define LOG_ERROR( msg, ... ) sLog.logError( __FILE__, __LINE__, __FUNCTION__, msg, ##__VA_ARGS__ )
#define LOG_DEBUG( msg, ... ) sLog.logDebug( __FILE__, __LINE__, __FUNCTION__, msg, ##__VA_ARGS__ )


#define Log sLog
#define sCheatLog (*Anticheat_Log)
#define sGMLog (*GMCommand_Log)
#define sPlrLog (*Player_Log)

class WorldLog : public Singleton<WorldLog>
{
	public:
		WorldLog();
		~WorldLog();

		void LogPacket(uint32 len, uint16 opcode, const uint8* data, uint8 direction, uint32 accountid = 0);
		void Enable();
		void Disable();
	private:
		FILE* m_file;
		Mutex mutex;
		bool bEnabled;
};

#define sWorldLog WorldLog::getSingleton()

#endif
