local Random = {}
Random.__index = Random

function Random.new(seed)
	local o = {
		seed = seed,
		--各常量参考
		--http://www.cnblogs.com/xkfz007/archive/2012/03/27/2420154.html
		m = math.pow(2,32),
		a = 1664525,
		c = 1013904223
	}
	return setmetatable(o, Random)
end

--重置随机种子
function Random:scand(v)
	self.seed = v
end

--随机1个整数
function Random:rand()
	self.seed = (self.seed*self.a + self.c)%self.m
	return self.seed
end

--随机给定范围[a,b]的整数
function Random:randInt(a, b)
	assert(b > a)
	return a + math.floor((b-a+1)*self:randFloat())
end

--随机一个0-1之间的浮点数
function Random:randFloat()
	return self:rand()/(self.m+1)
end

-- function test()
-- 	local r = Random.new(1)
-- 	--print (r:rand())
-- 	for i=1,100 do
-- 		print(r:randDInt(0,10))
-- 		if i%10 == 0 then
-- 			print('----')
-- 		end
-- 	end
-- end

-- test()

return Random
