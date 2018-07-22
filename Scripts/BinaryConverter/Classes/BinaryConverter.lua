-- From*() functions based on https://github.com/tederis/mta-resources/blob/master/dffframe/bytedata.lua

-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

local floor = math.floor
local char = string.char
local byte = string.byte
local abs = math.abs
local modf = math.modf
local min = math.min
local max = math.max
local NaN = 0/0

local _log = math.log
local function log(val, base)
	if not base then
		return _log(val)
	end
	return _log( val ) / _log( 2 )
end

BinaryConverter = {}
BinaryConverter.metatable = {
    __index = BinaryConverter,
}
setmetatable( BinaryConverter, { __call = function(self,...) return self:Get(...) end } )

function BinaryConverter:Get()
    if not self.instance then
        self.instance = self:New()
    end
    return self.instance
end

function BinaryConverter:New()
	local instance = setmetatable( {}, BinaryConverter.metatable )

	instance.endianness = "littleendian"

	instance.doubleNaNbig 	  = char(0x7F)..char(0xF8).."\0\0\0\0\0\0"
	instance.doubleNaNlittle  = "\0\0\0\0\0\0"..char(0xF8)..char(0x7F)
	instance.doublePInfbig 	  = char(0x7F)..char(0xF0).."\0\0\0\0\0\0"
	instance.doublePInflittle = "\0\0\0\0\0\0"..char(0xF0)..char(0x7F)
	instance.doubleNInfbig 	  = char(0xFF)..char(0xF0).."\0\0\0\0\0\0"
	instance.doubleNInflittle = "\0\0\0\0\0\0"..char(0xF0)..char(0xFF)
	instance.doubleZero 	  = "\0\0\0\0\0\0\0\0"

	instance.floatNaNbig 	 = char(0xFF)..char(0xC0).."\0"..char(0x01)
	instance.floatNaNlittle  = char(0x01).."\0"..char(0xC0)..char(0xFF)
	instance.floatPInfbig 	 = char(0x7F)..char(0x80).."\0\0"
	instance.floatPInflittle = "\0\0"..char(0x80)..char(0x7F)
	instance.floatNInfbig 	 = char(0xFF)..char(0x80).."\0\0"
	instance.floatNInflittle = "\0\0"..char(0x80)..char(0xFF)
	instance.floatZero 		 = "\0\0\0\0"

	instance.halfNaNbig 	= char(0xFE).."\0"
	instance.halfNaNlittle 	= "\0"..char(0xFE)
	instance.halfPInfbig 	= char(0xFC).."\0"
	instance.halfPInflittle = "\0"..char(0xFC)
	instance.halfNInfbig 	= char(0x7C).."\0"
	instance.halfNInflittle = "\0"..char(0x7C)
	instance.halfZero 		= "\0\0"

	return instance
end

function BinaryConverter:SetEndianness(val)
	if not(val == "bigendian" or val == "littleendian") then return false end
	self.endianness = val
end

function BinaryConverter:ToBinaryString(num, bits)
	local tab = {}
  	if bits then
    	for i=1,bits do
	      	table.insert(tab, 1, num%2)
	      	num = floor(num/2)
    	end
  	else
    	while num > 0 do
	      	table.insert(tab, 1, num%2)
	      	num = floor(num/2)
    	end
  	end
  	return table.concat(tab)
end

-- Converts from string of length 8 to 64bit signed integer
function BinaryConverter:FromInt64(str)
	local b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
	if self.endianness == "bigendian" then
		local convertedNumber = b1*0x100000000000000+b2*0x1000000000000+b3*0x10000000000+b4*0x100000000+b5*0x1000000+b6*0x10000+b7*0x100+b8
		if convertedNumber > 0x7FFFFFFFFFFFFFFF then
			convertedNumber = convertedNumber-0x10000000000000000
		end
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local convertedNumber =  b8*0x100000000000000+b7*0x1000000000000+b6*0x10000000000+b5*0x100000000+b4*0x1000000+b3*0x10000+b2*0x100+b1
		if convertedNumber > 0x7FFFFFFFFFFFFFFF then
			convertedNumber = convertedNumber-0x10000000000000000
		end
		return convertedNumber
	end
	return false
