' -------------------------Function To Create Main Game Engine Object------------------------

function gameEngine_init(game_width, game_height, debug = false)
	
	' ############### Create Initial Object - Begin ###############

	' Create the main game engine object
	gameEngine = {
		' ****BEGIN - For Internal Use, Do Not Manually Alter****
		debug: debug
		buttonHeld: -1
		dt: 0
		dtTimer: CreateObject("roTimespan")
		fpsTimer: CreateObject("roTimespan")
		fpsTicker: 0
		FPS: 0
		currentID: 0
		need_to_clear: []
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
		Instances: { room: {}} ' This holds all of the game object instances
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
		getInstanceByType: invalid
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
		loadSound: invalid
		playSound: invalid

		registryWriteString: invalid
		registryWriteFloat: invalid
		registryReadString: invalid
		registryReadFloat: invalid

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
	gameEngine.Update = function() as Void
		m.compositor.Draw() ' For some reason this has to be called or the colliders don't remove themselves from the compositor ¯\(°_°)/¯
		m.screen.Clear(&h000000FF) 
		m.frame.Clear(&h000000FF) 


		m.dt = m.dtTimer.TotalMilliseconds()/1000
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
		for each object_key in m.Instances
			for each instance_key in m.Instances[object_key]
				instance = m.Instances[object_key][instance_key]

				
				' -------------------- Then handle the object movement--------------------
				instance.x = instance.x + instance.xspeed*m.dt
				instance.y = instance.y + instance.yspeed*m.dt


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
				instance.onUpdate(m.dt)


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
								if other_collider_data.instance_id <> instance.id and m.Instances[other_collider_data.object_type].DoesExist(other_collider_data.instance_id)
									instance.onCollision(collider_key, other_collider_data.collider_name, m.Instances[other_collider_data.object_type][other_collider_data.instance_id])
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
		end for


		' ----------------------Then draw all of the instances and call onDrawBegin() and onDrawEnd()-------------------------
		for i = draw_depths.Count()-1 to 0 step -1
			instance = draw_depths[i]
			instance.onDrawBegin(m.frame)
			for each image in instance.images
				if image.enabled then
					if image.alpha > 255 then : image.alpha = 255 : end if
					m.frame.DrawScaledObject(instance.x+image.offset_x-(image.origin_x*image.scale_x), instance.y+image.offset_y-(image.origin_y*image.scale_y), image.scale_x, image.scale_y, image.region, (image.color << 8)+image.alpha)
				end if
			end for
			instance.onDrawEnd(m.frame)
			' if m.debug then : m.DrawColliders(instance) : end if
		end for


		' --------------------Then do camera magic if it's set to follow----------------------------
		if m.camera.follow <> invalid
			if m.camera.follow.id <> invalid and m.Instances[m.camera.follow.type].DoesExist(m.camera.follow.id)
				m.cameraCenterToInstance(m.camera.follow, m.camera.follow_mode)
			else
				m.camera.follow = invalid
			end if
		end if

		' -------------------This is placed here so that objects don't get invalidated mid function-----------------
		if m.need_to_clear.Count() > 0
			for i = 0 to m.need_to_clear.Count()-1
				m.need_to_clear[i].Clear()
				m.need_to_clear[i].id = invalid
			end for
			m.need_to_clear = []
		end if

		if m.debug then
			m.frame.DrawRect(10-4, 10, 100, 32, &h000000FF)
			m.frame.DrawText("FPS: "+m.FPS.ToStr(), 10, 10, &hFFFFFFFF, m.Fonts.default)
		end if
		m.screen.DrawScaledObject(m.camera.offset_x, m.camera.offset_y, m.camera.scale_x, m.camera.scale_y, m.frame)
		m.screen.SwapBuffers()


	end function
	' ################################################################ Update() function - End #####################################################################################################



	' ################################################################ newEmptyObject() function - Begin #####################################################################################################
	gameEngine.newEmptyObject = function(object_type as String) as Object
		m.currentID = m.currentID + 1
		new_object = {
			' -----Constants-----
			type: object_type
			id: m.currentID.ToStr()
			gameEngine: m

			' -----Variables-----
			persistent: false
			depth: 0
			x: 0.0
			y: 0.0
			xspeed: 0.0
			yspeed: 0.0
	        colliders: {}
	        images: []

	        ' -----Methods-----
	        onCreate: invalid
	        onUpdate: invalid
	        onCollision: invalid
	        onDrawBegin: invalid
	        onDrawEnd: invalid
	        onButton: invalid
	        onAudioEvent: invalid
	        onDestroy: invalid
	        addColliderCircle: invalid
	        addColliderRectangle: invalid
	        removeCollider: invalid
	        addImage: invalid
	        removeImage: invalid
		}

		' These empty functions are placeholders, they are to be overwritten by the user
		new_object.onCreate = function()
		end function

		new_object.onUpdate = function(deltaTime)
		end function

		new_object.onCollision = function(collider, other_collider, other_instance)
		end function

		new_object.onDrawBegin = function(screen)
		end function

		new_object.onDrawEnd = function(screen)
		end function

		new_object.onButton = function(code)
			' -------Button Code Reference--------
			' Button  When pressed  When released When Held

			' Back  0  100 1000
			' Up  2  102 1002
			' Down  3  103 1003
			' Left  4  104 1004
			' Right  5  105 1005
			' Select  6  106 1006
			' Instant Replay  7  107 1007
			' Rewind  8  108 1008
			' Fast  Forward  9  109 1009
			' Info  10  110 1010
			' Play  13  113 1013
		end function

		new_object.onAudioEvent = function(msg)
		end function

		new_object.onDestroy = function()
		end function


		new_object.addColliderCircle = function(collider_name, radius, offset_x = 0, offset_y = 0, enabled = true)
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
			collider.compositor_object.SetData({collider_name: collider_name, object_type: m.type, instance_id: m.id})
			if m.colliders[collider_name] = invalid then
				m.colliders[collider_name] = collider
			else
				if m.debug then : print "Collider Name Already Exists" : end if
			end if
		end function

		new_object.addColliderRectangle = function(collider_name, offset_x, offset_y, width, height, enabled = true)
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
			collider.compositor_object.SetData({collider_name: collider_name, object_type: m.type, instance_id: m.id})
			if m.colliders[collider_name] = invalid then
				m.colliders[collider_name] = collider 
			else
				if m.debug then : print "Collider Name Already Exists" : end if
			end if
		end function

		new_object.removeCollider = function(collider_name)
			if m.colliders[collider_name] <> invalid then
				if type(m.colliders[collider_name].compositor_object) = "roSprite" then : m.colliders[collider_name].compositor_object.Remove() : end if
				m.colliders[collider_name] = invalid
			else
				if m.debug then : print "Collider Doesn't Exist" : end if
			end if
		end function

		new_object.addImage = function(image, args = {})
			image_object = {
				' --------------Values That Can Be Changed------------
				offset_x: 0 ' The offset of the image.
				offset_y: 0 
				origin_x: 0 ' The image origin (where it will be drawn from). This helps for keeping an image in the correct position even when scaling.
				origin_y: 0
				scale_x: 1.0 ' The image scale.
				scale_y: 1.0
				color: &hFFFFFF ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
				alpha: 255 ' Change the image alpha (transparency).
				enabled: true ' Whether or not the image will be drawn.

				' -------------Only To Be Changed For Animation---------------
				' The following values should only be changed if the image is a spritesheet that needs to be animated.
				' The spritesheet can have any assortment of multiple columns and rows.
				image_count: 1 ' The number of images in the spritesheet.
				image_width: invalid ' The width of each individual image on the spritesheet.
				image_height: invalid ' The height of each individual image on the spritesheet.
				animation_speed: 0 ' The time in milliseconds for a single cycle through the animation to play.
				animation_position: 0 ' This would not normally be changed manually, but if you wanted to stop on a specific image in the spritesheet this could be set.

				' -------------Never To Be Manually Changed-----------------
				' These values should never need to be manually changed.
				image: image,
				region: invalid
				animation_timer: invalid
			}
			for each key in image_object
				if args.DoesExist(key) then
					image_object[key] = args[key]
				end if
			end for
			image_object.animation_timer = CreateObject("roTimespan")

			if image_object.image_width <> invalid and image_object.image_height <> invalid then
				image_object.region = CreateObject("roRegion", image_object.image, 0, 0, args.image_width, args.image_height)
			else if type(image) = "roRegion" then 
				image_object.region = image
			else
				image_object.region = CreateObject("roRegion", image_object.image, 0, 0, image_object.image.GetWidth(), image_object.image.GetHeight())
			end if

			m.images.push(image_object)
		end function

		new_object.removeImage = function(index)
			if m.images[index] <> invalid then
				m.images.Delete(index)
			else
				if m.debug then : print "removeImage() - Position In Image Array Is Invalid" : end if
			end if
		end function

		m.Instances[new_object.type][new_object.id] = new_object

		return new_object
	end function
	' ################################################################ newEmptyObject() function - End #####################################################################################################



	' ############### getDeltaTime() function - Begin ###############
	gameEngine.getDeltaTime = function() as Float
		return m.dt
	end function
	' ############### getDeltaTime() function - Begin ###############



	' ############### DrawColliders() function - Begin ###############
	gameEngine.drawColliders = function(instance as Object, color = &hFF0000FF as Integer) as Void
		for each collider_key in instance.colliders
			collider = instance.colliders[collider_key]
			if collider.enabled then
				if collider.type = "circle" then
					' This function is slow as I'm making draw calls for every section of the line.
					' It's for debugging purposes only!
					DrawCircle(m.frame, 100, instance.x+collider.offset_x, instance.y+collider.offset_y, collider.radius, color)
				end if
				if collider.type = "rectangle" then
					m.frame.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y, 1, collider.height, color)
					m.frame.DrawRect(instance.x+collider.offset_x+collider.width-1, instance.y+collider.offset_y, 1, collider.height, color)
					m.frame.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y, collider.width, 1, color)
					m.frame.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y+collider.height-1, collider.width, 1, color)
				end if
			end if
		end for
	end function
	' ############### DrawColliders() function - End ###############


	' --------------------------------Begin Object Functions----------------------------------------


	' ############### defineObject() function - Begin ###############
	gameEngine.defineObject = function(object_type as String, object_creation_function as Function) as Void
		m.Objects[object_type] = object_creation_function
		m.Instances[object_type] = {}
	end function
	' ############### defineObject() function - End ###############



	' ############### createInstance() function - Begin ###############
	gameEngine.createInstance = function(object_type as String, args = {} as Object) as Dynamic
		if m.Objects.DoesExist(object_type)
			new_instance = m.newEmptyObject(object_type)
			m.Objects[object_type](new_instance)
			new_instance.onCreate()
			for each key in args
				new_instance[key] = args[key]
			end for
			if m.debug then : print "createInstance() - Creating instance: "+new_instance.id : end if
			return new_instance
		else
			if m.debug then : print "createInstance() - No objects registered with the name - " ; object_type : end if
			return invalid
		end if
	end function
	' ############### createInstance() function - End ###############



	' ############### getInstanceByID() function - Begin ###############
	gameEngine.getInstanceByID = function(instance_id as String) as Dynamic
		for each object_key in m.Instances
			if m.Instances[object_key].DoesExist(instance_id) then
				return m.Instances[instance_id]
			end if
		end for
		if m.debug then : print "getInstanceByID() - No instance exists with id - " ; instance_id : end if
		return invalid
	end function
	' ############### getInstanceByID() function - End ###############



	' ############### getInstanceByType() function - Begin ###############
	gameEngine.getInstanceByType = function(object_type as String) as Dynamic
		if m.Instances.DoesExist(object_type) then
			for each instance_key in m.Instances[object_type]
				return m.Instances[object_type][instance_key] ' Obviously only retrieves the first value
			end for
		end if
		if m.debug then : print "getInstanceByType() - No instance exists with name - " ; object_type : end if
		return invalid
	end function
	' ############### getInstanceByType() function - End ###############



	' ############### getAllInstances() function - Begin ###############
	gameEngine.getAllInstances = function(object_type as String) as Dynamic
		if m.Instances.DoesExist(object_type) then
			array = []
			for each instance_key in m.Instances[object_type]
				array.Push(m.Instances[object_type][instance_key])
			end for
			return array
		else
			if m.debug then : print "getAllInstances() - No object defined with name - " ; object_type : end if
			return invalid
		end if
	end function
	' ############### getAllInstances() function - Begin ###############



	' ############### destroyInstance() function - Begin ###############
	gameEngine.destroyInstance = function(instance as Object) as Void
		if m.debug then : print "destroyInstance() - Destroying Instance: "+instance.id : end if
		if instance.id <> invalid and m.Instances[instance.type].DoesExist(instance.id) then
			for each collider_key in instance.colliders
				collider = instance.colliders[collider_key]
				if type(collider.compositor_object) = "roSprite" then 
					collider.compositor_object.Remove()
				end if
			end for
			instance.onDestroy()
			m.Instances[instance.type].Delete(instance.id)
			m.need_to_clear.Push(instance)
		else
			if m.debug then : print "destroyInstance() - Object was previously destroyed" : end if
		end if
	end function
	' ############### destroyInstance() function - End ###############



	' ############### destroyAllInstances() function - Begin ###############
	gameEngine.destroyAllInstances = function(object_type as String) as Void
		for each instance_key in m.Instances[object_type]
			m.destroyInstance(m.Instances[object_type][instance_key])
		end for
	end function
	' ############### destroyAllInstances() function - End ###############



	' ############### instanceCount() function - Begin ###############
	gameEngine.instanceCount = function(object_type as String) as Integer
		return m.Instances[object_type].Count()
	end function 
	' ############### instanceCount() function - End ###############


	' --------------------------------Begin Room Functions----------------------------------------


	' ############### defineRoom() function - Begin ###############
	gameEngine.defineRoom = function(room_name as String, room_creation_function as Function) as Void
		m.Rooms[room_name] = room_creation_function
		if m.debug then : print "defineRoom() - Room function has been added" : end if
	end function
	' ############### defineRoom() function - Begin ###############



	' ############### changeRoom() function - Begin ###############
	gameEngine.changeRoom = function(room_name as String, args = {} as Object) as Boolean
		if m.Rooms[room_name] <> invalid then
			if m.currentRoom <> invalid then 
				m.destroyInstance(m.currentRoom)
			end if
			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					if not m.Instances[object_key][instance_key].persistent then
						m.destroyInstance(m.Instances[object_key][instance_key])
					end if
				end for
			end for
			m.currentRoom = invalid
			m.currentRoom = m.newEmptyObject("room")
			m.currentRoom.name = room_name
			m.Rooms[room_name](m.currentRoom)
			for each key in args
				m.currentRoom[key] = args[key]
			end for
			m.currentRoom.onCreate()
			return true
		else
			if m.debug then : print "changeRoom() - The provided room name hasn't been defined" : end if
			return false
		end if
	end function
	' ############### changeRoom() function - End ###############


	' --------------------------------Begin Bitmap Functions----------------------------------------


	' ############### loadBitmap() function - Begin ###############
	gameEngine.loadBitmap = function(bitmap_name as String, path as String) as Boolean
		if type(path) = "roAssociativeArray" then
			if path.width <> invalid and path.height <> invalid and path.AlphaEnable <> invalid then
				m.Bitmaps[bitmap_name] = CreateObject("roBitmap", path)
				if m.debug then : print "loadBitmap() - New empty bitmap created." : end if
				return true
			else
				if m.debug then : print "loadBitmap() - Width as Integer, Height as Integer, and AlphaEnabled as Boolean must be provided in order to create an empty bitmap" : end if
				return false
			end if
		else if m.filesystem.Exists(path) then
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".png" or parts.extension = ".jpg" then
				m.Bitmaps[bitmap_name] = CreateObject("roBitmap", path)
				if m.debug then : print "loadBitmap() - Loaded bitmap from " ; path : end if
				return true
			else
				if m.debug then : print "loadBitmap() - Bitmap not loaded, file must be of type .png or .jpg" : end if
				return false
			end if
		else
			if m.debug then : print "loadBitmap() - Bitmap not created, invalid path or object properties provided." : end if
			return false
		end if
	end function
	' ############### loadBitmap() function - End ###############



	' ############### getBitmap() function - Begin ###############
	gameEngine.getBitmap = function(bitmap_name as String) as Dynamic
		if m.Bitmaps.DoesExist(bitmap_name)
			return m.Bitmaps[bitmap_name]
		else
			return invalid
		end if
	end function
	' ############### getBitmap() function - End ###############



	' ############### unloadBitmap() function - Begin ###############
	gameEngine.unloadBitmap = function(bitmap_name as String) as Boolean
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
	gameEngine.registerFont = function(path as String) as Boolean
		if m.filesystem.Exists(path) then
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".ttf" or parts.extension = ".otf" then
				m.font_registry.register(path)
				if m.debug then : print "Font registered successfully" : end if
				return true
			else
				if m.debug then : print "Font must be of type .ttf or .otf" : end if
				return false
			end if
		else
			if m.debug then : print "File at path " ; path ; " doesn't exist" : end if
			return false
		end if
	end function
	' ############### registerFont() function - End ###############



	' ############### loadFont() function - Begin ###############
	gameEngine.loadFont = function(font_name as String, size as Integer, italic as Boolean, bold as Boolean) as Void
		m.Fonts[font_name] = m.font_registry.GetFont(font_name, size, italic, bold)
	end function
	' ############### loadFont() function - End ###############



	' ############### unloadFont() function - Begin ###############
	gameEngine.unloadFont = function(font_name as String) as Void
		m.Fonts[font_name] = invalid
	end function
	' ############### unloadFont() function - End ###############



	' ############### getFont() function - Begin ###############
	gameEngine.getFont = function(font_name as String) as Object
		return m.Fonts[font_name]
	end function
	' ############### getFont() function - End ###############


	' --------------------------------Begin Camera Functions----------------------------------------
	' Note, camera functions can be complicated to use manually, because the "camera" is actually a single
	' bitmap that is being scaled and positioned. In order to make it easy for the user, I do things that might
	' seem odd, such as negating the offset so that it feels like you are offsetting the "camera" as opposed to
	' offsetting the bitmap.


	' ############### cameraIncreaseOffset() function - Begin ###############
	' This is as Float to allow incrementing by less than 1 pixel, it is converted to integer internally
	gameEngine.cameraIncreaseOffset = function(x as Float, y as Float) as Void
		m.camera.offset_x = m.camera.offset_x - x
		m.camera.offset_y = m.camera.offset_y - y
	end function
	' ############### cameraIncreaseOffset() function - End ###############



	' ############### cameraIncreaseZoom() function - Begin ###############
	gameEngine.cameraIncreaseZoom = function(scale_x as Float, scale_y = -999 as Float) as Void
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
	' This is as Float to allow incrementing by less than 1 pixel, it is converted to integer internally
	gameEngine.cameraSetOffset = function(x as Float, y as Float) as Void
		m.camera.offset_x = -x
		m.camera.offset_y = -y
	end function
	' ############### cameraSetOffset() function - End ###############



	' ############### cameraSetZoom() function - Begin ###############
	gameEngine.cameraSetZoom = function(scale_x as Float, scale_y = -999 as Float) as Void
		if scale_y = -999
			scale_y = scale_x
		end if
		m.camera.scale_x = scale_x
		m.camera.scale_y = scale_y
	end function
	' ############### cameraSetZoom() function - End ###############



	' ############### cameraSetFollow() function - Begin ###############
	gameEngine.cameraSetFollow = function(instance as Object, mode = 0 as Integer) as Void
		m.camera.follow = instance
		m.camera.follow_mode = mode
	end function
	' ############### cameraSetFollow() function - End ###############



	' ############### cameraUnsetFollow() function - Begin ###############
	gameEngine.cameraUnsetFollow = function() as Void
		m.camera.follow = invalid
	end function
	' ############### cameraUnsetFollow() function - End ###############



	' ############### cameraFitToScreen() function - Begin ###############
	gameEngine.cameraFitToScreen = function() as Void
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
	gameEngine.cameraCenterToInstance = function(instance as Object, mode = 0 as Integer) as dynamic
		if instance.id = invalid
			if m.debug then : print "cameraCenterToInstance() - Provided instance doesn't exist" : end if
			return invalid
		end if
		frame_width = m.frame.GetWidth()
		frame_height = m.frame.GetHeight()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()

		offset_x = 0-instance.x*m.camera.scale_x+m.screen.GetWidth()/2
		offset_y = 0-instance.y*m.camera.scale_y+screen_height/2

		if mode = 0
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
		else if mode = 1
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
	gameEngine.musicPlay = function(path as String, loop = false as Boolean) as Boolean
		if m.filesystem.Exists(path) then
			m.audioplayer.stop()
			m.audioplayer.ClearContent()
		    song = {}
		    song.url = path
		    audioplayer.AddContent(song)
		    audioplayer.SetLoop(loop)
		    audioPlayer.play()
			return true
			if m.debug then : print "musicPlay() - Playing music from path: " ; path : end if
		else
			if m.debug then : print "musicPlay() - No file exists at path: " ; path : end if
			return false
		end if
	end function
	' ############### musicPlay() function - End ###############



	' ############### musicStop() function - Begin ###############
	gameEngine.musicStop = function() as Void
		m.audioplayer.stop()
	end function
	' ############### musicStop() function - End ###############



	' ############### musicPause() function - Begin ###############
	gameEngine.musicPause = function() as Void
		m.audioplayer.pause()
	end function
	' ############### musicPause() function - End ###############



	' ############### musicResume() function - Begin ###############
	gameEngine.musicResume = function() as Void
		m.audioplayer.resume()
	end function
	' ############### musicResume() function - End ###############



	' ############### loadSound() function - Begin ###############
	gameEngine.loadSound = function(sound_name as String, path as String) as Void
		m.Sounds[sound_name] = CreateObject("roAudioResource", path)
	end function
	' ############### loadSound() function - End ###############



	' ############### playSound() function - Begin ###############
	gameEngine.playSound = function(sound_name as String, volume = 100 as Integer) as Boolean
		if m.Sounds.DoesExist(sound_name) then
			m.Sounds[sound_name].trigger(volume)
			if m.debug then : print "playSound() - Playing sound: " ; sound_name : end if
			return true
		else
			if m.debug then : print "playSound() - No sound has been loaded under the name: " ; sound_name : end if
			return false
		end if
	end function
	' ############### playSound() function - End ###############


	' ----------------------------------------Begin Registry Functions------------------------------------------
	gameEngine.registryWriteString = function(registry_section as String, key as String, value as String) as Void
	    section = CreateObject("roRegistrySection", registry_section)
	    section.Write(key, value)
	    section.Flush()
	end function

	gameEngine.registryWriteFloat = function(registry_section as String, key as String, value as Float) as Void
		value = str(value)
		m.registryWriteString(registry_section, key, value)
	end function

	gameEngine.registryReadString = function(registry_section as String, key as String, default_value as String) as String
		section = CreateObject("roRegistrySection", registry_section)
	    if section.Exists(registry_section) then
	        return section.Read(registry_section)
	    else
	    	section.Write(key, default_value)
	    	section.Flush()
	    	return default_value
	    end if
	end function

	gameEngine.registryReadFloat = function(registry_section as String, key as String, default_value as Float) as Float
		default_value = str(default_value)
        return val(m.registryReadString(registry_section, key, default_value))
	end function

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

