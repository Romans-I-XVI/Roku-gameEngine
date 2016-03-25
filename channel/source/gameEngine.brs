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
		empty_bitmap: CreateObject("roBitmap", {width: 1, height: 1, AlphaEnable: false})
		compositor: CreateObject("roCompositor")
		screen: CreateObject("roScreen", true, screen_width, screen_height)
		port: CreateObject("roMessagePort")
		font_registry: CreateObject("roFontRegistry")
		' ****END - For Internal Use, Do Not Manually Alter****

		' ****Variables****
		currentRoom: invalid
		objectHandler: {}
		Objects: {}
		Rooms: {}
		Bitmaps: {}
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
	gameEngine.compositor.SetDrawTo(gameEngine.screen, &h00000000)

	' Set up the screen
	gameEngine.screen.SetMessagePort(gameEngine.port)
	gameEngine.screen.SetAlphaEnable(true)

	' Create the default font
	gameEngine.Fonts["default"] = gameEngine.font_registry.GetDefaultFont(28, false, false)

	' ############### Create Initial Object - End ###############





	' ############### Update() function - Begin ###############

	gameEngine.Update = function()
		m.compositor.Draw() ' For some reason this has to be called or the colliders don't remove themselves from the compositor *shrug*
		m.screen.Clear(&h000000FF) 


		dt = m.dtTimer.TotalMilliseconds()/1000
		m.dtTimer.Mark()
        msg = m.port.GetMessage() 
		draw_depths = []
		m.fpsTicker = m.fpsTicker + 1
		if m.fpsTimer.TotalMilliseconds() > 1000 then
			m.FPS = m.fpsTicker
			m.fpsTicker = 0
			m.fpsTimer.Mark()
		end if

		' --------------------Begin giant loop for processing all game objects----------------
		for each object_key in m.objectHandler
			object = m.objectHandler[object_key]
			if object.creation_args <> invalid and type(object.creation_args) = "roAssociativeArray"
				if object.creation_args.DoesExist("x") then : object.x = object.creation_args.x : end if
				if object.creation_args.DoesExist("y") then : object.y = object.creation_args.y : end if
				if object.creation_args.DoesExist("depth") then : object.depth = object.creation_args.depth : end if
				if object.creation_args.DoesExist("data") then : object.data = object.creation_args.data : end if
				object.onCreate(object.creation_args)
				object.creation_args = invalid
			end if


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


			' -------------------Then handle collisions and call onCollision() for each collision---------------------------
			for each collider_key in object.colliders
				collider = object.colliders[collider_key]
				if collider.enabled then
					collider.compositor_object.SetMemberFlags(1)
					collider.compositor_object.SetCollidableFlags(1)
					if collider.type = "circle" then
						collider.compositor_object.GetRegion().SetCollisionCircle(collider.offset_x, collider.offset_y, collider.radius)
					else if collider.type = "rectangle" then
						collider.compositor_object.GetRegion().SetCollisionRectangle(collider.offset_x, collider.offset_y, collider.width, collider.height)
					end if
					collider.compositor_object.MoveTo(object.x, object.y)
					multiple_collisions = collider.compositor_object.CheckMultipleCollisions()
					if multiple_collisions <> invalid
						for each other_collider in multiple_collisions
							other_collider_data = other_collider.GetData()
							if m.objectHandler.DoesExist(other_collider_data.object_id)
								object.onCollision(collider_key, other_collider_data.collider_name, m.objectHandler[other_collider_data.object_id])
							end if
						end for
					end if
				else
					collider.compositor_object.SetMemberFlags(99)
					collider.compositor_object.SetCollidableFlags(99)
				end if
			end for


			' --------------------------Add object to the appropriate position in the draw_depths array-----------------
			if draw_depths.Count() > 0 then
				inserted = false
				for i = draw_depths.Count()-1 to 0 step -1
					if not inserted and object.depth > draw_depths[i].depth then
						ArrayInsert(draw_depths, i+1, object)
						inserted = true
					end if
					exit for
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
			' if GetGlobalAA().debug then : m.DrawColliders(object) : end if
		end for

		if GetGlobalAA().debug then : m.screen.DrawText("FPS: "+m.FPS.ToStr(), 10, 10, &hFFFFFFFF, m.Fonts.default) : end if
		m.screen.SwapBuffers()


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

	gameEngine.newObject = function(name = "", args = {})
		m.currentID = m.currentID + 1
		new_object = {
			name: name,
			id: m.currentID.ToStr(),
			creation_args: args
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
		new_object.onCreate = function(args)
		end function

		new_object.onCollision = function(collider, other_collider, other_object)
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
				compositor_object: invalid
			}
			region = CreateObject("roRegion", m.gameEngine.empty_bitmap, 0, 0, 1, 1)
			region.SetCollisionType(2)
			region.SetCollisionCircle(offset_x, offset_y, radius)
			collider.compositor_object = m.gameEngine.compositor.NewSprite(m.x, m.y, region)
			collider.compositor_object.SetDrawableFlag(false)
			collider.compositor_object.SetData({collider_name: name, object_id: m.id})
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
				compositor_object: invalid
			}
			region = CreateObject("roRegion", m.gameEngine.empty_bitmap, 0, 0, 1, 1)
			region.SetCollisionType(1)
			region.SetCollisionRectangle(offset_x, offset_y, width, height)
			collider.compositor_object = m.gameEngine.compositor.NewSprite(m.x, m.y, region)
			collider.compositor_object.SetDrawableFlag(false)
			collider.compositor_object.SetData({collider_name: name, object_id: m.id})
			if m.colliders[name] = invalid then : m.colliders[name] = collider : else : print "Collider Name Already Exists" : end if
		end function

		new_object.removeCollider = function(name)
			if m.colliders[name] <> invalid then
				if type(m.colliders[name].compositor_object) = "roSprite" then : m.colliders[name].compositor_object.Remove() : end if
				m.colliders[name] = invalid
			else
				print "Collider Doesn't Exist" 
			end if
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
		m.objectHandler[new_object.id] = new_object

		return new_object
	end function

	' ############### newObject() function - End ###############


	' ############### addObject() function - Begin ###############
	gameEngine.addObject = function(object_name, object_creation_function)
		m.Objects[object_name] = object_creation_function
	end function
	' ############### addObject() function - End ###############


	' ############### spawnObject() function - Begin ###############
	gameEngine.spawnObject = function(object_name, args = {})
		if m.Objects.DoesExist(object_name)
			new_object = m.newObject(object_name, args)
			m.Objects[object_name](new_object)
			return new_object
		else
			print "No objects registered with the name - " ; object_name
		end if
	end function
	' ############### spawnObject() function - End ###############


	' ############### removeObject() function - Begin ###############
	gameEngine.removeObject = function(object_id)
		if GetGlobalAA().debug then : print "Removing Object: "+object_id : end if
		if m.objectHandler.DoesExist(object_id) then
			for each collider_key in m.objectHandler[object_id].colliders
				collider = m.objectHandler[object_id].colliders[collider_key]
				if type(collider.compositor_object) = "roSprite" then 
					if GetGlobalAA().debug then : print "Removing Collider: "+collider_key : end if
					collider.compositor_object.Remove()
				end if
			end for
			m.objectHandler[object_id].onDestroy()
			m.objectHandler.Delete(object_id)
		end if
	end function
	' ############### removeObject() function - End ###############


	' ############### listObjects() function - Begin ###############
	gameEngine.listObjects = function()
		objects_list = []
		for each key in m.Objects
			objects_list.Push(key)
		end for
		return objects_list	
	end function
	' ############### listObjects() function - End ###############




	' ############### changeRoom() function - Begin ###############
	gameEngine.changeRoom = function(room_name, args = {})
		if m.Rooms[room_name] <> invalid then
			if m.currentRoom <> invalid then 
				m.removeObject(m.currentRoom.id)
			end if
			m.currentRoom = invalid
			m.currentRoom = m.newObject("room", args)
			m.Rooms[room_name](m.currentRoom)
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
	dist = (x1 - x2)^2 + (y1 - y2)^2
	return dist <= r1^2 + r2^2
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