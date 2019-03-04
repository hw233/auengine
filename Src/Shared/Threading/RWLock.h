#ifndef RWLOCK_H
#define RWLOCK_H

#include "Mutex.h"

class RWLock
{
	public:
		AU_INLINE void AcquireReadLock()
		{
			_lock.Acquire();
		}

		AU_INLINE void ReleaseReadLock()
		{
			_lock.Release();
		}

		AU_INLINE void AcquireWriteLock()
		{
			_lock.Acquire();
		}

		AU_INLINE void ReleaseWriteLock()
		{
			_lock.Release();
		}

	private:
		Mutex _lock;
};

#endif
