snowfall = Core.class(Sprite)

function snowfall:init()
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	
end

local count = conf.fulg_count

function snowfall:onEnterFrame()
	local generare = math.random(10000)
	if generare > conf.fulgi_interval and count>0 then
		local fulgu = flake.new(math.random(application:getContentWidth()))
		count = count - 1
		self:addChild(fulgu)
	elseif count == 0 then
		self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame,self)
		print("cam atat")
	end
end