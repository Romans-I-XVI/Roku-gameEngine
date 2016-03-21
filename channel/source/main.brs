sub Main()
	m.screen = CreateObject("roScreen", true, 1280, 720)
	m.port = CreateObject("roMessagePort")
	m.screen.SetMessagePort(m.port)
	m.screen.SetAlphaEnable(true)
	m.debug = true
	m.objectHandler = gameEngine_newObjectHandler()
	m.bm_ball = CreateObject("roBitmap", "pkg:/sprites/example.png")
	ball = new_ball(100, 100, 10*60, 0, 32)
	ball = new_ball(100, 100, 0, 0, 32, 5)
	while true
		m.objectHandler.Update()
		m.objectHandler.CheckCollisions()
		m.objectHandler.Draw()
		m.objectHandler.DrawColliders()
	end while
end sub