Function HSVtoRGB(h%,s%,v%,a = invalid) As Integer
   ' Romans_I_XVI port (w/ a few tweaks) of:
   ' http://schinckel.net/2012/01/10/hsv-to-rgb-in-javascript/
    
	h% = h% MOD 360
   
	rgb = [ 0, 0, 0 ]
	if s% = 0 then
		rgb = [v%/100, v%/100, v%/100]
	else
		s = s%/100 : v = v%/100 : h = h%/60 : i = int(h)

		data = [v*(1-s), v*(1-s*(h-i)), v*(1-s*(1-(h-i)))]
     
		if i = 0 then
			rgb = [v, data[2], data[0]]
		else if i = 1 then
			rgb = [data[1], v, data[0]]   
		else if i = 2 then
			rgb = [data[0], v, data[2]]
		else if i = 3 then
			rgb = [data[0], data[1], v]
		else if i = 4 then
			rgb = [data[2], data[0], v]
		else
			rgb = [v, data[0], data[1]]
		end if
	end if

	for c = 0 to rgb.count()-1 : rgb[c] = int(rgb[c] * 255) : end for
	if a <> invalid then
		color% = (rgb[0] << 24) + (rgb[1] << 16) + (rgb[2] << 8) + a
	else
		color% = (rgb[0] << 16) + (rgb[1] << 8) + rgb[2]
	end if

	return color%
End Function