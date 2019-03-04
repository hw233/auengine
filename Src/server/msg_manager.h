//#ifndef _AUENGINE_SRC_AUENGINE_MSG_MANAGER_H_
//#define _AUENGINE_SRC_AUENGINE_MSG_MANAGER_H_
//
//#include "Network/Network.h"
//#include "CThreads.h"
//
//#include "comm_lua_module.h"
//#include "netmsg_new.h"
//#include "message_list.h"
//
//
//namespace Au
//{
//
//template<typename T>
//class MessageManager
//{
//public:
//	MessageManager();
//	~MessageManager();
//	void PushMsg(void *data, unsigned int playerid, int data_len, const MsgPriority mp=PriorityUrgency);
//	T* GetMsg(const MsgPriority mp=PriorityUrgency);
//	void PushUrgencyMsg(void *data, unsigned int playerid, int data_len);
//	void PushNormalMsg(void *data, unsigned int playerid, int data_len);
//	T *PopUrgencyMsg();
//	T *PopNormalMsg();
//
//private:
//	MessageQueue<T> _urgency_msgs;
//	MessageQueue<T> _normal_msgs;
//	Mutex _urgency_lock;
//	Mutex _normal_lock;
//};
//
//template<typename T>
//MessageManager<T>::MessageManager()
//{
//
//}
//
//template<typename T>
//MessageManager<T>::~MessageManager()
//{
//
//}
//
//template<typename T>
//void MessageManager<T>::PushMsg(void *data, unsigned int playerid, int data_len, const MsgPriority mp)
//{
//	if (NULL==data)
//		return ;
//	else if (PriorityUrgency==mp)
//	{
//		this->PushUrgencyMsg(data, playerid, data_len);
//	}
//	else if (PriorityNormal==mp)
//	{
//		this->PushNormalMsg(data, playerid, data_len);
//	}
//}
//
//template<typename T>
//void MessageManager<T>::PushUrgencyMsg(void *data, unsigned int playerid, int data_len)
//{
//	if (NULL==data)
//		return ;
//	_urgency_lock.Acquire();
//	_urgency_msgs.push(playerid, data, data_len);
//	_urgency_lock.Release();
//}
//
//template<typename T>
//void MessageManager<T>::PushNormalMsg(void *data, unsigned int playerid, int data_len)
//{
//	_normal_lock.Acquire();
//	_normal_msgs.push(playerid, data, data_len);
//	_normal_lock.Release();
//}
//
//template<typename T>
//T* MessageManager<T>::GetMsg(const MsgPriority mp)
//{
//	T *msg = NULL;
//	if (mp==PriorityNormal)
//		msg = this->PopNormalMsg();
//	else
//		msg = this->PopUrgencyMsg();
//	return msg;
//}
//
//template<typename T>
//T* MessageManager<T>::PopUrgencyMsg()
//{
//	T *msg = NULL;
//	_urgency_lock.Acquire();
//	msg = _urgency_msgs.pop();
//	_urgency_lock.Release();
//	return msg;
//}
//
//template<typename T>
//T* MessageManager<T>::PopNormalMsg()
//{
//	T *msg = NULL;
//	_normal_lock.Acquire();
//	msg = _normal_msgs.pop();
//	_normal_lock.Release();
//	return msg;
//}
//
//
//}//namespace Au
//
//#endif