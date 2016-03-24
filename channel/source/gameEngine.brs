' -------------------------Function To Create Main Game Engine Object------------------------

function gameEngine_init(screen_width = 1280, screen_height = 720, debug = false)
	
	' ############### Create Initial Object - Begin ###############

	' Create the main game engine object
	m.debug = debug
	gameEngine = {
		' ****BEGIN - For Internal Use, Do Not Manually Alter****
		buttonHeld: -1
		dtTimer: CreateObject("roTimespan")
		fpsTimer: CreateObject("roTimespan")
		fpsTicker: 0
		FPS: 0
		currentID: 0
		screen: CreateObject("roScreen", true, screen_width, screen_height)
		port: CreateObject("roMessagePort")
		font_registry: CreateObject("roFontRegistry")
		' ****END - For Internal Use, Do Not Manually Alter****

		' ****Variables****
		current_room: invalid
		objectHolder: {}
		Bitmaps: {}
		Rooms: {}
		Fonts: {}

		' These are just placeholder reminders of what functions get added to the gameEngine
		' ****Functions****
		Update: invalid
		newObject: invalid
		removeObject: invalid
		addRoom: invalid
		changeRoom: invalid
		loadBitmap: invalid
		getBitmap: invalid
		unloadBitmap: invalid
		getFont: invalid
		removeFont: invalid

	}
	' Set up the screen
	gameEngine.screen.SetMessagePort(gameEngine.port)
	gameEngine.screen.SetAlphaEnable(true)

	' Create the default font
	gameEngine.Fonts["default"] = gameEngine.font_registry.GetDefaultFont(28, false, false)

	' ############### Create Initial Object - End ###############





	' ############### Update() function - Begin ###############

	gameEngine.Update = function()

        msg = m.port.GetMessage() 
		dt = m.dtTimer.TotalMilliseconds()/1000
		draw_depths = []
		game_objects = []
		for each key in m.objectHolder
			game_objects.Push(m.objectHolder[key])
		end for
		m.dtTimer.Mark()
		m.fpsTicker = m.fpsTicker + 1
		if m.fpsTimer.TotalMilliseconds() > 1000 then
			m.FPS = m.fpsTicker
			m.fpsTicker = 0
			m.fpsTimer.Mark()
		end if

		' --------------------Begin giant loop for processing all game objects----------------
		for each object in game_objects

			' --------------------First process the onButton() function--------------------
	        if type(msg) = "roUniversalControlEvent"
	        	object.onButton(msg.GetInt())
	        	if msg.GetInt() < 100
	        		m.buttonHeld = msg.GetInt()
	        	else
	        		m.buttonHeld = -1
	        	end if
	        end if
	        if m.buttonHeld <> -1
	        	' Button release codes are 100 plus the button press code
	        	' This shows a button held code as 1000 plus the button press code
	        	object.onButton(1000+m.buttonHeld)
	        end if


	        ' -------------------Then process the onUpdate() function----------------------
			object.onUpdate(dt)


			' -------------------Then process all collisions and call onCollision() function-------------
			for each collider_key in object.colliders
				collider = object.colliders[collider_key]
				for each other_key in m.objectHolder
					if m.objectHolder.DoesExist(other_key) then
						other_object = m.objectHolder[other_key]
						if other_object.id <> object.id then 
							for each other_collider_key in other_object.colliders
								if other_object.colliders.DoesExist(other_collider_key) then
									other_collider = other_object.colliders[other_collider_key]
								    in_collision = false
									if collider.type = "rectangle" and other_collider.type = "rectangle" then
										in_collision = gameEngine_collisionRectRect(object.x+collider.offset_x, object.y+collider.offset_y, collider.width, collider.height, other_object.x+other_collider.offset_x, other_object.y+other_collider.offset_y, other_collider.width, other_collider.height)
									end if
									if collider.type = "circle" and other_collider.type = "circle" then
										in_collision = gameEngine_collisionCircleCircle(object.x+collider.offset_x, object.y+collider.offset_y, collider.radius, other_object.x+other_collider.offset_x, other_object.y+other_collider.offset_y, other_collider.radius)
									end if
									if (collider.type = "rectangle" and other_collider.type = "circle") or (collider.type = "circle" and other_collider.type = "rectangle") then
										if collider.type = "circle" then 
											circle_x = object.x
											circle_y = object.y
											circle = collider 
											rectangle_x = other_object.x
											rectangle_y = other_object.y
											rectangle = other_collider
										else 
											circle_x = other_object.x
											circle_y = other_object.y
											circle = other_collider 
											rectangle_x = object.x
											rectangle_y = object.y
											rectangle = collider
										end if
										in_collision = gameEngine_collisionCircleRect(circle_x+circle.offset_x, circle_y+circle.offset_y, circle.radius, rectangle_x+rectangle.offset_x, rectangle_y+rectangle.offset_y, rectangle.width, rectangle.height)
									end if
									' if in_collision and GetGlobalAA().debug then print("Collision Detected: ",key, other_key, love.timer.getTime()) end
									if in_collision and collider.enabled then : object.onCollision(collider_key, other_collider_key, other_object) : end if
								end if
							end for
						end if
					end if
				end for
			end for

			' --------------------------Add object to the appropriate position in the draw_depths array-----------------
			if draw_depths.Count() > 0 then
				inserted = false
				for i = draw_depths.Count()-1 to 0 step -1
					if not inserted and object.depth > draw_depths[i].depth then
						ArrayInsert(draw_depths, i+1, object)
						inserted = true
					end if
				end for
				if not inserted then
					draw_depths.Unshift(object)
				end if
			else
				draw_depths.Unshift(object)
			end if
		end for


		' ----------------------Then draw all of the objects and call onDrawBegin() and onDrawEnd()-------------------------
		for i = draw_depths.Count()-1 to 0 step -1
			object = draw_depths[i]
			object.onDrawBegin(m.screen)
			for each image in object.images
				if image.enabled then
					m.screen.DrawScaledObject(object.x+image.offset_x-(image.origin_x*image.scale_x), object.y+image.offset_y-(image.origin_y*image.scale_y), image.scale_x, image.scale_y, image.image, image.rgba)
				end if
			end for
			object.onDrawEnd(m.screen)
			if GetGlobalAA().debug then : m.DrawColliders(object) : end if
			' if GetGlobalAA().debug then love.graphics.print(tostring(image.depth), object.x-100, object.y-100) end
		end for

		if GetGlobalAA().debug then : m.screen.DrawText("FPS: "+m.FPS.ToStr(), 10, 10, &hFFFFFFFF, m.Fonts.default) : end if
		m.screen.SwapBuffers()
		m.screen.Clear(&h000000FF)
	end function

	' ############### Update() function - End ###############



	' ############### DrawColliders() function - Begin ###############

	gameEngine.DrawColliders = function(object)
		for each collider_key in object.colliders
			collider = object.colliders[collider_key]
			if collider.enabled then
				if collider.type = "circle" then
					' This function is slow as I'm making draw calls for every section of the line.
					' It's for debugging purposes only!
					DrawCircle(m.screen, 100, object.x+collider.offset_x, object.y+collider.offset_y, collider.radius, &hFF0000FF)
				end if
				if collider.type = "rectangle" then
					m.screen.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y, 1, collider.height, &hFF0000FF)
					m.screen.DrawRect(object.x+collider.offset_x+collider.width-1, object.y+collider.offset_y, 1, collider.height, &hFF0000FF)
					m.screen.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y, collider.width, 1, &hFF0000FF)
					m.screen.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y+collider.height-1, collider.width, 1, &hFF0000FF)
				end if
			end if
		end for
	end function

	' ############### DrawColliders() function - End ###############



	' ############### newObject() function - Begin ###############

	gameEngine.newObject = function(name = "")
		m.currentID = m.currentID + 1
		new_object = {
			name: name,
			id: m.currentID.ToStr(),
			' -----This line is so every game object can easily access the gameEngine component
			gameEngine: m
			' -----
			depth: 0,
			x: 0,
			y: 0,
	        colliders: {},
	        images: [],
			data: {}
		}

		' These empty functions are placeholders, they are to be overwritten by the user
		new_object.onCollision = function(collider_name, other_collider_name, other_object)
		end function

		new_object.onUpdate = function(dt)
		end function

		new_object.onDrawBegin = function(screen)
		end function

		new_object.onDrawEnd = function(screen)
		end function

		new_object.onButton = function(button)
			' -------Button Code Reference--------
			' Button  When pressed  When released

			' Back  0  100
			' Up  2  102
			' Down  3  103
			' Left  4  104
			' Right  5  105
			' Select  6  106
			' Instant Replay  7  107
			' Rewind  8  108
			' Fast  Forward  9  109
			' Info  10  110
			' Play  13  113
		end function

		new_object.onDestroy = function()
		end function


		new_object.addColliderCircle = function(name, radius, offset_x = 0, offset_y = 0, enabled = true)
			collider = {
				type: "circle",
				enabled: enabled,
				radius: radius,
				offset_x: offset_x,
				offset_y: offset_y,
			}
			if m.colliders[name] = invalid then : m.colliders[name] = collider : else : print "Collider Name Already Exists" : end if
		end function

		new_object.addColliderRectangle = function(name, width, height, offset_x = 0, offset_y = 0, enabled = true)
			collider = {
				type: "rectangle",
				enabled: enabled,
				offset_x: offset_x,
				offset_y: offset_y,
				width: width,
				height: height,
			}
			if m.colliders[name] = invalid then : m.colliders[name] = collider : else : print "Collider Name Already Exists" : end if
		end function

		new_object.removeCollider = function(name)
			if m.colliders[name] <> invalid then : m.colliders[name] = invalid : else : print "Collider Doesn't Exist" : end if
		end function

		new_object.addImage = function(image, scale_x = 1, scale_y = 1, offset_x = 0, offset_y = 0, origin_x = 0, origin_y = 0, rgba = &hFFFFFFFF, enabled = true)
			image = {
				image: image,
				offset_x: offset_x,
				offset_y: offset_y,
				origin_x: origin_x,
				origin_y: origin_y,
				scale_x: scale_x,
				scale_y: scale_y,
				rgba: rgba,
				enabled: enabled
			}
			m.images.push(image)
		end function

		new_object.removeImage = function(index)
			if m.images[index] <> invalid then : m.images.Delete(index) : else : print "Position In Image Array Is Invalid" : end if
		end function

		if GetGlobalAA().debug then : print "Adding Object: "+new_object.id : end if
		m.objectHolder[new_object.id] = new_object

		return new_object
	end function

	' ############### newObject() function - End ###############



	' ############### removeObject() function - Begin ###############
	gameEngine.removeObject = function(object_id)
		if GetGlobalAA().debug then : print "Removing Object: "+object_id : end if
		if m.objectHolder.DoesExist(object_id) then
			m.objectHolder[object_id].onDestroy()
			m.objectHolder.Delete(object_id)
		end if
	end function
	' ############### removeObject() function - End ###############



	' ############### changeRoom() function - Begin ###############
	gameEngine.changeRoom = function(room)
		if m.Rooms[room] <> invalid then
			if m.current_room <> invalid then 
				m.removeObject(m.current_room.id)
			end if
			empty_room = m.newObject("room")
			m.current_room = m.Rooms[room](empty_room)
		end if
	end function
	' ############### changeRoom() function - End ###############



	' ############### addRoom() function - Begin ###############
	gameEngine.addRoom = function(room_name, room_creation_function)
		m.Rooms[room_name] = room_creation_function
		print "Room function has been added"
	end function
	' ############### addRoom() function - Begin ###############

	' ############### loadBitmap() function - Begin ###############
	gameEngine.loadBitmap = function(name, path)
		m.Bitmaps[name] = CreateObject("roBitmap", path)
		print "Loaded bitmap from " ; path
	end function
	' ############### loadBitmap() function - End ###############

	' ############### getBitmap() function - Begin ###############
	gameEngine.getBitmap = function(name)
		return m.Bitmaps[name]
	end function
	' ############### getBitmap() function - End ###############

	' ############### unloadBitmap() function - Begin ###############
	gameEngine.unloadBitmap = function(name)
		m.Bitmaps[name] = invalid
	end function
	' ############### unloadBitmap() function - End ###############

	' ############### getFont() function - Begin ###############
	gameEngine.getFont = function(name)
		return m.Fonts[name]
	end function
	' ############### getFont() function - End ###############

	' ############### removeFont() function - Begin ###############
	gameEngine.removeFont = function(name)
		m.Fonts[name] = invalid
	end function
	' ############### removeFont() function - End ###############

	return gameEngine
