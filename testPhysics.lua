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
---------------------------------------------------------------------

---------------------OBJECTS---------------------------

function game:character(i,j,width,height)
	local char = Bitmap.new(Texture.new("Images/debug_char.png"))
	
	char:setAnchorPoint(0.5,0.5)
	setSize(char,width,height)
	char:setPosition(j*conf.dimens+conf.dimens/2,i*conf.dimens+conf.dimens/2)
	
	local body = self.world:createBody{type = b2.DYNAMIC_BODY}
	body:setPosition(char:getX(), char:getY())
	body:setAngle(char:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(char:getWidth()/2, char:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0}
	
	body:setAngularVelocity(0)
	body:setFixedRotation(true)
	body:setSleepingAllowed(false)
	
	char.body = body
	char.body.type = "character"	
	
	
	self:addChild(char)
	return char
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
	friction = 0.1, restitution = 0}
	wall.body = body
	wall.body.type = "wall"
	
	self:addChild(wall)
	return wall
end

function game:solid(x, y, img)
	local solid = Bitmap.new(Texture.new(img))
	
	solid:setAnchorPoint(0.5,0.5)
	setSize(solid,conf.dimens,conf.dimens)
	solid:setPosition(x,y)
	local body = self.world:createBody{type = b2.STATIC_BODY}
	body:setPosition(solid:getX(), solid:getY())
	body:setAngle(solid:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(solid:getWidth()/2, solid:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 1.0, 
	friction = 0.1, restitution = 0}
	solid.body = body
	solid.body.type = "solid"	
	self:addChild(solid)
	return solid
end

------------------------------------------------------------
---------------------DESENEAZA------------------------------
------------------------------------------------------------

function game:deseneaza()
	local dim = conf.dimens
	local surplus
	surplus=dim/2
	
	for i=1,conf.linii do
		for j=1,conf.coloane do
			if grid[i][j].tile==0 or grid[i][j].tile==4 then
				local img = Bitmap.new(Texture.new("Images/debug_grass.png"))
				setSize(img,dim,dim)
				img:setAnchorPoint(.5,.5)
				img:setPosition(j*dim+surplus,i*dim+surplus)
				self:addChild(img)
			elseif grid[i][j].tile==1 then
				self:solid(j*dim+surplus,i*dim+surplus,"Images/debug_wall.png")
			elseif grid[i][j].tile==2 then
				self:solid(j*dim+surplus,i*dim+surplus,"Images/debug_tower.png")
			elseif grid[i][j].tile==3 then
				--self:solid(j*dim+surplus,i*dim+surplus,"Images/debug_portal.png")
				--self:portal(i,j, 3000)
			end
		end
	end
end

------------------------------------------------------------
---------------------JOYSTICK-------------------------------
------------------------------------------------------------
local j1,j2
--move joystick
local move_powX = 0
local move_powY = 0
local function move_joystick(jX,jY)
	local umbra = Bitmap.new(Texture.new("Images/joystick1.png"))
	umbra:setAnchorPoint(.5,.5)
	umbra:setPosition(jX+31,jY+31) -- + 13 la 1.4
	umbra:setScale(conf.marimeBox,conf.marimeBox)
	umbra:setColorTransform(0,0,0,1)
	umbra:setAlpha(0)
	
	local joystick2 = Button.new(Bitmap.new(Texture.new("Images/joystick1.png")))
	joystick2:setAnchorPoint(.5,.5)
	joystick2:setPosition(jX,jY)
	joystick2:setScale(conf.marimeJoy,conf.marimeJoy)
	joystick2:setAlpha(0.5)
	
	j1 = joystick2
	
	local onJoy = false
	
	joystick2:addEventListener("clickDown", 
		function(e)	
			umbra:setAlpha(conf.transp_umbra)
			print("DOWN1")
			e:stopPropagation() --?
			onJoy = true
	end)
	
	joystick2:addEventListener("clickUP", 
		function(e)	
			print("UP1")
			umbra:setAlpha(0)
			e:stopPropagation() --?
			onJoy = false
			move_powX = 0
			move_powY = 0
			joystick2:setAlpha(0.5)
			GTween.new(joystick2,0.2,{x=jX,y=jY},{ease = easing.outSine})
			--EventDispatcher:removeEventListener(Event.ENTER_FRAME, joystick2, joystick2)
	end)	
	
	joystick2:addEventListener("clickMove",
		function(e)
		if onJoy == true then
			local tx = e.x
			local ty = e.y
			
			local l = conf.dimens
			local extindere = conf.extensie
			
			if math.sqrt((jX-tx)*(jX-tx)+(ty-jY)*(ty-jY))<=extindere then --formula de lungime a unui segment
				joystick2:setPosition(tx,ty)
			else
				local AB = math.sqrt((jX-tx)*(jX-tx)+(ty-jY)*(ty-jY))
				
				local raport = 100-extindere/AB*100
				local fx = tx*(100-raport)/100+jX*raport/100
				local fy = ty*(100-raport)/100+jY*raport/100
				joystick2:setPosition(fx,fy)
			end
			
			local fluctuent = 5
			if tx < jX - extindere/fluctuent then
				move_powX = -1
			elseif tx >= jX -extindere/fluctuent and tx < jX + extindere/fluctuent then
				move_powX = 0
			else
				move_powX = 1
			end
			
			if ty<jY - extindere/fluctuent then
				move_powY = 1
			elseif ty >= jY - extindere/fluctuent and ty < jY + extindere/fluctuent then
				move_powY = 0
			else
				move_powY = -1
			end
			
			joystick2:setAlpha(1) 
		end 
	end)
	
	stage:addChild(umbra)
	stage:addChild(joystick2)
end


--bullet joystick
local powX = 0
local powY = 0
local function joystick(jX,jY)
	local umbra = Bitmap.new(Texture.new("Images/joystick1.png"))
	umbra:setAnchorPoint(.5,.5)
	umbra:setPosition(jX+31,jY+31)
	umbra:setScale(conf.marimeBox,conf.marimeBox)
	umbra:setColorTransform(0,0,0,1)
	umbra:setAlpha(0)
	
	local joystick2 = Button.new(Bitmap.new(Texture.new("Images/joystick1.png")))
	joystick2:setAnchorPoint(.5,.5)
	joystick2:setPosition(jX,jY)
	joystick2:setScale(conf.marimeJoy,conf.marimeJoy)
	joystick2:setAlpha(0.5)
	
	local onJoy = false
	
	joystick2:addEventListener("clickDown", 
		function(e)	
			umbra:setAlpha(conf.transp_umbra)
			print("DOWN2")
			e:stopPropagation() --?
			onJoy = true
	end)
	
	joystick2:addEventListener("clickUP", 
		function(e)	
			print("UP2")
			umbra:setAlpha(0)
			e:stopPropagation() --?
			onJoy = false
			powX = 0
			powY = 0
			joystick2:setAlpha(0.5)
			GTween.new(joystick2,0.2,{x=jX,y=jY},{ease = easing.outSine})
		
	end)	
	
	
	stage:addChild(umbra)
	stage:addChild(joystick2)
end

---------------------------------------


-------------------------------------------------------------
----------------------STARTING GAME--------------------------
-------------------------------------------------------------

-- spawn in functie de inamici
-- spawn in functie de timpul

-- timp1,timp2, enPool1, timp, enPool2, timp, -1


local spawned_enemies=0
local timp_schimbare, inamici_schimbare
local prtl
local prtl_index

function game:check_for_empty()
	if helpers.enemy_count > 0 then
		Timer.delayedCall(600, function() self:check_for_empty() end)
	else
		local panou = notification.new(conf.greetings[math.random( #conf.greetings )])
		stage:addChild(panou)
		Timer.delayedCall(conf.intermission, function() self:start_game() end)
	end
end

function timed_spawn(i,delay)
	
	-- numara portale --
	local c=0
	for k,v in pairs(portal_group) do
		c=c+1
	end
	-------
	--print("Numar portale: " .. c .. " cu indexul " .. i)
	if i < c then
		prtl = portal_group:getChildAt(i+1)
		prtl_index = i+1
		Timer.delayedCall(delay, function() timed_spawn(i+1,delay) end)
	else
		i=1
		Timer.delayedCall(delay, function() timed_spawn(i,delay) end)
	end
end

local Si=0
local Sj=1
function game:rutina(pool,delay,m,n)
	--spawnare inamic la prtl, dupa care recall la delayed call cu delay-ul dat
	
	local i = prtl.i
	local j = prtl.j
	
	if i~= nil and j ~=nil then
		if grid[i-1][j].isObstacle == 0 then
			self:enemy(i-1,j,nil,10,50,0) -- pozitie, set de imagini, viteza, damage, special power
		elseif grid[i][j-1].isObstacle == 0 then
			self:enemy(i,j-1,nil,10,50,0)
		elseif grid[i][j+1].isObstacle == 0 then
			self:enemy(i,j+1,nil,10,50,0)
		elseif grid[i+1][j].isObstacle == 0 then
			self:enemy(i+1,j,nil,10,50,0)
		end
		if system[m][n+2] ~= -1 then
			Timer.delayedCall(delay, function() self:rutina(system[m][n+2],system[m][n+3],m,n+2) end)
		else
			Si = Si + 1
			self:check_for_empty()
		end
	end
end

function game:start_game()
	if Si < table.getn(system) then
		local panou = notification.new("Wave " .. Si+1)
		stage:addChild(panou)
		Sj=1
		if Sj <= table.getn(system[Si]) then
			if system[Si][1] > 0 and Sj == 1 then
				print("Mergem pe timp:" .. system[Si][1])
				timp_schimbare = system[Si][Sj]
				timed_spawn(0,timp_schimbare)
				Sj=Sj+2
				--chemare functie de selectare portal de spawn in functie de timp
			elseif system[Si][2] > 0 and Sj== 1 then
				inamici_schimbare = system[Si][2]
				Sj=Sj+2
				-- chemare functie de selectare portal de spawn in functie de inamici
			end
			if system[Si][Sj]~=-1 and Sj>2 then
				self:rutina(system[Si][Sj],system[Si][Sj+1],Si,Sj)
				
			end
		end
		 --- !!!!!!!!!! Aici ai ramas, e timpul sa faci intermisiunea si sa pleci de la urmatoarea linie
	end
	
end


-------------------------------------------------------------
---------------------------INIT------------------------------
-------------------------------------------------------------
function game:init()
	application:setBackgroundColor(0x404152)
	self.world = b2.World.new(0, 10, true)
	self.world:setGravity(0, 0)
	local debugDraw = b2.DebugDraw.new()
	self.world:setDebugDraw(debugDraw)
	self:addChild(debugDraw)    ------------------------- DEBUG !!!!!!
	self.worldW = application:getContentWidth()*2
	self.worldH = application:getContentHeight()*2
	
	
	self:deseneaza()
	self:portal(7,9, 3000)
	self:portal(4,4, 3000)
	self:portal(2,6, 3000)
	self:portal(6,9, 3000)
	
	self:addChild(portal_group)
	self:addChild(bullet_group)
	self:addChild(enemies)
	carac=self:character(2,2,conf.dimens,conf.dimens)
	
	joystick(application:getContentWidth()-conf.extensie,application:getContentHeight()-conf.extensie)
	move_joystick( conf.dimens * 1.5, application:getContentHeight()-conf.dimens*2.2)
	
	self:start_game()
	-----------------------------------------------------------
	----------------CONTROLS-----------------------------------
	--------------DEBUG CONTROLS-------------------------------
	-----------------------------------------------------------
	
	local debounce_w=false
	local debounce_a=false
	local debounce_s=false
	local debounce_d=false
	local dly=10
	local increment=conf.char_speed
	
	local function goW()
		local heroX, heroY = carac.body:getPosition()
		carac.body:setPosition(heroX,heroY-increment)
		carac:setPosition(heroX,heroY-increment)
		if debounce_w == true then
			Timer.delayedCall(dly, function() goW() end) 
		end
	end
	local function goA()
		local heroX, heroY = carac.body:getPosition()
		carac.body:setPosition(heroX-increment,heroY)
		carac:setPosition(heroX-increment,heroY)
		if debounce_a == true then	
			Timer.delayedCall(dly, function() goA() end) 
		end
	end
	local function goS()
		local heroX, heroY = carac.body:getPosition()
		carac.body:setPosition(heroX,heroY+increment)
		carac:setPosition(heroX,heroY+increment)
		if debounce_s == true then	
			Timer.delayedCall(dly, function() goS() end) 
		end
		
	end
	local function goD()
		local heroX, heroY = carac.body:getPosition()
		carac.body:setPosition(heroX+increment,heroY)
		carac:setPosition(heroX+increment,heroY)
		if debounce_d == true then	
			Timer.delayedCall(dly, function() goD() end) 
		end
	end
	
	self:addEventListener(Event.KEY_DOWN, function(event)
    if event.keyCode == KeyCode.W then
		debounce_w=true
		goW()
	elseif event.keyCode == KeyCode.A then
		debounce_a=true
		goA()
	elseif event.keyCode == KeyCode.S then
		debounce_s=true
		goS()
	elseif event.keyCode == KeyCode.D then
		debounce_d=true
		goD()
	elseif event.keyCode == KeyCode.F then
		local panou = notification.new("BOIIIII")
		stage:addChild(panou)
	end
	end)
	
	self:addEventListener(Event.KEY_UP, function(event)
		if event.keyCode == KeyCode.W then
			debounce_w=false
		elseif event.keyCode == KeyCode.A then
			debounce_a=false
		elseif event.keyCode == KeyCode.S then
			debounce_s=false
		elseif event.keyCode == KeyCode.D then
			debounce_d=false
		end
	end)
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

------------------------------------------------------------
---------------------ENTER FRAME----------------------------
------------------------------------------------------------
function game:onEnterFrame()
	self.world:step(1/60, 8, 3)
	--- CAMERA
		--get screen dimensions
		local screenW = application:getContentWidth()
		local screenH = application:getContentHeight()
		local offsetX = -conf.dimens
		local offsetY = -conf.dimens
		--- pt camera pe latime
		if((self.worldW - carac:getX()) < screenW/2) then
			offsetX = -self.worldW + screenW -conf.dimens
		elseif(carac:getX() >= screenW/2) then
			offsetX = -(carac:getX() - screenW/2) -conf.dimens
		end
		--- pt camera pe inaltime
		if((self.worldH - carac:getY()) < screenH/2) then
			offsetY = -self.worldH + screenH -conf.dimens
		elseif(carac:getY() >= screenH/2) then
			offsetY = -(carac:getY() - screenH/2) -conf.dimens
		end
		self:setX(offsetX)
		self:setY(offsetY)
		
	----
	local heroX, heroY = carac.body:getPosition()
	carac.body:setPosition(heroX+conf.char_speed*move_powX,heroY-conf.char_speed*move_powY)
	carac:setPosition(heroX+conf.char_speed*move_powX,heroY-conf.char_speed*move_powY)
	--Enemy cleanup
	for i=1, helpers.enemy_count do
		if enemies:getChildAt(i)~=nil and enemies:getChildAt(i).health<=0 then
			helpers.enemy_count = helpers.enemy_count - 1
			enemies:removeChild(enemies:getChildAt(i))
			break
		end
	end
	--Bullet creator
	local delay = conf.delay
	
	if powX ~=0 or powY ~=0 then
		
		if conf.delay_debounce == false then
			conf.delay_debounce= true
			local bul = bullet.new(carac:getX(),carac:getY(),powX,powY,5.5)
			local range = conf.range -- timpul pana la stergerea glontului
			
			local function autoDestroy()
				bullet_group:removeChild(bul)
				bul=nil
			end
			Timer.delayedCall(delay, function() undebounce() end)
			Timer.delayedCall(range, function() autoDestroy() end)
			bullet_group:addChild(bul)
			
		end
	end
end