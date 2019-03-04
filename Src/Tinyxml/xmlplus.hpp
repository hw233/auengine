/*
	xml ��д��
		����:	
				<root>
					<server>
						<ip>172.16.0.12</ip>
						<port>6000</port>
					</server>
				</root>
		    	--------------------------------------------------------------------------------
				XmlPlus* xml = new XmlPlus("KBEngine.xml");
				TiXmlNode* node = xml->getRootNode("server");

				XML_FOR_BEGIN(node)
				{
					printf("%s--%s\n", xml->getKey(node).c_str(), xml->getValStr(node->FirstChild()).c_str());
				}
				XML_FOR_END(node);
				
				delete xml;
		���:
				---ip---172.16.0.12
				---port---6000
				

		����2:
				XmlPlus* xml = new XmlPlus("KBEngine.xml");
				TiXmlNode* serverNode = xml->getRootNode("server");
				
				TiXmlNode* node;
				node = xml->enterNode(serverNode, "ip");	
				printf("%s\n", xml->getValStr(node).c_str() );	

				node = xml->enterNode(serverNode, "port");		
				printf("%s\n", xml->getValStr(node).c_str() );	
			
		���:
			172.16.0.12
			6000
*/

#ifndef __XMLPLUS__
#define __XMLPLUS__

// common include	
//#define NDEBUG
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string>
#include "tinyxml.h"


#define XML_FOR_BEGIN(node)																\
		do																				\
		{																				\
		if(node->Type() != TiXmlNode::ELEMENT)									\
				continue;																\
			
#define XML_FOR_END(node)																\
	}while((node = node->NextSibling()));												\
			
class  XmlPlus
{
public:
	XmlPlus(void):
		txdoc_(NULL),
		rootElement_(NULL),
		isGood_(false)
	{
	}

	XmlPlus(const char* xmlFile):
		txdoc_(NULL),
		rootElement_(NULL),
		isGood_(false)
	{
		isGood_ = openSection(xmlFile) != NULL || rootElement_ != NULL;
	}
	
	~XmlPlus(void){
		if(txdoc_){
			txdoc_->Clear();
			delete txdoc_;
			txdoc_ = NULL;
			rootElement_ = NULL;
		}
	}

	bool isGood()const{ return isGood_; }

	TiXmlNode* openSection(const char* xmlFile)
	{
		char pathbuf[255];
		#ifdef WIN32
			_snprintf(pathbuf, 255, "%s", xmlFile);
		#else
			snprintf(pathbuf, 255, "%s", xmlFile);
		#endif
		txdoc_ = new TiXmlDocument((char*)&pathbuf);

		if(!txdoc_->LoadFile())
		{
			return NULL;
		}

		rootElement_ = txdoc_->RootElement();
		return getRootNode();
	}

	/**��ȡ��Ԫ��*/
	TiXmlElement* getRootElement(void){return rootElement_;}

	/**��ȡ���ڵ㣬 ������keyΪ��Χ���ڵ��µ�ĳ���ӽڵ��*/
	TiXmlNode* getRootNode(const char* key = "")
	{
		if(rootElement_ == NULL)
			return rootElement_;

		if(strlen(key) > 0){
			TiXmlNode* node = rootElement_->FirstChild(key);
			if(node == NULL)
				return NULL;
			return node->FirstChild();
		}
		return rootElement_->FirstChild();
	}

	/**ֱ�ӷ���Ҫ�����key�ڵ�ָ��*/
	TiXmlNode* enterNode(TiXmlNode* node, const char* key)
	{
		do{
			if(node->Type() != TiXmlNode::ELEMENT)
				continue;

			if(getKey(node) == key)
				return node->FirstChild();

		}while((node = node->NextSibling()));

		return NULL;
	}

	/**�Ƿ��������һ��key*/
	bool hasNode(TiXmlNode* node, const char* key)
	{
		do{
			if(node->Type() != TiXmlNode::ELEMENT)
				continue;

			if(getKey(node) == key)
				return true;

		}while((node = node->NextSibling()));

		return false;	
	}
	
	TiXmlDocument* getTxdoc()const { return txdoc_; }

	std::string getKey(const TiXmlNode* node){return node->Value();}
	std::string getValStr(const TiXmlNode* node){return node->ToText()->Value();}
	std::string getVal(const TiXmlNode* node){return node->ToText()->Value();}
	int getValInt(const TiXmlNode* node){return atoi(node->ToText()->Value());}
	double getValFloat(const TiXmlNode* node){return atof(node->ToText()->Value());}
protected:
	TiXmlDocument* txdoc_;
	TiXmlElement* rootElement_;
	bool isGood_;
};

#endif
