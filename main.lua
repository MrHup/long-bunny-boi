--setting up some configurations
application:setOrientation(conf.orientation)
--application:setLogicalDimensions(conf.width, conf.height)
application:setScaleMode(conf.scaleMode)
application:setFps(conf.fps)
application:setKeepAwake(conf.keepAwake)
application:setBackgroundColor(0x9C9BA3)

----------------- broken admob

--my ad


--[[require "ads"
admob=Ads.new("admob")
admob:setKey("ca-app-pub-7984557040279312/2398862700")
--admob:enableTesting(true)
admob:loadAd("banner", "ca-app-pub-7984557040279312/6127204785")

admob:addEventListener(Event.AD_RECEIVED , function (event) 
	print(event.type, "ad received")
	if event.type=="banner" then admob:showAd("banner") admob:setAlignment("center","bottom") end
end)
]]
--test ad
--[[
require "ads"
admob = Ads.new("admob")

admob:setKey("ca-app-pub-3940256099942544/1033173712")
admob:loadAd("banner", "ca-app-pub-3940256099942544/6300978111")


]]

-----------------------applovin

--[[
require "ads"
applovin = Ads.new("applovin")
applovin:setKey("ce7raDCaHMLRKCwVMpNZokkwdMxtQS5HiGITSTiyVPAUiM3_Z_QpaLcZqXt7Tzo569rTctJnRqJLTi_yODwo-R")
--applovin:loadAd("banner", "ca-app-pub-3940256099942544/6300978111")
--applovin:loadAd("banner")

applovin:addEventListener(Event.AD_RECEIVED , function (event) 
	print(event.type, "ad received")
	if event.type=="banner" then applovin:showAd("banner") applovin:setAlignment("center","bottom") end
end)]]--

sceneManager = SceneManager.new({
	["game"] = game,
	["menu"] = menu
})

stage:addChild(sceneManager)
sceneManager:changeScene("game", 1, conf.transition, conf.easing)
