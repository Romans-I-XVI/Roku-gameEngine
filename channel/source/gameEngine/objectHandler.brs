function gameEngine_newObjectHandler()
	objectHandler = {}
	objectHandler.buttonHeld = -1
	objectHandler.dtTimer = CreateObject("roTimespan")
	objectHandler.currentID = 0
	objectHandler.objectHolder = {}

	objectHandler.Update = function()
		port = GetGlobalAA().port
        msg = port.GetMessage() 
		dt = m.dtTimer.TotalMilliseconds()/1000
		m.dtTimer.Mark()
		for each key in m.objectHolder
	        if type(msg) = "roUniversalControlEvent"
	        	m.objectHolder[key].onButton(msg.GetInt())
	        	if msg.GetInt() < 100
	        		m.buttonHeld = msg.GetInt()
	        	else
	        		m.buttonHeld = -1
	        	end if
	        end if
	        if m.buttonHeld <> -1
	        	' Button release codes are 100 plus the button press code
	        	' This shows a button held code as 1000 plus the button press code
	        	m.objectHolder[key].onButton(1000+m.buttonHeld)
	        end if
			m.objectHolder[key].onUpdate(dt)
		end for
		screen = GetGlobalAA().screen
		screen.SwapBuffers()
		screen.Clear(&h000000FF)
	end function

	objectHandler.Draw = function()
		screen = GetGlobalAA().screen
		depths = []
		for each object_key in m.objectHolder
			object = m.objectHolder[object_key]
			if depths.Count() > 0 then
				inserted = false
				for i = depths.Count()-1 to 0 step -1
					if not inserted and object.depth > depths[i].depth then
						arrayInsert(depths, i+1, object)
						inserted = true
						exit for
					end if
				end for
				if not inserted then
					depths.Unshift(object)
				end if
			else
				depths.Unshift(object)
			end if
		end for

		for i = depths.Count()-1 to 0 step -1
			object = depths[i]
			print object.depth
			object.onDrawBegin()
			for each image in object.images
				if image.enabled then
					screen.DrawScaledObject(object.x+image.offset_x-(image.origin_x*image.scale_x), object.y+image.offset_y-(image.origin_y*image.scale_y), image.scale_x, image.scale_y, image.image, image.rgba)
				end if
			end for
			object.onDrawEnd()
			' if GetGlobalAA().debug then love.graphics.print(tostring(image.depth), object.x-100, object.y-100) end
		end for
		print "--------------------"
	end function

	objectHandler.DrawColliders = function()
		screen = GetGlobalAA().screen
		for each object_key in m.objectHolder
			object = m.objectHolder[object_key]
			for each collider_key in object.colliders
				collider = object.colliders[collider_key]
				if collider.enabled then
					if collider.type = "circle" then
						screen.DrawRect(object.x+collider.offset_x+collider.radius-2, object.y+collider.offset_y-2, 4, 4, &hFF0000FF)
						screen.DrawRect(object.x+collider.offset_x-collider.radius-2, object.y+collider.offset_y-2, 4, 4, &hFF0000FF)
						screen.DrawRect(object.x+collider.offset_x-2, object.y+collider.offset_y+collider.radius-2, 4, 4, &hFF0000FF)
						screen.DrawRect(object.x+collider.offset_x-2, object.y+collider.offset_y-collider.radius-2, 4, 4, &hFF0000FF)
					end if
					if collider.type = "rectangle" then
						screen.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y, 1, collider.height, &hFF0000FF)
						screen.DrawRect(object.x+collider.offset_x+collider.width-1, object.y+collider.offset_y, 1, collider.height, &hFF0000FF)
						screen.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y, collider.width, 1, &hFF0000FF)
						screen.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y+collider.height-1, collider.width, 1, &hFF0000FF)
					end if
				end if
			end for
		end for
	end function

	' objectHandler.CheckCollisions = function()
	' 	for key, object in pairs(objectHolder) do
	' 		for collider_key, collider in pairs(object.colliders) do
	' 			for other_key, other_object in pairs(objectHolder) do
	' 				if other_object ~= object then 
	' 					for other_collider_key, other_collider in pairs(other_object.colliders) do
	' 					    in_collision = false
	' 						if collider.type = "rectangle" and other_collider.type = "rectangle" then
	' 							in_collision = collisionFunction:RectRect(object.x+collider.offset_x, object.y+collider.offset_y, collider.width, collider.height, other_object.x+other_collider.offset_x, other_object.y+other_collider.offset_y, other_collider.width, other_collider.height)
	' 						end
	' 						if collider.type = "circle" and other_collider.type = "circle" then
	' 							in_collision = collisionFunction:CircleCircle(object.x+collider.offset_x, object.y+collider.offset_y, collider.radius, other_object.x+other_collider.offset_x, other_object.y+other_collider.offset_y, other_collider.radius)
	' 						end
	' 						if (collider.type = "rectangle" and other_collider.type = "circle") or (collider.type = "circle" and other_collider.type = "rectangle") then
	' 							circle, circle_x, circle_y, rectangle, rectangle_x, rectangle_y
	' 							if collider.type = "circle" then 
	' 								circle_x = object.x
	' 								circle_y = object.y
	' 								circle = collider 
	' 								rectangle_x = other_object.x
	' 								rectangle_y = other_object.y
	' 								rectangle = other_collider
	' 							else 
	' 								circle_x = other_object.x
	' 								circle_y = other_object.y
	' 								circle = other_collider 
	' 								rectangle_x = object.x
	' 								rectangle_y = object.y
	' 								rectangle = collider
	' 							end
	' 							in_collision = collisionFunction:CircleRect(circle_x+circle.offset_x, circle_y+circle.offset_y, circle.radius, rectangle_x+rectangle.offset_x, rectangle_y+rectangle.offset_y, rectangle.width, rectangle.height)
	' 						end
	' 						' if in_collision and GetGlobalAA().debug then print("Collision Detected: ",key, other_key, love.timer.getTime()) end
	' 						if in_collision and collider.enabled then object:onCollision(collider_key, other_collider_key, other_object) end
	' 					end
	' 				end
	' 			end
	' 		end
	' 	end
	' end

	' Give a unique identifier to the object
	objectHandler.setID = function()
		m.currentID = m.currentID + 1
		return m.currentID.ToStr()
	end function

	' Add an object to the objectHandler
	objectHandler.Add = function(object)
		if GetGlobalAA().debug then : print "Adding Object: "+object.id : end if
		m.objectHolder[object.id] = object
	end function

	' Remove an object from the objectHandler
	objectHandler.Remove = function(object)
		if GetGlobalAA().debug then : print "Removing Object: "+object.id : end if
		m.objectHolder[object.id].onDestroy()
		m.objectHolder.Delete(object.id)
	end function

	return objectHandler
end function