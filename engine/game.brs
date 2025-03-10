' -------------------------Function To Create Main Game Object------------------------

function new_game(canvas_width, canvas_height, canvas_as_screen_if_possible = false)
	game = game_getMainObject(canvas_width, canvas_height)
	game_defineMainLoopFunction(game)
	game_defineResourcesFunctions(game)
	game_defineRoomFunctions(game)
	game_defineInstancesFunctions(game)
	game_defineCanvasFunctions(game)
	game_defineMediaFunctions(game)
	game_defineCollidersFunctions(game)
	game_defineTimeFunctions(game)
	game_defineUtilsFunctions(game)
	game_setUpScreen(game, canvas_width, canvas_as_screen_if_possible)
	game_setUpFonts(game)
	return game
end function
