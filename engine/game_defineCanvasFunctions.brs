sub game_defineCanvasFunctions(game as object)

	game.getCanvas = function() as object
		return m.canvas.bitmap
	end function

	game.canvasFitToScreen = sub()
		canvas_width = m.canvas.bitmap.GetWidth()
		canvas_height = m.canvas.bitmap.GetHeight()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()
		if screen_width / screen_height < canvas_width / canvas_height
			m.canvas.scaleX = screen_width / canvas_width
			m.canvas.scaleY = m.canvas.scaleX
			m.canvas.offsetX = 0
			m.canvas.offsetY = (screen_height - (screen_width / (canvas_width / canvas_height))) / 2
		else if screen_width / screen_height > canvas_width / canvas_height
			m.canvas.scaleX = screen_height / canvas_height
			m.canvas.scaleY = m.canvas.scaleX
			m.canvas.offsetX = (screen_width - (screen_height * (canvas_width / canvas_height))) / 2
			m.canvas.offsetY = 0
		else
			m.canvas.offsetX = 0
			m.canvas.offsetY = 0
			scale_difference = screen_width / canvas_width
			m.canvas.scaleX = 1 * scale_difference
			m.canvas.scaleY = 1 * scale_difference
		end if

		if m.canvas.scaleX <> 1 or m.canvas.scaleY <> 1
			m.canvas.region.setScaleMode(1)
		end if
	end sub

end sub
