menu = gideros.class(Sprite)

function menu:init()
	Timer.delayedCall(1500, function() sceneManager:changeScene("game", 1, conf.transition, conf.easing) end)
end