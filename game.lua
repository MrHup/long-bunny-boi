game = gideros.class(Sprite)
require "box2d"

application:setOrientation(conf.orientation)
-------------------------------
local MX = application:getContentWidth()
local MY = application:getContentHeight()
function setSize(imagine,newWidth, newHeight)
  imagine:setScale(1, 1)
  local originalWidth = imagine:getWidth()
  local originalHeight = imagine:getHeight()
  imagine:setScale(newWidth / originalWidth, newHeight / originalHeight)
end
function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local carac
local pressed = false
local lungit = 0
local scalar = 1 -- daca nu merge treaba cu GTweenu
local stretch_debouncer = false
local inCadere = false
local hit = false
local power = 0
-------------------------------------------------------
---------------------EFFECTS---------------------------
-------------------------------------------------------

function game:shakeScreen()
	local screenW = application:getContentWidth()
	local screenH = application:getContentHeight()
	local offsetX = 0;
	local offsetY = 0;
	self:setPosition(offsetX-10,offsetY-10)
	GTween.new(self, 0.25, {x = offsetX,y = offsetY}, {delay = 0, ease = easing.outBounce })
end

-------------------------------------------------------
---------------------OBJECTS---------------------------
-------------------------------------------------------
local obstacole = Sprite.new()
local grounds = Sprite.new()
local onTop = Sprite.new()

