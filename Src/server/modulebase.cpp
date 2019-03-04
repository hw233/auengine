#include "modulebase.h"
#include <iostream>
namespace Au
{

ModuleBase::ModuleBase(void)
{
}

bool ModuleBase::Init()
{
	return true;
}

bool ModuleBase::Destroy(void)
{
	return true;
}

bool ModuleBase::Start()
{
	return true;
}

ModuleBase::~ModuleBase(void)
{
}

bool ModuleBase::CreateThreads(int n)
{

	return true;
}

}//end namespace Au