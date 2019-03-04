#include "servermap.h"

namespace Au
{
	ServerMap::ServerMap()
	{

	}

	ServerMap::~ServerMap()
	{

	}

	bool ServerMap::ObtainSockFd(int rand_key, unsigned int &res)
	{
		std::map<int, unsigned int>::const_iterator kiter;
		kiter = _server.find(rand_key);
		if (_server.end()!=kiter)
		{
			res = kiter->second;
			return true;
		}
		return false;
	}

	bool ServerMap::Insert(int rand_key, unsigned int sockfd)
	{
		if (IsExist(rand_key))
			return false;
		_server[rand_key] = sockfd;
		return true;
	}

	bool ServerMap::IsExist(int rand_key)
	{
		std::map<int, unsigned int>::iterator kiter;
		kiter = _server.find(rand_key);
		if (_server.end()!=kiter)
			return true;
		return false;
	}

	bool ServerMap::Init()
	{
		return true;
	}

	bool ServerMap::Destroy()
	{
		return true;
	}

	bool ServerMap::Start()
	{
		return true;
	}

}//namespace Au