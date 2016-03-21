function new_ball(x, y, xspeed, yspeed, radius, depth = 0)
	ball = gameEngine_newObject(m.objectHandler, "ball")
	ball.depth = depth
	ball.x = x
	ball.y = y
	ball.data = {
		radius: radius,
		xspeed: xspeed,
		yspeed: yspeed,
	}

	ball.addColliderCircle("main_collider", radius, 0, 0)
	ball.addColliderRectangle("left_arm", 30, 10, -radius-30, -5)
	ball.addColliderRectangle("right_arm", 30, 10, radius, -5)
	ball.addImage(m.bm_ball, rnd(1000)-1000, 1*(radius/32), 1*(radius/32), 0, 0, 100, 100)

	' Detect collision with other object
	ball.onCollision = function(collider, other_collider, other_object)
		print "In collision with - " ; other_object.name
	end function

	' Run if a button is pressed, released, or held
	ball.onButton = function(button)
		if GetGlobalAA().debug then : print "Button Code: " ; button : end if

		' I've made it so 1000 plus the button press code means the button is held
		if button = 5 or button = 1005 then
			m.data.xspeed = m.data.xspeed + 0.1*60
		end if
		if button = 4 or button = 1004 then
			m.data.xspeed = m.data.xspeed - 0.1*60
		end if
		if button = 3 or button = 1003 then
			m.data.yspeed = m.data.yspeed + 0.1*60
		end if
		if button = 2 or button = 1002 then
			m.data.yspeed = m.data.yspeed - 0.1*60
		end if

	end function

	' This is run on every frame
	ball.onUpdate = function(dt)
		' Handle Movement
		m.x = m.x + (m.data.xspeed*dt)
		m.y = m.y + (m.data.yspeed*dt)
		if m.x-m.colliders["main_collider"].radius <= 0 then
		    m.data.xspeed = abs(m.data.xspeed)
		end if
		if m.x+m.colliders["main_collider"].radius >= 1280 then
			m.data.xspeed = abs(m.data.xspeed)*-1
		end if
		if m.y-m.colliders["main_collider"].radius <= 0 then
		    m.data.yspeed = abs(m.data.yspeed)
		end if
		if m.y+m.colliders["main_collider"].radius >= 720 then
			m.data.yspeed = abs(m.data.yspeed)*-1
		end if
	end function

	return ball
end function