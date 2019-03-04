#ifndef _AUENGINE_SRC_AUENGINE_ENGINE_LAUNCHER_H_
#define _AUENGINE_SRC_AUENGINE_ENGINE_LAUNCHER_H_
namespace AuEngine
{
	
#define SERVER_TYPE_BEGINE		0
#define SERVER_AUENGINE_MGR		SERVER_TYPE_BEGINE + 1
#define SERVER_TYPE_END			SERVER_AUENGINE_MGR + 1

class ServerLauncher
{
public:
	ServerLauncher();
	virtual ~ServerLauncher()=0;

	virtual bool Init()=0;

	virtual bool Start()=0;

	virtual bool Shutdown()=0;

private:

};

}//namespace AuEngine

#endif