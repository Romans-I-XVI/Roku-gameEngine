function room_main(object)

	object.onCreate = function(args)
		m.game.createInstance("pause_handler")
		m.game.createInstance("score_handler")
		m.game.createInstance("player")
		m.game.createInstance("computer")
		m.game_started = false
		m.ball_spawn_timer = CreateObject("roTimespan")
		m.ball_direction = -1
		m.ball = invalid
	end function

	object.onUpdate = function(dt)
		if m.game_started and m.ball = invalid and m.ball_spawn_timer.TotalMilliseconds() > 1000
			m.ball = m.game.createInstance("ball", {direction: m.ball_direction})
		end if
	end function

	object.onDrawBegin = function(canvas)
		canvas.DrawRect(0, 0, 1280, 50, &hFFFFFFFF)
		canvas.DrawRect(0, 720-50, 1280, 50, &hFFFFFFFF)
		if not m.game_started then
			DrawText(canvas, "Press OK To Play", canvas.GetWidth()/2, canvas.GetHeight()/2-20, m.game.getFont("default"), "center")
		end if
	end function

	object.onButton = function(button)
		if button = 0 then
			m.game.End()
		end if
		if not m.game_started and button = 6 then
			m.game_started = true
		end if
	end function

	object.onGameEvent = function(event as string, data as object)
		if event = "score"
			if data.team = 0
				m.ball_direction = -1
			else
				m.ball_direction = 1
			end if
			m.ball = invalid
			m.ball_spawn_timer.Mark()
		end if
	end function

end function