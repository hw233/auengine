#ifndef _AUENGINE_SRC_SERVER_SERVERCOMMON_SAFE_TECH_H_
#define _AUENGINE_SRC_SERVER_SERVERCOMMON_SAFE_TECH_H_


#define SAFE_RELEASE(p)							\
	if (p)										\
	{											\
		delete p;								\
		p = NULL;								\
	}

#define SAFE_RELEASE_ARRAY(p)						\
	if (p)											\
	{												\
		delete[] p;									\
		p = NULL;									\
	}

#endif 