end

-- Converts from string of length 4 to 32bit signed integer
function BinaryConverter:FromInt32(str)
	if self.endianness == "bigendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b1*0x1000000+b2*0x10000+b3*0x100+b4
		if convertedNumber > 0x7FFFFFFF then
			convertedNumber = convertedNumber-0x100000000
		end
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b4*0x1000000+b3*0x10000+b2*0x100+b1
		if convertedNumber > 0x7FFFFFFF then
			convertedNumber = convertedNumber-0x100000000
		end
		return convertedNumber
	end
	return false
end

-- Converts from string of length 2 to 16bit signed integer
function BinaryConverter:FromInt16(str)
	if self.endianness == "bigendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b1*0x100+b2
		if convertedNumber > 0x7FFF then
			convertedNumber = convertedNumber-0x10000
		end
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b2*0x100+b1
		if convertedNumber > 0x7FFF then
			convertedNumber = convertedNumber-0x10000
		end
		return convertedNumber
	end
	return false
end

-- Converts from string of length 1 to 8bit signed integer
function BinaryConverter:FromInt8(str)
	local b1 = str:byte(1)
	local convertedNumber = b1
	if convertedNumber > 0x7F then
		convertedNumber = convertedNumber-0x100
	end
	return convertedNumber
end


-- Converts from string of length 8 to 64bit unsigned integer
function BinaryConverter:FromUInt64(str)
	if self.endianness == "bigendian" then
		local b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
		local convertedNumber = b1*0x100000000000000+b2*0x1000000000000+b3*0x10000000000+b4*0x100000000+b5*0x1000000+b6*0x10000+b7*0x100+b8
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
		local convertedNumber =  b8*0x100000000000000+b7*0x1000000000000+b6*0x10000000000+b5*0x100000000+b4*0x1000000+b3*0x10000+b2*0x100+b1
		return convertedNumber
	end
	return false
end

-- Converts from string of length 4 to 32bit unsigned integer
function BinaryConverter:FromUInt32(str)
	if self.endianness == "bigendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b1*0x1000000+b2*0x10000+b3*0x100+b4
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2,b3,b4 = str:byte(1,4)
		local convertedNumber = b4*0x1000000+b3*0x10000+b2*0x100+b1
		return convertedNumber
	end
	return false
end

-- Converts from string of length 2 to 16bit unsigned integer
function BinaryConverter:FromUInt16(str)
	if self.endianness == "bigendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b1*0x100+b2
		return convertedNumber
	elseif self.endianness == "littleendian" then
		local b1,b2 = str:byte(1,2)
		local convertedNumber = b2*0x100+b1
		return convertedNumber
	end
	return false
end

-- Converts from string of length 1 to 16bit unsigned integer
function BinaryConverter:FromUInt8(str)
	local b1 = str:byte(1)
	local convertedNumber = b1
	return convertedNumber
end

-- Converts from string of length 2 to 16 bit floating point number
function BinaryConverter:FromHalf(str)
	if str == self.halfZero then
		return 0
	elseif str == self.halfNaNbig or str == self.halfNaNlittle then
		return NaN
	elseif str == self.halfPInfbig or str == self.halfPInflittle then
		return math.huge
	elseif setr == self.halfNInfbig or str == self.halfNInflittle then
		return -math.huge
	end

    local b1,b2
    if self.endianness == "bigendian" then
        b1,b2 = str:byte(1,2)
    elseif self.endianness == "littleendian" then
        b2,b1 = str:byte(1,2)
    end
   
    local sign = (b1 > 128 and -1) or 1
    local exp = floor((b1%128)/0x4)-15
    local mantissa = (b1%0x4)*0x100 + b2
    local convertedNumber = 2^exp*(mantissa/(0x400)+1)
    return sign * convertedNumber
end

