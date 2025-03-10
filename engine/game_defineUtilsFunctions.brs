sub game_defineUtilsFunctions(game as object)
	game.getNewUniqId = function(groupName as string) as string
		if m.currentIDs[groupName] = invalid
			m.currentIDs[groupName] = 0
		else
			m.currentIDs[groupName]++
		end if
		return m.currentIDs[groupName].toStr()
	end function

	game.getVersion = function() as string
        return m.version
    end function

end sub
