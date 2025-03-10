sub game_defineTimeFunctions(game as object)
	game.Pause = sub()
		if not m.paused
			m.paused = true

			for i = 0 to m.sorted_instances.Count() - 1
				instance = m.sorted_instances[i]
				if instance <> invalid and instance.id <> invalid and instance.onPause <> invalid
					instance.onPause()
				end if
			end for

			m.pauseTimer.Mark()
		end if
	end sub

	game.Resume = function() as dynamic
		if m.paused
			m.paused = false
			paused_time = m.pauseTimer.TotalMilliseconds()

			for i = 0 to m.sorted_instances.Count() - 1
				instance = m.sorted_instances[i]
				if instance <> invalid and instance.id <> invalid
					for each imageName in instance.imagesAA
						image = instance.imagesAA[imageName]
						if image.DoesExist("onResume") and image.onResume <> invalid and asBoolean(image.pauseable)
							image.onResume(paused_time)
						end if
					end for
					if instance.onResume <> invalid
						instance.onResume(paused_time)
					end if
				end if
			end for

			return paused_time
		end if
		return invalid
	end function

	game.isPaused = function() as boolean
		return m.paused
	end function

	game.getDeltaTime = function() as float
		return m.dt
	end function
end sub
