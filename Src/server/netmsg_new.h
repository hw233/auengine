#ifndef _AUENGINE_SRC_AUENGINE_NETMSG_NEW_H_
#define _AUENGINE_SRC_AUENGINE_NETMSG_NEW_H_

#include <string.h>
#include <queue>
#include "version_info.h"
//It contains LOGIN_KEY_LOW_BOUND and LOGIN_KEY_UP__BOUND 
#define MAX_BUFFER_SIZE		60000
#define MAX_BUFFER_READ_SIZE 2000
#define LOGIN_KEY_PLAYER     0
#define LOGIN_KEY_LOW_BOUND  1
#define LOGIN_KEY_UP__BOUND  INT_MAX


//it contains the up and low bound
#define MSG_ID_LOW_BOUND   0  
#define MSG_ID_UP__BOUND   USHRT_MAX
//#define LOGIN_MSG_ID      102

//Data Type
#define DATA_TYPE_PLAYERID    unsigned int


#define MSG_ID_PLAYER_LOGON_SUCCESS 1000

#undef MAX_SEND_DATA_SIZE
#define MAX_SEND_DATA_SIZE 25000
#define MAX_ACCOUNT_ID_SIZE 102
typedef void socketStreams;

///////////MsgHead:定义消息头，取出消息的属性//////////////
#ifdef WIN32
#pragma pack(push, 1)
#endif 
struct MsgHead
{
	unsigned short 		msgLen;
#ifdef MSG_VERSION_0_1
	unsigned char       msgFrom;
	unsigned char       msgType;
#endif 
	unsigned short 		msgID;
	unsigned int		playerID;
	long				context;		//消息的开始
#ifdef WIN32
};
#pragma pack(pop)
#else
}__attribute__ ((__packed__));
#endif 
//////////End MsgHead///////////

//////////ModuleMsg:用于模块间传递，或者发向客户端的消息包，实际发送部分param/////////////////
#ifdef WIN32
#pragma pack(push, 1)
#endif 
struct ModuleMsg
{
	unsigned short  msgLen;	//数据包长度，包含该字段
	void *param;				//包含消息头(MsgHead)和一些参数
	bool isUsed;				
	int playerID;				//玩家对应的ID，绑定与socketid
	ModuleMsg();
	~ModuleMsg();
	//void makeData(int len, void *data);
	//void setSize(int datalen);
#ifdef WIN32
};
#pragma pack(pop)
#else
}__attribute__((__packed__));
#endif
///////////End ModuleMsg////////


//////////////MsgBuffer: 用于消息封包//////////////////////
#ifdef WIN32
#pragma pack(push, 1)
#endif 
struct MsgBuffer
{
	unsigned short  msgLen;
	char msg[MAX_SEND_DATA_SIZE];

#ifdef WIN32
};
#pragma pack(pop)
#else
}__attribute__((__packed__));
#endif 
///////End MsgBuffer///////


#ifdef MAX_ACCOUNT_ID_SIZE 
	#undef MAX_ACCOUNT_ID_SIZE 
#endif
#define  MAX_ACCOUNT_ID_SIZE 102
// 登录连接
#ifdef WIN32
#pragma pack(push,1)
#endif
struct LoginMsg
{
	unsigned short	msgLen;
#ifdef MSG_VERSION_0_1 
	unsigned char	msgFrom;
	unsigned char	msgType;
#endif
	unsigned short	msgID;
	unsigned int    playerID;
	unsigned int	key;								//登录时的一个随机验证码
	char			accountID[MAX_ACCOUNT_ID_SIZE];		//登录玩家的帐号
#ifdef WIN32
};
#pragma pack(pop)
#else
}__attribute__ ((__packed__));
#endif





#endif// _AUENGINE_SRC_AUENGINE_NETMSG_NEW_H_

