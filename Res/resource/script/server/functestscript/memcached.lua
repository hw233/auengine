--Demo And Test
--1.除Au.MemcachedGet函数外，其他函数都是把key,value放到处理队列中，
--Memcached Module对应的线程不断的进行处理，所有有些
--存数据的操作，立即去取不一定可以获取到。
--后续会根据实际进行调整。
--2.实际使用直接调用Au的接口。
require "resource.script.server.resource.script.server.functestscript.supportfunc"

function MemcachedAdd()
	local key_add = "key_add"
	local value_add = "value_add"
	Au.MemcachedAdd(key_add, value_add, string.len(value_add))
	--Memcached Server Command To Check: get key_set
	local res = Au.MemcachedGet(key_add)
	if string.len(res)~=0 then 
		print("res:"..tostring(res))
	end 
	Au.MemcachedDel(key_add)
	
	--Test Of int
	local key_add_int = "intisvalue"
	local value_add_int = 102
	Au.MemcachedAdd(key_add_int, value_add_int, string.len(value_add_int))
	local res_int = Au.MemcachedGet(key_add_int)
	if string.len(res_int)~=0 then 
		print("resssss:"..tonumber(res_int))
		local t_num = tonumber(res_int) + 1
		print("num_o:"..t_num)
	end 
	Au.MemcachedDel(key_add_int)
	
	--Test of table
	local player1 = "Jesse_deng"
	local player1_info = {}
	player1_info.gender = "female"
	player1_info.hobby = {"Reading", "Play Games", "Coding"}
	local player1_info_str = sz_T2S(player1_info)
	Au.MemcachedAdd(player1, player1_info_str, string.len(player1_info_str))
	local res_str = Au.MemcachedGet(player1)
	if string.len(res_str)~=0 then 
		local res_table = t_S2T(res_str)
		if (res_table.gender=="female") then 
			print("Ok")
		else
			print("Not Ok")
		end
	else
		print("Not ok")
	end 
	Au.MemcachedDel(player1)
end 

function MemcachedSet()
	local key_add = "key_set"
	local value_add = "value_set"
	Au.MemcachedSet(key_add, value_add, string.len(value_add))
	--Memcached Server Command To Check: get key_set
	local res = Au.MemcachedGet(key_add)
	print("res:"..tostring(res))
	Au.MemcachedDel(key_add)
	
	--Test Of int
	local key_add_int = "intisvalue"
	local value_add_int = 120
	Au.MemcachedSet(key_add_int, value_add_int, string.len(value_add_int))
	local res_int = Au.MemcachedGet(key_add_int)
	if (string.len(res_int)~=0) then 
		print("res_int:"..tonumber(res_int))
		local t_num = tonumber(res_int) + 1
		print("num_o:"..t_num)
	end 
	Au.MemcachedDel(key_add_int)
	
	--Test of table
	local player1 = "Jesse_deng"
	local player1_info = {}
	player1_info.gender = "female"
	player1_info.hobby = {"Reading", "Play Games", "Coding"}
	local player1_info_str = sz_T2S(player1_info)
	Au.MemcachedSet(player1, player1_info_str, string.len(player1_info_str))
	local res_str = Au.MemcachedGet(player1)
	local res_table = t_S2T(res_str)
	if ((res_table.gender)=="female") then 
		print("Ok")
	else
		print("Not Ok")
	end
	Au.MemcachedDel(player1)
end 

function MemcachedReplace()
	local key_re = "key_re"
	local value_re = "old_value"
	local new_value = "new_value"
	Au.MemcachedAdd(key_re, value_re, string.len(value_re))
	Au.MemcachedReplace(key_re, new_value, string.len(new_value))
	local new_value_res = Au.MemcachedGet(key_re)
	if (tostring(new_value_res)==tostring(new_value)) then 
		print("MemcachedReplace nice")
	else
		print("replace failured.")
	end 
end 

function MemcachedAppend()
	local key_append = "key_append"
	local value_append = "abc"
	Au.MemcachedAdd(key_append, value_append, string.len(value_append))
	local appendvalue = "bcd"
	Au.MemcachedAppend(key_append, appendvalue, string.len(appendvalue))
	local res_str = Au.MemcachedGet(key_append)
	if (tostring(res_str)==tostring("abcbcd")) then 
		print("MemcachedAppend nice")
	else 
		print("MemcachedAppend Not Ok")
	end 
	Au.MemcachedDel(key_append)
end

function MemcachedPrepend()
	local key_prepend = "key_prepend"
	local value_prepend = "abc"
	Au.MemcachedAdd(key_prepend, value_prepend, string.len(value_prepend))
	local prependvalue = "bcd"
	Au.MemcachedPrepend(key_prepend, prependvalue, string.len(prependvalue))
	local res_str = Au.MemcachedGet(key_prepend)
	if (tostring(res_str)==tostring("bcdabc")) then 
		print("MemcachedPrepend nice")
	else 
		print("MemcachedPrepend Not Ok")
	end
	Au.MemcachedDel(key_prepend)
end 

function MemcachedIncrement()
	local key_incre = "key_incre"
	local value_incre = 100
	Au.MemcachedAdd(key_incre, value_incre, string.len(value_incre))
	
	Au.MemcachedIncrement(key_incre, 22)
	local ret_src = Au.MemcachedGet(key_incre)
	if (tonumber(ret_src)==122) then 
		print("MemcachedIncrement nice")
	else 
		print("MemcachedIncrement Not Ok")
	end 
	Au.MemcachedDel(key_incre)
end 

function MemcachedDecrement()
	local key_decre = "key_decre"
	local value_decre = 111
	Au.MemcachedAdd(key_decre, value_decre, string.len(value_decre))
	Au.MemcachedDecrement(key_decre, 11)
	local ret_src = Au.MemcachedGet(key_decre)
	if (tonumber(ret_src)==100) then 
		print("MemcachedDecrement Nice")
	else
		print("MemcachedDecrement Not Ok")
	end 
end 

function MemcachedDel(key)
	Au.MemcachedDel(key)
end 

function MemcachedGet(key)
	return Au.MemcachedGet(key)
end 

function MemcachedTest()
	MemcachedSet()
	MemcachedAdd()
	MemcachedReplace()
	MemcachedAppend()
	MemcachedPrepend()
	MemcachedIncrement()
	MemcachedDecrement()
end 