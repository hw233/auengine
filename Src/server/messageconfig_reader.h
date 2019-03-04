#pragma once
#ifndef _AUENGINE_SRC_AUENGINE_MESSAGECONFIGREADER_H_
#define _AUENGINE_SRC_AUENGINE_MESSAGECONFIGREADER_H_
#include <string>
#include <map>
#include <vector>
#include <queue>


struct MsgConfig
{
	MsgConfig():msgid(0){}
	~MsgConfig(){};
	int msgid;
	std::string funcname;
	std::vector<int> parameters;
};

#define FILESUFFIX ".def"
class TiXmlElement;
namespace Au
{

class MessageConfigReader
{
public:
	MessageConfigReader();
	~MessageConfigReader();
	bool Destroy();
	bool ReadConfig(const char *filepath);
public:
	bool ReadMsgConfigure(const char *filepath);
	MsgConfig *GetMsgConfigFromMsgId(int msgid);
	void ShowAll();

private:
	bool ParseNode(const TiXmlElement *node);
	bool Split(std::string &src, const std::string &delim, std::vector<std::string> &ret);
	void TranFormat(const std::vector<std::string> &src, std::vector<int> &dst);
	int ParseType(const std::string &text);
	bool DataTypeCheck(std::string &type);
private:
	std::map<int , MsgConfig> _msgcfg;
	
};

}//namespace Au
#endif