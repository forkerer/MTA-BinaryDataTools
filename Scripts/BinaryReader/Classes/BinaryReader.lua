-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

BinaryReader = {}
BinaryReader.metatable = {
    __index = BinaryReader,
}
setmetatable( BinaryReader, { __call = function(self,...) return self:New(...) end } )

function BinaryReader:New(fileHandle)
	local instance = setmetatable( {}, BinaryReader.metatable )

	instance.file = fileHandle
	instance.mode = "file"
	instance.curOffset = 1
	if type(fileHandle) == "string" then
		instance.mode = "string"
	end
	instance.converter = BinaryConverter()

	return instance
end

function BinaryReader:ReadInt64()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromInt64(fileRead( self.file, 8 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 7 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+7)
			self.curOffset = self.curOffset + 8
			return self.converter:FromInt64(subStr)
		end
	end
	return false
end

function BinaryReader:ReadInt32()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromInt32(fileRead( self.file, 4 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 3 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+3)
			self.curOffset = self.curOffset + 4
			return self.converter:FromInt32(subStr)
		end
	end
	return false
end

function BinaryReader:ReadInt16()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromInt16(fileRead( self.file, 2 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 1 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+1)
			self.curOffset = self.curOffset + 2
			return self.converter:FromInt16(subStr)
		end
	end
	return false
end

function BinaryReader:ReadInt8()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromInt8(fileRead( self.file, 1 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 0 then
			local subStr = self.file:sub(self.curOffset, self.curOffset)
			self.curOffset = self.curOffset + 1
			return self.converter:FromInt8(subStr)
		end
	end
	return false
end

function BinaryReader:ReadUInt64()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromUInt64(fileRead( self.file, 8 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 7 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+7)
			self.curOffset = self.curOffset + 8
			return self.converter:FromUInt64(subStr)
		end
	end
	return false
end

function BinaryReader:ReadUInt32()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromUInt32(fileRead( self.file, 4 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 3 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+3)
			self.curOffset = self.curOffset + 4
			return self.converter:FromUInt32(subStr)
		end
	end
	return false
end

function BinaryReader:ReadUInt16()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromUInt16(fileRead( self.file, 2 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 1 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+1)
			self.curOffset = self.curOffset + 2
			return self.converter:FromUInt16(subStr)
		end
	end
	return false
end

function BinaryReader:ReadUInt8()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromUInt8(fileRead( self.file, 1 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 0 then
			local subStr = self.file:sub(self.curOffset, self.curOffset)
			self.curOffset = self.curOffset + 1
			return self.converter:FromUInt8(subStr)
		end
	end
	return false
end

function BinaryReader:ReadHalf()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromHalf(fileRead( self.file, 2 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 1 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+1)
			self.curOffset = self.curOffset + 2
			return self.converter:FromHalf(subStr)
		end
	end
	return false
end

function BinaryReader:ReadFloat()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromFloat(fileRead( self.file, 4 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 3 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+3)
			self.curOffset = self.curOffset + 4
			return self.converter:FromFloat(subStr)
		end
	end
	return false
end

function BinaryReader:ReadDouble()
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			return self.converter:FromDouble(fileRead( self.file, 8 ))
		end
	elseif self.mode == "string" then
		if #self.file - self.curOffset >= 7 then
			local subStr = self.file:sub(self.curOffset, self.curOffset+7)
			self.curOffset = self.curOffset + 8
			return self.converter:FromDouble(subStr)
		end
	end
	return false
end

function BinaryReader:ReadString(length)
	if self.mode == "file" then
		if not fileIsEOF( self.file ) then
			if length then
				return self.converter:FromCharArray(fileRead( self.file, length ))
			else
				local str = ""
				local lastByte = nil
				while ((lastByte ~= '\0') and (not fileIsEOF( self.file ))) do
					lastByte = fileRead( self.file, 1 )
					str = str .. lastByte
				end
				return self.converter:FromCharArray(str)
			end
		end
	elseif self.mode == "string" then
		if length then
			local subStr = self.file:sub(self.curOffset, self.curOffset+length-1)
			self.curOffset = self.curOffset+length
			return self.converter:FromCharArray(subStr)
		else
			local str = ""
			local lastByte = nil
			while (lastByte ~= '\0' and (self.curOffset < #self.file)) do
				lastByte = self.file:sub(self.curOffset,self.curOffset)
				str = str .. lastByte
				self.curOffset = self.curOffset + 1
			end
			return self.converter:FromCharArray(str)
		end
	end
	return false
end