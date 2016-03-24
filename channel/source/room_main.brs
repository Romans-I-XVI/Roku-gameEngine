function room_main()
	return function(room)

		room.onCreate = function(args)
			m.data.balls = []
			for i = 1 to 10
				m.data.balls.Push(m.gameEngine.spawnObject("ball"))
			end for
		end function

		room.onDrawBegin = function(screen)
			if GetGlobalAA().debug then : screen.DrawText("room: room_main", 10, 720-10-m.gameEngine.Fonts.default.GetOneLineHeight(), &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
		end function

		room.onButton = function(button)
			if button = 10
				m.gameEngine.changeRoom("room_example")
			end if
		end function

		room.onDestroy = function()
			for i = 0 to m.data.balls.Count()-1
				m.gameEngine.removeObject(m.data.balls[i].id)
			end for
		end function

		return room

	end function
end function
