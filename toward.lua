
local vector2 = require 'util.vector2'
--从整数32朝向
local kTowardCount = 32


--如果太小就归0吧
local function IsFloatZero( v )
	local EPSILON = 0.001
	if v >= - EPSILON and v <= EPSILON then
		return 0
	else
		return v
	end
end

--从朝向转化为向量
local function GetVector2FromToward( toward, towardCount )
	--默认32方向
	local radian = 2 * math.pi * toward / (towardCount or kTowardCount)
	local x,y = math.cos(radian), math.sin(radian)
	local v = vector2.new(x, y)	
	v.x, v.y = IsFloatZero(v.x), IsFloatZero(v.y)
	v:normalizeInplace()
	return v
end

--根据向量获得
local function GetTowardFromVector2( ori, towardCount )
	towardCount = towardCount or kTowardCount

	local o = math.atan2(ori.y, ori.x)
	if o < 0 then
		o = o + (math.pi * 2)
	end
	local num = o / (2 * math.pi / towardCount)
	--4舍5入
	local toward = math.floor(num + 0.5)
	--当他等于32的时候应该要转成0
	return toward == towardCount and 0 or toward
end

--根据浮点型小数点转化为带符号的字节127~-127
local function float2ubyte( f )
	--防止超过先这么处理
	f  = f > 1 and 1 or f
	f = f < -1 and -1 or f

	local byte = f * 127
	byte = math.floor(byte+0.5)
	return byte < 0 and (128 - byte) or byte
end

--将有符号字节转化成浮点数
--ubyte 0~255 -127~127 == -1.0 ~ 1.0
local function ubyte2float( b )
	--先将b转化成有符号再来除
	b = b>128 and -(b-128) or b
	local f = b/127
	return (f > 1) and (f - 1) or f
end


return {
	kTowardCount = kTowardCount,
	IsFloatZero = IsFloatZero,
	GetVector2FromToward = GetVector2FromToward,
	GetTowardFromVector2 = GetTowardFromVector2,
	float2byte = float2ubyte,
	byte2float = ubyte2float
}
