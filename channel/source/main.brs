Sub Main()
	m.screen = CreateObject("roScreen", true, 1280, 720)
	m.port = CreateObject("roMessagePort")
	m.screen.SetMessagePort(m.port)
	m.screen.SetAlphaEnable(true)
	m.debug = true
	m.objectHandler = gameEngine_newObjectHandler()	
	ball = new_ball(100, 100, 0, 0, 32)
	while true
		m.objectHandler.Update()
		m.objectHandler.DrawColliders()
	end while
End Sub