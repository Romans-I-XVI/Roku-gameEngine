function ball()
	return function(ball)

		' ################ What we are doing here is modifying the empty object with our ball specific function overrides ###################

		ball.onCreate = function(args)
			' This is just for if not all of the required arguments are passed, do random stuff
			if not args.DoesExist("x") then : m.x = rnd(1280) : end if
			if not args.DoesExist("y") then : m.y = rnd(720) : end if
			if not args.DoesExist("depth") then : m.depth = rnd(1000)-1000 : end if
			if not args.DoesExist("data") then
				m.data = {
					radius: 20+rnd(30),
					xspeed: rnd(5)*60,
					yspeed: rnd(5)*60,
				}
			end if

			m.addColliderCircle("main_collider", m.data.radius, 0, 0)
			m.addColliderRectangle("left_arm", 30, 10, -m.data.radius-30, -5)
			m.addColliderRectangle("right_arm", 30, 10, m.data.radius, -5)
			m.addImage(m.gameEngine.getBitmap("bm_ball"), m.data.radius/32, m.data.radius/32, 0, 0, 100, 100)
		end function


		' Detect collision with other object
		ball.onCollision = function(collider, other_collider, other_object)
			if GetGlobalAA().debug then : print m.name; " " ; m.id; "'s "; collider ; " is in a collision with " ; other_object.name ; " " ; other_object.id ; "'s " ; other_collider : end if
		end function

		ball.onDrawEnd = function(screen)
			' Uncomment if you want to view the object depth
			' if GetGlobalAA().debug then : screen.DrawText(m.depth.ToStr(), m.x+m.data.radius+5, m.y-m.data.radius-10, &hFFFFFFFF, m.gameEngine.Fonts.default) : end if
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
			if button = 9 or button = 1009 then
				m.data.radius = m.data.radius+1
				m.colliders.main_collider.radius = m.data.radius
				m.images[0].scale_x = 1*(m.data.radius/32)
				m.images[0].scale_y = 1*(m.data.radius/32)
			end if
			if (button = 8 or button = 1008) and m.data.radius > 1 then
				m.data.radius = m.data.radius-1
				m.colliders.main_collider.radius = m.data.radius
				m.images[0].scale_x = 1*(m.data.radius/32)
				m.images[0].scale_y = 1*(m.data.radius/32)
			end if


			if button = 13 then
				if rnd(5) = 1 then : m.gameEngine.removeObject(m.id) : end if
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

		' This function is called when I get destroyed
		ball.onDestroy = function()
			print "I've been destroyed!"
		end function

		return ball
	end function
end function