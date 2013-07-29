--[[
DValues

Adds extra display dimension values to the defaults.

By Caleb P of Gymbyl Coding
www.gymbyl.com
--]]

display.contentLeft=display.screenOriginX -- Left side of the screen
display.contentRight=display.contentWidth-display.contentLeft -- Right side of the screen
display.contentTop=display.screenOriginY -- Top of the screen
display.contentBottom=display.contentHeight-display.contentTop -- Bottom of the screen
display.contentSizeX=display.contentRight-display.contentLeft -- Actual width of the screen
display.contentSizeY=display.contentBottom-display.contentTop -- Actual height of the screen
display.contentXBleed=display.contentSizeX-display.contentWidth -- Width of the area not covered with display.contentWidth
display.contentYBleed=display.contentSizeY-display.contentHeight -- Height of the area not covered with display.contentHeight