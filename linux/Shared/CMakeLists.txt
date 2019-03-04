PROJECT(Shared)

SET( prefix ${ROOT_PATH}/Src/Shared )
SET( sources
	CrashHandler.cpp
	CThreads.cpp
	Log.cpp
	MersenneTwister.cpp
	PerformanceCounter.cpp
	printStackTrace.cpp
	SysInfo.cpp
	Util.cpp
	Database/CreateInterface.cpp
	Database/Database.cpp
	Database/MySQLDatabase.cpp
	Network/CircularBuffer.cpp
	Network/Socket.cpp
	Threading/AtomicBoolean.cpp
	Threading/AtomicCounter.cpp
	Threading/AtomicFloat.cpp
	Threading/AtomicULong.cpp
	Threading/ConditionVariable.cpp
	Threading/Mutex.cpp
	Threading/ThreadPool.cpp
)

SET( headers 
	auConfig.h
	Array.h
	CallBack.h
	CircularQueue.h
	Common.h
	CrashHandler.h
	CThreads.h
	Errors.h
	Log.h
	MersenneTwister.h
	printStackTrace.h
	Singleton.h
	StackWalker.h
	Util.h
	Database/Database.h
	Database/DatabaseEnv.h
	Database/Field.h
	Database/MySQLDatabase.h
	Network/CircularBuffer.h
	Network/ListenSocketLinux.h
	Network/ListenSocketWin32.h
	Network/Network.h
	Network/Socket.h
	Network/SocketDefines.h
	Network/SocketMgrLinux.h
	Network/SocketMgrWin32.h
	Network/SocketOps.h
	Threading/AtomicBoolean.h
	Threading/AtomicCounter.h
	Threading/AtomicFloat.h
	Threading/AtomicULong.h
	Threading/ConditionVariable.h
	Threading/Guard.h
	Threading/LockedQueue.h
	Threading/Mutex.h
	Threading/Queue.h
	Threading/RWLock.h
	Threading/Threading.h
	Threading/ThreadPool.h
	Threading/ThreadStarter.h
)


IF(WIN32)
	SET( sources ${sources} Network/SocketMgrWin32.cpp  Network/SocketOpsWin32.cpp  Network/SocketWin32.cpp StackWalker.cpp)
ELSEIF(IS_FREEBSD OR APPLE)
	#SET( sources ${sources}  Network/SocketMgrFreeBSD.cpp  Network/SocketFreeBSD.cpp  Network/SocketOpsFreeBSD.cpp )
ELSE(WIN32)
	SET( sources ${sources}  Network/SocketMgrLinux.cpp  Network/SocketLinux.cpp  Network/SocketOpsLinux.cpp )
ENDIF(WIN32)

foreach(src IN ITEMS ${sources} )
  SET( SRCSShared ${SRCSShared} ${prefix}/${src} )
endforeach(src)

foreach(src IN ITEMS ${headers} )
  SET(HEADERS ${HEADERS} ${prefix}/${src} )
endforeach(src)

include_directories( ${GLOBAL_INCLUDE_DIRS} )
IF( IS_64BIT )
	link_directories( ${DEPENDENCY_DLLS64} )
ELSE()
	link_directories( ${DEPENDENCY_DLLS} )
ENDIF()

link_directories( ${DEPENDENCY_LIBS} )
ADD_LIBRARY( ${PROJECT_NAME} STATIC ${SRCSShared} ${HEADERS})

target_link_libraries( ${PROJECT_NAME} ${CMAKE_THREAD_LIBS_INIT} ${MYSQL_LIBRARY} ${OPENSSL_LIBRARIES}  )

unset(SRCSShared)
unset(sources)

