#include "auxiliary_kit.h"
#include <stdio.h>
namespace Kit
{
	
	int ExecCmd(const char *cmd, std::string &dst)
	{
		int    ret = 0;
		char   psBuffer[128];
		FILE   *chkdsk = NULL;
		if( (chkdsk = PIPEOPEN(cmd, "r")) == NULL )
			return 0;

		while( !feof( chkdsk ) )
		{
			if( fgets( psBuffer, 128, chkdsk ) != NULL )
				dst.append(psBuffer);//printf( psBuffer );
		}

		ret = (PIPECLOSE(chkdsk)==0);
		return ret;
	}


	void ObtainCaption(std::string &src, std::vector<std::string> &dst)
	{
#define SEPRATOR "\r\n"
		int startpos = 0;
		int found = src.find_first_of(SEPRATOR, startpos);
		//cout<<"src:"<<src<<endl;
		while ( found!=std::string::npos)
		{	
			if (found>startpos)
			{
				std::string ss = src.substr(startpos, found-startpos);
				dst.push_back(ss);
			}
			startpos = found+1;
			found = src.find_first_of(SEPRATOR, startpos);
		}
#undef SEPRATOR
	}

	void ObtainFiled(std::vector<std::string> &src, int paramnum, std::vector<std::string> &dst)
	{
#define SEPRATOR " "
		std::vector<std::string>::iterator it_beg = src.begin();
		std::vector<std::string>::iterator it_end = src.end();
		while (it_beg!=it_end)
		{
			int startpos = 0;
			int found = it_beg->find_first_of(SEPRATOR, startpos);
			int cnt = 0;
			while (found!=std::string::npos)
			{
				if (found>startpos)
				{
					++cnt;
					if (cnt==paramnum)
					{
						std::string ss = it_beg->substr(startpos, found-startpos);
						dst.push_back(ss);
						break;
					}
				}
				startpos = found + 1;
				found = it_beg->find_first_of(SEPRATOR, startpos);
			}
			++it_beg;
		}
#undef SEPRATOR
	}


}