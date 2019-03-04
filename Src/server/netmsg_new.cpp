#include "netmsg_new.h"

ModuleMsg::ModuleMsg()
{
	msgLen = 0;
	param = NULL;
	isUsed = false;
	playerID = -1;
}

ModuleMsg::~ModuleMsg()
{
	if(param)
	{
		delete[] (char*)param;
		param = NULL;
	}
}

//void ModuleMsg::makeData(int len, void *data)
//{
//	msgLen = len;
//	param = new char[len];
//	memcpy(param, data, len);
//}
//
//void ModuleMsg::setSize(int data_len)
//{
//	if(param)
//	{
//		delete[] (char*)param;
//		param = NULL;
//	}
//	msgLen = data_len;
//	param = new char[data_len];
//	memset(param,0,data_len);
//}