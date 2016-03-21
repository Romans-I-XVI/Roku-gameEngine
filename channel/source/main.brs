sub Main()
	m.screen = CreateObject("roScreen", true, 1280, 720)
	m.port = CreateObject("roMessagePort")
	m.screen.SetMessagePort(m.port)
	m.screen.SetAlphaEnable(true)
	m.debug = true
	m.objectHandler = gameEngine_newObjectHandler()
	m.bm_ball = CreateObject("roBitmap", "pkg:/sprites/example.png")
	ball = new_ball(100, 100, 0, 0, 32)
	ball = new_ball(100, 100, 0, 0, 32, 5)
	ball = new_ball(100, 100, 0, 0, 32, 2)
	ball = new_ball(100, 100, 0, 0, 32, 3)
	ball = new_ball(100, 100, 0, 0, 32, 230)
	ball = new_ball(100, 100, 0, 0, 32, 2)
	ball = new_ball(100, 100, 0, 0, 32, 1)
	ball = new_ball(100, 100, 0, 0, 32, 3423)
	ball = new_ball(100, 100, 0, 0, 32, 232332)
	while true
		m.objectHandler.Update()
		m.objectHandler.Draw()
		m.objectHandler.DrawColliders()
	end while
end sub