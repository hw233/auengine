--Redis.lua
require "resource.script.server.Base.Base"

Redis = {}

function Redis:get(key)
	return Au.procRedisCmd("get "..key)
end

function Redis:set(key,value)
	return Au.procRedisCmd("set "..key.." "..value)
end

function Redis:hget(key,field)
	return Au.procRedisCmd("get "..key.." "..field)
end

function Redis:hset(key,field,value)
	return Au.procRedisCmd("get "..key.." "..field.." "..value)
end

function Redis:hdel(key,field)
	return Au.procRedisCmd("hdel "..key.." "..field)
end

function Redis:llen(key)
	return Au.procRedisCmd("llen "..key)
end

--redis��ȡ����(get)
function Redis:RedisGet(dbID)
	return unpackDBValue(self:get(tostring(dbID)))
end

--���ݴ���redis(set)
function Redis:RedisSet(data)
	return self:set(data.databaseID, packDBValue(data))
end

--redisɾ������
function Redis:RedisDel(dbID)
	return Au.procRedisCmd("del "..tostring(dbID))
end

--redis��ȡ����(hget)
function Redis:RedisHGet(key, field)
	return unpackDBValue(self.hget(tostring(key),tostring(field)))
end

--redis��������(hset)
function Redis:RedisHSet()
	return
end


--���Դ���
function set()
	local data = {
		databaseID=1,
		itemID=16,
		itemType=0,
	}
	printTB(data)
	print(Redis:RedisSet(data))
end

function get(key)
	printTB(Redis:RedisGet(key))
end

function del(key)
	print(Redis:RedisDel(key))
end