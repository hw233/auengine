PROJECT(Lua)

SET( prefix ${ROOT_PATH}/Src/Lua/src )
SET( sources
    lapi.c
    lauxlib.c
    lbaselib.c
    lcode.c
    ldblib.c
    ldebug.c
    ldo.c
    ldump.c
    lfunc.c
    lgc.c
    linit.c
    liolib.c
    llex.c
    lmathlib.c
    lmem.c
    loadlib.c
    lobject.c
    lopcodes.c
    loslib.c
    lparser.c
    lstate.c
    lstring.c
    lstrlib.c
    ltable.c
    ltablib.c
    ltm.c
    lua.c
    luac.c
    lundump.c
    lvm.c
    lzio.c
    print.c
)

foreach(src IN ITEMS ${sources} )
  SET( SRCSLua ${SRCSLua} ${prefix}/${src} )
endforeach(src)

include_directories( ${ROOT_PATH}/Src/Lua/include ${prefix} )
add_library(${PROJECT_NAME} STATIC ${SRCSLua} )

unset(sources)
unset(SRCSLua)
unset(prefix)




