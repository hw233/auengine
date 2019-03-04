#ifndef _AU_SRC_SERVER_MONITOR_MODULE_H_
#define _AU_SRC_SERVER_MONITOR_MODULE_H_
#include "modulebase.h"
#include <vector>
#include <string>
#include "Network/Network.h"
#define ONE_TICK 20 //20 millisecond
#define ONE_MINNUTE 50
#define EXE_NAME_WINDOWS "auengine"
#define CMD_LINUX  
namespace Au
{
#define UNEXIST false
#define EXIST true
	typedef struct ModuleStatusNode
	{
		std::string nodename;
		bool status; //if true, it existed.
	}ModuleStatusNode;

  class MonitorModule:public ModuleBase
  {
  public:
    MonitorModule();
    ~MonitorModule();
    bool Init();
    bool Destory();
    bool Start();
    bool CreateThreads(int thread_nums);
  public:
	void Tick();
	void DoWork();
	bool NodeCheck();
	void ObtainFiled(std::vector<std::string> &src, int paramnum,std::vector<std::string> &dst);
  public:
	//void ObtainNodeInfo(std::string &dst);
    std::vector<ModuleStatusNode>  _watched_modules;
    int _tickcnt;
    Mutex _ticklock;
  };//class MonitorModule


}//namesapce Au


#endif
