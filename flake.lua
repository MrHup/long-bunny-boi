flake = Core.class(Sprite)

function flake:init(x)
	local fulg = Bitmap.new(Texture.new("Art/flake.png"))
	fulg:setScale(conf.fulg_size)
	self:addChild(fulg)
	fulg:setPosition(x,-5)
	fulg:addEventListener(Event.ENTER_FRAME, onEnterFrame, fulg)
end

function onEnterFrame(fulguu)
	fulguu:setPosition(fulguu:getX()+math.random(-conf.fulg_freckle,conf.fulg_freckle),fulguu:getY()+2)
	if fulguu:getY()>application:getContentHeight() then
		fulguu:setPosition(math.random(application:getContentWidth()),-4)
	end
end