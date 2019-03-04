#ifndef _AUENGINE_SRC_AUENGINE_PACKAGER_INTERFACE_H_
#define _AUENGINE_SRC_AUENGINE_PACKAGER_INTERFACE_H_
#include "netmsg_new.h"
#include "Common.h"
#define MAX_UNSEND_PACKAGE_SIZE 10
namespace Au
{

	extern void messageBegin(unsigned int playerid, unsigned short msgid);
	extern void messageEnd();
	extern void addUint32( uint32 value );
	extern void addInt32( int32 value );
	extern void addUint16( uint16 value );
	extern void addInt16( int16 value );
	extern void addUint8( uint8 value );
	extern void addInt8( int8 value );
	extern void addBool( bool value );
	extern void addFloat( float value );
	extern void addString(const char* value );

	extern void checkPackError();

}//namespace Au
//For Test

#endif 