function obj_player(object)

	object.x = 50
	object.y = invalid
	object.width = invalid
	object.height = invalid
	object.bounds = {top: 50, bottom: 720 - 50}

	object.onCreate = function(args)
		m.y = m.game.getCanvas().GetHeight() / 2

		bm_paddle = m.game.getBitmap("paddle")
		m.width = bm_paddle.GetWidth()
		m.height = bm_paddle.GetHeight()
		m.addColliderRectangle("front", m.width / 2 - 1, -m.height / 2, 1, m.height)
		m.addColliderRectangle("top", -m.width / 2, -m.height / 2, m.width, 1)
		m.addColliderRectangle("bottom", -m.width / 2, m.height / 2 - 1, m.width, 1)

		region = CreateObject("roRegion", bm_paddle, 0, 0, m.width, m.height)
		region.SetPretranslation(-m.width / 2, -m.height / 2)
		m.addImage("main", region)
	end function

	object.onUpdate = function(dt)
		if m.y < m.bounds.top + m.height / 2
			m.y = m.bounds.top + m.height / 2
			m.yspeed = 0
		end if
		if m.y > m.bounds.bottom - m.height / 2
			m.y = m.bounds.bottom - m.height / 2
			m.yspeed = 0
		end if
	end function

	object.onButton = function(code as integer)
		if code = 2 ' Up Pressed
			m.yspeed = -3.5
		else if code = 102 ' Up Released
			m.yspeed = 0
		else if code = 3 ' Down Pressed
			m.yspeed = 3.5
		else if code = 103 ' Down Released
			m.yspeed = 0
		end if

		' -------Button Code Reference--------
		' Pressed | Released | Held

		' Back  0  100 1000
		' Up  2  102 1002
		' Down  3  103 1003
		' Left  4  104 1004
		' Right  5  105 1005
		' Select  6  106 1006
		' Instant Replay  7  107 1007
		' Rewind  8  108 1008
		' Fast  Forward  9  109 1009
		' Info  10  110 1010
		' Play  13  113 1013
	end function

end function
