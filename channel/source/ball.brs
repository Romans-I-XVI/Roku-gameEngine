function obj_ball()
	return function(object)

		' ################ What we are doing here is modifying the empty object with our ball specific function overrides ###################

		object.onCreate = function()
			' This is just for if not all of the required arguments are passed, do random stuff
			m.x = rnd(m.gameEngine.frame.GetWidth())
			m.y = rnd(m.gameEngine.frame.GetHeight())
			m.radius = 20+rnd(30)
			m.xspeed = (rnd(10)-5)*60
			m.yspeed = (rnd(10)-5)*60
			m.depth = 0

			m.addColliderCircle("main_collider", m.radius, 0, 0)
			' m.addColliderRectangle("left_arm", 30, 10, -m.radius-30, -5)
			' m.addColliderRectangle("right_arm", 30, 10, m.radius, -5)
			region = CreateObject("roRegion", m.gameEngine.getBitmap("ball"), 0, 0, 200, 200)
			m.addImage(region, m.radius/32, m.radius/32, 0, 0, 100, 100)

		end function


		' Detect collision with other object
		object.onCollision = function(collider, other_collider, other_object)
			' if GetGlobalAA().debug then : print m.name; " " ; m.id; "'s "; collider ; " is in a collision with " ; other_object.name ; " " ; other_object.id ; "'s " ; other_collider : end if
		end function

		object.onDrawEnd = function(screen)
			' Uncomment if you want to view the object depth
			' if GetGlobalAA().debug then : screen.DrawText(m.depth.ToStr(), m.x+m.radius+5, m.y-m.radius-10, &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
		end function

		' Run if a button is pressed, released, or held
		object.onButton = function(button)
			if GetGlobalAA().debug then : print "Button Code: " ; button : end if

			' I've made it so 1000 plus the button press code means the button is held
			' if button = 5 or button = 1005 then
			' 	m.x = m.x + 5
			' end if
			' if button = 4 or button = 1004 then
			' 	m.x = m.x - 5
			' end if
			' if button = 3 or button = 1003 then
			' 	m.y = m.y + 5
			' end if
			' if button = 2 or button = 1002 then
			' 	m.y = m.y - 5
			' end if
			' if button = 9 or button = 1009 then
			' 	m.radius = m.radius+1
			' 	m.colliders.main_collider.radius = m.radius
			' 	m.images[0].scale_x = 1*(m.radius/32)
			' 	m.images[0].scale_y = 1*(m.radius/32)
			' end if
			' if (button = 8 or button = 1008) and m.radius > 1 then
			' 	m.radius = m.radius-1
			' 	m.colliders.main_collider.radius = m.radius
			' 	m.images[0].scale_x = 1*(m.radius/32)
			' 	m.images[0].scale_y = 1*(m.radius/32)
			' end if

			' if button = 7 then
			' 	if m.colliders.main_collider.enabled then
			' 		m.colliders.main_collider.enabled = false
			' 	else
			' 		m.colliders.main_collider.enabled = true
			' 	end if
			' end if

		end function

		' This is run on every frame
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

		' This function is called when I get destroyed
		object.onDestroy = function()
			print "I've been destroyed!"
		end function
	end function
end function