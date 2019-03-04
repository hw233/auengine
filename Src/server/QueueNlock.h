#ifndef _NLOCK_QUEUE_H
#define _NLOCK_QUEUE_H

#include "Network/Network.h"

template<class T>

class QueueNlock
{
public:
	QueueNlock() { first = last = NULL; size = 0; }
	unsigned int size;

	unsigned int get_size()
	{
		return size;
	}

	void push(T & item)
	{
		h* p = new h;
		p->value = item;
		p->pNext = NULL;

		if(last != NULL)//have some items
		{
			last->pNext = (h*)p;
			last = p;
			++size;
		}
		else //first item
		{
			last = first = p;
			size = 1;
		}
	}

	T pop_nowait() { return pop(); }

	T pop()
	{
		if(size == 0)
		{
			return NULL;
		}

		h* tmp = first;
		if(tmp == NULL)
		{
			return NULL;
		}

		if(--size) //more than 1 item
			first = (h*)first->pNext;
		else //last item
		{
			first = last = NULL;
		}
		T returnVal = tmp->value;
		delete tmp;
		return returnVal;
	}

private:
	struct h
	{
		T value;
		void* pNext;
	};

	h* first;
	h* last;
};

#endif