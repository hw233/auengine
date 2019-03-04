/*
** Lua binding: All
** Generated automatically by tolua++-1.0.92 on 03/14/15 10:25:57.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif
#include "string.h"

#include "tolua++.h"

/* Exported function */
int tolua_All_open (lua_State* tolua_S);

#include "tolua.h"
#include <string>
#include "tolua.h"
#include "packager_interface.h"
#include "robots.h"

/* function to release collected object via destructor */
#ifdef __cplusplus

static int tolua_collect_uint64 (lua_State* tolua_S)
{
 uint64* self = (uint64*) tolua_tousertype(tolua_S,1,0);
 delete self;
 return 0;
}
#endif


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"Au::ConnSocket");
 tolua_usertype(tolua_S,"QueryResult");
 tolua_usertype(tolua_S,"uint64");
 tolua_usertype(tolua_S,"Field");
}

/* method: SetValue of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_SetValue00
static int tolua_All_Field_SetValue00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
  char* value = ((char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'SetValue'",NULL);
#endif
 {
  self->SetValue(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'SetValue'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetString of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetString00
static int tolua_All_Field_GetString00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetString'",NULL);
#endif
 {
  const char* tolua_ret = (const char*)  self->GetString();
 tolua_pushstring(tolua_S,(const char*)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetString'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetFloat of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetFloat00
static int tolua_All_Field_GetFloat00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetFloat'",NULL);
#endif
 {
  float tolua_ret = (float)  self->GetFloat();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetFloat'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetBool of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetBool00
static int tolua_All_Field_GetBool00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetBool'",NULL);
#endif
 {
  bool tolua_ret = (bool)  self->GetBool();
 tolua_pushboolean(tolua_S,(bool)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetBool'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetUInt8 of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetUInt800
static int tolua_All_Field_GetUInt800(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetUInt8'",NULL);
#endif
 {
  unsigned int tolua_ret = ( unsigned int)  self->GetUInt8();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetUInt8'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetInt8 of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetInt800
static int tolua_All_Field_GetInt800(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetInt8'",NULL);
#endif
 {
  signed int tolua_ret = ( signed int)  self->GetInt8();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetInt8'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetUInt16 of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetUInt1600
static int tolua_All_Field_GetUInt1600(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetUInt16'",NULL);
#endif
 {
  unsigned int tolua_ret = ( unsigned int)  self->GetUInt16();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetUInt16'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetInt16 of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetInt1600
static int tolua_All_Field_GetInt1600(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetInt16'",NULL);
#endif
 {
  signed int tolua_ret = ( signed int)  self->GetInt16();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetInt16'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetUInt32 of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetUInt3200
static int tolua_All_Field_GetUInt3200(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetUInt32'",NULL);
#endif
 {
  unsigned int tolua_ret = ( unsigned int)  self->GetUInt32();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetUInt32'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetInt32 of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetInt3200
static int tolua_All_Field_GetInt3200(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetInt32'",NULL);
#endif
 {
  signed int tolua_ret = ( signed int)  self->GetInt32();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetInt32'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetUInt64 of class  Field */
