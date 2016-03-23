sub Main()
	' ------- These two lines are required --------
	gameEngine_init() ' This initializes the game engine
	m.debug = true ' Set debug to false before creating final channel build.
	' ------- These two lines are required --------

	' ------- Other game specific initializations --------
	m.bm_ball = CreateObject("roBitmap", "pkg:/sprites/example.png")
	ball = new_ball(100, 100, 0, 0, 32, 5)
	' ------- Other game specific initializations --------

	' You should really only need m.gameEngine.process() in your while loop. 
	' Everything else should be attached to objects.
	while true
		m.gameEngine.process() ' This must be in the main while loop, it's what makes the game engine tick.
	end while
end sub