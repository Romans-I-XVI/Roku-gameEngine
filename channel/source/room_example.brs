function room_example()
	return function(room)

		room.onCreate = function(args)
			ball_data = {xspeed: 0, yspeed: 0,  radius: 32}
			m.data.ball = m.gameEngine.spawnObject("ball", {x: 640, y: 360, depth: 0, data: ball_data})
		end function


		room.onDrawBegin = function(screen)
			if GetGlobalAA().debug then : screen.DrawText("room: room_example", 10, 720-10-m.gameEngine.Fonts.default.GetOneLineHeight(), &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
		end function

		room.onButton = function(button)
			if button = 10
				m.gameEngine.changeRoom("room_main")
			end if
		end function

		room.onDestroy = function()
			m.gameEngine.removeObject(m.data.ball.id)
		end function

		return room
	end function
end function