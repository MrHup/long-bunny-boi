notification = Core.class(Sprite)

function notification:autoDestroy()
	stage:removeChild(self)
	self = nil
end

function notification:init(mesaj)
	local panou = Bitmap.new(Texture.new("Images/panou.png"))
	panou:setScale(2,2)
	panou:setPosition(application:getContentWidth()/2-panou:getWidth()/2, -200)
	
	local text = TextField.new(conf.smallFont, mesaj)
	text:setPosition(panou:getX()+panou:getWidth()/2-text:getWidth()/2, -200)
	text:setTextColor(0xFFFFFF)
	
	local rx = panou:getX()+panou:getWidth()/2-text:getWidth()/2
	local ry = 50
	
	GTween.new(panou,0.2,{x=panou:getX(),y=50},{ease = easing.inSine})
	GTween.new(text,0.2,{x=rx,y=ry+ panou:getHeight()/2-text:getHeight()/2},{ease = easing.inSine})
	
	self:addChild(panou)
	self:addChild(text)
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	
	Timer.delayedCall(2000, function() self:autoDestroy() end)
end

function notification:onEnterFrame()

end