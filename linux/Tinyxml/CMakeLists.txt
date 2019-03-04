project(Tinyxml)

SET( prefix ${ROOT_PATH}/Src/Tinyxml )

SET(sources
tinystr.cpp
tinyxml.cpp
tinyxmlerror.cpp
tinyxmlparser.cpp
)

foreach(src IN ITEMS ${sources} )
  SET( SRCTinyxml ${SRCTinyxml} ${prefix}/${src} )
endforeach(src)

include_directories( ${ROOT_PATH}/Src/Tinyxml)
add_library(${PROJECT_NAME} STATIC ${SRCTinyxml} )

unset(SRCTinyxml)
unset(sources)