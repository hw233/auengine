PROJECT(AuEngineCmake)
SET( prefix ${ROOT_PATH}/Src/server )
SET(sources
analytical_param.cpp
aulistensock.cpp
auxiliary_kit.cpp
basesocket.cpp
comm_lua_module.cpp
config_module.cpp
config_struct.cpp
connsocket.cpp
doublemsgqueue.cpp
gameconsole.cpp
gameconsolethread.cpp
gdata.cpp
launcher.cpp
luathread.cpp
lua_engine.cpp
lua_export.cpp
lua_module.cpp
main.cpp
memcached_module.cpp
memcached_test.cpp
memcached_thread.cpp
messageconfig_reader.cpp
message_queue.cpp
modulebase.cpp
modulemanager.cpp
monitor_module.cpp
monitor_thread.cpp
msgpackager.cpp
msg_manager.cpp
mysql_module.cpp
mysql_thread.cpp
netmsg_new.cpp
oper_member.cpp
packager_interface.cpp
param_type_map.cpp
QueueNlock.cpp
robots.cpp
robotthread.cpp
sendmodule.cpp
sendthread.cpp
servermap.cpp
server_launcher.cpp
sockmgr.cpp
sockmsgnode.cpp
testcase.cpp
timeinterface.cpp
timer.cpp
timerinfo.cpp
tolua.cpp
tolua_event.c
tolua_is.c
tolua_map.c
tolua_push.c
tolua_to.c
)

foreach(src IN ITEMS ${sources} )
  SET( SRCSWord ${SRCSWord} ${prefix}/${src} )
endforeach(src)
#include_directories( ${GLOBAL_INCLUDE_DIRS} ${CURL_INCLUDE_DIR} ${REDIS_INCLUDE_DIR})
include_directories( ${GLOBAL_INCLUDE_DIRS} ${CURL_INCLUDE_DIR} ${MEMCACHED_INCLUDE_DIR})
add_executable( ${PROJECT_NAME} ${SRCSWord} ${COMMON_SOURCE} ${COMMON_LUA_SOURCE})

set_target_properties(${PROJECT_NAME} PROPERTIES ENABLE_EXPORTS TRUE)

add_dependencies( ${PROJECT_NAME} Shared Lua Tinyxml MemCache)

IF(IS_64BIT)
	SET(dcapi ${ROOT_PATH}/Src/QQlib/libdcapi_cpp-64.a)
ELSE()
	SET(dcapi ${ROOT_PATH}/Src/QQlib/libdcapi_cpp-32.a)
	SET(CURL_LIBRARY ${ROOT_PATH}/Dep/lib/libcurl.lib ${ROOT_PATH}/Dep/lib/libcurld_imp.lib)
ENDIF()

#MESSAGE("-- QQ dcapi = " ${dcapi} ${CURL_LIBRARY})

#target_link_libraries( ${PROJECT_NAME} Shared Lua Tinyxml Redis MemCache ${CURL_LIBRARY})
target_link_libraries( ${PROJECT_NAME} Shared Lua Tinyxml MemCache ${CURL_LIBRARY})
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${INSTALL_PATH})

unset(SRCSWord)
unset(sources)
