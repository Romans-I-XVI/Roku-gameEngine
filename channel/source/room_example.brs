function room_example()
	return function(room)

		room.onCreate = function(args)
			ball_data = {xspeed: 0, yspeed: 0,  radius: 32}
			m.data.ball = m.gameEngine.spawnObject("ball", {x: m.gameEngine.frame.GetWidth()/2, y: m.gameEngine.frame.GetHeight()/2, depth: 0, data: ball_data})
		end function


		room.onDrawBegin = function(frame)
			if GetGlobalAA().debug then : frame.DrawText("room: room_example", 10, 720-10-m.gameEngine.Fonts.default.GetOneLineHeight(), &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
			frame.DrawObject(0, 0, m.gameEngine.getBitmap("background"))
			frame.DrawRect(0, 0, frame.GetWidth(), 10, &h000000FF)
			frame.DrawRect(0, frame.GetHeight()-10, frame.GetWidth(), 10, &h000000FF)
			frame.DrawRect(0, 0, 10, frame.GetHeight(), &h000000FF)
			frame.DrawRect(frame.GetWidth()-10, 0, 10, frame.GetHeight(), &h000000FF)
		end function

		room.onButton = function(button)
			if button = 10
				m.gameEngine.changeRoom("room_main")
			end if


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
			m.gameEngine.removeObject(m.data.ball.id)
		end function

	end function
end function