#ifndef _THREADING_MUTEX_H
#define _THREADING_MUTEX_H

class SERVER_DECL Mutex
{
	public:
		//friend class Condition;

		/** Initializes a mutex class, with InitializeCriticalSection / pthread_mutex_init
		 */
		Mutex();

		/** Deletes the associated critical section / mutex
		 */
		virtual ~Mutex();

		/** Attempts to acquire this mutex. If it cannot be acquired (held by another thread)
		 * it will return false.
		 * @return false if cannot be acquired, true if it was acquired.
		 */
		bool AttemptAcquire();

		/** Acquires this mutex. If it cannot be acquired immediately, it will block.
		 */
		void Acquire();

		/** Releases this mutex. No error checking performed
		 */
		void Release();

	protected:
#ifdef WIN32
		/** Critical section used for system calls
		 */
		CRITICAL_SECTION cs;

#else
		/** Static mutex attribute
		 */
		static bool attr_initalized;
		static pthread_mutexattr_t attr;

		/** pthread struct used in system calls
		 */
		pthread_mutex_t mutex;
#endif
};

#ifdef WIN32

class SERVER_DECL FastMutex
{
#pragma pack(push,8)
		volatile long m_lock;
#pragma pack(pop)
		DWORD m_recursiveCount;

	public:
		FastMutex() : m_lock(0), m_recursiveCount(0) {}

		~FastMutex() {}

		bool AttemptAcquire();

		void Acquire();

		void Release();
};

#else

#define FastMutex Mutex

#endif

#endif

