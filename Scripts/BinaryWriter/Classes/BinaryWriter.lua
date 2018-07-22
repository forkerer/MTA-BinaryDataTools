-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

BinaryWriter = {}
BinaryWriter.metatable = {
    __index = BinaryWriter,
}
setmetatable( BinaryWriter, { __call = function(self,...) return self:New(...) end } )

function BinaryWriter:New(fileHandle)
	local instance = setmetatable( {}, BinaryWriter.metatable )

	instance.file = fileHandle
	instance.mode = "file"
	instance.curOffset = 1
	if type(fileHandle) == "string" then
		instance.mode = "string"
	end
	instance.converter = BinaryConverter()

	return instance
end

function BinaryWriter:GetCurrentString()
	if self.mode == "file" then
		local curPos = fileGetPos(self.file)
		fileSetPos( self.file, 0 )
		local ret = fileRead( self.file, fileGetSize(self.file) )
		fileSetPos( self.file, curPos )
		return ret
	elseif self.mode == "string" then
		return self.file
	end
end

function BinaryWriter:WriteInt64( num )
	local res = self.converter:ToInt64(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteInt32( num )
	local res = self.converter:ToInt32(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteInt16( num )
	local res = self.converter:ToInt16(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteInt8( num )
	local res = self.converter:ToInt8(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteUInt64( num )
	local res = self.converter:ToUInt64(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteUInt32( num )
	local res = self.converter:ToUInt32(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteUInt16( num )
	local res = self.converter:ToUInt16(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteUInt8( num )
	local res = self.converter:ToUInt8(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteHalf( num )
	local res = self.converter:ToHalf(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteFloat( num )
	local res = self.converter:ToFloat(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteDouble( num )
	local res = self.converter:ToDouble(num)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end

function BinaryWriter:WriteString( str )
	local res = self.converter:ToCharArray(str)
	if not res then return false end

	if self.mode == "file" then
		fileWrite(self.file, res)
		return res
	elseif self.mode == "string" then
		self.file = self.file..res
		return res
	end
	return false
end