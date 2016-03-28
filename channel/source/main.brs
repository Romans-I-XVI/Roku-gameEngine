' Library "gameEngine.brs"

sub Main()
	' ------- These two lines are required --------
	gameEngine = gameEngine_init(128, 72, false) ' This initializes the game engine
	gameEngine.loadBitmap("ball", "pkg:/sprites/example.png")
	gameEngine.loadBitmap("background", "pkg:/sprites/background.png")
	gameEngine.addRoom("room_main", room_main())
	gameEngine.addRoom("room_example", room_example())
	gameEngine.addObject("ball", obj_ball())
	gameEngine.addObject("player", obj_player())
	gameEngine.changeRoom("room_main", {depth: -1000})
	gameEngine.spawnObject("player")

	' You should really only need gameEngine.Update() in your while loop. 
	' Everything else should be attached to objects.
	while true
		gameEngine.Update() ' This must be in the main while loop, it's what makes the game engine tick.
	end while
end sub