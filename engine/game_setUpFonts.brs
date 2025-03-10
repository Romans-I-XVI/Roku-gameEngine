sub game_setUpFonts(game as object)
	game.labelsTextures["default"] = { font: game.font_registry.GetDefaultFont(28, false, false) }

    ttfs_in_package = game.filesystem.FindRecurse("pkg:/fonts/", ".ttf")
    otfs_in_package = game.filesystem.FindRecurse("pkg:/fonts/", ".otf")
    for each font_path in ttfs_in_package
        game.registerFont("pkg:/fonts/" + font_path)
    end for
    for each font_path in otfs_in_package
        game.registerFont("pkg:/fonts/" + font_path)
    end for
end sub