-- Converts from string of length 4 to 32 bit floating point number
function BinaryConverter:FromFloat(str)
	if str == self.floatZero then
		return 0
	elseif str == self.floatNaNbig or str == self.floatNaNlittle then
		return NaN
	elseif str == self.floatPInfbig or str == self.floatPInflittle then
		return math.huge
	elseif setr == self.floatNInfbig or str == self.floatNInflittle then
		return -math.huge
	end

	local b1,b2,b3,b4
	if self.endianness == "bigendian" then
		b1,b2,b3,b4 = str:byte(1,4)
	elseif self.endianness == "littleendian" then
		b4,b3,b2,b1 = str:byte(1,4)
	end

	local sign = (b1 > 128 and -1) or 1
	local mantissa = b2%0x80*0x10000+b3*0x100+b4
	local exp = floor(((b1%128)*0x100+b2)/0x80)-127
	local convertedNumber = 2^exp*(mantissa/0x800000+1)
	return sign * convertedNumber
end

-- Converts from string of length 8 to 64 bit floating point number
function BinaryConverter:FromDouble(str)
	if str == self.doubleZero then
		return 0
	elseif str == self.doubleNaNbig or str == self.doubleNaNlittle then
		return NaN
	elseif str == self.doublePInfbig or str == self.doublePInflittle then
		return math.huge
	elseif setr == self.doubleNInfbig or str == self.doubleNInflittle then
		return -math.huge
	end

	local b1,b2,b3,b4,b5,b6,b7,b8
	if self.endianness == "bigendian" then
		b1,b2,b3,b4,b5,b6,b7,b8 = str:byte(1,8)
	elseif self.endianness == "littleendian" then
		b8,b7,b6,b5,b4,b3,b2,b1 = str:byte(1,8)
	end	

	local sign = (b1 > 128 and -1) or 1
	local mantissa = (b2%0x10)*0x1000000000000+b3*0x10000000000+b4*0x100000000+b5*0x1000000+b6*0x10000+b7*0x100+b8
	local exp = floor(((b1%128)*0x100+b2)/0x10)-1023
	local convertedNumber = 2^exp*(mantissa/(0x10000000000000)+1)
	return sign * convertedNumber
end

function BinaryConverter:FromCharArray(str)
	--iprint(str)
	local convertedString = str
	local endPoint = str:find('\0')
	if endPoint then 
		convertedString = convertedString:sub(1,endPoint-1) 
	end
	return convertedString
end

function BinaryConverter:ToCharArray(str)
	if type(str) ~= "string" then return false end
	local zeroInd = string.find(str, "\0")
	if zeroInd then
		return str:sub(1,zeroInd)
	end
	
	str = str..'\0'
	return str
end


function BinaryConverter:ToUInt64(number)
	number = floor(number)%0x10000000000000000
	local b1,b2,b3,b4,b5,b6,b7,b8
	b8 = number%256
	b7 = floor(number/(0x100))%256
	b6 = floor(number/(0x10000))%256
	b5 = floor(number/(0x1000000))%256
	b4 = floor(number/(0x100000000))%256
	b3 = floor(number/(0x10000000000))%256
	b2 = floor(number/(0x1000000000000))%256
	b1 = floor(number/(0x100000000000000))%256

	if self.endianness == "bigendian" then
		return char(b1)..char(b2)..char(b3)..char(b4)..char(b5)..char(b6)..char(b7)..char(b8)
	elseif self.endianness == 'littleendian' then
		return char(b8)..char(b7)..char(b6)..char(b5)..char(b4)..char(b3)..char(b2)..char(b1)
	end
	return false
end

function BinaryConverter:ToUInt32(number)
	number = floor(number)%0x100000000
	local b1,b2,b3,b4
	b4 = number%256
	b3 = floor(number/(0x100))%256
	b2 = floor(number/(0x10000))%256
	b1 = floor(number/(0x1000000))%256

	if self.endianness == "bigendian" then
		return char(b1)..char(b2)..char(b3)..char(b4)
	elseif self.endianness == 'littleendian' then
		return char(b4)..char(b3)..char(b2)..char(b1)
	end
	return false
end

