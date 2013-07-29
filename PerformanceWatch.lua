--[[
Project: PerformanceWatch
Author: Caleb P of Gymbyl Coding

PerformanceWatch is a widget library that creates a slick, customizable tracker of FPS and system memory.

www.gymbyl.com
--]]

local performanceWatch={}

function performanceWatch.new()
	local w=display.newGroup()

	w.options={}
		w.options.fps={}
			w.options.fps.string="%.02f"
			w.options.fps.countDelay=20
			w.options.fps.multipleOf30=false
			w.options.fps.ignoreMultipleUnder30=true
			w.options.fps.roundMode="nearest"
			w.options.fps.capAt60=true

		w.options.memory={}
			w.options.memory.string="%0.02f"
			w.options.memory.countDelay=20
			w.options.memory.useMB=true

	local memDelay=0

	local fpsDelay=0
	local oldTime=system.getTimer()
	local newTime
	local fps
	local fpsString
	local round

	if w.options.fps.roundMode=="down" then
		round=math.floor
	elseif w.options.fps.roundMode=="up" then
		round=math.ceil
	elseif w.options.fps.roundMode=="nearest" then
		round=math.round
	else
		round=function(n) return n end
	end

	------------------------------------------------------------------------------
	-- Build Widget Display Objects
	------------------------------------------------------------------------------
	w.bkg=display.newRoundedRect(0, 0, display.contentWidth*0.2, display.contentHeight*0.055, (display.contentWidth*0.25)*0.06)
		w.bkg.strokeWidth=3
		w.bkg:setStrokeColor(0, 0, 0)
		w.bkg:setReferencePoint(display.TopLeftReferencePoint)
		w.bkg.x, w.bkg.y=display.screenOriginX, display.screenOriginY
		w:insert(w.bkg)

	w.fpsText=display.newText("FPS: "..w.options.fps.string:format(display.fps), 0, 0, "Courier New Bold", w.bkg.width*0.075)
		w.fpsText:setTextColor(0, 0, 0)
		w.fpsText:setReferencePoint(display.TopLeftReferencePoint)
		w.fpsText.x, w.fpsText.y=w.bkg.x+w.bkg.contentWidth*0.1, w.bkg.y
		w:insert(w.fpsText)

	w.memoryText=display.newText("MEM: 0.00", 0, 0, "Courier New Bold", w.bkg.width*0.075)
		w.memoryText:setTextColor(0, 0, 0)
		w.memoryText:setReferencePoint(display.TopLeftReferencePoint)
		w.memoryText.x, w.memoryText.y=w.bkg.x+w.bkg.contentWidth*0.1, w.fpsText.y+w.fpsText.height*0.75
		w:insert(w.memoryText)

	------------------------------------------------------------------------------
	-- Update Function
	------------------------------------------------------------------------------
	function w.update()
		memDelay=(memDelay+1)%w.options.memory.countDelay
		fpsDelay=(fpsDelay+1)%w.options.fps.countDelay

		newTime=system.getTimer()

		----------------------------------------------------------------------------
		-- Update Memory Text
		----------------------------------------------------------------------------
		if memDelay==0 then
			collectgarbage("collect")
			local memoryUsed=collectgarbage("count")

			if w.options.memory.useMB then
				memoryUsed=memoryUsed*0.001
			end

			local memoryString=w.options.memory.string:format(memoryUsed)
		
			w.memoryText.text="MEM: "..memoryString

			if w.options.memory.useMB then
				w.memoryText.text=w.memoryText.text.." Mb"
			else
				w.memoryText.text=w.memoryText.text.." Kb"
			end

			w.memoryText:setReferencePoint(display.TopLeftReferencePoint)
			w.memoryText.x, w.memoryText.y=w.bkg.x+w.bkg.contentWidth*0.1, w.fpsText.y+w.fpsText.height*0.75
		end

		----------------------------------------------------------------------------
		-- Update FPS Text
		----------------------------------------------------------------------------
		if fpsDelay==0 then
			local diffTime=newTime-oldTime
			
			fps=(1000/diffTime)

			if w.options.fps.capAt60 and fps>60 then fps=60 end

			if w.options.fps.multipleOf30 then
				if w.options.fps.ignoreMultipleUnder30 then
					if fps>=30 then
						fps=round(fps/30)*30
					end
				else
					fps=round(fps/30)*30
				end
			end

			fpsString=w.options.fps.string:format(fps)

			w.fpsText.text="FPS: "..fpsString
			w.fpsText:setReferencePoint(display.TopLeftReferencePoint)
			w.fpsText.x, w.fpsText.y=w.bkg.x+w.bkg.contentWidth*0.1, w.bkg.y
		end

		oldTime=newTime
		w:toFront()
	end

	w:setReferencePoint(display.CenterReferencePoint)
	Runtime:addEventListener("enterFrame", w.update)

	return w
end

return performanceWatch