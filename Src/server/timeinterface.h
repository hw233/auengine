#ifndef _AUENGINE_SRC_AUENGINE_TIMEINTERFACE_H_
#define _AUENGINE_SRC_AUENGINE_TIMEINTERFACE_H_

namespace Au
{
#define MINMUM_CIRCLE  0.1

	class TimeInterface
	{
	public:
		TimeInterface();
		~TimeInterface();

		static const long GetTicks(void);
	};
}

#endif