' -------------------------Function To Create Main Game Engine Object------------------------

function gameEngine_init(game_width, game_height, debug = false)
	
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
		device: CreateObject("roDeviceInfo")
		compositor: CreateObject("roCompositor")
		screen: invalid
		port: CreateObject("roMessagePort")
		font_registry: CreateObject("roFontRegistry")
		frame: CreateObject("roBitmap", {width: game_width, height: game_height, AlphaEnable: true})
		camera: {
			offset_x: 0
			offset_y: 0
			scale_x: 1.0
			scale_y: 1.0
			follow: invalid
			follow_mode: 0
		}
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
	UIResolution = gameEngine.device.getUIResolution()
	gameEngine.screen = CreateObject("roScreen", true, UIResolution.width, UIResolution.height)
	gameEngine.compositor.SetDrawTo(gameEngine.screen, &h00000000)

	' Set up the screen
	gameEngine.screen.SetMessagePort(gameEngine.port)
	gameEngine.screen.SetAlphaEnable(true)

	' Create the default font
	gameEngine.Fonts["default"] = gameEngine.font_registry.GetDefaultFont(28, false, false)

	' ############### Create Initial Object - End ###############





	' ################################################################ Update() function - Begin #####################################################################################################
	gameEngine.Update = function()
		m.compositor.Draw() ' For some reason this has to be called or the colliders don't remove themselves from the compositor ¯\(°_°)/¯
		m.screen.Clear(&h000000FF) 
		m.frame.Clear(&h000000FF) 


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


			' -------------------- Then handle the object movement--------------------
			object.x = object.x + object.xspeed*dt
			object.y = object.y + object.yspeed*dt


			' -------------------- Then handle image animation------------------------
			for each image_object in object.images
				if image_object.image_count > 1 then
					image_animation_timing = image_object.animation_timer.TotalMilliseconds()/(image_object.animation_speed*(image_object.animation_position+1))*image_object.image_count
					if image_animation_timing >= 1 then
						image_object.animation_position = image_object.animation_position+image_animation_timing
						if image_object.animation_position > image_object.image_count then
							image_object.animation_position = 0
							image_object.animation_timer.Mark()
						end if
						image_width = image_object.image.GetWidth()
						region_position = int(image_object.animation_position)
						region_width = image_object.region.GetWidth()
						region_height = image_object.region.GetHeight()

						y_offset = region_position*region_width \ image_width
						x_offset = region_position*region_width-image_width*y_offset
						image_object.region = CreateObject("roRegion", image_object.image, x_offset, y_offset*region_height, region_width, region_height)
					end if
				end if
			end for


			' --------------------------Add object to the appropriate position in the draw_depths array-----------------
			if draw_depths.Count() > 0 then
				inserted = false
				for i = draw_depths.Count()-1 to 0 step -1
					if not inserted and object.depth > draw_depths[i].depth then
						ArrayInsert(draw_depths, i+1, object)
						inserted = true
						exit for
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
			object.onDrawBegin(m.frame)
			for each image in object.images
				if image.enabled then
					m.frame.DrawScaledObject(object.x+image.offset_x-(image.origin_x*image.scale_x), object.y+image.offset_y-(image.origin_y*image.scale_y), image.scale_x, image.scale_y, image.region, image.rgba)
				end if
			end for
			object.onDrawEnd(m.frame)
			' if GetGlobalAA().debug then : m.DrawColliders(object) : end if
		end for


		' --------------------Then do camera magic if it's set to follow and object----------------------------
		if m.camera.follow <> invalid
			if type(m.camera.follow) = "roAssociativeArray" and m.objectHandler.DoesExist(m.camera.follow.id)
				m.cameraCenterToObject(m.camera.follow)
			else
				m.camera.follow = invalid
			end if
		end if


		if true then : m.frame.DrawText("FPS: "+m.FPS.ToStr(), 10, 10, &hFFFFFFFF, m.Fonts.default) : end if
		m.screen.DrawScaledObject(m.camera.offset_x, m.camera.offset_y, m.camera.scale_x, m.camera.scale_y, m.frame)
		m.screen.SwapBuffers()


	end function
	' ################################################################ Update() function - End #####################################################################################################



	' ################################################################ newObject() function - Begin #####################################################################################################
	gameEngine.newObject = function(name = "")
		m.currentID = m.currentID + 1
		new_object = {
			' -----These variables should be considered off limits
			name: name,
			id: m.currentID.ToStr(),
			gameEngine: m
			' -----
			depth: 0,
			x: 0,
			y: 0,
			xspeed: 0,
			yspeed: 0,
	        colliders: {},
	        images: [],
		}

		' These empty functions are placeholders, they are to be overwritten by the user
		new_object.onCreate = function()
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
			image_object = {
				image: image,
				region: invalid
				offset_x: offset_x,
				offset_y: offset_y,
				origin_x: origin_x,
				origin_y: origin_y,
				scale_x: scale_x,
				scale_y: scale_y,
				rgba: rgba,
				enabled: enabled
				animation_speed: 0
				animation_timer: CreateObject("roTimespan")
				animation_position: 0
				image_count: 1
			}
			if type(image) = "roRegion" then 
				image_object.region = image
			else
				image_object.region = CreateObject("roRegion", image, 0, 0, image.GetWidth(), image.GetHeight())
			end if
			m.images.push(image_object)
		end function

		new_object.addAnimatedImage = function(image_sheet, image_width, image_height, image_count, animation_speed, scale_x = 1, scale_y = 1, offset_x = 0, offset_y = 0, origin_x = 0, origin_y = 0, rgba = &hFFFFFFFF, enabled = true)
			image = {
				image: image_sheet,
				region: CreateObject("roRegion", image_sheet, 0, 0, image_width, image_height)
				offset_x: offset_x,
				offset_y: offset_y,
				origin_x: origin_x,
				origin_y: origin_y,
				scale_x: scale_x,
				scale_y: scale_y,
				rgba: rgba,
				enabled: enabled
				animation_speed: animation_speed
				animation_timer: CreateObject("roTimespan")
				animation_position: 0
				image_count: image_count
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
	' ################################################################ newObject() function - End #####################################################################################################



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
					m.frame.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y, 1, collider.height, &hFF0000FF)
					m.frame.DrawRect(object.x+collider.offset_x+collider.width-1, object.y+collider.offset_y, 1, collider.height, &hFF0000FF)
					m.frame.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y, collider.width, 1, &hFF0000FF)
					m.frame.DrawRect(object.x+collider.offset_x, object.y+collider.offset_y+collider.height-1, collider.width, 1, &hFF0000FF)
				end if
			end if
		end for
	end function
	' ############### DrawColliders() function - End ###############



	' ############### addObject() function - Begin ###############
	gameEngine.addObject = function(object_name, object_creation_function)
		m.Objects[object_name] = object_creation_function
	end function
	' ############### addObject() function - End ###############



	' ############### spawnObject() function - Begin ###############
	gameEngine.spawnObject = function(object_name, args = {})
		if m.Objects.DoesExist(object_name)
			new_object = m.newObject(object_name)
			m.Objects[object_name](new_object)
			for each key in args
				new_object[key] = args[key]
			end for
			new_object.onCreate()
			return new_object
		else
			print "No objects registered with the name - " ; object_name
		end if
	end function
	' ############### spawnObject() function - End ###############



	' ############### removeObject() function - Begin ###############
	gameEngine.removeObject = function(object)
		object_id = object.id
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
				m.removeObject(m.currentRoom)
			end if
			m.currentRoom = invalid
			m.currentRoom = m.newObject("room")
			m.Rooms[room_name](m.currentRoom)
			for each key in args
				m.currentRoom[key] = args[key]
			end for
			m.currentRoom.onCreate()
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


	' --------------------------------Begin Camera Functions----------------------------------------


	' ############### cameraIncreaseOffset() function - Begin ###############
	gameEngine.cameraIncreaseOffset = function(x, y)
		m.camera.offset_x = m.camera.offset_x + x
		m.camera.offset_y = m.camera.offset_y + y
	end function
	' ############### cameraIncreaseOffset() function - End ###############



	' ############### cameraIncreaseZoom() function - Begin ###############
	gameEngine.cameraIncreaseZoom = function(scale_x, scale_y = -999)
		if scale_y = -999
			scale_y = scale_x
		end if
		m.camera.scale_x = m.camera.scale_x + scale_x
		m.camera.scale_y = m.camera.scale_y + scale_y
		if m.camera.scale_x < 0 then : m.camera.scale_x = 0 : end if
		if m.camera.scale_y < 0 then : m.camera.scale_y = 0 : end if
	end function
	' ############### cameraIncreaseZoom() function - End ###############



	' ############### cameraSetOffset() function - Begin ###############
	gameEngine.cameraSetOffset = function(x, y)
		m.camera.offset_x = x
		m.camera.offset_y = y
	end function
	' ############### cameraSetOffset() function - End ###############



	' ############### cameraSetZoom() function - Begin ###############
	gameEngine.cameraSetZoom = function(scale_x, scale_y = -999)
		if scale_y = -999
			scale_y = scale_x
		end if
		m.camera.scale_x = scale_x
		m.camera.scale_y = scale_y
	end function
	' ############### cameraSetZoom() function - End ###############



	' ############### cameraSetFollow() function - Begin ###############
	gameEngine.cameraSetFollow = function(game_object, mode = 0)
		m.camera.follow = game_object
		m.camera.follow_mode = mode
	end function
	' ############### cameraSetFollow() function - End ###############



	' ############### cameraUnsetFollow() function - Begin ###############
	gameEngine.cameraUnsetFollow = function()
		m.camera.follow = invalid
	end function
	' ############### cameraUnsetFollow() function - End ###############



	' ############### cameraFitToScreen() function - Begin ###############
	gameEngine.cameraFitToScreen = function()
		frame_width = m.frame.GetWidth()
		frame_height = m.frame.GetHeight()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()
		if screen_width/screen_height < frame_width/frame_height then
			m.camera.scale_x = screen_width/frame_width
			m.camera.scale_y = m.camera.scale_x
			m.camera.offset_x = 0
			m.camera.offset_y = (screen_height-(screen_width/(frame_width/frame_height)))/2
		else if screen_width/screen_height > frame_width/frame_height then
			m.camera.scale_x = screen_height/frame_height
			m.camera.scale_y = m.camera.scale_x
			m.camera.offset_x = (screen_width-(screen_height*(frame_width/frame_height)))/2
			m.camera.offset_y = 0
		else
			m.camera.offset_x = 0
			m.camera.offset_y = 0
			m.camera.scale_x = 1
			m.camera.scale_y = 1
		end if
	end function
	' ############### cameraFitToScreen() function - End ###############



	' ############### cameraCenterToObject() function - Begin ###############
	gameEngine.cameraCenterToObject = function(game_object)
		frame_width = m.frame.GetWidth()
		frame_height = m.frame.GetHeight()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()

		offset_x = 0-game_object.x*m.camera.scale_x+m.screen.GetWidth()/2
		offset_y = 0-game_object.y*m.camera.scale_y+screen_height/2

		if m.camera.follow_mode = 0
			minimum_offset_x = -((frame_width*m.camera.scale_x)-screen_width)
			minimum_offset_y = -((frame_height*m.camera.scale_y)-screen_height)

			if offset_x >= minimum_offset_x and offset_x <= 0
				m.camera.offset_x = offset_x
			else if not offset_x >= minimum_offset_x
				m.camera.offset_x = minimum_offset_x
			else if not offset_x <= 0 
				m.camera.offset_x = 0
			end if

			if offset_y >= minimum_offset_y and offset_y <=0
				m.camera.offset_y = offset_y
			else if not offset_y >= minimum_offset_y
				m.camera.offset_y = minimum_offset_y
			else if not offset_y <= 0
				m.camera.offset_y = 0
			end if
		else if m.camera.follow_mode = 1
			m.camera.offset_x = offset_x
			m.camera.offset_y = offset_y
		end if


		if frame_width*m.camera.scale_x < screen_width
			m.camera.offset_x = (screen_width-frame_width*m.camera.scale_x)/2
		end if

		if frame_height*m.camera.scale_y < screen_height
			m.camera.offset_y = (screen_height-frame_height*m.camera.scale_y)/2
		end if


	end function
	' ############### cameraCenterToObject() function - End ###############



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