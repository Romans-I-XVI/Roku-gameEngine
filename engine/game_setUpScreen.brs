sub game_setUpScreen(game as object, canvas_width as integer, canvas_as_screen_if_possible as boolean)
	UIResolution = game.device.getUIResolution()
	SupportedResolutions = game.device.GetSupportedGraphicsResolutions()
	FHD_Supported = false
	for i = 0 to SupportedResolutions.Count() - 1
		if SupportedResolutions[i].name = "FHD"
			FHD_Supported = true
		end if
	end for

	if UIResolution.name = "SD"
		game.screen = CreateObject("roScreen", true, 854, 626)
	else
		if canvas_width <= 854
			game.screen = CreateObject("roScreen", true, 854, 480)
		else if canvas_width <= 1280 or not FHD_Supported
			game.screen = CreateObject("roScreen", true, 1280, 720)
		else
			game.screen = CreateObject("roScreen", true, 1920, 1080)
		end if
	end if
	game.videoDestinationRect = { x: 0, y: 0, w: game.screen.GetWidth(), h: game.screen.GetHeight() }
	game.compositor.SetDrawTo(game.screen, &h00000000)
	game.screen.SetMessagePort(game.screen_port)
	game.screen.SetAlphaEnable(true)

	if canvas_as_screen_if_possible
		if game.screen.GetWidth() = game.canvas.bitmap.GetWidth() and game.screen.GetHeight() = game.canvas.bitmap.GetHeight()
			game.canvas.bitmap = game.screen
			game.canvas_is_screen = true
		end if
	end if
end sub
