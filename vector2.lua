--[[
Copyright (c) 2010-2013 Matthias Richter
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local assert = assert
local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

local vector2 = {}
vector2.__index = vector2

local function new(x,y)
	return setmetatable({x = x or 0, y = y or 0}, vector2)
end
local zero = new(0,0)
local right = new(1,0)
local left = new(-1,0)
local up = new(0,1)
local down = new(0,-1)

--极小值
local EPSINON = 0.000001

--判断float是否等于0
local function isFloatZero( v )
	
	return (v >= -EPSINON and v <= EPSINON) and 0 or v
end

--从极坐标得到向量
local function fromPolar( length, angle)
	local x, y = cos(angle)*length, sin(angle)*length
	return new(isFloatZero(x), isFloatZero(y))
end

local function isvector2(v)
	assert(v)
	return type(v) == 'table' and type(v.x) == 'number' and type(v.y) == 'number'
end

--获得插值
local function lerp( P0, P1, t )
	return P0*(1-t) + P1*t
end

function vector2:lerpInPlace( P1, t )
	local _t = 1 - t
	self.x = self.x * _t + P1.x * t
	self.y = self.y * _t + P1.y * t
end

function vector2:clone()
	return new(self.x, self.y)
end

function vector2:unpack()
	return self.x, self.y
end

function vector2:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function vector2.__unm(a)
	return new(-a.x, -a.y)
end

function vector2.__add(a,b)
	assert(isvector2(a) and isvector2(b), "Add: wrong argument types (<vector2> expected)")
	return new(a.x+b.x, a.y+b.y)
end

function vector2:add( b )
	self.x, self.y = self.x + b.x,self.y + b.y
end

function vector2.__sub(a,b)
	assert(isvector2(a) and isvector2(b), "Sub: wrong argument types (<vector2> expected)")
	return new(a.x-b.x, a.y-b.y)
end

function vector2.__mul(a,b)
	if type(a) == "number" then
		return new(a*b.x, a*b.y)
	elseif type(b) == "number" then
		return new(b*a.x, b*a.y)
	else
		assert(isvector2(a) and isvector2(b), "Mul: wrong argument types (<vector2> or <number> expected)")
		return a.x*b.x + a.y*b.y
	end
end

function vector2.__div(a,b)
	assert(isvector2(a) and type(b) == "number", "wrong argument types (expected <vector2> / <number>)")
	return new(a.x / b, a.y / b)
end

function vector2.__eq(a,b)
	-- return a.x == b.x and a.y == b.y
	local diff_x = (a.x > b.x) and (a.x - b.x) or (b.x - a.x)
	local diff_y = (a.y > b.y) and (a.y - b.y) or (b.y - a.y)
	return diff_y < EPSINON and diff_x < EPSINON
end

function vector2.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function vector2.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function vector2.permul(a,b)
	assert(isvector2(a) and isvector2(b), "permul: wrong argument types (<vector2> expected)")
	return new(a.x*b.x, a.y*b.y)
end

function vector2:quad_length()
	return self.x * self.x + self.y * self.y
end

function vector2:len()
	return sqrt(self.x * self.x + self.y * self.y)
end

function vector2.dist(a, b)
	assert(isvector2(a) and isvector2(b), "dist: wrong argument types (<vector2> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	return sqrt(dx * dx + dy * dy)
end

function vector2.dist2(a, b)
	assert(isvector2(a) and isvector2(b), "dist: wrong argument types (<vector2> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	return (dx * dx + dy * dy)
end

--本对象单位向量化
function vector2:normalizeInplace()
	local l = self:len()
	if l > 0 then
		self.x, self.y = self.x / l, self.y / l
	end
	return self
end

--产生新单位向量
function vector2:normalized()
	return self:clone():normalizeInplace()
end

--修改本实例
function vector2:rotateInplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

--产生新对象
function vector2:rotated(phi)
	local a_s, a_c = sin(phi), cos(phi)

    local mat11, mat12 = a_c, -a_s
    local mat21, mat22 = a_s,  a_c

    return new(mat11*self.x + mat12*self.y, mat21*self.x + mat22*self.y)
end

--垂直
function vector2:perpendicular()
	return new(-self.y, self.x)
end

--正交
function vector2:orthogonal()
    return new(self.y, -self.x)
end

function vector2:projectOn(v)
	assert(isvector2(v), "invalid argument: cannot project vector2 on " .. type(v))
	-- (self * v) * v / v:quad_length()
	local s = (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return new(s * v.x, s * v.y)
end

function vector2:mirrorOn(v)
	assert(isvector2(v), "invalid argument: cannot mirror vector2 on " .. type(v))
	-- 2 * self:projectOn(v) - self
	local s = 2 * (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	return new(s * v.x - self.x, s * v.y - self.y)
end

function vector2:cross(v)
	assert(isvector2(v), "cross: wrong argument types (<vector2> expected)")
	return self.x * v.y - self.y * v.x
end

function vector2:dot( other )
    return (self.x * other.x) + (self.y * other.y)
end

function vector2:trimInplace(maxLen)
	local s = maxLen * maxLen / self:quad_length()
	s = (s > 1 and 1) or math.sqrt(s)
	self.x, self.y = self.x * s, self.y * s
	return self
end

function vector2:angleTo(other)
	if other then
		return atan2(self.y, self.x) - atan2(other.y, other.x)
	end
	return atan2(self.y, self.x)
end

function vector2:trimmed(maxLen)
	return self:clone():trimInplace(maxLen)
end


-- the module
return setmetatable(
	{
		new = new, 
		isvector2 = isvector2, 
		zero = zero, right = right, left = left, up = up, down = down, 
		fromPolar = fromPolar,
		lerp = lerp
	},
	{__call = function(_, ...) return new(...) end}
)
