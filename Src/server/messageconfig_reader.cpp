#include "messageconfig_reader.h"
#include <iostream>
#include "Log.h"
#include "tinyxml.h"
#include "param_type_map.h"
const::std::string DELIMITERS = ",";

namespace Au
{


MessageConfigReader::MessageConfigReader()
{

}

MessageConfigReader::~MessageConfigReader()
{

}

bool MessageConfigReader::ReadConfig(const char *filepath)
{
	if (!this->ReadMsgConfigure(filepath))
		return false;

	this->ShowAll();
	return true;
}

bool MessageConfigReader::Destroy()
{
	_msgcfg.clear();
	return true;
}
bool MessageConfigReader::ReadMsgConfigure(const char *filepath)
{
	if ( !filepath ) return false;

	TiXmlDocument doc;
	if ( !doc.LoadFile( filepath ) )
	{
		Log.outError( "%s no exist or format error", filepath );
		return false;
	}

	TiXmlElement *root = doc.RootElement();
	if ( !root )
	{
		Log.outError( "root node error" );
		doc.Clear();
		return false;
	}

	const TiXmlElement *pMsg = root->FirstChildElement();
	while ( pMsg )
	{
		if (!this->ParseNode(pMsg))
		{
			doc.Clear();
			return false;
		}
		pMsg = pMsg->NextSiblingElement();
	}
	doc.Clear();
	return true;
}

bool MessageConfigReader::ParseNode(const TiXmlElement *node)
{
	MsgConfig msgCfg;

	const TiXmlElement* pID = node->FirstChildElement( "id" );
	if (pID)
	{
		msgCfg.msgid = atoi(pID->GetText());
	}

	std::string strArg;
	std::vector<std::string> vecArgString;
	std::vector<int> vecArgInt;
	const TiXmlElement* pArg = node->FirstChildElement( "arg" );
	if ( pArg )
	{
		strArg = pArg->GetText();	
		if (!this->Split(strArg, DELIMITERS, vecArgString))
			return false;
		this->TranFormat(vecArgString, msgCfg.parameters);
	}

	const TiXmlElement* pFun = node->FirstChildElement( "function" );
	if (pFun)
	{
		msgCfg.funcname = pFun->GetText();
	}

	_msgcfg.insert( std::map<int,MsgConfig>::value_type( msgCfg.msgid, msgCfg));

	return true;
}

bool MessageConfigReader::Split(std::string &src, const std::string &delim, std::vector<std::string> &ret)
{
	size_t last = 0;
	size_t index = src.find_first_of(delim,last);
	while (index!=std::string::npos)
	{
		std::string type = src.substr(last,index-last);
		if (!this->DataTypeCheck(type))
			return false;
		ret.push_back(src.substr(last,index-last));
		last=index+1;
		index=src.find_first_of(delim,last);
	}
	if (index-last>0)
	{
		ret.push_back(src.substr(last,index-last));
	}
	return true;
}

bool MessageConfigReader::DataTypeCheck(std::string &type)
{
	bool ret = true;
	if (strcmp(type.c_str(), "UINT32")!=0 &&
		strcmp(type.c_str(), "INT32")!=0  &&
		strcmp(type.c_str(), "UINT16")!=0 &&
		strcmp(type.c_str(), "INT16")!=0  &&
		strcmp(type.c_str(), "UINT8")!=0  &&
		strcmp(type.c_str(), "INT8")!=0   &&
		strcmp(type.c_str(), "BOOL")!=0   &&
		strcmp(type.c_str(), "FLOAT")!=0  &&
		strcmp(type.c_str(), "STRING")!=0 &&
		strcmp(type.c_str(), "REPEAT") !=0
		)
		ret = false;

	return ret;
}

void MessageConfigReader::TranFormat(const std::vector<std::string> &src, std::vector<int> &dst)
{
	int iValue( 0 );
	std::vector<std::string>::const_iterator iter = src.begin();
	while ( iter != src.end() )
	{
		iValue = ParseType( *iter );
		dst.push_back( iValue );
		++iter;
	}
}

int MessageConfigReader::ParseType(const std::string &text)
{
	if( text == "REPEAT")
		return LUA_PARAM_TYPE_REPEAT;

	if( text == "UINT32" )
		return LUA_PARAM_TYPE_UINT32;

	if( text == "INT32" )
		return LUA_PARAM_TYPE_INT32;

	if( text == "UINT16" )
		return LUA_PARAM_TYPE_UINT16;

	if( text == "INT16" )
		return LUA_PARAM_TYPE_INT16;

	if( text == "UINT8" )
		return LUA_PARAM_TYPE_UINT8;

	if( text == "INT8" )
		return LUA_PARAM_TYPE_INT8;

	if( text == "BOOL" )
		return LUA_PARAM_TYPE_BOOL;

	if( text == "FLOAT" )
		return LUA_PARAM_TYPE_FLOAT;

	if( text == "STRING" )
		return LUA_PARAM_TYPE_STRING;
	
	return LUA_PARAM_TYPE_ERROR;
}

MsgConfig *MessageConfigReader::GetMsgConfigFromMsgId(int msgid)
{
	std::map<int, MsgConfig>::iterator iter = _msgcfg.find(msgid);
	if (iter==_msgcfg.end())
	{
		Log.outError("there is no Message ID = %d",msgid);
		return NULL;
	}
	if (iter->second.funcname.length()== 0)
	{
		Log.outError("there is no Message ID = %d function Call",msgid);
		return NULL;
	}
	return &(iter->second);
}

void MessageConfigReader::ShowAll()
{
//#define _SHOW_INFO_
#ifdef _SHOW_INFO_
	std::map<int , MsgConfig>::const_iterator it_beg = _msgcfg.begin();
	std::map<int , MsgConfig>::const_iterator it_end = _msgcfg.end();
	while (it_beg!=it_end)
	{
		const MsgConfig *msg = &(it_beg->second);
		std::cout<<"msgid"<<msg->msgid<<std::endl;
		std::cout<<"funcname:"<<msg->funcname<<std::endl;
		std::vector<int>::const_iterator tit_b = msg->parameters.begin();
		std::vector<int>::const_iterator tit_e = msg->parameters.end();
		while (tit_b!=tit_e)
		{
			std::cout<<*tit_b<<" "<<std::endl;
			++tit_b;
		}
		++it_beg;
	}
#endif 
#undef _SHOW_INFO_
}

}//namespace Au
