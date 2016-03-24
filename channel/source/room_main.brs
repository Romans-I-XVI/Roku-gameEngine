function room_main()
	return function(room)
		room.data.balls = []

		for i = 1 to 10
			room.data.balls.Push(new_ball(room.gameEngine.newObject(), rnd(1280), rnd(720), (rnd(10)-5)*60, (rnd(10)-5)*60, 10+rnd(60), rnd(1000)))
		end for

		room.onDrawBegin = function(screen)
			if GetGlobalAA().debug then : screen.DrawText("room: room_main", 10, 720-10-m.gameEngine.Fonts.default.GetOneLineHeight(), &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
		end function

		room.onButton = function(button)
			if button = 10
				m.gameEngine.changeRoom("room_example")
			end if
		end function

		room.onDestroy = function()
			for each key in m.data.balls
				m.gameEngine.removeObject(m.data.balls[key].id)
			end for
		end function

		return room
	end function
end function
