function obj_ball(object)

	object.direction = invalid
	object.hit_frequency_timer = CreateObject("roTimeSpan")
	object.dead = false
	object.bounds = {top: 50, bottom: 720 - 50}

	object.onCreate = function(args)
		m.direction = args.direction
		m.x = 1280 / 2
		m.y = 720 / 2
		m.xspeed = 5.5 * m.direction
		m.yspeed = 5
		if rnd(2) = 1
			m.yspeed *= -1
		end if

		bm_ball = m.game.getBitmap("ball")
		region = CreateObject("roRegion", bm_ball, 0, 0, bm_ball.GetWidth(), bm_ball.GetHeight())
		region.SetPretranslation(-bm_ball.GetWidth() / 2, -bm_ball.GetHeight() / 2)
		m.addImage("main", region, {color: &hffffff, alpha: 0})
		m.addColliderRectangle("main_collider", -bm_ball.GetWidth() / 2, -bm_ball.GetHeight() / 2, bm_ball.GetWidth(), bm_ball.GetHeight())
	end function

	object.onCollision = function(collider_name as string, other_collider_name as string, other_instance as object)
		need_to_play_hit_sound = false

		' If colliding with the front of the player paddle
		if not m.dead and other_instance.name = "player" and other_collider_name = "front"
			m.xspeed = Abs(m.xspeed)
			need_to_play_hit_sound = true
		end if

		' If colliding with the front of the computer paddle
		if not m.dead and other_instance.name = "computer" and other_collider_name = "front"
			m.xspeed = Abs(m.xspeed) * -1
			need_to_play_hit_sound = true
		end if

		' If colliding with the front or bottom of the either paddle
		if (other_instance.name = "player" or other_instance.name = "computer")
			if other_collider_name = "top" then
				m.yspeed = Abs(m.yspeed) * -1
				need_to_play_hit_sound = true
			end if
			if other_collider_name = "bottom" then
				m.yspeed = Abs(m.yspeed)
				need_to_play_hit_sound = true
			end if
		end if

		if need_to_play_hit_sound
			m.PlayHitSound()
		end if
	end function

	object.onUpdate = function(dt as float)
		image = m.getImage("main")
		collider = m.getCollider("main_collider")

		' Increase alpha until full if not at full
		if image.alpha < 255 then
			image.alpha += 3
		end if

		' If the left side of the ball is past the center of the player paddle position
		if m.x - collider.width / 2 <= m.game.getInstanceByName("player").x
			m.dead = true
			if m.x <= -100
				m.game.postGameEvent("score", {team: 1})
				m.game.destroyInstance(m)
				return void ' If an entity destroys itself it must return immediately as all internal variables are now invalid
			end if
		end if

		' If the right side of the ball is past the center of the computer paddle
		if m.x + collider.width / 2 >= m.game.getInstanceByName("computer").x
			m.dead = true
			if m.x >= 1280 + 100
				m.game.postGameEvent("score", {team: 0})
				m.game.destroyInstance(m)
				return void ' If an entity destroys itself it must return immediately as all internal variables are now invalid
			end if
		end if

		' If the ball is hitting the top bounds
		if m.y - collider.height / 2 <= m.bounds.top
			m.yspeed = abs(m.yspeed)
			m.PlayHitSound()
		end if

		' If the ball is hitting the bottom bounds
		if m.y + collider.height / 2 >= m.bounds.bottom
			m.yspeed = abs(m.yspeed) * -1
			m.PlayHitSound()
		end if
	end function

	object.PlayHitSound = function()
		' Play the hit sound if ball is on screen and didn't already play within the last 100ms
		if m.x > 0 and m.x < m.game.getCanvas().GetWidth() and m.hit_frequency_timer.TotalMilliseconds() > 100
			m.game.playSound("hit", 50)
			m.hit_frequency_timer.Mark()
		end if
	end function

	object.onDestroy = function()
		m.game.playSound("score", 50)
	end function

end function
