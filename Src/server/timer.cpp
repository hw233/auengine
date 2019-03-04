#include "timer.h"
#include "Log.h"
#include "gdata.h"

namespace Au
{
	Mutex g_timermutex;

	bool TickTimer(int dTime)
	{
		bool hastimer;
		
		hastimer = Timer::getInstance().tick(dTime);
		
		return hastimer;
	}

	int addTimer( int start, int interval, const char* luaFunc,int param1, int param2)
	{
		if(interval <= 0 )
			return 0;
		
		int timeID = Timer::getInstance().addTimer( start, interval,luaFunc,param1,param2);
		
		return timeID;
	}

	void stopTimer( int timeID )
	{
		
		Timer::getInstance().stopTimer( timeID );
		
	}

	
	Timer::Timer(void)
	{

	}

	Timer::~Timer(void)
	{

	}

	int Timer::addTimer( int start, int interval,const char* luaFunc,int param1, int param2)
	{
		_lock_timer.Acquire();
		int timeID = 100;
		Log.outString("m_time.size():%d\n", m_timer.size());
		TIMER_DICT::iterator iter = m_timer.find(timeID);
		while(iter != m_timer.end())
		{
			Log.outString("m_time.size():%d\n", m_timer.size());
			timeID++;
			iter = m_timer.find(timeID);
		}

		TimerInfo *pInfo = new TimerInfo;
		pInfo->start = start;
		pInfo->interval = interval;
		pInfo->now = 0;
		pInfo->timeID = timeID;
		pInfo->param1 = param1;
		pInfo->param2 = param2;
		memset(pInfo->luaFunc,0,100);
		memcpy(pInfo->luaFunc,luaFunc,strlen(luaFunc));

		if( start == 0 )
		{
			callUserDataFun(pInfo);
		}

		m_timer[timeID] = pInfo;

		Log.outString("Add Time success, TimerID: = %d LunFunction = %s", timeID,luaFunc);
		_lock_timer.Release();
		return timeID;
	}

	void Timer::stopTimer( int timeID )
	{
		_lock_timer.Acquire();
		TIMER_DICT::iterator iter = m_timer.find(timeID);
		if (iter != m_timer.end())
		{
			TimerInfo *pInfo = iter->second;
			delete pInfo;
			m_timer.erase(iter);
			pInfo = NULL;
			Log.outString("Close Timer success, TimerID: = %d", timeID);
		}
		_lock_timer.Release();
	}


	bool Timer::tick( int dTime )
	{
		_lock_timer.Acquire();
		if(m_timer.size() <= 0 )
			return false;


		std::vector<int> myvec;
		for(TIMER_DICT::iterator iter=m_timer.begin(); iter!=m_timer.end(); ++iter)
			myvec.push_back(iter->first);
		TIMER_DICT::iterator iter;
		for(std::vector<int>::iterator iter_vec=myvec.begin(); iter_vec!=myvec.end(); ++iter_vec)
		{
			if ((iter=m_timer.find(*iter_vec))!=m_timer.end())
			{
				
				TimerInfo *pTinfo = iter->second;
				pTinfo->now += dTime;

				if( pTinfo->start > 0 && pTinfo->start <= pTinfo->now )
				{
					pTinfo->now -= pTinfo->start;
					pTinfo->start = 0;

					callUserDataFun(pTinfo);
				}
				else
				{
					if( pTinfo->interval <= pTinfo->now )
					{
						pTinfo->now -= pTinfo->interval;
						callUserDataFun(pTinfo);
					}
				}
			}
		}
		_lock_timer.Release();
		return true;
	}

	void Timer::callUserDataFun(TimerInfo* pTInfo)
	{
		/*
		MsgPackage pack;
		pack.messageBegin(0,103,MSG_TYPE_TO_WORLD_Q);
		pack.addString(pTInfo->luaFunc);
		pack.addUint32(pTInfo->param1);
		pack.addUint32(pTInfo->param2);
		pack.messageEnd();
		*/
		//
		//使用lua 模块调用函数。
		/*MsgPackager pack;
		pack.MessageBegin(0,103);
		pack.AddString(pTInfo->luaFunc);
		pack.AddUint32(pTInfo->param1);
		pack.AddUint32(pTInfo->param2);
		pack.MessageEnd();
*/

		Au::GData::g_luamodule->RunLuaFunctionVariableParaModule("onTimer","%s%d%d",pTInfo->luaFunc, pTInfo->param1, pTInfo->param2);
		
	}


}