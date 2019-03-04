#include "testcase.h"
#include "gdata.h"
#include "testmacro.h"
namespace TestCase
{

void TestOfVariPara()
{
#ifdef TESTOFVARIPARA
	bool b = true;
	int i = 10086;
	char ch = 'c';
	Au::GData::g_luamodule->RunLuaFunctionVariableParaModule("TestVariableParaBool","%b", b);
	Au::GData::g_luamodule->RunLuaFunctionVariableParaModule("TestVariParaChar","%c", ch);
	Au::GData::g_luamodule->RunLuaFunctionVariableParaModule("TestVariParaBoolIntChar","%b%d%c", b,i,ch);
#endif
}


}//namespace TestCase
