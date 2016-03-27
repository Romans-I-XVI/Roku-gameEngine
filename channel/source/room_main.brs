function room_main()
	return function(room)

		room.onCreate = function()
			m.depth = 100
			m.balls = []
			for i = 1 to 20
				m.balls.Push(m.gameEngine.spawnObject("ball"))
			end for

			player_onCreate = function()
				m.addColliderCircle("main_collider", m.radius, 0, 0)
				m.addImage(m.gameEngine.getBitmap("ball"), m.radius/32, m.radius/32, 0, 0, 100, 100, &hFF0000FF)
			end function
			player_onButton = function(button)
				if button = 5 or button = 1005 then
					m.xspeed = m.xspeed + 5
				end if
				if button = 4 or button = 1004 then
					m.xspeed = m.xspeed - 5
				end if
				if button = 3 or button = 1003 then
					m.yspeed = m.yspeed + 5
				end if
				if button = 2 or button = 1002 then
					m.yspeed = m.yspeed - 5
				end if
			end function
			player_data = {
				x: 100
				y: 100
				depth: -100
				radius: 32
				onCreate: player_onCreate
				onButton: player_onButton
			}
			m.player = m.gameEngine.spawnObject("ball", player_data)
			m.gameEngine.cameraSetFollow(m.player)
		end function

		room.onDrawBegin = function(frame)
			' if GetGlobalAA().debug then : frame.DrawText("room: room_main", 10, 720-10-m.gameEngine.Fonts.default.GetOneLineHeight(), &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
			frame.DrawObject(0, 0, m.gameEngine.getBitmap("background"))
			frame.DrawRect(0, 0, frame.GetWidth(), 10, &hFF0000FF)
			frame.DrawRect(0, frame.GetHeight()-10, frame.GetWidth(), 10, &hFF0000FF)
			frame.DrawRect(0, 0, 10, frame.GetHeight(), &hFF0000FF)
			frame.DrawRect(frame.GetWidth()-10, 0, 10, frame.GetHeight(), &hFF0000FF)
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
			for i = 0 to m.balls.Count()-1
				m.gameEngine.removeObject(m.balls[i].id)
			end for
		end function

	end function
end function
