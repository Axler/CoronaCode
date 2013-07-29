--[[
Project: Singlefile Data Module
Author: Caleb P of Gymbyl Coding

Singlefile is a data saving class which saves all data in a single file to minimize your project's data size.

www.gymbyl.com
--]]

local singlefile={}
local state={}

local system		= system
local io				= io
local json			= require("json")

function singlefile.save()
	local path=system.pathForFile("singlefile.json", system.DocumentsDirectory)
	local file=io.open(path, "w")
	
	if file then
		local contents=json.encode(state)
		file:write(contents)
		io.close(file)
		return true
	else
		return false
	end
end

function singlefile.load()
	local path=system.pathForFile("singlefile.json", system.DocumentsDirectory)
	local file=io.open(path, "r")
	
	if file then
		local contents=file:read("*a")
		if contents=="" then
			contents="{}"
		end
		state=json.decode(contents)
		io.close(file)
	end
end


function singlefile.enter(data, dataName)
	state[dataName]=data
	return true
end

function singlefile.getValue(filename)
  return state[filename]
end


return singlefile