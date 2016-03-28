function obj_player()
	return function(object)
		object.onCreate = function()
			m.x = m.gameEngine.Frame.GetWidth()/2
			m.y = m.gameEngine.Frame.GetHeight()/2
			m.depth = -100
			m.radius = 12
			m.addColliderCircle("main_collider", m.radius, 0, 0)
			m.addAnimatedImage(m.gameEngine.getBitmap("ball"), 200, 200, 8, 500, m.radius/32, m.radius/32, 0, 0, 100, 100, &hFF0000FF)
			m.gameEngine.cameraSetFollow(m)
		end function

		object.onCollision = function(collider, other_collider, other_object)
			' if other_object.name = "ball" then
			' 	m.gameEngine.removeObject(other_object)
			' end if
		end function

		object.onButton = function(button)
			if button = 5 or button = 1005 then
				m.xspeed = m.xspeed + 10
			end if
			if button = 4 or button = 1004 then
				m.xspeed = m.xspeed - 10
			end if
			if button = 3 or button = 1003 then
				m.yspeed = m.yspeed + 10
			end if
			if button = 2 or button = 1002 then
				m.yspeed = m.yspeed - 10
			end if
		end function

		object.onUpdate = function(dt)
			' Handle Movement
			if m.x-m.radius <= 10 then
			    m.xspeed = abs(m.xspeed)
			end if
			if m.x+m.radius >= m.gameEngine.frame.GetWidth()-10 then
				m.xspeed = abs(m.xspeed)*-1
			end if
			if m.y-m.radius <= 10 then
			    m.yspeed = abs(m.yspeed)
			end if
			if m.y+m.radius >= m.gameEngine.frame.GetHeight()-10 then
				m.yspeed = abs(m.yspeed)*-1
			end if
		end function

	end function
end function
