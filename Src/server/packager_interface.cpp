#include "packager_interface.h"
#include <stack>
#include "Common.h"
#include "msgpackager.h"
#include "Log.h"
#include "msg_manager.h"
#include "sockmgr.h"

#define OUTPUT_MSG_INFO  

namespace Au
{

	namespace MsgPack
	{
		std::stack<MsgPackager *> package_stack;
		MsgPackager *g_packager =  NULL;
		void GetPackager()
		{
			if (!g_packager)
			{
				g_packager = new MsgPackager;
				return ;
			}
			if (0< g_packager->GetDataSize())
			{
				package_stack.push(g_packager);
				g_packager = NULL;
				g_packager = new MsgPackager;
			}
		}

		void ReleasePackage()
		{
			if (!package_stack.empty())
			{
				delete g_packager;
				g_packager = NULL;
				g_packager = package_stack.top();
				package_stack.pop();
				if (MAX_UNSEND_PACKAGE_SIZE<package_stack.size())
				{
					Log.outError("luaPackStack error ================= luaPackStack size %d\n", package_stack.size());
				}
				Log.outError("Please check is there any wrong with Message ID: %d\n", g_packager->GetMsgID());
			}
		}

		void checkErrorFromLuaEngine() //在处理一个Lua数据出错的时候,会清除掉Lua里的数据包
		{
			MsgPackager* pPack = NULL;
			while (!package_stack.empty())
			{

				pPack = package_stack.top(); //获取栈顶数据包
				delete pPack;				//销毁数据包
				pPack = NULL;
				package_stack.pop();
			}
			if (g_packager != NULL)
			{
				Log.outError(" Message Error ID: %d\n", g_packager->GetMsgID());
				g_packager->Clear();	//清空这次需要发送的数据
			}
		}

	}//namesapce MsgPack

	void checkPackError()
	{
		MsgPack::checkErrorFromLuaEngine();
	}

	void messageBegin(unsigned int playerid, unsigned short  msgid)
	{
		MsgPack::GetPackager();
		printf("%s:%d msgid:%u\n", __FUNCTION__, __LINE__, msgid);
		MsgPack::g_packager->MessageBegin(playerid, msgid);
	}

	void messageEnd()
	{
		bool ret = false;
		ret = MsgPack::g_packager->MessageEnd();
		if (ret)
		{
			
			Au::SockMgr::getSingleton().PushMsgToSock(MsgPack::g_packager->GetPlayerID(),
				MsgPack::g_packager->GetPackageData(),
				MsgPack::g_packager->GetDataSize());

		}
		else 
			printf("%s:%d messageEnd error\n",__FUNCTION__, __LINE__);
		MsgPack::g_packager->Clear();
		MsgPack::ReleasePackage();

	}

	void addUint32(uint32 value)
	{
		MsgPack::g_packager->AddUint32(value);
	}

	void addInt32(int32 value)
	{
		MsgPack::g_packager->AddInt32(value);
	}

	void addUint16(uint16 value)
	{
		MsgPack::g_packager->AddUint16(value);
	}

	void addInt16( int16 value )
	{
		MsgPack::g_packager->AddInt16(value);
	}

	void addUint8(uint8 value)
	{
		MsgPack::g_packager->AddUint8(value);
	}

	void addInt8(int8 value)
	{
		MsgPack::g_packager->AddInt8(value);
	}

	void addBool(bool value)
	{
		MsgPack::g_packager->AddBool(value);
	}

	void addFloat(float value)
	{
		MsgPack::g_packager->AddFloat(value);
	}

	void addString(const char* value )
	{
		if (!value)
		{
			MsgPack::g_packager->AddString("[errorString]");
		}
		else
			MsgPack::g_packager->AddString(value);
	}

}