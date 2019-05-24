scor = 0
best = 0
ingame = false
inmenu = true


function loadHighscore() --- da load la stats
	local file = io.open("|D|data.txt", "r")
	if file then
		best = tonumber(file:read())
		io.close(file)
	else
		best = 0
	end
end

loadHighscore()
 
function saveHighscore()
	local file = io.open("|D|data.txt", "w+")
	if file then
		file:write(best)
	end
	io.close(file)
end

--[[
local font1 = TTFont.new("Fonts/karma1.ttf", 34)
local font2 = TTFont.new("Fonts/karma2.ttf", 34)

text_score1 = TextField.new(font1, scor) 
text_score1:setTextColor(0x000000)

text_score2 = TextField.new(font2, scor) 
text_score2:setTextColor(0xffffff)

text_score1:setScale(1)
text_score2:setScale(.9,.9)
text_score2:setPosition(text_score1:getX()+2,text_score1:getY()+1)


text_score1:setPosition(application:getContentWidth()/2-text_score1:getWidth(),20)
text_score2:setPosition(text_score1:getX()+2,text_score1:getY()+1)
]]

