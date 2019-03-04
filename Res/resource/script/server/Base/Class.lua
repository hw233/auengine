--ģ��ʵ��C++��̳еĲ���
local function ParseName(str)
	local _begin, _end, clsName = assert(str:find('%s*([a-zA-Z][a-zA-Z0-9_]*)%s*%:?'));
	-- print(_begin, _end, clsName);
	if not str:find(':', _end) then
		return clsName, {};
	end
	local bases = {};	-- ��������
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

-- ģ��C++��class�ؼ���
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
		-- t.class = t -- ָ���࣬��������������Ա
		t.className = clsName; -- ����string
		t.super = bases[1]; -- ���ؼ̳еĵ�һ������
		env[clsName] = setmetatable(t, meta);
	end
end

-- ʹ��
-- ����һ����
class 'Person'{
	-- ���캯��
	__init__ = function (self, name)
		self.name = name;
	end,
	
	Say = function (self)
		if self.super then
			print('����: ', self.className, '��һ������: ', self.super.className);
		else
			print('����: ', self.className);
		end
		print('��Һã��ҽ� ' .. (self.name or 'no name') .. '.');
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

-- �̳У�����ж�����࣬�ö��Ÿ���
class 'Employee: Person,Man'{
	__init__ = function (self, name, salary)
		Person.__init__(self, name); -- call base class's method
		Man.__init__(self, name)
		self.salary = salary;
	end;
	
	-- ���غ���
	SaySthElse = function (self)
		print('�ҵ�нˮ�� ' .. (self.salary or 'no salary') .. '.');
	end;
};
function test()
	local p = Person'�ɷ�';
	p:Say();
	local e = Employee('��ɸ�', 2000);
	e:Say();
	e:Write()
	-- e:SaySthElse();	
end