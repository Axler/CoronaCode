--[[
Spark v1.1.0

A stable, easy to use, and more accurate timer system to replace the built-in timer library.

The built-in timer library gets out of sync with repeating iterations. Spark fixes that by using a different algorithm - one that never gets out of sync.

Methods:
	spark.timer(time, func, iterations, onComplete) - timer.performWithDelay
	spark.stop(handle) - timer.cancel
	spark.pause(handle) - timer.pause
	spark.resume(handle) - timer.resume
	spark.init() - Overwrites the timer library with Spark for instant porting

By Caleb P, Gymbyl Coding
www.gymbyl.com
--]]

--------------------------------------------------------------------------------
-- Locals
--------------------------------------------------------------------------------
local getTimer			= system.getTimer
local round					= math.round
local pairs					= pairs
local tRemove				= table.remove
local tInsert				= table.insert
local tIndexOf			= table.indexOf
local timerStack		= {}


--------------------------------------------------------------------------------
-- Update the Timer Stack
--------------------------------------------------------------------------------
local function sparkUpdate()
	local time=getTimer() -- Get the time
	
	for i, v in pairs(timerStack) do
		if timerStack[i] and timerStack[i].running then -- Not paused
			if time>=(timerStack[i].time*timerStack[i].iterCount)+timerStack[i].timeOffset then
				timerStack[i].iterCount=timerStack[i].iterCount+1 -- Number of iterations
				if timerStack[i].iterations>1 then
					timerStack[i].iterations=timerStack[i].iterations-1
					timerStack[i].func()
				elseif timerStack[i].iterations==1 then
					timerStack[i].func()
					timerStack[i].onComplete()
					tRemove(timerStack, i)
				end
			end

		elseif timerStack[i] and not timerStack[i].running then
			timerStack[i].timeOffset=time -- Update for pause
		end

	end
end


--------------------------------------------------------------------------------
-- Actual Spark library
--------------------------------------------------------------------------------
local spark={}


--------------------------------------------------------------------------------
-- spark.timer
--------------------------------------------------------------------------------
function spark.timer(time, func, iterations, onComplete)
	local time=time or 500
	local func=func or function()end
	local iterations=iterations or 1
	local onComplete=onComplete or function()end

	iterations=round(iterations)

	if iterations<=0 then
		iterations=math.huge -- Accomodate for infinite iterations
	end

	local newTimer={
		time=time, -- Length between iterations
		iterCount=1, -- Number of iterations toggled
		iterations=iterations, -- Number of iterations to toggle
		func=func, -- Function to call on each iteration
		onComplete=onComplete, -- Function to call when all iterations are finished
		timeOffset=getTimer(), -- Time the timer was created
		running=true -- Paused or not
	}

	tInsert(timerStack, newTimer)

	local handle={
		_spark_timerStack_count=tIndexOf(timerStack, newTimer) -- Timer stack identifier
	}

	return handle
end


--------------------------------------------------------------------------------
-- spark.stop()
--------------------------------------------------------------------------------
function spark.stop(handle)
	if handle and type(handle)=="table" and handle._spark_timerStack_count then
		if timerStack[handle._spark_timerStack_count] then
			tRemove(timerStack, handle._spark_timerStack_count) -- Delete a timer
		else
			if spark.alert then
				print("Spark: Stop failed; handle invalid") -- Give warning message
			end
		end
	else -- Stop all timers
		for i=1, #timerStack do
			tRemove(timerStack, i)
		end
	end
	return true
end


--------------------------------------------------------------------------------
-- spark.pause()
--------------------------------------------------------------------------------
function spark.pause(handle)
	if handle and type(handle)=="table" and handle._spark_timerStack_count then -- Check for valid handle
		if timerStack[handle._spark_timerStack_count] then -- Check for existent timer
			timerStack[handle._spark_timerStack_count].running=false -- Pause
		else
			if spark.alert then
				print("Spark: Pause failed; handle invalid")
			end
		end
	else
		for i=1, #timerStack do -- Pause all
			timerStack[i].running=false
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- spark.resume()
--------------------------------------------------------------------------------
function spark.resume(handle)
	if handle and type(handle)=="table" and handle._spark_timerStack_count then
		if timerStack[handle._spark_timerStack_count] then
			timerStack[handle._spark_timerStack_count].running=true -- Resume
		else
			if spark.alert then
				print("Spark: Resume failed; handle invalid")
			end
		end
	else
		for i=1, #timerStack do
			timerStack[i].running=true -- Resume all
		end
	end
end

--------------------------------------------------------------------------------
-- spark.running()
--------------------------------------------------------------------------------
function spark.running(handle)
	if handle and type(handle)=="table" and handle._spark_timerStack_count then
		if timerStack[handle._spark_timerStack_count] then
			return timerStack[handle._spark_timerStack_count].running
		else
			return false
		end
	else
		return false
	end
end


--------------------------------------------------------------------------------
-- spark.init()
--------------------------------------------------------------------------------
function spark.init()
	timer.performWithDelay=spark.timer
	timer.cancel=spark.stop
	timer.pause=spark.pause
	timer.resume=spark.resume
end



Runtime:addEventListener("enterFrame", sparkUpdate) -- Add update listener

return spark