end function


' ------------------------Collision Functions------------------------

function gameEngine_collisionRectRect(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end function

function gameEngine_collisionCircleCircle(x1,y1,r1, x2,y2,r2)
	dist = Sqr((x1 - x2)^2 + (y1 - y2)^2)
	return dist <= r1 + r2
end function

function gameEngine_collisionCircleRect( cx, cy, cr, rx, ry, rw, rh )
	circle_distance_x = Abs(cx - rx - rw/2)
	circle_distance_y = Abs(cy - ry - rh/2)

	if circle_distance_x > (rw/2 + cr) or circle_distance_y > (rh/2 + cr) then
		return false
	elseif circle_distance_x <= (rw/2) or circle_distance_y <= (rh/2) then
		return true
	end if

	return ((circle_distance_x - rw/2)^2 + (circle_distance_y - rh/2)^2) <= cr^2
end function




' -----------------------Other Utilities---------------------------

function ArrayInsert(array, index, value)
	for i = array.Count() to index+1 step -1
		array[i] = array[i-1]
	end for
	array[index] = value
	return array
end function

function DrawCircle(draw2d, line_count, x, y, radius, color)
	previous_x = radius
	previous_y = 0
	for i = 0 to line_count
		degrees = 360*(i/line_count)
		current_x = cos(degrees*.01745329)*radius
		current_y = sin(degrees*.01745329)*radius
		draw2d.DrawLine(x+previous_x, y+previous_y, x+current_x, y+current_y, color)
		previous_x = current_x
		previous_y = current_y
	end for
end function

function atan2(y, x)
    if x > 0
        collision_angle = Atn(y/x)
    else if y >= 0 and x < 0
        collision_angle = Atn(y/x)+3.14159265359
    else if y < 0 and x < 0
        collision_angle = Atn(y/x)-3.14159265359
    else if y > 0 and x = 0
        collision_angle = 3.14159265359/2
    else if y < 0 and x = 0
        collision_angle = (3.14159265359/2)*-1
    else
        collision_angle = 0
    end if
    
    return collision_angle
end function