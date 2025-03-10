sub game_defineInstancesFunctions(game as object)
	game.defineObject = sub(object_name as string, object_creation_function as function)
		m.Objects[object_name] = object_creation_function
		m.Instances[object_name] = {}
	end sub

	game.createInstance = function(object_name as string, args = {} as object) as dynamic
		if m.Objects.DoesExist(object_name)
			new_instance = new_emptyGameObject(m, object_name)
			m.Objects[object_name](new_instance)
			new_instance.onCreate(args)
			return new_instance
		else
			return invalid
		end if
	end function

	game.getInstanceByID = function(instance_id as string) as dynamic
		for each object_key in m.Instances
			if m.Instances[object_key].DoesExist(instance_id)
				return m.Instances[object_key][instance_id]
			end if
		end for
		return invalid
	end function

	game.getInstanceByName = function(object_name as string) as dynamic
		if m.Instances.DoesExist(object_name)
			for each instance_key in m.Instances[object_name]
				return m.Instances[object_name][instance_key] ' Obviously only retrieves the first value
			end for
		end if
		return invalid
	end function

	game.getAllInstances = function(object_name as string) as dynamic
		if m.Instances.DoesExist(object_name)
			array = []
			for each instance_key in m.Instances[object_name]
				array.Push(m.Instances[object_name][instance_key])
			end for
			return array
		else
			return invalid
		end if
	end function

	game.destroyInstance = sub(instance as object, call_on_destroy = true)
		if instance <> invalid and instance.id <> invalid and m.Instances[instance.name].DoesExist(instance.id)
			for each collider_key in instance.colliders
				collider = instance.colliders[collider_key]
				if type(collider.compositor_object) = "roSprite"
					collider.compositor_object.Remove()
				end if
			end for
			for each name in instance.imagesAA
				instance.removeImage(name)
			end for
			for each name in instance.labelsAA
				instance.removeLabel(name)
			end for
			if instance.onDestroy <> invalid and call_on_destroy
				instance.onDestroy()
			end if
			if instance <> invalid and instance.id <> invalid and m.Instances[instance.name].DoesExist(instance.id) ' This redundency is here because if somebody would try to change rooms within the onDestroy() method the game would break.
				m.Instances[instance.name].Delete(instance.id)
				instance.Clear()
				instance.id = invalid
			end if
		end if
	end sub

	game.destroyAllInstances = sub(object_name as string, call_on_destroy = true)
		for each instance_key in m.Instances[object_name]
			m.destroyInstance(m.Instances[object_name][instance_key], call_on_destroy)
		end for
	end sub

	game.instanceCount = function(object_name as string) as integer
		return m.Instances[object_name].Count()
	end function

	game.setInputInstance = sub(instance as object)
		m.input_instance = instance.id
	end sub

	game.unsetInputInstance = sub()
		m.input_instance = invalid
	end sub

	game.postGameEventsArray = sub(events as object)
		if not isArray(events) then return
		for i = 0 to events.count() - 1
			data = ifElse(events[i].data <> invalid, events[i].data, {})
			m.postGameEvent(events[i].event, data)
		end for
	end sub

	game.postGameEvent = sub(event as string, data = {} as object)
		print "[EVENT] - " event' " - " FormatJson(data)
		for i = 0 to m.sorted_instances.Count() - 1
			instance = m.sorted_instances[i]
			if instance <> invalid and instance.id <> invalid and instance.onGameEvent <> invalid
				instance.onGameEvent(event, data)
			end if
		end for
	end sub
end sub
