#pragma once

#ifndef _AUENGINE_SRC_AUENGINE_MESSAGE_LIST_H_
#define _AUENGINE_SRC_AUENGINE_MESSAGE_LIST_H_

#include <queue>
#include "netmsg_new.h"
#include "Network/Network.h"
#include "safe_tech.hpp"

template<typename T>
void CopyData(void *src, int len, T *dst);
template<typename T>
void ReMalloc(T *src, int len);

//T 类型要有msgLen 和param 成员
template<typename T>
class MessageQueue
{
public:
	MessageQueue(void);
	~MessageQueue(void);
	void push(unsigned int playerID, void *pData, int len);
	T* pop();
	void DestroyAll();
	bool isEmpty();
private:
	std::queue<T*> _msglist;
};

template <typename T>
MessageQueue<T>::MessageQueue(void)
{

}

template <typename T>
MessageQueue<T>::~MessageQueue(void)
{
	while(!_msglist.empty())
	{
		T* pMsg = _msglist.front();
		_msglist.pop();
		delete pMsg;
		pMsg = NULL;
	}
}

template <typename T>
T* MessageQueue<T>::pop()
{
	while(!_msglist.empty())
	{
		T* pMsg = _msglist.front();
		if(pMsg->isUsed)
		{
			_msglist.pop();
			delete pMsg;
			pMsg = NULL;
		}
		else
		{
			pMsg->isUsed = true;
			return pMsg;
		}
	}
	return NULL;
}

template <typename T>
void MessageQueue<T>::push( unsigned int playerID, void *pData, int len)
{
	T *pMsg = new T();
	CopyData<T>(pData, len, pMsg);
	pMsg->playerID = playerID;
	_msglist.push(pMsg);
}

template<typename T>
void MessageQueue<T>::DestroyAll()
{
	T *msg = NULL;
	while (!_msglist.empty())
	{
		msg = _msglist.front();
		_msglist.pop();
		SAFE_RELEASE(msg)
	}
}

template <typename T>
bool MessageQueue<T>::isEmpty()
{
	if (_msglist.empty())
	{
		return true;
	}
	else if(_msglist.size() == 1)
	{
		T* pMsg = _msglist.front();
		if(pMsg->isUsed)
			return true;
		else
			return false;
	}
	return false;
}

template<typename T>
void CopyData(void *src, int len, T *dst)
{
	dst->msgLen = len;
	if (dst->param)
	{
		delete[] (char*)(dst->param);
		dst->param = NULL;
	}
	dst->param = new char[len];
	memcpy(dst->param, src, len);
}

template<typename T>
void ReMalloc(T *src, int len)
{
	if (src->param)
	{
		delete[] (char *)(src->param);
		src->param = NULL;
	}
	src->msgLen = len;
	src->param = new char[len];
	memset(src->param, 0, len);
}

#endif //_MESSAGE_LIST_H