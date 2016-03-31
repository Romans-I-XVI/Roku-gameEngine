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
		filesystem: CreateObject("roFileSystem")
		screen_port: CreateObject("roMessagePort")
		audioplayer: CreateObject("roAudioPlayer")
		music_port: CreateObject("roMessagePort")
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
		Instances: {} ' This holds all of the game object instances
		Objects: {} ' This holds the object definitions by name (the object creation functions)
		Rooms: {} ' This holds the room definitions by name (the room creation functions)
		Bitmaps: {} ' This holds the loaded bitmaps by name
		Sounds: {} ' This holds the loaded sounds by name
		Fonts: {} ' This holds the loaded fonts by name

		' These are just placeholder reminders of what functions get added to the gameEngine
		' ****Functions****
		Update: invalid
		newEmptyObject: invalid
		drawColliders: invalid

		defineObject: invalid
		createInstance: invalid
		getInstanceByID: invalid
		getInstanceByName: invalid
		getAllInstances: invalid
		destroyInstance: invalid
		destroyAllInstances: invalid
		instanceCount: invalid

		defineRoom: invalid
		changeRoom: invalid

		loadBitmap: invalid
		getBitmap: invalid
		unloadBitmap: invalid

		registerFont: invalid
		loadFont: invalid
		unloadFont: invalid
		getFont: invalid

		cameraIncreaseOffset: invalid
		cameraIncreaseZoom: invalid
		cameraSetOffset: invalid
		cameraSetZoom: invalid
		cameraSetFollow: invalid
		cameraUnsetFollow: invalid
		cameraFitToScreen: invalid
		cameraCenterToInstance: Invalid

		musicPlay: invalid
		musicStop: invalid
		musicPause: invalid
		musicResume: invalid

		addSound: invalid
		playSound: invalid

	}

	' Set up the screen
	UIResolution = gameEngine.device.getUIResolution()
	gameEngine.screen = CreateObject("roScreen", true, UIResolution.width, UIResolution.height)
	gameEngine.compositor.SetDrawTo(gameEngine.screen, &h00000000)
	gameEngine.screen.SetMessagePort(gameEngine.screen_port)
	gameEngine.screen.SetAlphaEnable(true)

	' Set up the audioplayer
	gameEngine.audioplayer.SetMessagePort(gameEngine.music_port)

	' Register all fonts in package
	ttfs_in_package = gameEngine.filesystem.FindRecurse("pkg:/fonts/", ".ttf")
	otfs_in_package = gameEngine.filesystem.FindRecurse("pkg:/fonts/", ".otf")
	for each font_path in ttfs_in_package
		gameEngine.font_registry.Register(font_path)
	end for
	for each font_path in otfs_in_package
		gameEngine.font_registry.Register(font_path)
	end for

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
        screen_msg = m.screen_port.GetMessage() 
        music_msg = m.music_port.GetMessage()
		draw_depths = []
		m.fpsTicker = m.fpsTicker + 1
		if m.fpsTimer.TotalMilliseconds() > 1000 then
			m.FPS = m.fpsTicker
			m.fpsTicker = 0
			m.fpsTimer.Mark()
		end if


		' --------------------Begin giant loop for processing all game objects----------------
		for each instance_key in m.Instances
			instance = m.Instances[instance_key]

			
			' -------------------- Then handle the object movement--------------------
			instance.x = instance.x + instance.xspeed*dt
			instance.y = instance.y + instance.yspeed*dt


			' --------------------First process the onButton() function--------------------
	        if type(screen_msg) = "roUniversalControlEvent" then
	        	instance.onButton(screen_msg.GetInt())
	        	if screen_msg.GetInt() < 100
	        		m.buttonHeld = screen_msg.GetInt()
	        	else
	        		m.buttonHeld = -1
	        	end if
	        end if
	        if m.buttonHeld <> -1 then
	        	' Button release codes are 100 plus the button press code
	        	' This shows a button held code as 1000 plus the button press code
	        	instance.onButton(1000+m.buttonHeld)
	        end if


	        ' -------------------Then send the audioplayer event msg if applicable-------------------
	        if type(music_msg) = "roAudioPlayerEvent" then
	        	instance.onAudioEvent(music_msg)
	        end if


	        ' -------------------Then process the onUpdate() function----------------------
			instance.onUpdate(dt)


			' -------------------Then handle collisions and call onCollision() for each collision---------------------------
			for each collider_key in instance.colliders
				collider = instance.colliders[collider_key]
				if collider.enabled then
					collider.compositor_object.SetMemberFlags(1)
					collider.compositor_object.SetCollidableFlags(1)
					if collider.type = "circle" then
						collider.compositor_object.GetRegion().SetCollisionCircle(collider.offset_x, collider.offset_y, collider.radius)
					else if collider.type = "rectangle" then
						collider.compositor_object.GetRegion().SetCollisionRectangle(collider.offset_x, collider.offset_y, collider.width, collider.height)
					end if
					collider.compositor_object.MoveTo(instance.x, instance.y)
					multiple_collisions = collider.compositor_object.CheckMultipleCollisions()
					if multiple_collisions <> invalid
						for each other_collider in multiple_collisions
							other_collider_data = other_collider.GetData()
							if m.Instances.DoesExist(other_collider_data.instance_id)
								instance.onCollision(collider_key, other_collider_data.collider_name, m.Instances[other_collider_data.instance_id])
							end if
						end for
					end if
				else
					collider.compositor_object.SetMemberFlags(99)
					collider.compositor_object.SetCollidableFlags(99)
				end if
			end for


			' -------------------- Then handle image animation------------------------
			for each image_object in instance.images
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
					if not inserted and instance.depth > draw_depths[i].depth then
						ArrayInsert(draw_depths, i+1, instance)
						inserted = true
						exit for
					end if
				end for
				if not inserted then
					draw_depths.Unshift(instance)
				end if
			else
				draw_depths.Unshift(instance)
			end if
		end for


		' ----------------------Then draw all of the instances and call onDrawBegin() and onDrawEnd()-------------------------
		for i = draw_depths.Count()-1 to 0 step -1
			instance = draw_depths[i]
			instance.onDrawBegin(m.frame)
			for each image in instance.images
				if image.enabled then
					m.frame.DrawScaledObject(instance.x+image.offset_x-(image.origin_x*image.scale_x), instance.y+image.offset_y-(image.origin_y*image.scale_y), image.scale_x, image.scale_y, image.region, image.rgba)
				end if
			end for
			instance.onDrawEnd(m.frame)
			' if GetGlobalAA().debug then : m.DrawColliders(instance) : end if
		end for


		' --------------------Then do camera magic if it's set to follow----------------------------
		if m.camera.follow <> invalid
			if m.camera.follow.id <> invalid and m.Instances.DoesExist(m.camera.follow.id)
				m.cameraCenterToInstance(m.camera.follow)
			else
				m.camera.follow = invalid
			end if
		end if


		if true then : m.frame.DrawText("FPS: "+m.FPS.ToStr(), 10, 10, &hFFFFFFFF, m.Fonts.default) : end if
		m.screen.DrawScaledObject(m.camera.offset_x, m.camera.offset_y, m.camera.scale_x, m.camera.scale_y, m.frame)
		m.screen.SwapBuffers()


	end function
	' ################################################################ Update() function - End #####################################################################################################



	' ################################################################ newEmptyObject() function - Begin #####################################################################################################
	gameEngine.newEmptyObject = function(name)
		m.currentID = m.currentID + 1
		new_object = {
			' -----These variables should be considered off limits
			name: name
			id: m.currentID.ToStr()
			persistent: false
			gameEngine: m
			' -----
			depth: 0
			x: 0.0
			y: 0.0
			xspeed: 0.0
			yspeed: 0.0
	        colliders: {}
	        images: []
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

		new_object.onAudioEvent = function(msg)
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
			collider.compositor_object.SetData({collider_name: name, instance_id: m.id})
			if m.colliders[name] = invalid then : m.colliders[name] = collider : else : print "Collider Name Already Exists" : end if
		end function

		new_object.addColliderRectangle = function(name, offset_x, offset_y, width, height, enabled = true)
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
			collider.compositor_object.SetData({collider_name: name, instance_id: m.id})
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

		new_object.addImage = function(image, offset_x = 0, offset_y = 0, origin_x = 0, origin_y = 0, scale_x = 1, scale_y = 1, rgba = &hFFFFFFFF, enabled = true)
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

		if GetGlobalAA().debug then : print "Creating instance - "+new_object.id : end if
		m.Instances[new_object.id] = new_object

		return new_object
	end function
	' ################################################################ newEmptyObject() function - End #####################################################################################################



	' ############### DrawColliders() function - Begin ###############
	gameEngine.drawColliders = function(instance)
		for each collider_key in instance.colliders
			collider = instance.colliders[collider_key]
			if collider.enabled then
				if collider.type = "circle" then
					' This function is slow as I'm making draw calls for every section of the line.
					' It's for debugging purposes only!
					DrawCircle(m.screen, 100, instance.x+collider.offset_x, instance.y+collider.offset_y, collider.radius, &hFF0000FF)
				end if
				if collider.type = "rectangle" then
					m.frame.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y, 1, collider.height, &hFF0000FF)
					m.frame.DrawRect(instance.x+collider.offset_x+collider.width-1, instance.y+collider.offset_y, 1, collider.height, &hFF0000FF)
					m.frame.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y, collider.width, 1, &hFF0000FF)
					m.frame.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y+collider.height-1, collider.width, 1, &hFF0000FF)
				end if
			end if
		end for
	end function
	' ############### DrawColliders() function - End ###############


	' --------------------------------Begin Object Functions----------------------------------------


	' ############### defineObject() function - Begin ###############
	gameEngine.defineObject = function(object_name, object_creation_function)
		m.Objects[object_name] = object_creation_function
	end function
	' ############### defineObject() function - End ###############



	' ############### createInstance() function - Begin ###############
	gameEngine.createInstance = function(object_name, args = {})
		if m.Objects.DoesExist(object_name)
			new_instance = m.newEmptyObject(object_name)
			m.Objects[object_name](new_instance)
			for each key in args
				new_instance[key] = args[key]
			end for
			new_instance.onCreate()
			return new_instance
		else
			print "createInstance() - No objects registered with the name - " ; object_name
			return invalid
		end if
	end function
	' ############### createInstance() function - End ###############



	' ############### getInstanceByID() function - Begin ###############
	gameEngine.getInstanceByID = function(instance_id)
		if m.Instances.DoesExist(instance_id) then
			return m.Instances[instance_id]
		else
			print "getInstanceByID() - No instance exists with id - " ; instance_id
			return invalid
		end if
	end function
	' ############### getInstanceByID() function - End ###############



	' ############### getInstanceByName() function - Begin ###############
	gameEngine.getInstanceByName = function(object_name)
		for each instance_key in m.Instances
			if m.Instances[instance_key].name = object_name then
				return m.Instances[instance_key]
			end if
		end for
		print "getInstanceByName() - No instance exists with name - " ; object_name
		return invalid
	end function
	' ############### getInstanceByName() function - End ###############



	' ############### getAllInstances() function - Begin ###############
	gameEngine.getAllInstances = function(object_name)
		array = []
		for each instance_key in m.Instances
			instance = m.Instances[instance_key]
			if instance.name = object_name then
				array.Push(instance)
			end if
		end for
		return array
	end function
	' ############### getAllInstances() function - Begin ###############



	' ############### destroyInstance() function - Begin ###############
	gameEngine.destroyInstance = function(instance)
				
		if GetGlobalAA().debug then : print "Removing Instance: "+instance.id : end if
		if instance.id <> invalid and m.Instances.DoesExist(instance.id) then
			for each collider_key in instance.colliders
				collider = instance.colliders[collider_key]
				if type(collider.compositor_object) = "roSprite" then 
					if GetGlobalAA().debug then : print "Removing Collider: "+collider_key : end if
					collider.compositor_object.Remove()
				end if
			end for
			instance.onDestroy()
			m.Instances.Delete(instance.id)
			instance.Clear()
			instance.id = invalid
		else
			print "gameEngine.destroyInstance() - Object was previously destroyed"
		end if
	end function
	' ############### destroyInstance() function - End ###############



	' ############### destroyAllInstances() function - Begin ###############
	gameEngine.destroyAllInstances = function(object_name)
		for each instance_key in m.Instances
			instance = m.Instances[instance_key]
			if instance.name = object_name then
				m.destroyInstance(instance)
			end if
		end for
	end function
	' ############### destroyAllInstances() function - End ###############



	' ############### instanceCount() function - Begin ###############
	gameEngine.instanceCount = function(object_name)
		instance_count = 0
		for each instance_key in m.Instances
			if m.Instances[instance_key].name = object_name then
				instance_count = instance_count + 1
			end if
		end for
		return instance_count
	end function 
	' ############### instanceCount() function - End ###############


	' --------------------------------Begin Room Functions----------------------------------------


	' ############### defineRoom() function - Begin ###############
	gameEngine.defineRoom = function(room_name, room_creation_function)
		m.Rooms[room_name] = room_creation_function
		print "defineRoom() - Room function has been added"
	end function
	' ############### defineRoom() function - Begin ###############



	' ############### changeRoom() function - Begin ###############
	gameEngine.changeRoom = function(room_name, args = {})
		if m.Rooms[room_name] <> invalid then
			if m.currentRoom <> invalid then 
				m.destroyInstance(m.currentRoom)
			end if
			for each key in m.Instances
				if not m.Instances[key].persistent then
					m.destroyInstance(m.Instances[key])
				end if
			end for
			m.currentRoom = invalid
			m.currentRoom = m.newEmptyObject("room")
			m.Rooms[room_name](m.currentRoom)
			for each key in args
				m.currentRoom[key] = args[key]
			end for
			m.currentRoom.onCreate()
			return true
		else
			print "changeRoom() - The provided room name hasn't been defined"
			return false
		end if
	end function
	' ############### changeRoom() function - End ###############


	' --------------------------------Begin Bitmap Functions----------------------------------------


	' ############### loadBitmap() function - Begin ###############
	gameEngine.loadBitmap = function(bitmap_name, path)
		if type(path) = "roAssociativeArray" then
			if path.width <> invalid and path.height <> invalid and path.AlphaEnable <> invalid then
				m.Bitmaps[bitmap_name] = CreateObject("roBitmap", path)
				print "loadBitmap() - New empty bitmap created."
				return true
			else
				print "loadBitmap() - Width as Integer, Height as Integer, and AlphaEnabled as Boolean must be provided in order to create an empty bitmap"
				return false
			end if
		else if m.filesystem.Exists(path) then
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".png" or parts.extension = ".jpg" then
				m.Bitmaps[bitmap_name] = CreateObject("roBitmap", path)
				print "loadBitmap() - Loaded bitmap from " ; path
				return true
			else
				print "loadBitmap() - Bitmap not loaded, file must be of type .png or .jpg"
				return false
			end if
		else
			print "loadBitmap() - Bitmap not created, invalid path or object properties provided."
			return false
		end if
	end function
	' ############### loadBitmap() function - End ###############



	' ############### getBitmap() function - Begin ###############
	gameEngine.getBitmap = function(bitmap_name)
		if m.Bitmaps.DoesExist(bitmap_name)
			return m.Bitmaps[bitmap_name]
		else
			return invalid
		end if
	end function
	' ############### getBitmap() function - End ###############



	' ############### unloadBitmap() function - Begin ###############
	gameEngine.unloadBitmap = function(bitmap_name)
		if m.Bitmaps.DoesExist(bitmap_name)
			m.Bitmaps[bitmap_name] = invalid
			return true
		else
			return false
		end if
	end function
	' ############### unloadBitmap() function - End ###############


	' --------------------------------Begin Font Functions----------------------------------------


	' ############### registerFont() function - Begin ###############
	gameEngine.registerFont = function(path)
		if m.filesystem.Exists(path) then
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".ttf" or parts.extension = ".otf" then
				m.font_registry.register(path)
				print "Font registered successfully"
				return true
			else
				print "Font must be of type .ttf or .otf"
				return false
			end if
		else
			print "File at path " ; path ; " doesn't exist"
			return false
		end if
	end function
	' ############### registerFont() function - End ###############



	' ############### loadFont() function - Begin ###############
	gameEngine.loadFont = function(name, size, italic, bold)
		m.Fonts[name] = m.font_registry.GetFont(name, size, italic, bold)
	end function
	' ############### loadFont() function - End ###############



	' ############### unloadFont() function - Begin ###############
	gameEngine.unloadFont = function(name)
		m.Fonts[name] = invalid
	end function
	' ############### unloadFont() function - End ###############



	' ############### getFont() function - Begin ###############
	gameEngine.getFont = function(name)
		return m.Fonts[name]
	end function
	' ############### getFont() function - End ###############


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
	gameEngine.cameraSetFollow = function(instance, mode = 0)
		m.camera.follow = instance
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
			scale_difference = screen_width/frame_width
			m.camera.scale_x = 1*scale_difference
			m.camera.scale_y = 1*scale_difference
		end if
	end function
	' ############### cameraFitToScreen() function - End ###############



	' ############### cameraCenterToInstance() function - Begin ###############
	gameEngine.cameraCenterToInstance = function(instance)
		if instance.id = invalid
			print "cameraCenterToInstance() - Provided instance doesn't exist"
			return invalid
		end if
		frame_width = m.frame.GetWidth()
		frame_height = m.frame.GetHeight()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()

		offset_x = 0-instance.x*m.camera.scale_x+m.screen.GetWidth()/2
		offset_y = 0-instance.y*m.camera.scale_y+screen_height/2

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
	' ############### cameraCenterToInstance() function - End ###############


	' --------------------------------Begin Audio Functions----------------------------------------


	' ############### musicPlay() function - Begin ###############
	gameEngine.musicPlay = function(audio_path, loop = false)
		m.audioplayer.stop()
		m.audioplayer.ClearContent()
	    song = {}
	    song.url = path
	    audioplayer.AddContent(song)
	    audioplayer.SetLoop(loop)
	    audioPlayer.play()
	end function
	' ############### musicPlay() function - End ###############



	' ############### musicStop() function - Begin ###############
	gameEngine.musicStop = function()
		m.audioplayer.stop()
	end function
	' ############### musicStop() function - End ###############



	' ############### musicPause() function - Begin ###############
	gameEngine.musicPause = function()
		m.audioplayer.pause()
	end function
	' ############### musicPause() function - End ###############



	' ############### musicResume() function - Begin ###############
	gameEngine.musicResume = function()
		m.audioplayer.resume()
	end function
	' ############### musicResume() function - End ###############



	' ############### addSound() function - Begin ###############
	gameEngine.addSound = function(sound_name, sound_path)
		m.Sounds[sound_name] = CreateObject("roAudioResource", sound_path)
	end function
	' ############### addSound() function - End ###############



	' ############### playSound() function - Begin ###############
	gameEngine.playSound = function(sound_name, volume = 100)
		m.Sounds[sound_name].trigger(volume)
	end function
	' ############### playSound() function - End ###############


	return gameEngine
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