#ifndef TOLUA_DISABLE_tolua_All_Field_GetUInt6400
static int tolua_All_Field_GetUInt6400(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"Field",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  Field* self = (Field*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetUInt64'",NULL);
#endif
 {
  uint64 tolua_ret = (uint64)  self->GetUInt64();
 {
#ifdef __cplusplus
 void* tolua_obj = new uint64(tolua_ret);
 tolua_pushusertype_and_takeownership(tolua_S,tolua_obj,"uint64");
#else
 void* tolua_obj = tolua_copy(tolua_S,(void*)&tolua_ret,sizeof(uint64));
 tolua_pushusertype_and_takeownership(tolua_S,tolua_obj,"uint64");
#endif
 }
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetUInt64'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: NextRow of class  QueryResult */
#ifndef TOLUA_DISABLE_tolua_All_QueryResult_NextRow00
static int tolua_All_QueryResult_NextRow00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"QueryResult",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  QueryResult* self = (QueryResult*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'NextRow'",NULL);
#endif
 {
  self->NextRow();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'NextRow'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: Delete of class  QueryResult */
#ifndef TOLUA_DISABLE_tolua_All_QueryResult_Delete00
static int tolua_All_QueryResult_Delete00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"QueryResult",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  QueryResult* self = (QueryResult*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'Delete'",NULL);
#endif
 {
  self->Delete();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'Delete'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetFieldFromCount of class  QueryResult */
#ifndef TOLUA_DISABLE_tolua_All_QueryResult_GetFieldFromCount00
static int tolua_All_QueryResult_GetFieldFromCount00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"QueryResult",0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  QueryResult* self = (QueryResult*)  tolua_tousertype(tolua_S,1,0);
  unsigned int i = (( unsigned int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetFieldFromCount'",NULL);
#endif
 {
  Field* tolua_ret = (Field*)  self->GetFieldFromCount(i);
 tolua_pushusertype(tolua_S,(void*)tolua_ret,"Field");
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetFieldFromCount'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetFieldCount of class  QueryResult */
#ifndef TOLUA_DISABLE_tolua_All_QueryResult_GetFieldCount00
static int tolua_All_QueryResult_GetFieldCount00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"const QueryResult",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  const QueryResult* self = (const QueryResult*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetFieldCount'",NULL);
#endif
 {
  unsigned int tolua_ret = ( unsigned int)  self->GetFieldCount();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetFieldCount'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: GetRowCount of class  QueryResult */
#ifndef TOLUA_DISABLE_tolua_All_QueryResult_GetRowCount00
static int tolua_All_QueryResult_GetRowCount00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isusertype(tolua_S,1,"const QueryResult",0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  const QueryResult* self = (const QueryResult*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
 if (!self) tolua_error(tolua_S,"invalid 'self' in function 'GetRowCount'",NULL);
#endif
 {
  unsigned int tolua_ret = ( unsigned int)  self->GetRowCount();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetRowCount'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::messageBegin */
#ifndef TOLUA_DISABLE_tolua_All_Au_messageBegin00
static int tolua_All_Au_messageBegin00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  unsigned int playerid = ((unsigned int)  tolua_tonumber(tolua_S,1,0));
  unsigned short msgid = ((unsigned short)  tolua_tonumber(tolua_S,2,0));
 {
  Au::messageBegin(playerid,msgid);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'messageBegin'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::messageEnd */
#ifndef TOLUA_DISABLE_tolua_All_Au_messageEnd00
static int tolua_All_Au_messageEnd00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  Au::messageEnd();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'messageEnd'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addUint32 */
#ifndef TOLUA_DISABLE_tolua_All_Au_addUint3200
static int tolua_All_Au_addUint3200(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  unsigned int value = (( unsigned int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::addUint32(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addUint32'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addInt32 */
#ifndef TOLUA_DISABLE_tolua_All_Au_addInt3200
static int tolua_All_Au_addInt3200(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  signed int value = (( signed int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::addInt32(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addInt32'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addUint16 */
#ifndef TOLUA_DISABLE_tolua_All_Au_addUint1600
static int tolua_All_Au_addUint1600(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  unsigned int value = (( unsigned int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::addUint16(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addUint16'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addInt16 */
#ifndef TOLUA_DISABLE_tolua_All_Au_addInt1600
static int tolua_All_Au_addInt1600(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  signed int value = (( signed int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::addInt16(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addInt16'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addUint8 */
#ifndef TOLUA_DISABLE_tolua_All_Au_addUint800
static int tolua_All_Au_addUint800(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  unsigned int value = (( unsigned int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::addUint8(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addUint8'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addInt8 */
#ifndef TOLUA_DISABLE_tolua_All_Au_addInt800
static int tolua_All_Au_addInt800(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  signed int value = (( signed int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::addInt8(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addInt8'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addBool */
#ifndef TOLUA_DISABLE_tolua_All_Au_addBool00
static int tolua_All_Au_addBool00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isboolean(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  bool value = ((bool)  tolua_toboolean(tolua_S,1,0));
 {
  Au::addBool(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addBool'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addFloat */
#ifndef TOLUA_DISABLE_tolua_All_Au_addFloat00
static int tolua_All_Au_addFloat00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  float value = ((float)  tolua_tonumber(tolua_S,1,0));
 {
  Au::addFloat(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addFloat'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addString */
#ifndef TOLUA_DISABLE_tolua_All_Au_addString00
static int tolua_All_Au_addString00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  const char* value = ((const char*)  tolua_tostring(tolua_S,1,0));
 {
  Au::addString(value);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addString'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::RegisterModule */
#ifndef TOLUA_DISABLE_tolua_All_Au_RegisterModule00
static int tolua_All_Au_RegisterModule00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int moduleid = ((int)  tolua_tonumber(tolua_S,1,0));
 {
  bool tolua_ret = (bool)  Au::RegisterModule(moduleid);
 tolua_pushboolean(tolua_S,(bool)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'RegisterModule'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::StartModule */
#ifndef TOLUA_DISABLE_tolua_All_Au_StartModule00
static int tolua_All_Au_StartModule00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,1,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int moduleid = ((int)  tolua_tonumber(tolua_S,1,0));
  int threadnum = ((int)  tolua_tonumber(tolua_S,2,1));
 {
  bool tolua_ret = (bool)  Au::StartModule(moduleid,threadnum);
 tolua_pushboolean(tolua_S,(bool)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'StartModule'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::Listen */
#ifndef TOLUA_DISABLE_tolua_All_Au_Listen00
static int tolua_All_Au_Listen00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  Au::Listen();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'Listen'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::ConnectToServer */
#ifndef TOLUA_DISABLE_tolua_All_Au_ConnectToServer00
static int tolua_All_Au_ConnectToServer00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string server_name = ((std::string)  tolua_tocppstring(tolua_S,1,0));
 {
  Au::ConnSocket* tolua_ret = (Au::ConnSocket*)  Au::ConnectToServer(server_name);
 tolua_pushusertype(tolua_S,(void*)tolua_ret,"Au::ConnSocket");
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'ConnectToServer'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::GetSockfdByServerName */
#ifndef TOLUA_DISABLE_tolua_All_Au_GetSockfdByServerName00
static int tolua_All_Au_GetSockfdByServerName00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string server_name = ((std::string)  tolua_tocppstring(tolua_S,1,0));
 {
  unsigned int tolua_ret = (unsigned int)  Au::GetSockfdByServerName(server_name);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetSockfdByServerName'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::RobotStart */
#ifndef TOLUA_DISABLE_tolua_All_Au_RobotStart00
static int tolua_All_Au_RobotStart00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  Au::RobotStart();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'RobotStart'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::CreateRobots */
#ifndef TOLUA_DISABLE_tolua_All_Au_CreateRobots00
static int tolua_All_Au_CreateRobots00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int robot_num = ((int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::CreateRobots(robot_num);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'CreateRobots'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::CreateOneRobot */
#ifndef TOLUA_DISABLE_tolua_All_Au_CreateOneRobot00
static int tolua_All_Au_CreateOneRobot00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  Au::CreateOneRobot();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'CreateOneRobot'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::ValidateConnect */
#ifndef TOLUA_DISABLE_tolua_All_Au_ValidateConnect00
static int tolua_All_Au_ValidateConnect00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  unsigned int sockid = ((unsigned int)  tolua_tonumber(tolua_S,1,0));
  const char* accountID = ((const char*)  tolua_tostring(tolua_S,2,0));
 {
  int tolua_ret = (int)  Au::ValidateConnect(sockid,accountID);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'ValidateConnect'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::query */
#ifndef TOLUA_DISABLE_tolua_All_Au_query00
static int tolua_All_Au_query00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  const char* pszCommand = ((const char*)  tolua_tostring(tolua_S,1,0));
 {
  QueryResult* tolua_ret = (QueryResult*)  Au::query(pszCommand);
 tolua_pushusertype(tolua_S,(void*)tolua_ret,"QueryResult");
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'query'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::queryQueue */
#ifndef TOLUA_DISABLE_tolua_All_Au_queryQueue00
static int tolua_All_Au_queryQueue00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  const char* pszCommand = ((const char*)  tolua_tostring(tolua_S,1,0));
 {
  bool tolua_ret = (bool)  Au::queryQueue(pszCommand);
 tolua_pushboolean(tolua_S,(bool)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'queryQueue'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::queryGetSize */
#ifndef TOLUA_DISABLE_tolua_All_Au_queryGetSize00
static int tolua_All_Au_queryGetSize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int sizetype = ((int)  tolua_tonumber(tolua_S,1,0));
 {
  int tolua_ret = (int)  Au::queryGetSize(sizetype);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'queryGetSize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::StartSqlQueue */
#ifndef TOLUA_DISABLE_tolua_All_Au_StartSqlQueue00
static int tolua_All_Au_StartSqlQueue00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  Au::StartSqlQueue();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'StartSqlQueue'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::EndSqlQueue */
#ifndef TOLUA_DISABLE_tolua_All_Au_EndSqlQueue00
static int tolua_All_Au_EndSqlQueue00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  Au::EndSqlQueue();
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'EndSqlQueue'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::AddSqlQueue */
#ifndef TOLUA_DISABLE_tolua_All_Au_AddSqlQueue00
static int tolua_All_Au_AddSqlQueue00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  const char* QueryString = ((const char*)  tolua_tostring(tolua_S,1,0));
 {
  Au::AddSqlQueue(QueryString);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'AddSqlQueue'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::GetWorldQueueResult */
#ifndef TOLUA_DISABLE_tolua_All_Au_GetWorldQueueResult00
static int tolua_All_Au_GetWorldQueueResult00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  QueryResult* tolua_ret = (QueryResult*)  Au::GetWorldQueueResult();
 tolua_pushusertype(tolua_S,(void*)tolua_ret,"QueryResult");
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetWorldQueueResult'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::getDatateID */
#ifndef TOLUA_DISABLE_tolua_All_Au_getDatateID00
static int tolua_All_Au_getDatateID00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  const char* strKey = ((const char*)  tolua_tostring(tolua_S,1,0));
 {
  unsigned int tolua_ret = ( unsigned int)  Au::getDatateID(strKey);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getDatateID'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedAdd */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedAdd00
static int tolua_All_Au_MemcachedAdd00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  char* value = ((char*)  tolua_tostring(tolua_S,2,0));
  int datalen = ((int)  tolua_tonumber(tolua_S,3,0));
 {
  Au::MemcachedAdd(key,value,datalen);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedAdd'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedSet */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedSet00
static int tolua_All_Au_MemcachedSet00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  char* value = ((char*)  tolua_tostring(tolua_S,2,0));
  int value_len = ((int)  tolua_tonumber(tolua_S,3,0));
 {
  Au::MemcachedSet(key,value,value_len);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedSet'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedReplace */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedReplace00
static int tolua_All_Au_MemcachedReplace00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  char* new_value = ((char*)  tolua_tostring(tolua_S,2,0));
  int value_len = ((int)  tolua_tonumber(tolua_S,3,0));
 {
  Au::MemcachedReplace(key,new_value,value_len);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedReplace'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedAppend */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedAppend00
static int tolua_All_Au_MemcachedAppend00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  char* value = ((char*)  tolua_tostring(tolua_S,2,0));
  int value_len = ((int)  tolua_tonumber(tolua_S,3,0));
 {
  Au::MemcachedAppend(key,value,value_len);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedAppend'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedPrepend */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedPrepend00
static int tolua_All_Au_MemcachedPrepend00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  char* value = ((char*)  tolua_tostring(tolua_S,2,0));
  int value_len = ((int)  tolua_tonumber(tolua_S,3,0));
 {
  Au::MemcachedPrepend(key,value,value_len);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedPrepend'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedIncrement */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedIncrement00
static int tolua_All_Au_MemcachedIncrement00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  int diff = ((int)  tolua_tonumber(tolua_S,2,0));
 {
  Au::MemcachedIncrement(key,diff);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedIncrement'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedDecrement */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedDecrement00
static int tolua_All_Au_MemcachedDecrement00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  int diff = ((int)  tolua_tonumber(tolua_S,2,0));
 {
  Au::MemcachedDecrement(key,diff);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedDecrement'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedDel */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedDel00
static int tolua_All_Au_MemcachedDel00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
 {
  Au::MemcachedDel(key);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedDel'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::MemcachedGet */
#ifndef TOLUA_DISABLE_tolua_All_Au_MemcachedGet00
static int tolua_All_Au_MemcachedGet00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_iscppstring(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,1,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  std::string key = ((std::string)  tolua_tocppstring(tolua_S,1,0));
  int icount = ((int)  tolua_tonumber(tolua_S,2,1));
 {
  std::string tolua_ret = (std::string)  Au::MemcachedGet(key,icount);
 tolua_pushcppstring(tolua_S,(const char*)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'MemcachedGet'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::GetConnSocks */
#ifndef TOLUA_DISABLE_tolua_All_Au_GetConnSocks00
static int tolua_All_Au_GetConnSocks00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  int tolua_ret = (int)  Au::GetConnSocks();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'GetConnSocks'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::nowTime */
#ifndef TOLUA_DISABLE_tolua_All_Au_nowTime00
static int tolua_All_Au_nowTime00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  int tolua_ret = (int)  Au::nowTime();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'nowTime'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::addTimer */
#ifndef TOLUA_DISABLE_tolua_All_Au_addTimer00
static int tolua_All_Au_addTimer00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isstring(tolua_S,3,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,4,1,&tolua_err) ||
 !tolua_isnumber(tolua_S,5,1,&tolua_err) ||
 !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int start = ((int)  tolua_tonumber(tolua_S,1,0));
  int interval = ((int)  tolua_tonumber(tolua_S,2,0));
  const char* luaFunc = ((const char*)  tolua_tostring(tolua_S,3,0));
  int param1 = ((int)  tolua_tonumber(tolua_S,4,0));
  int param2 = ((int)  tolua_tonumber(tolua_S,5,0));
 {
  int tolua_ret = (int)  Au::addTimer(start,interval,luaFunc,param1,param2);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addTimer'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::stopTimer */
#ifndef TOLUA_DISABLE_tolua_All_Au_stopTimer00
static int tolua_All_Au_stopTimer00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  signed int timeID = (( signed int)  tolua_tonumber(tolua_S,1,0));
 {
  Au::stopTimer(timeID);
 }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'stopTimer'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::auRand */
#ifndef TOLUA_DISABLE_tolua_All_Au_auRand00
static int tolua_All_Au_auRand00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnoobj(tolua_S,1,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
 {
  int tolua_ret = (int)  Au::auRand();
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'auRand'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::bitAddState */
#ifndef TOLUA_DISABLE_tolua_All_Au_bitAddState00
static int tolua_All_Au_bitAddState00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int state = ((int)  tolua_tonumber(tolua_S,1,0));
  int pos = ((int)  tolua_tonumber(tolua_S,2,0));
 {
  int tolua_ret = (int)  Au::bitAddState(state,pos);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'bitAddState'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::bitDelState */
#ifndef TOLUA_DISABLE_tolua_All_Au_bitDelState00
static int tolua_All_Au_bitDelState00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int state = ((int)  tolua_tonumber(tolua_S,1,0));
  int pos = ((int)  tolua_tonumber(tolua_S,2,0));
 {
  int tolua_ret = (int)  Au::bitDelState(state,pos);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'bitDelState'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* function: Au::bitCheckState */
#ifndef TOLUA_DISABLE_tolua_All_Au_bitCheckState00
static int tolua_All_Au_bitCheckState00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
 !tolua_isnumber(tolua_S,1,0,&tolua_err) ||
 !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
 !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
 goto tolua_lerror;
 else
#endif
 {
  int state = ((int)  tolua_tonumber(tolua_S,1,0));
  int pos = ((int)  tolua_tonumber(tolua_S,2,0));
 {
  int tolua_ret = (int)  Au::bitCheckState(state,pos);
 tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
 }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'bitCheckState'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
int tolua_All_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
 tolua_cclass(tolua_S,"Field","Field","",NULL);
 tolua_beginmodule(tolua_S,"Field");
  tolua_function(tolua_S,"SetValue",tolua_All_Field_SetValue00);
  tolua_function(tolua_S,"GetString",tolua_All_Field_GetString00);
  tolua_function(tolua_S,"GetFloat",tolua_All_Field_GetFloat00);
  tolua_function(tolua_S,"GetBool",tolua_All_Field_GetBool00);
  tolua_function(tolua_S,"GetUInt8",tolua_All_Field_GetUInt800);
  tolua_function(tolua_S,"GetInt8",tolua_All_Field_GetInt800);
  tolua_function(tolua_S,"GetUInt16",tolua_All_Field_GetUInt1600);
  tolua_function(tolua_S,"GetInt16",tolua_All_Field_GetInt1600);
  tolua_function(tolua_S,"GetUInt32",tolua_All_Field_GetUInt3200);
  tolua_function(tolua_S,"GetInt32",tolua_All_Field_GetInt3200);
  tolua_function(tolua_S,"GetUInt64",tolua_All_Field_GetUInt6400);
 tolua_endmodule(tolua_S);
 tolua_cclass(tolua_S,"QueryResult","QueryResult","",NULL);
 tolua_beginmodule(tolua_S,"QueryResult");
  tolua_function(tolua_S,"NextRow",tolua_All_QueryResult_NextRow00);
  tolua_function(tolua_S,"Delete",tolua_All_QueryResult_Delete00);
  tolua_function(tolua_S,"GetFieldFromCount",tolua_All_QueryResult_GetFieldFromCount00);
  tolua_function(tolua_S,"GetFieldCount",tolua_All_QueryResult_GetFieldCount00);
  tolua_function(tolua_S,"GetRowCount",tolua_All_QueryResult_GetRowCount00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"messageBegin",tolua_All_Au_messageBegin00);
  tolua_function(tolua_S,"messageEnd",tolua_All_Au_messageEnd00);
  tolua_function(tolua_S,"addUint32",tolua_All_Au_addUint3200);
  tolua_function(tolua_S,"addInt32",tolua_All_Au_addInt3200);
  tolua_function(tolua_S,"addUint16",tolua_All_Au_addUint1600);
  tolua_function(tolua_S,"addInt16",tolua_All_Au_addInt1600);
  tolua_function(tolua_S,"addUint8",tolua_All_Au_addUint800);
  tolua_function(tolua_S,"addInt8",tolua_All_Au_addInt800);
  tolua_function(tolua_S,"addBool",tolua_All_Au_addBool00);
  tolua_function(tolua_S,"addFloat",tolua_All_Au_addFloat00);
  tolua_function(tolua_S,"addString",tolua_All_Au_addString00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"RegisterModule",tolua_All_Au_RegisterModule00);
  tolua_function(tolua_S,"StartModule",tolua_All_Au_StartModule00);
  tolua_function(tolua_S,"Listen",tolua_All_Au_Listen00);
  tolua_function(tolua_S,"ConnectToServer",tolua_All_Au_ConnectToServer00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"GetSockfdByServerName",tolua_All_Au_GetSockfdByServerName00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"RobotStart",tolua_All_Au_RobotStart00);
  tolua_function(tolua_S,"CreateRobots",tolua_All_Au_CreateRobots00);
  tolua_function(tolua_S,"CreateOneRobot",tolua_All_Au_CreateOneRobot00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"ValidateConnect",tolua_All_Au_ValidateConnect00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"query",tolua_All_Au_query00);
  tolua_function(tolua_S,"queryQueue",tolua_All_Au_queryQueue00);
  tolua_function(tolua_S,"queryGetSize",tolua_All_Au_queryGetSize00);
  tolua_function(tolua_S,"StartSqlQueue",tolua_All_Au_StartSqlQueue00);
  tolua_function(tolua_S,"EndSqlQueue",tolua_All_Au_EndSqlQueue00);
  tolua_function(tolua_S,"AddSqlQueue",tolua_All_Au_AddSqlQueue00);
  tolua_function(tolua_S,"GetWorldQueueResult",tolua_All_Au_GetWorldQueueResult00);
  tolua_function(tolua_S,"getDatateID",tolua_All_Au_getDatateID00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"MemcachedAdd",tolua_All_Au_MemcachedAdd00);
  tolua_function(tolua_S,"MemcachedSet",tolua_All_Au_MemcachedSet00);
  tolua_function(tolua_S,"MemcachedReplace",tolua_All_Au_MemcachedReplace00);
  tolua_function(tolua_S,"MemcachedAppend",tolua_All_Au_MemcachedAppend00);
  tolua_function(tolua_S,"MemcachedPrepend",tolua_All_Au_MemcachedPrepend00);
  tolua_function(tolua_S,"MemcachedIncrement",tolua_All_Au_MemcachedIncrement00);
  tolua_function(tolua_S,"MemcachedDecrement",tolua_All_Au_MemcachedDecrement00);
  tolua_function(tolua_S,"MemcachedDel",tolua_All_Au_MemcachedDel00);
  tolua_function(tolua_S,"MemcachedGet",tolua_All_Au_MemcachedGet00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"GetConnSocks",tolua_All_Au_GetConnSocks00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"nowTime",tolua_All_Au_nowTime00);
  tolua_function(tolua_S,"addTimer",tolua_All_Au_addTimer00);
  tolua_function(tolua_S,"stopTimer",tolua_All_Au_stopTimer00);
 tolua_endmodule(tolua_S);
 tolua_module(tolua_S,"Au",0);
 tolua_beginmodule(tolua_S,"Au");
  tolua_function(tolua_S,"auRand",tolua_All_Au_auRand00);
  tolua_function(tolua_S,"bitAddState",tolua_All_Au_bitAddState00);
  tolua_function(tolua_S,"bitDelState",tolua_All_Au_bitDelState00);
  tolua_function(tolua_S,"bitCheckState",tolua_All_Au_bitCheckState00);
 tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 int luaopen_All (lua_State* tolua_S) {
 return tolua_All_open(tolua_S);
};
#endif

