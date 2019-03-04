#ifndef _AUENGINE_SRC_SERVER_DOUBLEMSGLIST_H_
#define _AUENGINE_SRC_SERVER_DOUBLEMSGLIST_H_

#include "message_queue.h"

typedef enum MsgPriority{PriorityUrgency, PriorityNormal}MsgPriority;

template<typename T>
class DoubleMsgQueue
{
public:
	DoubleMsgQueue();
	~DoubleMsgQueue();
	void PushMsg(void *data, unsigned int sockfd, int data_len, const MsgPriority mp = PriorityUrgency);
	T* GetMsg(const MsgPriority mp = PriorityUrgency);

	void DestroyAll();
private:
	void PushUrgencyMsg(void *data, unsigned int playerid, int data_len);
	void PushNormalMsg(void *data, unsigned int playerid, int data_len);
	T *PopUrgencyMsg();
	T *PopNormalMsg();
	MessageQueue<T> _urgency_msg;
	MessageQueue<T> _normal_msg;
};

template<typename T>
DoubleMsgQueue<T>::DoubleMsgQueue()
{

}

template<typename T>
DoubleMsgQueue<T>::~DoubleMsgQueue()
{

}

template<typename T>
void DoubleMsgQueue<T>::PushMsg(void *data, unsigned int sockfd, int data_len, const MsgPriority mp /* = PriorityUrgency */)
{
	if (NULL==data)
		return ;
	else if (PriorityUrgency==mp)
	{
		this->PushUrgencyMsg(data, sockfd, data_len);
	}
	else if (PriorityNormal==mp)
	{
		this->PushNormalMsg(data, sockfd, data_len);
	}
}

template<typename T>
void DoubleMsgQueue<T>::PushUrgencyMsg(void *data, unsigned int playerid, int data_len)
{
	if (NULL==data)
		return ;
	_urgency_msg.push(playerid, data, data_len);
}

template<typename T>
void DoubleMsgQueue<T>::PushNormalMsg(void *data, unsigned int playerid, int data_len)
{
	_normal_msg.push(playerid, data, data_len);
}

template<typename T>
T* DoubleMsgQueue<T>::GetMsg(const MsgPriority mp)
{
	T *msg = NULL;
	if (mp==PriorityNormal)
		msg = this->PopNormalMsg();
	else
		msg = this->PopUrgencyMsg();
	return msg;
}

template<typename T>
T* DoubleMsgQueue<T>::PopUrgencyMsg()
{
	T *msg = NULL;
	msg = _urgency_msg.pop();
	return msg;
}

template<typename T>
T* DoubleMsgQueue<T>::PopNormalMsg()
{
	T *msg = NULL;
	msg = _normal_msg.pop();
	return msg;
}

template<typename T>
void DoubleMsgQueue<T>::DestroyAll()
{
	_normal_msg.DestroyAll();
	_urgency_msg.DestroyAll();
}

#endif 