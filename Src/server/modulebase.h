#ifndef _AUENGINE_SRC_AUENGINE_MODULEBASE_H_
#define _AUENGINE_SRC_AUENGINE_MODULEBASE_H_

#include <stdio.h>

namespace Au
{
	class ModuleBase
	{
	public:
		ModuleBase(void);
		virtual ~ModuleBase(void)=0;
		
		//Initialize all the resources you need.
		virtual bool Init()=0;

		//Destroy all thre resources the module holded.
		virtual bool Destroy()=0;

		//Some module may be hold some threads, start all the holded threads.
		virtual bool Start()=0;

		virtual bool CreateThreads(int n);
	private:
		ModuleBase(const ModuleBase &);
		void operator=(const ModuleBase &);
	};
}


#endif