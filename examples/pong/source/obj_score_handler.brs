function obj_score_handler(object)

    object.scores = {
        player: 0
        computer: 0
    }

    object.onCreate = function(args)
    end function

    object.onGameEvent = function(event as string, data as object)
        if event = "score"
            if data.team = 0
                m.scores.player++
            else
                m.scores.computer++
            end if
        end if
    end function

    object.onDrawEnd = function(canvas as object)
        font = m.game.getFont("default")

        DrawText(canvas, m.scores.player.ToStr(), 1280 / 2 - 200, 100, font, "center")
        DrawText(canvas, m.scores.computer.ToStr(), 1280 / 2 + 200, 100, font, "center")
    end function

end function