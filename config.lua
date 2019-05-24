conf = {
	-------------GENERAL STUFF----------------------
	orientation = Stage.PORTRAIT,
	transition = SceneManager.crossfade,  --crossfade
	easing = easing.outBack,
	textureFilter = true,
	scaleMode = "letterbox",
	keepAwake = true,
	smallFont = TTFont.new("Fonts/kongtext.ttf", 60),
	width = 640,
	height = 960,
	fps = 60,
	dx = application:getLogicalTranslateX() / application:getLogicalScaleX(),
	dy = application:getLogicalTranslateY() / application:getLogicalScaleY(),
	-------------GAME STUFF------------
	unitate = 10, --viteza la stretching la bunny
	viteza = 3, -- viteza la obiecte
	gravity = 35, -- 55
	cleanupTime = 7200, -- timpul la care dau cleanup la obstacole
	bunnyStart = 60, --coord la bunny
	bunnyY = 373, -- coord de start bunny
	spatiu = 100, -- spatiu dintre coloane, -- 120
	minRand = -160,
	maxRand = 20,
	dieSpace = 18, -- spatiul care ii este jucatorului sa se miste pe axa X
	---------------SNOW SYSTEM----------------------------
	fulgi_interval = 9000,
	fulg_freckle = 1,
	fulg_size = 2,
	fulg_count = 32,
	--------------DEBUGGING---------------
	killingOn = true,
	snowing = true,
	debug = false
}
