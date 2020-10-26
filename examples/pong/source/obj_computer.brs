function obj_computer(object)

	object.x = 1280 - 50
	object.y = invalid
	object.width = invalid
	object.height = invalid
	object.bounds = {top: 50, bottom: 720 - 50}

	object.onCreate = function(args)
		m.y = m.game.getCanvas().GetHeight() / 2

		bm_paddle = m.game.getBitmap("paddle")
		m.width = bm_paddle.GetWidth()
		m.height = bm_paddle.GetHeight()
		m.addColliderRectangle("front", -m.width / 2, -m.height / 2, 1, m.height)
		m.addColliderRectangle("top", -m.width / 2, -m.height / 2, m.width, 1)
		m.addColliderRectangle("bottom", -m.width / 2, m.height / 2 - 1, m.width, 1)

		region = CreateObject("roRegion", bm_paddle, 0, 0, m.width, m.height)
		region.SetPretranslation(-m.width / 2, -m.height / 2)
		m.addImage("main", region)
	end function

	object.onUpdate = function(dt)
		ball = m.game.getInstanceByName("ball")

		' If there is a ball and the ball is moving to the right and hasn't gotten to the computer paddle yet move paddle towards ball
		if ball <> invalid and ball.xspeed > 0 and ball.x < m.x
			if ball.y < m.y - 20
				if m.y > m.bounds.top + m.height / 2
					m.y -= 3.5 * 60 * dt
				else
					m.y = m.bounds.top + m.height / 2
				end if
			else if ball.y > m.y + 20
				if m.y < m.bounds.bottom - m.height / 2
					m.y += 3.5 * 60 * dt
				else
					m.y = m.bounds.bottom - m.height / 2
				end if
			end if
		end if
	end function

end function