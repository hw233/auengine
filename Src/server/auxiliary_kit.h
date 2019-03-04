#ifndef _AU_SRC_SERVER_AUXILIARY_KIT_H_
#define _AU_SRC_SERVER_AUXILIARY_KIT_H_
#include <string>
#include <vector>

#ifdef WIN32
#define PIPEOPEN   _popen
#define PIPECLOSE  _pclose
#else
#define PIPEOPEN   popen
#define PIPECLOSE  pclose
#endif
namespace Kit
{
	int ExecCmd(const char *cmd, std::string &res);
	void ObtainCaption(std::string &src, std::vector<std::string> &dst);
	void ObtainFiled(std::vector<std::string> &src, int paramnum,std::vector<std::string> &dst);

}


#endif