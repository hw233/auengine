#ifndef _AU_SRC_SERVER_TIMER_H_
#define _AU_SRC_SERVER_TIMER_H_
#include "timerinfo.h"
#include <map>
#include <vector>
#include "Network/Network.h"
//#include "../Common.h"
#include "Threading/Mutex.h"

namespace Au
{

	extern int addTimer( int start, int interval, const char* luaFunc,int param1 = 0, int param2 = 0);
	extern void stopTimer( int timeID );
	extern bool TickTimer(int dTime);
	extern Mutex g_timermutex;
class Timer
{
public:
	static Timer& getInstance() { static Timer s_timer; return s_timer;}

	Timer(void);
	~Timer(void);

	int addTimer( int start, int interval,const char* luaFunc,int param1, int param2);
	void stopTimer( int timeID );
	bool tick( int dTime );
	void callUserDataFun(TimerInfo* pTInfo);

private:
	typedef std::map<int,TimerInfo*> TIMER_DICT;
	TIMER_DICT m_timer;
	Mutex _lock_timer;
};

}

#endif 