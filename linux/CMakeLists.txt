cmake_minimum_required(VERSION 2.8)
#Do system checking.
#SET( CMAKE_BUILD_TYPE Debug)
#SET( CMAKE_BUILD_TYPE Release)
#ÃüÁîÐÐ cmake -DCMAKE_BUILD_TYPE=Debug
SET( GLOBAL_DEFINES "-DHAVE_CONFIG_H")

#check platform version.

SET( IS_64BIT FALSE)

IF( CMAKE_SYSTEM_PROCESSOR MATCHES "[xX]64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "[xX]86_64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "[aA][mM][dD]64" OR CMAKE_GENERATOR MATCHES Win64*)
	#define for 64bit
	SET( GLOBAL_DEFINES ${GLOBAL_DEFINES} -"DX64")
	SET( IS_64BIT TRUE)
	IF( CMAKE_GENERATOR MATCHES Visual* OR CMAKE_GENERATOR MATCHES NMake*)
		SET( GLOBAL_DEFINES ${GLOBAL_DEFINES} "-bigobj")
	ENDIF()
ENDIF()


message("-- IS_64BIT: " ${IS_64BIT} )

IF(UNIX)
	#check for freebsd
	IF( ( CMAKE_SYSTEM_NAME  STREQUAL "FreeBSD" ) OR ( CMAKE_SYSTEM_NAME STREQUAL kFreeBSD ) )
		SET( GLOBAL_DEFINES ${GLOBAL_DEFINES} "-DUSE_KQUEUE")
		SET( IS_FREEBSD TRUE)
	ELSE()
		SET( GLOBAL_DEFINES ${GLOBAL_DEFINES} "-DUSE_EPOLL")
		SET( IS_LINUX TRUE)
	ENDIF()
ENDIF()

SET( ROOT_PATH  ${CMAKE_SOURCE_DIR}/..) #${CMAKE_SOURCE_DIR}Ô´ÂëÊ÷µÄ¶¥²ãÂ·¾¶
#We have our own custom modules that we use. This tells cmakes where to find them.
SET( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ROOT_PATH}/linux/cmake_modules )
SET( DEPENDENCY_COMMON_SOURCE ${ROOT_PATH}/Src/Common)
SET( INSTALL_PATH ${ROOT_PATH}/Res)

#fwx add config
SET( DEPENDENCY_SOURCES ${ROOT_PATH}/Dep/src)
SET( DEPENDENCY_INCLUDE_ROOT ${ROOT_PATH}/Dep/include)
SET( CURL_INCLUDE_DIR ${DEPENDENCY_INCLUDE_ROOT}/curl)
#SET( REDIS_INCLUDE_DIR ${ROOT_PATH}/Src/redis)
#fwx end config

SET(sources
#	BaseSocket.cpp
#	bytearrays.cpp
#	CommonLib.cpp
#	DefManager.cpp
#	#http_request_helper.cpp
#	#MathLib.cpp
#	Memory.cpp
#	MessageList.cpp
#	MsgPackage.cpp
#	nedmalloc.cpp
#	NetMsg.cpp
#	QueueNlock.cpp
#	uri_new.cpp
#	Au_tcpclient.cpp
)
foreach(src IN ITEMS ${sources} )
  SET( COMMON_SOURCE ${COMMON_SOURCE} ${DEPENDENCY_COMMON_SOURCE}/${src} )
endforeach(src)

unset(src)
unset(sources)


SET( sources
	#tolua_event.c
	#tolua_is.c
	#tolua_map.c
	#tolua_push.c
	#tolua_to.c
)

foreach(src IN ITEMS ${sources} )
  SET( COMMON_LUA_SOURCE ${COMMON_LUA_SOURCE} ${DEPENDENCY_COMMON_SOURCE}/${src} )
endforeach(src)

unset(src)
unset(sources)


include(CompilerVersion)
if( CMAKE_GENERATOR MATCHES Unix* )
    add_definitions(-Wno-deprecated)
    
    #Check support for unordered_map/set
    GetCompilerVersion( gcc_version)
    IF( DEFINED gcc_version AND ( ${gcc_version} VERSION_EQUAL "4" OR ${gcc_version} VERSION_GREATER "4" ) AND NOT APPLE )
        add_definitions(-DHAS_CXX0X -std=gnu++0x)
    ENDIF()
    
ELSEIF( CMAKE_GENERATOR MATCHES Visual* )
    #Extract revision
    execute_process(WORKING_DIRECTORY ${ROOT_PATH}/Src/Shared COMMAND RevisionExtractor)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    
    #Check support for unordered_map/set
    GetCompilerVersion( msvc_version)
    IF(DEFINED ${msvc_version} AND ${msvc_version} GREATER "1599" )
        add_definitions(-DHAS_CXX0X)
    ENDIF()
    
    #This fixes PCH issues 'Inconsistent values for /Ym'
    IF( CMAKE_GENERATOR MATCHES Visual* ) 
        STRING( REGEX REPLACE "(/Zm)([0-9]+)" "\\1${VISUALSTUDIO_COMPILERHEAPLIMIT}" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} )
        STRING( REGEX REPLACE "(/Zm)([0-9]+)" "\\1${VISUALSTUDIO_COMPILERHEAPLIMIT}" CMAKE_C_FLAGS ${CMAKE_C_FLAGS} )
        SET( CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} CACHE STRING "CMAKE_CXX_FLAGS" FORCE)
        SET( CMAKE_C_FLAGS ${CMAKE_C_FLAGS} CACHE STRING "CMAKE_C_FLAGS" FORCE)
    ENDIF( CMAKE_GENERATOR MATCHES Visual* )
ENDIF()


#Pass our configurable variables to the C++ preprocessor.
add_definitions( ${GLOBAL_DEFINES} -DCONFDIR=\"${ARCEMU_CONFIGSFILE_PATH}\" -DPREFIX=\"${ARCEMU_SCRIPTLIB_PATH}\")



set(GLOBAL_INCLUDE_DIRS 
${ROOT_PATH}/Src/Shared
${DEPENDENCY_COMMON_SOURCE}
${ROOT_PATH}/Src/Lua/include
${ROOT_PATH}/Src/Tinyxml
${ROOT_PATH}/Src/memcached
#${ROOT_PATH}/Src/QQlib
)

#Find our needed libs
IF( NOT WIN32 )
	find_package(Threads REQUIRED)
	find_package(MySQL REQUIRED)
	#find_package(CURL REQUIRED)
ENDIF()

add_subdirectory(Lua)
add_subdirectory(Memcache)
add_subdirectory(server)
add_subdirectory(Shared)
add_subdirectory(Tinyxml)
#add_subdirectory(redis)
#add_subdirectory(Robot)
#add_subdirectory(Flash)


INSTALL(FILES ${INSTALLED_DEPENDENCIES} DESTINATION INSTALL_PATH)
