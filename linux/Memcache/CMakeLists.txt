PROJECT(MemCache)

SET( prefix ${ROOT_PATH}/Src/memcached )
SET( sources
	Matilda.cpp
	MemCacheClient.cpp
	ReadWriteBuffer.cpp
	sha1.c
	Socket.cpp
)

SET( headers 
	Matilda.h
	MemCacheClient.h
	ReadWriteBuffer.h
	sha1.h
	Socket.h
)

foreach(src IN ITEMS ${sources} )
  SET( SRCSMemcache ${SRCSMemcache} ${prefix}/${src} )
endforeach(src)

include_directories( ${ROOT_PATH}/Src/memcached ${prefix} )
add_library(${PROJECT_NAME} STATIC ${SRCSMemcache} )

unset(sources)
unset(SRCSMemcache)
unset(prefix)

