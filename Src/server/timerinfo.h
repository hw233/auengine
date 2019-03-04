#ifndef _AU_SRC_SERVER_TIMERINFO_H_
#define _AU_SRC_SERVER_TIMERINFO_H_

typedef struct TimerInfo
{
	int timeID;
	int	start;
	int	interval;
	int	now;
	int param1;
	int param2;
	char luaFunc[100];			
}TimerInfo;


#endif 