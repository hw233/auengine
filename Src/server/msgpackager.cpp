#include "msgpackager.h"
#include "Common.h"
#include "sockmgr.h"

MsgPackager::MsgPackager()
{
	_data_insertpos = NULL;
	_datasize = 0;
}

MsgPackager::~MsgPackager()
{

}

void MsgPackager::MessageBegin(unsigned int playerid, unsigned short msgid)
{
	memset((void *)&_buff, 0, sizeof(_buff));
	MsgHead *head = (MsgHead *)&_buff;
	head->msgID = msgid;
	head->playerID = playerid;

	_msgid = msgid;
	_playerid = playerid;
	_datasize = sizeof(MsgHead)-sizeof(long);
	_data_insertpos = (char *)&_buff;
	_data_insertpos += _datasize;
	//printf("in class begin:%u %u %u\n", head->msgID, head->playerID, _datasize);
}

bool MsgPackager::MessageEnd()
{
	if (sizeof(MsgHead)-sizeof(long)>=_datasize)
	{
		this->Clear();
		printf("=========\n");
		return false;
	}
	if (_datasize>=MAX_SEND_DATA_SIZE)
	{
		printf("*********\n");
		this->Clear();
		return false;
	}
	_buff.msgLen = _datasize;

	//MsgHead *head = (MsgHead *)&_buff;

	return true;
}

void* MsgPackager::GetPackageData()
{
	if (_datasize==sizeof(MsgHead)-sizeof(long))
	{
		return NULL;
	}
	_buff.msgLen = _datasize;
	return &_buff;
}

unsigned short MsgPackager::GetDataSize()
{
	return _datasize;
}

unsigned short  MsgPackager::GetMsgID()
{
	return _msgid;
}

unsigned short  MsgPackager::GetPlayerID()
{
	return _playerid;
}

void MsgPackager::AddUint32(uint32 value)
{
	this->AddValue<uint32>(value);
}

void MsgPackager::AddInt32(int32 value)
{
	this->AddValue<int32>(value);
}

void MsgPackager::AddUint16(uint16 value)
{
	this->AddValue<uint16>(value);
}

void MsgPackager::AddInt16( int16 value )
{
	this->AddValue<int16>(value);
}

void MsgPackager::AddUint8(uint8 value)
{
	this->AddValue<uint8>(value);
}

void MsgPackager::AddInt8(int8 value)
{
	this->AddValue<int8>(value);
}

void MsgPackager::AddBool(bool value)
{
	this->AddValue<bool>(value);
}

void MsgPackager::AddFloat(float value)
{
	this->AddValue<float>(value);
}

void MsgPackager::AddString(const char* value )
{
	if (!value)
	{
		this->AddValueString("[errorString]");
	}
	else
		this->AddValueString(value);
}

void MsgPackager::AddValueString(const char *v)
{
	uint16 vsize = (uint16)strlen(v);
	int tt = _datasize+vsize+sizeof(uint16);
	if (tt>= MAX_SEND_DATA_SIZE)
		return ;

	*((uint16*)_data_insertpos) = vsize;
	_data_insertpos += sizeof(uint16);
	_datasize += sizeof(uint16);

	memcpy(_data_insertpos, v, vsize);
	_data_insertpos += vsize;
	_datasize += vsize;

}