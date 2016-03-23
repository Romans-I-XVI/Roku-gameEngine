function gameEngine_init()
	' Create the main game engine object
	m.gameEngine = {
		screen: CreateObject("roScreen", true, 1280, 720)
		port: CreateObject("roMessagePort")
		objectHandler: gameEngine_newObjectHandler() ' Create the objectHandler object
	}
	' Set up the screen
	m.gameEngine.screen.SetMessagePort(m.gameEngine.port)
	m.gameEngine.screen.SetAlphaEnable(true)

	' Create the main game engine processing function
	m.gameEngine.process = function()
		m.objectHandler.Update(m.port)
		m.objectHandler.CheckCollisions()
		m.objectHandler.Draw(m.screen)
		end function
end function