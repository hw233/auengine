# - Find curl
# Find the native curl includes and library
#
#  CURL_INCLUDE_DIR - where to find curl.h, etc.
#  CURL_LIBRARIES   - List of libraries when using curl.
#  CURL_FOUND       - True if curl found.

IF (CURL_INCLUDE_DIR)
  # Already in cache, be silent
  SET(CURL_FIND_QUIETLY TRUE)
ENDIF (CURL_INCLUDE_DIR)

FIND_PATH(CURL_INCLUDE_DIR curl.h
  /usr/local/include/curl
  /usr/include/curl
  /usr/local/curl/include
)


SET(CURL_NAMES curl)
FIND_LIBRARY(CURL_LIBRARY
  NAMES ${CURL_NAMES}
  PATHS /usr/lib /usr/lib/curl /usr/local/lib /usr/local/curl/lib /usr/local/lib/curl
)

IF (CURL_INCLUDE_DIR AND CURL_LIBRARY)
  SET(CURL_FOUND TRUE)
  SET( CURL_LIBRARIES ${CURL_LIBRARY} )
ELSE (CURL_INCLUDE_DIR AND CURL_LIBRARY)
  SET(CURL_FOUND FALSE)
  SET( CURL_LIBRARIES )
ENDIF (CURL_INCLUDE_DIR AND CURL_LIBRARY)

IF (CURL_FOUND)
  IF (NOT CURL_FIND_QUIETLY)
    MESSAGE(STATUS "Found curl: ${CURL_LIBRARY}")
  ENDIF (NOT CURL_FIND_QUIETLY)
ELSE (CURL_FOUND)
  IF (CURL_FIND_REQUIRED)
    MESSAGE(STATUS "Looked for curl libraries named ${CURL_NAMES}.")
    MESSAGE(FATAL_ERROR "Could NOT find curl library")
  ENDIF (CURL_FIND_REQUIRED)
ENDIF (CURL_FOUND)

MARK_AS_ADVANCED(
  CURL_LIBRARY
  CURL_INCLUDE_DIR
  )

