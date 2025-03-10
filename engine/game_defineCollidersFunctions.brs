sub game_defineCollidersFunctions(game as object)
	game.debugDrawColliders = sub(enabled as boolean)
		m.debugging.draw_colliders = enabled
	end sub

	game.debugDrawSafeZones = sub(enabled as boolean)
		m.debugging.draw_safe_zones = enabled
	end sub

	game.debugLimitFrameRate = sub(limit_frame_rate as integer)
		m.debugging.limit_frame_rate = limit_frame_rate
	end sub

	game.drawColliders = sub(instance as object, color = &hFFffffFF as integer)
		for each collider_key in instance.colliders
			collider = instance.colliders[collider_key]
			if collider.enabled
				if collider.type = "circle"
					' This function is slow as I'm making draw calls for every section of the line.
					' It's for debugging purposes only!
					DrawCircle(m.canvas.bitmap, 100, instance.x + collider.offsetX, instance.y + collider.offsetY, collider.radius, color)
				end if
				if collider.type = "rectangle"
					m.canvas.bitmap.DrawRect(instance.x + collider.offsetX, instance.y + collider.offsetY, 1, collider.height, color)
					m.canvas.bitmap.DrawRect(instance.x + collider.offsetX + collider.width - 1, instance.y + collider.offsetY, 1, collider.height, color)
					m.canvas.bitmap.DrawRect(instance.x + collider.offsetX, instance.y + collider.offsetY, collider.width, 1, color)
					m.canvas.bitmap.DrawRect(instance.x + collider.offsetX, instance.y + collider.offsetY + collider.height - 1, collider.width, 1, color)
				end if
			end if
		end for
	end sub

	game.drawSafeZones = sub()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()
		if m.device.GetDisplayAspectRatio() = "4x3"
			action_offset = { w: 0.033 * screen_width, h: 0.035 * screen_height }
			title_offset = { w: 0.067 * screen_width, h: 0.05 * screen_height }
		else
			action_offset = { w: 0.035 * screen_width, h: 0.035 * screen_height }
			title_offset = { w: 0.1 * screen_width, h: 0.05 * screen_height }
		end if
		action_safe_zone = { x1: action_offset.w, y1: action_offset.h, x2: screen_width - action_offset.w, y2: screen_height - action_offset.h }
		title_safe_zone = { x1: title_offset.w, y1: title_offset.h, x2: screen_width - title_offset.w, y2: screen_height - title_offset.h }

		m.screen.DrawRect(action_safe_zone.x1, action_safe_zone.y1, action_safe_zone.x2 - action_safe_zone.x1, action_safe_zone.y2 - action_safe_zone.y1, &hFF00003F)
		m.screen.DrawRect(title_safe_zone.x1, title_safe_zone.y1, title_safe_zone.x2 - title_safe_zone.x1, title_safe_zone.y2 - title_safe_zone.y1, &h0000FF3F)
		m.screen.DrawText("Action Safe Zone", m.screen.GetWidth() / 2 - m.getDefaultFont().GetOneLineWidth("Action Safe Zone", 1000) / 2, action_safe_zone.y1 + 10, &hFF0000FF, m.getDefaultFont())
		m.screen.DrawText("Title Safe Zone", m.screen.GetWidth() / 2 - m.getDefaultFont().GetOneLineWidth("Title Safe Zone", 1000) / 2, action_safe_zone.y1 + 50, &hFF00FFFF, m.getDefaultFont())
	end sub
end sub
