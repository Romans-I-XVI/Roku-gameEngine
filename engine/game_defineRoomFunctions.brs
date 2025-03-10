sub game_defineRoomFunctions(game as object)
	game.getRoom = function() as object
		return m.currentRoom
	end function

	game.defineRoom = sub(room_name as string, room_creation_function as function)
		m.Rooms[room_name] = room_creation_function
		m.Instances[room_name] = {}
	end sub

	game.changeRoom = function(room_name as string, args = {} as object) as boolean
		if m.Rooms[room_name] <> invalid
			for i = 0 to m.sorted_instances.Count() - 1
				instance = m.sorted_instances[i]
				if instance <> invalid and instance.id <> invalid and instance.onChangeRoom <> invalid
					instance.onChangeRoom(room_name)
				end if
			end for
			for i = 0 to m.sorted_instances.Count() - 1
				instance = m.sorted_instances[i]
				if instance.id <> invalid and not instance.persistent and instance.name <> m.currentRoom.name
					m.destroyInstance(instance, false)
				end if
			end for
			if m.currentRoom <> invalid and m.currentRoom.id <> invalid
				m.destroyInstance(m.currentRoom, false)
			end if
			m.currentRoom = new_emptyGameObject(m, room_name)
			m.Rooms[room_name](m.currentRoom)
			m.currentRoomArgs = args
			m.currentRoom.onCreate(args)
			print_info("Room changed to - " + room_name)
			return true
		else
			print_info("A room named " + room_name + " hasn't been defined")
			return false
		end if
	end function

	game.resetRoom = sub()
		m.changeRoom(m.currentRoom.name, m.currentRoomArgs)
	end sub
end sub