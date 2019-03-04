#ifndef _AU_SRC_SERVER_OPER_MEMBER_H
#define _AU_SRC_SERVER_OPER_MEMBER_H
#include "MemCacheClient.h"
#define MEMCACHED_OPER_VALUE_LOWER_BOUND 0 
#define MEMCACHED_OPER_ADD			1
#define MEMCACHED_OPER_SET			2
#define MEMCACHED_OPER_REPLACE		3
#define MEMCACHED_OPER_APPEND       4
#define MEMCACHED_OPER_PREPEND      5
#define MEMCACHED_OPER_DEL			6
#define MEMCACHED_OPER_INCREMENT	7
#define MEMCACHED_OPER_DECREMENT	8
#define MEMCACHED_OPER_DELTIMEOUT   9

#define MEMCACHED_OPER_VALUE_UPPER_BOUND MEMCACHED_OPER_DELTIMEOUT+1

typedef struct Oper
{
	Oper()
	{
		opertype = MEMCACHED_OPER_VALUE_LOWER_BOUND;
	}
	int opertype;
	MemCacheClient::MemRequest  item;
	//For Increment and Decrement
	MemCacheClient::uint64_t  newvalue;
	MemCacheClient::uint64_t  diff;
}Oper;


#endif 