function BinaryConverter:ToUInt16(number)
	number = floor(number)%0x10000
	local b1,b2
	b2 = number%256
	b1 = floor(number/(0x100))%256

	if self.endianness == "bigendian" then
		return char(b1)..char(b2)
	elseif self.endianness == 'littleendian' then
		return char(b2)..char(b1)
	end
	return false
end

function BinaryConverter:ToUInt8(number)
	number = floor(number)%0x100
	local b1 = number%256

	if self.endianness == "bigendian" then
		return char(b1)
	elseif self.endianness == 'littleendian' then
		return char(b1)
	end
	return false
end

function BinaryConverter:ToInt64(number)
	if number < 0 then number = number + 0x10000000000000000 end
	return self:ToUInt64(number)
end

function BinaryConverter:ToInt32(number)
	if number < 0 then number = number + 0x100000000 end
	return self:ToUInt32(number)
end

function BinaryConverter:ToInt16(number)
	if number < 0 then number = number + 0x10000 end
	return self:ToUInt16(number)
end

function BinaryConverter:ToInt8(number)
	if number < 0 then number = number + 0x100 end
	return self:ToUInt8(number)
end

function BinaryConverter:GetFrac(frac, bits)
  	local ret = 0
  	for i=1,bits do
    	frac = frac * 2
    	if frac >= 1 then
	      	ret = ret + 2^(bits-i)
	      	frac = frac%1
          
	      	if frac == 0 then
	        	break
	      	end
    	end
  	end
  	return ret
end

function BinaryConverter:GetIntegralBinary(int)
	if int < 2 then
		if int == 0 then
			return 1,1
		else
			return 0,0
		end
	end

	local intCopy = int
	local first = floor(log(int,2))
	local last = 0
	while (intCopy%1 == 0) and (intCopy ~= 0) do
		last = last+1
		intCopy = floor(intCopy/2)
	end
	return first,last
end

function BinaryConverter:ToDouble(number)
	if type(number) ~= "number" then return false end
	-- Check for NaN
	if number ~= number then
		if self.endianness == "bigendian" then
			return self.doubleNaNbig
		elseif self.endianness == 'littleendian' then
			return self.doubleNaNlittle
		end
	-- +infinity
	elseif number == math.huge then
		if self.endianness == "bigendian" then
			return self.doublePInfbig
		elseif self.endianness == 'littleendian' then
			return self.doublePInflittle
		end
	-- -infinity
	elseif number == -math.huge then
		if self.endianness == "bigendian" then
			return self.doubleNInfbig
		elseif self.endianness == 'littleendian' then
			return self.doubleNInflittle
		end
	end

	local sign = 0
	if number < 0 then sign = 128 end

	number = abs(number)
	local main,frac = modf(number)
  	local mant = 0
	local exp = 0

	if number == 0 then
    	exp = 0
    	mant = 0
	elseif number < 1 then
		local fracFirst = floor(log(1/frac,2))
      	local fracPart = self:GetFrac(frac*(2^fracFirst), 52)
		exp = -fracFirst-1 + 1023
    	mant = (fracPart*2) % 0x10000000000000
	else
		local intFirst = self:GetIntegralBinary(main)
		local fracPart = self:GetFrac(frac, 52)
		exp = intFirst + 1023
    	mant = ((main * 2^(52-intFirst)) + floor(fracPart / 2^(intFirst))) % 0x10000000000000
	end

  	local b1,b2,b3,b4,b5,b6,b7,b8
  	b1 = char(mant%256)
  	b2 = char(floor(mant/(0x100))%256)
  	b3 = char(floor(mant/(0x10000))%256)
  	b4 = char(floor(mant/(0x1000000))%256)
  	b5 = char(floor(mant/(0x100000000))%256)
  	b6 = char(floor(mant/(0x10000000000))%256)
  	b7 = char((floor(mant/(0x1000000000000))%256 + floor(exp%128)*0x10)%256)
  	b8 = char(floor(exp/16)%128 + sign)
  
	if self.endianness == "bigendian" then
		return b8..b7..b6..b5..b4..b3..b2..b1
	elseif self.endianness == 'littleendian' then
		return b1..b2..b3..b4..b5..b6..b7..b8
	end
  	return false