function game:character(x,y)
	local cap = Bitmap.new(Texture.new("Art/head.png"))
	cap:setAnchorPoint(0.5,1)
	local corp = Bitmap.new(Texture.new("Art/body.png"))
	corp:setAnchorPoint(0.5,1)
	

	local picioare = MovieClip.new{
	{1, 5, Bitmap.new(Texture.new("Art/legs_0.png"))},	
	{5, 10, Bitmap.new(Texture.new("Art/legs_1.png"))}
}	picioare:setAnchorPoint(0.5,1)
	picioare:setGotoAction(10, 1)	

	local chr = Sprite.new()
	--chr:setAnchorPoint(0.5,0)
	chr:addChild(corp)
	chr:addChild(cap)
	chr:addChild(picioare)
	
	chr:setScale(.5)
	
	local lung_total = cap:getHeight() + corp:getHeight() + picioare:getHeight()
	
	picioare:setPosition(0,0)
	corp:setPosition(picioare:getX(),picioare:getY()-picioare:getHeight())
	cap:setPosition(picioare:getX(), corp:getY()-corp:getHeight()+3)
	local addUp = lung_total/2
	picioare:setPosition(picioare:getX(),picioare:getY()+addUp)
	corp:setPosition(corp:getX(),corp:getY()+addUp)
	cap:setPosition(cap:getX(),cap:getY()+addUp)
	
	local body = self.world:createBody{type = b2.DYNAMIC_BODY}
	body:setPosition(chr:getX(), chr:getY())
	body:setSleepingAllowed(false)
	--body:setAngle(chr:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(chr:getWidth()/2-5, chr:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0}
	
	body:setAngularVelocity(0)
	body:setFixedRotation(true)
	body:setSleepingAllowed(false)
	
	chr.body = body
	chr.body.type = "character"	
	chr.legs = picioare
	chr.head = cap
	chr.mainBody = corp
	chr:setPosition(x,y)
	
	self:addChild(chr)
	return chr
end

function game:wall(x, y, width, height)
	local wall = Shape.new()
	wall:beginPath()
	wall:moveTo(-width/2,-height/2)
	wall:lineTo(width/2, -height/2)
	wall:lineTo(width/2, height/2)
	wall:lineTo(-width/2, height/2)
	wall:closePath()
	wall:endPath()
	wall:setPosition(x,y)
	
	--create box2d physical object
	local body = self.world:createBody{type = b2.STATIC_BODY}
	body:setPosition(wall:getX(), wall:getY())
	body:setAngle(wall:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(wall:getWidth()/2, wall:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0.25}
	wall.body = body
	wall.body.type = "wall"
	
	self:addChild(wall)
	return wall
end

function game:solid(x, y, img) -- aka obstacle
	local solid = Bitmap.new(Texture.new(img))
	solid:setAnchorPoint(0.5,0.5)
	solid:setScale(.5)
	solid:setPosition(x,y)
	local body = self.world:createBody{type = b2.STATIC_BODY}
	body:setPosition(solid:getX(), solid:getY())
	body:setAngle(solid:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(solid:getWidth()/2-8, solid:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0}
	solid.body = body
	solid.body.type = "solid"	
	obstacole:addChild(solid)
	local function autodestroy()
		self.world:destroyBody(solid.body)
		obstacole:removeChild(solid)
		solid = nil
		print("STERS")
	end
	Timer.delayedCall(conf.cleanupTime, function() autodestroy() end)
	return solid
end

function game:solid_sided(x, y, img) -- aka obstacle
	local twoSided = Bitmap.new(Texture.new(img))
	twoSided:setAnchorPoint(0.5,0.5)
	twoSided:setScale(1.2)
	twoSided:setPosition(x,y)
	local body = self.world:createBody{type = b2.STATIC_BODY}
	body:setPosition(twoSided:getX(), twoSided:getY())
	body:setAngle(twoSided:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(twoSided:getWidth()/2, twoSided:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0}
	twoSided.body = body
	twoSided.body.type = "punctabil"	
	obstacole:addChild(twoSided)
	
	local twoSided2 = Bitmap.new(Texture.new(img))
	twoSided2:setAnchorPoint(0.5,0.5)
	twoSided2:setRotationX(180)
	twoSided2:setScale(1.2)
	twoSided2:setPosition(twoSided:getX(), twoSided:getY()-twoSided:getHeight()-conf.spatiu)
	local body2 = self.world:createBody{type = b2.STATIC_BODY}
	body2:setPosition(twoSided2:getX(), twoSided2:getY())
	body2:setAngle(twoSided2:getRotation() * math.pi/180)
	local poly2 = b2.PolygonShape.new()
	poly2:setAsBox(twoSided2:getWidth()/2, twoSided2:getHeight()/2)
	local fixture = body2:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0}
	twoSided2.body = body2
	twoSided2.body.type = "twoSided2"	
	obstacole:addChild(twoSided2)
	
	local repozitionare = math.random(conf.minRand, conf.maxRand)
	twoSided:setPosition(twoSided:getX(),twoSided:getY()-repozitionare)
	twoSided2:setPosition(twoSided2:getX(),twoSided2:getY()-repozitionare)
	return twoSided
end


function game:ground(x,y)
	local pamant = Bitmap.new(Texture.new("Art/basic_tile2.png"))
	pamant:setAnchorPoint(0.5,0.5)
	pamant:setScale(.5)
	pamant:setPosition(x,y)
	local body = self.world:createBody{type = b2.STATIC_BODY}
	body:setPosition(pamant:getX(),pamant:getY())
	local poly = b2.PolygonShape.new()
	poly:setAsBox(pamant:getWidth()/2, pamant:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, friction= 0.1, restitution = 0}
	pamant.body = body
	pamant.body.type = "tile"
	grounds:addChild(pamant)
	return pamant
end

-------------------------------------------------------------
----------------------TEXT AND STUFF-------------------------
-------------------------------------------------------------
--[[local text_score1 = TextWrap.new("0", 150, "center") -- descrierea costumului selectat
text_score1:setFont(font1)
text_score1:setTextColor(0x000000)
text_score1:setScale(.5)

local text_score2 = TextWrap.new("0", 150, "center") -- descrierea costumului selectat
text_score2:setFont(font2)
text_score2:setTextColor(0xffffff)
text_score2:setScale(.5,.47)
text_score:addChild(text_score2)
text_score:addChild(text_score1)]]



-- under ground

local dark = Bitmap.new(Texture.new("Art/dark.png"))
setSize(dark,application:getContentWidth()*2,180)
dark:setPosition(-25,application:getContentHeight()-40)
onTop:addChild(dark)

local buff = Sound.new("Sounds/buff.wav")
local pop = Sound.new("Sounds/pop.mp3")
local snap = Sound.new("Sounds/snap.mp3")
local swish = Sound.new("Sounds/swish.mp3")
-------------------------------------------------------------
---------------------------INIT------------------------------
-------------------------------------------------------------

function game:worldCleanup()
	--if carac.body then self.world:destroyBody(carac.body) end
	carac:setPosition(conf.bunnyStart,conf.bunnyY)
	hit = false
	scor = 0
	
	setSize(carac.mainBody,carac.mainBody:getWidth(),carac.mainBody:getHeight()-lungit)
	lungit = 0
	
	carac.legs:setPosition(0,0)
	carac.mainBody:setPosition(carac.legs:getX(),carac.legs:getY()-carac.legs:getHeight())
	carac.head:setPosition(carac.legs:getX(), carac.mainBody:getY()-carac.mainBody:getHeight()+3)
	local lung_total = carac.head:getHeight() + carac.mainBody:getHeight() + carac.legs:getHeight()
	local addUp = lung_total/2
	carac.legs:setPosition(carac.legs:getX(),carac.legs:getY()+addUp)
	carac.mainBody:setPosition(carac.mainBody:getX(),carac.mainBody:getY()+addUp)
	carac.head:setPosition(carac.head:getX(),carac.head:getY()+addUp)
	
	carac:setPosition(carac:getX(),carac:getY()-conf.unitate+2)  --- -unit+2 ii in plus
	local V_x,V_y
	V_x,V_y = carac.body:getLinearVelocity()
	self.world:destroyBody(carac.body)
	local body = self.world:createBody{type = b2.DYNAMIC_BODY}
	body:setPosition(carac:getX(), carac:getY())
	body:setSleepingAllowed(false)
	--body:setAngle(chr:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(carac:getWidth()/2-5, carac:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0}
	
	body:setAngularVelocity(0)
	body:setFixedRotation(true)
	body:setSleepingAllowed(false)
	
	carac.body = body
	carac.body.type = "character"
	
	
	for i = 1, obstacole:getNumChildren() do
		local sprite = obstacole:getChildAt(i)
		sprite:setPosition(-1200,0)
	end
	
	Timer.delayedCall(1000, function() 
		scor = 0
		ingame = true
		self:generate_obs()
	end)
end

function game:scoreboard()
	local font = TTFont.new("Fonts/kongtext.ttf", 34)
	local board = TextField.new(font, scor) 
	board:setTextColor(0xffffff)
	board:setPosition(application:getContentWidth()/2-board:getWidth()/2,20)
	
	self:addChild(board)
	self.world.board = board
end

function game:init()
	application:setBackgroundColor(0x9C9BA3)
	self.world = nil
	self.world = b2.World.new(0, 10, true)
	self.world:setGravity(0, conf.gravity)
	
	local debugDraw = b2.DebugDraw.new()
	self.world:setDebugDraw(debugDraw)
	if conf.debug == true then 
		self:addChild(debugDraw)    ------------------------- DEBUG !!!!!!
	end
	self.worldW = application:getContentWidth()*2
	self.worldH = application:getContentHeight()*2
	
	--self:wall(50,application:getContentHeight()-60,application:getContentWidth()*256,20)
	--bg
	local bg = Bitmap.new(Texture.new("Art/BG.png"))
	setSize(bg,application:getContentWidth(),application:getContentHeight())
	bg:setAlpha(.88)
	self:addChild(bg)
	
	self:ground(100,application:getContentHeight()-57)
	self:ground(310,application:getContentHeight()-57)
	self:ground(520,application:getContentHeight()-57)
	self:ground(730,application:getContentHeight()-57)
	carac = self:character(conf.bunnyStart,conf.bunnyY)
	carac.legs:stop()
	
	
	self:addChild(obstacole)
	self:addChild(grounds)
	
	if conf.snowing == true then
		local ninge = snowfall.new()
		stage:addChild(ninge)
	end
	
	
	csor = self:scoreboard()
	self:addChild(onTop)
	
	self:startPanel()
	
	--------------------
	
	
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
end

------------------------------------------------------------
---------------------ENTER FRAME----------------------------
------------------------------------------------------------
local start_panel = Sprite.new()
local popup = Sprite.new()
local tweenul

function game:onMouseDown()
	print("DOWN")
	if inmenu == true then
		inmenu = false
		ingame = true
		local bog = pop:play()
		bog:setVolume(3)
		tweenul:setPaused(true)
		Timer.delayedCall(1000, function() self:generate_obs() end)
		carac.legs:play()
		GTween.new(start_panel, 0.25, {y = -750}, {delay = 0, ease = easing.outSine })
		self.world.board:setPosition(application:getContentWidth()/2-self.world.board:getWidth()/2,20)
	end
	pressed = true
end

function game:onMouseUp()
	print("UP")
	if power == 0 then
		power = lungit
		print("clark")
	end
	if ingame == true and lungit >200 then
		local sw = swish:play()
		sw:setVolume(.16)
	end
	pressed = false
end

local timerr
function game:generate_obs()
	--self:solid(application:getContentWidth()+250,application:getContentHeight()-100,"Art/tree.png")
	
	if ingame == true then
		self:solid_sided(application:getContentWidth()+250,application:getContentHeight()-100,"Art/column.png")
		timerr = Timer.delayedCall(2300, function()
			self:generate_obs() 
		end)
	end
end

--[[
function game:generate_ground()
	self:ground(0,application:getContentHeight()-34)
	if ingame == true then
		Timer.delayedCall(2300, function() self:generate_ground() end)
	end
end]]

----------------------------------------PANEL------------------------------------------------

function game:startPanel()
	local titlu = Bitmap.new(Texture.new("Art/title.png"))
	titlu:setScale(1.5)
	start_panel:addChild(titlu)
	
	self.world.board:setPosition(self.world.board:getX(),-600)
	local font = TTFont.new("Fonts/kongtext.ttf", 8)
	info_text = TextField.new(font, "Tap and hold to start") 
	info_text:setTextColor(0xffffff)
	start_panel:addChild(info_text)
	info_text:setAnchorPoint(.5)
	info_text:setPosition(start_panel:getWidth()/2-info_text:getWidth()/4,start_panel:getHeight())
	
	
	start_panel:setPosition(application:getContentWidth()/2-start_panel:getWidth()/2,application:getContentHeight()/2-start_panel:getHeight()/2)
	stage:addChild(start_panel)
	
	tweenul = GTween.new(info_text, 0.35, {scaleX = 1.2,scaleY=1.2}, {delay = 0, ease = easing.outSine,reflect = true, repeatCount = 1020 })
end


function game:panel()
	self.world.board:setPosition(self.world.board:getX(),-600)
	local panou = Bitmap.new(Texture.new("Art/panel.png"))
	panou:setScale(1,1.25)
	popup:addChild(panou)
	popup:setPosition(application:getContentWidth()/2-popup:getWidth()/2, -700)
	stage:addChild(popup)
	
	--Timer.stopAll()
	timerr:stop()
	GTween.new(popup, 0.25, {x = application:getContentWidth()/2-popup:getWidth()/2,y = application:getContentHeight()/2-popup:getHeight()/2}, {delay = 0, ease = easing.inSine })
	
	local gover = Bitmap.new(Texture.new("Art/gover.png"))
	gover:setScale(1.25)
	popup:addChild(gover)
	gover:setPosition(popup:getWidth()/2-gover:getWidth()/2,-gover:getHeight()-5)
	
	local but = Button.new(Bitmap.new(Texture.new("Art/play_0.png", conf.textureFilter)), Bitmap.new(Texture.new("Art/play_1.png", conf.textureFilter)))
	but:setScale(1,1)
	but:setPosition(popup:getWidth()/2-but:getWidth()/2+1,popup:getHeight()- but:getHeight()-gover:getHeight() - 17)
	popup:addChild(but)
	
	local font = TTFont.new("Fonts/kongtext.ttf", 22)
	
	local text_cur_scor = Bitmap.new(Texture.new("Art/score.png"))
	text_cur_scor:setScale(0.75)
	text_cur_scor:setPosition(20,20)
	popup:addChild(text_cur_scor)
	
	local text_best_scor = Bitmap.new(Texture.new("Art/best.png"))
	text_best_scor:setScale(0.75)
	text_best_scor:setPosition(20,45)
	popup:addChild(text_best_scor)
	
	local cur_scor = TextField.new(font,scor)
	cur_scor:setTextColor(0xffffff)
	cur_scor:setPosition(text_cur_scor:getX()+text_cur_scor:getWidth()+10,text_cur_scor:getY()+2)
	local cur_scor2 = TextField.new(font, best)
	cur_scor2:setTextColor(0xffffff)
	cur_scor2:setPosition(text_best_scor:getX()+text_best_scor:getWidth()+10,text_best_scor:getY()+2)
	popup:addChild(cur_scor)
	popup:addChild(cur_scor2)
	
	function play(target,event)
		if target:hitTestPoint(event.x, event.y) then
			self:worldCleanup()
			self.world.board:setPosition(application:getContentWidth()/2-self.world.board:getWidth()/2,20)
			self.world.board:setText(scor)
			self.world.board:setPosition(application:getContentWidth()/2-self.world.board:getWidth()/2,20)
			carac.legs:play()
			local bog = pop:play()
			bog:setVolume(3)
			GTween.new(popup, 0.25, {x = application:getContentWidth()/2-popup:getWidth()/2,y = -700}, {delay = 0, ease = easing.outSine })
		end
	end
	but:addEventListener(Event.MOUSE_DOWN, play, but)
end
--popup:setScale(1.2)

----------------------------------------------------------------------------------------------

function game:onEnterFrame()
	self.world:step(1/60, 8, 3)
	
	for i = 1, self:getNumChildren() do
				local sprite = self:getChildAt(i)
				if sprite.body then
					local body = sprite.body
					local bodyX, bodyY = body:getPosition()
					sprite:setPosition(bodyX, bodyY)
					sprite:setRotation(body:getAngle() * 180 / math.pi)
				end
	end	
	if ingame == true then
		
		for i = 1, obstacole:getNumChildren() do
			local sprite = obstacole:getChildAt(i)
			if sprite.body then
				local body = sprite.body
				local bodyX,bodyY = body:getPosition()
				sprite:setPosition(bodyX-conf.viteza,bodyY)
				if bodyX < carac:getX() and body.type == "punctabil" and ingame == true then	
					scor = scor+1
					if scor > best then 
						best=scor 
						saveHighscore()
					end
					
					self.world.board:setText(scor)
					self.world.board:setPosition(application:getContentWidth()/2-self.world.board:getWidth()/2,20)
					
					body.type = "notAnymore"
				end
				
				if bodyX < -25 then
					self.world:destroyBody(body)
					obstacole:removeChild(sprite)
					sprite = nil
					break
				end
			end
		end
		
		--[[grounds:setPosition(grounds:getX()-conf.viteza,grounds:getY())
			if grounds:getX() <=-210 then
			grounds:setPosition(0,grounds:getY())
		end]]
		for i=1, grounds:getNumChildren() do
			local sprite = grounds:getChildAt(i)
			if sprite.body then
				local body = sprite.body
				local bodyX,bodyY = body:getPosition()
				sprite:setPosition(bodyX-conf.viteza,bodyY)
				if bodyX < -110 then
					sprite:setPosition(720,bodyY)
				end
			end
		end
	end
	local unit = conf.unitate
	if pressed == true and ingame == true then
		----------stretch up----------
		if lungit < 700 and stretch_debouncer == false then
			carac:setPosition(carac:getX(),carac:getY()-2)
			setSize(carac.mainBody,carac.mainBody:getWidth(),carac.mainBody:getHeight()+unit)
			lungit = lungit + unit
			
			carac.legs:setPosition(0,0)
			carac.mainBody:setPosition(carac.legs:getX(),carac.legs:getY()-carac.legs:getHeight())
			carac.head:setPosition(carac.legs:getX(), carac.mainBody:getY()-carac.mainBody:getHeight()+3)
			local lung_total = carac.head:getHeight() + carac.mainBody:getHeight() + carac.legs:getHeight()
			local addUp = lung_total/2
			carac.legs:setPosition(carac.legs:getX(),carac.legs:getY()+addUp)
			carac.mainBody:setPosition(carac.mainBody:getX(),carac.mainBody:getY()+addUp)
			carac.head:setPosition(carac.head:getX(),carac.head:getY()+addUp)
			
			local V_x,V_y
			V_x,V_y = carac.body:getLinearVelocity()
			self.world:destroyBody(carac.body)
			local body = self.world:createBody{type = b2.DYNAMIC_BODY}
			body:setPosition(carac:getX(), carac:getY())
			body:setSleepingAllowed(false)
			body:setLinearVelocity(V_x,V_y)
			--body:setAngle(chr:getRotation() * math.pi/180)
			local poly = b2.PolygonShape.new()
			poly:setAsBox(carac:getWidth()/2-5, carac:getHeight()/2)
			local fixture = body:createFixture{shape = poly, density = 1.0, 
			friction = 0.1, restitution = 0}
			
			body:setAngularVelocity(0)
			body:setFixedRotation(true)
			body:setSleepingAllowed(false)
			
			carac.body = body
			carac.body.type = "character"
		end
	elseif ingame == true then 
		if lungit > 0 then
			--------stretch down-----------
			stretch_debouncer = true
			local mult -- multiplier
			if lungit > 500 then
				setSize(carac.mainBody,carac.mainBody:getWidth(),carac.mainBody:getHeight()-unit*12)
				mult = 12
			elseif lungit > 300 then
				setSize(carac.mainBody,carac.mainBody:getWidth(),carac.mainBody:getHeight()-unit*9)
				mult = 9
			elseif lungit > 150 then
				setSize(carac.mainBody,carac.mainBody:getWidth(),carac.mainBody:getHeight()-unit*6)
				mult = 6
			else
				setSize(carac.mainBody,carac.mainBody:getWidth(),carac.mainBody:getHeight()-unit*3)
				mult = 3
			end
			lungit = lungit - unit*mult
			
			carac.legs:setPosition(0,0)
			carac.mainBody:setPosition(carac.legs:getX(),carac.legs:getY()-carac.legs:getHeight())
			carac.head:setPosition(carac.legs:getX(), carac.mainBody:getY()-carac.mainBody:getHeight()+3)
			local lung_total = carac.head:getHeight() + carac.mainBody:getHeight() + carac.legs:getHeight()
			local addUp = lung_total/2
			carac.legs:setPosition(carac.legs:getX(),carac.legs:getY()+addUp)
			carac.mainBody:setPosition(carac.mainBody:getX(),carac.mainBody:getY()+addUp)
			carac.head:setPosition(carac.head:getX(),carac.head:getY()+addUp)
			
			carac:setPosition(carac:getX(),carac:getY()-unit+2)  --- -unit+2 ii in plus
			
			local V_x,V_y
			V_x,V_y = carac.body:getLinearVelocity()
			self.world:destroyBody(carac.body)
			local body = self.world:createBody{type = b2.DYNAMIC_BODY}
			body:setPosition(carac:getX(), carac:getY())
			body:setSleepingAllowed(false)
			
			--body:setAngle(chr:getRotation() * math.pi/180)
			local poly = b2.PolygonShape.new()
			poly:setAsBox(carac:getWidth()/2-5, carac:getHeight()/2)
			local fixture = body:createFixture{shape = poly, density = 1.0, 
			friction = 0.1, restitution = 0}
			
			body:setAngularVelocity(0)
			body:setFixedRotation(true)
			body:setSleepingAllowed(false)
			
			carac.body = body
			carac.body.type = "character"
		elseif lungit <= 0 then
			scalar = 1
		end
	end
	if carac:getY() <= conf.bunnyY+8 and carac:getY() >= conf.bunnyY-8 and stretch_debouncer == true then
		print("DEBOUNCED")
		--carac.legs:play()
		stretch_debouncer=false
	end
	
	if (carac:getX() <= conf.bunnyStart-conf.dieSpace or carac:getX() >= conf.bunnyStart+conf.dieSpace) and hit == false and conf.killingOn == true then
		hit = true
		print("BUFF")
		ingame = false
		buff:play()
		self:shakeScreen()
		carac.legs:stop()
		for i = 1, obstacole:getNumChildren() do
			local sprite = obstacole:getChildAt(i)
			if sprite.body then
				local body = sprite.body
				if body.type == "punctabil" then	
					body.type = "notAnymore"
				end
			end
		end
		
		Timer.delayedCall(250, function() self:panel() end)
		
	end
	
end