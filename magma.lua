--[[
Project: Magma Cache System
Author: Caleb P of Gymbyl Coding

Magma makes it easy to keep private data secure by opening up unique-titled tables for storage.

www.gymbyl.com
--]]
local magma={}
local cache={}

local print						= print
local type						= type
local mrand						= math.random
local characters			= "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890~!@#$%^&*()_+=-{}[]:;\"\'.,></?|"
local numCharacters		= string.len(characters)
local function newTitle() local title="" for i=1, magma.encryptLevel do local r=mrand(numCharacters) title=title..characters:sub(r, r) end return title end


local function convertToString(v)
	if type(v)=="string" then return v
	elseif type(v)=="number" then return tonumber(v)
	elseif type(v)=="boolean" then return (v==true and "true") or "false"
	else return "["..type(v).."]" end
end


--[[
	Magma Values:
		Message 						= Print debug messages or not
		EncryptLevel 				= Number of characters per title. The higher the number, the less likely that a cache will get overwritten. Anything over 3 should be high enough.
		objCanAccessCache		= Give linked objects .magmaRetrieve() and .magmaStore() abilities to access their respective cache
--]]
magma.message 								= true
magma.encryptLevel						= 5
magma.objCanAdd								= false
magma.objCanRetrieve					= true

--Print startup message
if magma.message then
	print("Magma > Startup")
	print("\tEncryption Level: "..magma.encryptLevel)
	print("\tUnique Titles Available:")
	print("\t\t"..numCharacters^magma.encryptLevel)
	print("\n")
end


--[[
	Creates a new cache

	Argument: "t"
		Type: Table
		Value: Links "t" to associated cache and creates a ._cacheID value for it
		Other: If no "t" argument, will create and return a new table

	Return: "title"
		Type: String
		Value: ID code of new cache
		Other: ID can be used to access cache

	Return: "obj"
		Type: Table
		Value: Table linked to new cache
		Other: Obj only created if no argument "t"
--]]
function magma.new(t)
	local obj
	
	if not t then
		obj={}
	else
		obj=t
	end
	
	local title=newTitle()
	
	obj._cacheID=title
	
	cache[title]={
		_obj=obj,
		_title=title
	}

	if magma.objCanAdd then
		function obj.magmaStore(t, value)
			if magma.message then
				print("Magma > Store")
				print("\tStatus: Success")
				print("\tValue Title: "..t)
				print("\tPath: Obj")
				print("\n")
			end
			cache[obj._cacheID][t]=value
		end
	else
		function obj.magmaStore()
			if magma.message then
				print("Magma > obj.magmaStore() is not available.")
				print("\n")
			end
		end
	end

	if magma.objCanRetrieve then
		function obj.magmaRetrieve(val)
			if magma.message then
				print("Magma > Retrieve")
				print("\tStatus: Success")
				print("\tValue Title: "..val)
				print("\tCache Value: "..cache[obj._cacheID][val])
				print("\tPath: Obj")
				print("\n")
			end
			return cache[obj._cacheID][val]
		end
	else
		function obj.magmaRetrieve()
			if magma.message then
				print("Magma > obj.magmaRetrieve() is not available.")
				print("\n")
			end
		end
	end

	if magma.message then
		print("Magma > New Cache")
		print("\tStatus: Success")
		print("\tCache Code: "..obj._cacheID)
		print("\tObject Can Add: "..convertToString(magma.objCanAdd))
		print("\tObject Can Retrieve: "..convertToString(magma.objCanRetrieve))
		print("\n")
	end

	if not t then
		return title, obj
	else
		return title
	end
end