end

function BinaryConverter:ToFloat(number)
	if type(number) ~= "number" then return false end
	-- Check for NaN
	if number ~= number then
		if self.endianness == "bigendian" then
			return self.floatNaNbig
		elseif self.endianness == 'littleendian' then
			return self.floatNaNlittle
		end
	-- +infinity
	elseif number > 3.402823466e38 then
		if self.endianness == "bigendian" then
			return self.floatPInfbig
		elseif self.endianness == 'littleendian' then
			return self.floatPInflittle
		end
	-- -infinity
	elseif number < -3.402823466e38 then
		if self.endianness == "bigendian" then
			return self.floatNInfbig
		elseif self.endianness == 'littleendian' then
			return self.floatNInflittle
		end
	end

	local sign = 0
	if number < 0 then sign = 128 end

	number = abs(number)
	local main,frac = modf(number)
  	local mant = 0
	local exp = 0

 	if number == 0 then
 		if self.endianness == "bigendian" then
			return char(sign).."\0\0\0"
		elseif self.endianness == 'littleendian' then
			return "\0\0\0"..char(sign)
		end
		return false
	elseif number < 1 then
      	local fracFirst = floor(log(1/frac,2))
      	local fracPart = self:GetFrac(frac*(2^fracFirst), 23)
	  	exp = (-fracFirst-1) + 127
    	mant = (fracPart*2) % 0x800000
	else
		local intFirst = self:GetIntegralBinary(main)
  		local fracPart = self:GetFrac(frac, 23)
		exp = intFirst + 127
    	mant = ((main * 2^(23-intFirst)) + floor(fracPart / 2^(intFirst))) % 0x800000
	end

  	local b1,b2,b3,b4
  	b1 = char(mant%256)
  	b2 = char(floor(mant/(0x100))%256)
  	b3 = char(floor(mant/(0x10000))%128 + floor(exp%2)*128)
  	b4 = char(floor(exp/2)%128 + sign)

	if self.endianness == "bigendian" then
		return b4..b3..b2..b1
	elseif self.endianness == 'littleendian' then
		return b1..b2..b3..b4
	end
  	return false
end

function BinaryConverter:ToHalf(number)
	if type(number) ~= "number" then return false end
	-- Check for NaN
	if number ~= number then
		if self.endianness == "bigendian" then
			return self.halfNaNbig
		elseif self.endianness == 'littleendian' then
			return self.halfNaNlittle
		end
	-- +infinity
	elseif number > 65504 then
		if self.endianness == "bigendian" then
			return self.halfPInfbig
		elseif self.endianness == 'littleendian' then
			return self.halfPInflittle
		end
	-- -infinity
	elseif number < -65504 then
		if self.endianness == "bigendian" then
			return self.halfNInfbig
		elseif self.endianness == 'littleendian' then
			return self.halfNInflittle
		end
	end

	local sign = 0
	if number < 0 then sign = 128 end

	number = abs(number)
	local main,frac = modf(number)
	local mant = 0
	local exp = 0

	if number == 0 then
    	exp = 0
    	mant = 0
	elseif number < 1 then
		local fracFirst = floor(log(1/frac,2))
      	local fracPart = self:GetFrac(frac*(2^fracFirst), 10)
		exp = -fracFirst-1 + 15
    	mant = (fracPart*2) % 0x400
	else
		local intFirst = self:GetIntegralBinary(main)
		local fracPart = self:GetFrac(frac, 10)
		exp = intFirst + 15
    	mant = ((main * 2^(10-intFirst)) + floor(fracPart / 2^(intFirst))) % 0x400
	end

  	local b1,b2,b3,b4
  	b1 = char(mant%256)
  	b2 = char(floor(mant/0x100)%8 + (exp*0x4)%128 + sign)

	if self.endianness == "bigendian" then
		return b2..b1
	elseif self.endianness == 'littleendian' then
		return b1..b2
	end
  	return false
end