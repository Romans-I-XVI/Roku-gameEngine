function room_main()
	return function(room)

		room.onCreate = function(args)
			m.data.balls = []
			for i = 1 to 20
				m.data.balls.Push(m.gameEngine.spawnObject("ball"))
			end for
		end function

		room.onDrawBegin = function(frame)
			' if GetGlobalAA().debug then : frame.DrawText("room: room_main", 10, 720-10-m.gameEngine.Fonts.default.GetOneLineHeight(), &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
			frame.DrawObject(0, 0, m.gameEngine.getBitmap("background"))
			frame.DrawRect(0, 0, frame.GetWidth(), 10, &h000000FF)
			frame.DrawRect(0, frame.GetHeight()-10, frame.GetWidth(), 10, &h000000FF)
			frame.DrawRect(0, 0, 10, frame.GetHeight(), &h000000FF)
			frame.DrawRect(frame.GetWidth()-10, 0, 10, frame.GetHeight(), &h000000FF)
		end function

		room.onButton = function(button)
			if button = 10
				m.gameEngine.changeRoom("room_example")
			end if

			' if button = 5 or button = 1005 then
			' 	m.gameEngine.cameraIncreaseOffset(5,0)
			' end if
			' if button = 4 or button = 1004 then
			' 	m.gameEngine.cameraIncreaseOffset(-5,0)
			' end if
			' if button = 3 or button = 1003 then
			' 	m.gameEngine.cameraIncreaseOffset(0,5)
			' end if
			' if button = 2 or button = 1002 then
			' 	m.gameEngine.cameraIncreaseOffset(0,-5)
			' end if
			if button = 9 or button = 1009 then
				m.gameEngine.cameraIncreaseZoom(0.01)
			end if
			if button = 8 or button = 1008 then
				m.gameEngine.cameraIncreaseZoom(-0.01)
			end if

			if button = 7 then
				m.gameEngine.cameraFitToScreen()
			end if

		end function

		room.onDestroy = function()
			for i = 0 to m.data.balls.Count()-1
				m.gameEngine.removeObject(m.data.balls[i].id)
			end for
		end function

	end function
end function