--[[
	Retrieves a value from a previously created cache

	Argument: "t"
		Type: String, Table
		Value: ID of cache
		Other: If "t" is a string, "t" must be a valid cache title; if "t" is a table, it must be a valid magma-linked table

	Return: "value"
		Type: Variable
		Value: Value of associated cache
		Other: Must already have been entered into cache
--]]
function magma.retrieve(t, val)
	local title
	local value
	if type(t)=="string" then
		title=t
	elseif type(t)=="table" then
		title=t._cacheID
	end

	if cache[title] then
		if val then
			if cache[title][val]~=nil then
				if magma.message then
					print("Magma > Retrieve")
					print("\tStatus: Success")
					print("\tCache Code: "..t)
					print("\tValue Title: "..val)
					print("\tPath: Lib")
					print("\n")
				end
				return cache[title][val]
			else
				if magma.message then
					print("Magma > Retrieve")
					print("\tStatus: Failure")
					print("\tCache Code: "..t)
					print("\tValue Nonexistent: "..val)
					print("\tPath: Lib")
					print("\n")
				end
			end
		else
			if magma.message then
				print("Magma > Retrieve")
				print("\tStatus: Success")
				print("\tCache Code: "..title)
				print("\tPath: Lib")
				print("\n")
			end
			return cache[title]
		end
	else
		if magma.message then
			print("Magma > Retrieve")
			print("\tStatus: Failure")
			print("\tCache Nonexistent: "..title)
			print("\n")
		end
	end
end


--[[
	Stores a value into a previously created cache

	Argument: "t"
		Type: String, Table
		Value: ID of cache
		Other: If "t" is a string, "t" must be a valid cache title; if "t" is a table, it must be a valid magma-linked table

	Argument: "valTitle"
		Type: String
		Value: Title/key of cache value
		Other: (nil)

	Argument: "val"
		Type: Variable
		Value: Value stored under "valTitle" key
		Other: (nil)
--]]
function magma.store(t, valTitle, val)
	if t and valTitle and val then
		
		local title
		local value
		if type(t)=="string" then
			title=t
		elseif type(t)=="table" then
			title=t._cacheID
		end

		if cache[title] then
			if magma.message then
				print("Magma > Store")
				print("\tStatus: Success")
				print("\tCache Code: "..title)
				print("\tValue Title: "..valTitle)
				print("\n")
			end
			cache[title][valTitle]=val
		else
			if magma.message then
				print("Magma > Store")
				print("\tStatus: Failure")
				print("\tCache Nonexistent: "..title)
				print("\n")
			end
		end
	else
		if magma.message then
			print("Magma > Store")
			print("\tStatus: Failure")
			print("\tMissing Argument")
			print("\n")
		end
	end
end


--[[
	Deletes a cache or value

	Argument: "t"
		Type: String, Table
		Value: ID of cache
		Other: If "t" is a string, "t" must be a valid cache title; if "t" is a table, it must be a valid magma-linked table

	Argument: "val"
		Type: String
		Value: Title of value to delete
		Other: If no "val" argument, entire cache will be deleted, and the .magmaStore() and .magmaRetrieve() functions will be removed from the linked object.
--]]
function magma.delete(t, val)
	local title
	if type(t)=="string" then
		title=t
	elseif type(t)=="table" then
		title=t._cacheID
	end

	if val then
		if cache[title][val]~=nil then
			if magma.message then
				print("Magma > Delete")
				print("\tCache Code: "..title)
				print("\tValue: "..val)
				print("\n")
			end
			cache[title][val]=nil
		end
	else
		cache[title]._obj.magmaStore=nil
		cache[title]._obj.magmaRetrieve=nil
		cache[title]=nil
		if magma.message then
			print("Magma > Delete")
			print("\tCache Code: "..titlte)
			print("\n")
		end
	end
end

function magma.printCacheInfo(t)
	local title
	
	if type(t)=="string" then
		title=t
	elseif type(t)=="table" then
		title=t._cacheID
	end

	if cache[title] then
		if magma.message then
			print("Magma > Print Cache Info")
			print("\tCache Title: "..title)
			print("\tCache Values:")

			for k,v in pairs(cache[title]) do
				if k:sub(1, 1)~="_" then
					print("\t\t\""..k.."\" : "..convertToString(v))
				end
			end
                  
			print("\n")
		end

	end
end



return magma