#include "timeinterface.h"
#include <ctime>

namespace Au
{
	TimeInterface::TimeInterface()
	{

	}
	
	TimeInterface::~TimeInterface()
	{

	}

	const long TimeInterface::GetTicks()
	{
		return clock();
	}

}