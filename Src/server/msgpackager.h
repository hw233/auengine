#ifndef _AUENGINE_SRC_AUENGINE_MSGPACKAGER_H_
#define _AUENGINE_SRC_AUENGINE_MSGPACKAGER_H_

#include "netmsg_new.h"
#include "Common.h"

class MsgPackager
{
public:
	MsgPackager();
	~MsgPackager();
	void MessageBegin(unsigned int  playerid, unsigned short  msgid);
	bool MessageEnd();
	inline void Clear()
	{
		_datasize = 0;
	}
	unsigned short GetDataSize();
	unsigned short  GetPlayerID();
	unsigned short  GetMsgID();
	//返回的实际包长在返回的数据的 开始sizeof(MSGLEN_DATA_TYPE)字节中
	void *GetPackageData();

	void AddUint32( uint32 value );
	void AddInt32( int32 value );
	void AddUint16( uint16 value );
	void AddInt16( int16 value );
	void AddUint8( uint8 value );
	void AddInt8( int8 value );
	void AddBool( bool value );
	void AddFloat( float value );
	void AddString(const char* value );

	template<typename T>
	void AddValue(T value)
	{
		unsigned short typesize = sizeof(T);
		_datasize += typesize;
		//printf("in AddValue:%u\n", _datasize);
		int tt = _datasize;
		if (tt>=MAX_SEND_DATA_SIZE)
			return ;
		*((T*)_data_insertpos) = value;
		_data_insertpos += typesize;
		
	}

	void AddValueString(const char *v);
	
private:
	MsgBuffer _buff;
	unsigned short _datasize;
	char *_data_insertpos;

	unsigned int  _playerid;
	unsigned short  _msgid;

};




#endif 