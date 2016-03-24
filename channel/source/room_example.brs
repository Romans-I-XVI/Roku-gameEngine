function room_example()
	return function(room)
		room.data.ball = new_ball(room.gameEngine.newObject(), 640, 360, 0, 0, 32)

		room.onDrawBegin = function(screen)
			if GetGlobalAA().debug then : screen.DrawText("room: room_example", 10, 720-10-m.gameEngine.Fonts.default.GetOneLineHeight(), &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
		end function

		room.onButton = function(button)
			if button = 10
				gameEngine_changeRoom("room_main")
			end if
		end function

		room.onDestroy = function()
			m.objectHandler.Remove(m.data.ball.id)
		end function

		return room
	end function
end function