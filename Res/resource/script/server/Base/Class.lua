--模拟实现C++多继承的操作
local function ParseName(str)
	local _begin, _end, clsName = assert(str:find('%s*([a-zA-Z][a-zA-Z0-9_]*)%s*%:?'));
	-- print(_begin, _end, clsName);
	if not str:find(':', _end) then
		return clsName, {};
	end
	local bases = {};	-- 基类名表
	while true do
		local base;
		_begin, _end, base = str:find('%s*([a-zA-Z][a-zA-Z0-9_]*)%s*%,?', _end + 1);
		if base then table.insert(bases, base) else break end;
	end
	return clsName, bases;
end

local function Create(t, ...)
	local o = {};
	if t.__init__ then t.__init__(o, ...) end;
	return setmetatable(o, {__index = t, __class__ = t});
end

-- 模拟C++的class关键字
function class(name)
	local env = getfenv(2);
	-- print('env=', env);
	local clsName, bases = ParseName(name);
	-- print(clsName, #bases);
	for i, v in ipairs(bases)do bases[i] = env[v] end; -- Replace string name with class table
	
	return function (t)
		local meta = {__call = Create, __bases__ = bases};
		meta.__index = function (nouse, key)
			for _, cls in ipairs(meta.__bases__)do
				local val = cls[key];	-- Do a recursive search on each cls
				if val ~= nil then return val end;
			end
		end
		-- t.class = t -- 指向类，可以用于添加类成员
		t.className = clsName; -- 类名string
		t.super = bases[1]; -- 多重继承的第一个父类
		env[clsName] = setmetatable(t, meta);
	end
end

-- 使用
-- 定义一个类
class 'Person'{
	-- 构造函数
	__init__ = function (self, name)
		self.name = name;
	end,
	
	Say = function (self)
		if self.super then
			print('类名: ', self.className, '第一个基类: ', self.super.className);
		else
			print('类名: ', self.className);
		end
		print('大家好，我叫 ' .. (self.name or 'no name') .. '.');
		self:SaySthElse();
	end,
	
	SaySthElse = function (self)
		print'SaySthElse';
	end,
};
class 'Man'
{
	__init__ = function (self, name)
		self.name = name;
	end,
	Write = function (self)
		print("gasdfadfdsf"..self.name);
	end,
};

-- 继承，如果有多个基类，用逗号隔开
class 'Employee: Person,Man'{
	__init__ = function (self, name, salary)
		Person.__init__(self, name); -- call base class's method
		Man.__init__(self, name)
		self.salary = salary;
	end;
	
	-- 重载函数
	SaySthElse = function (self)
		print('我的薪水是 ' .. (self.salary or 'no salary') .. '.');
	end;
};
function test()
	local p = Person'飞飞';
	p:Say();
	local e = Employee('大飞哥', 2000);
	e:Say();
	e:Write()
	-- e:SaySthElse();	
end