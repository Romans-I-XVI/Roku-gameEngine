' -------------------------Function To Create Main Game Object------------------------

function new_game(canvas_width, canvas_height, debug = false, canvas_as_screen_if_possible = false)
	
	' ############### Create Initial Object - Begin ###############

	' Create the main game engine object
	game = {
		' ****BEGIN - For Internal Use, Do Not Manually Alter****
		debug: debug
		canvas_is_screen: false
		running: true
		paused: false
		buttonHeld: -1
		buttonHeldTime: 0
		input_instance: invalid
		current_input_instance: invalid
		dt: 0
		FakeDT: invalid
		dtTimer: CreateObject("roTimespan")
		fpsTimer: CreateObject("roTimespan")
		pauseTimer: CreateObject("roTimespan")
		buttonHeldTimer: CreateObject("roTimespan")
		fpsTicker: 0
		FPS: 0
		currentID: 0
		shouldUseIntegerMovement: false
		empty_bitmap: CreateObject("roBitmap", {width: 1, height: 1, AlphaEnable: false})
		device: CreateObject("roDeviceInfo")
		urltransfers: {}
		url_port: CreateObject("roMessagePort")
		compositor: CreateObject("roCompositor")
		filesystem: CreateObject("roFileSystem")
		screen_port: CreateObject("roMessagePort")
		audioplayer: CreateObject("roAudioPlayer")
		music_port: CreateObject("roMessagePort")
		font_registry: CreateObject("roFontRegistry")
		background_color: &h000000FF
		screen: invalid
		canvas: {
			bitmap: CreateObject("roBitmap", {width: canvas_width, height: canvas_height, AlphaEnable: true})
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
		currentRoomArgs: {}
		Instances: {} ' This holds all of the game object instances
		Objects: {} ' This holds the object definitions by name (the object creation functions)
		Rooms: {} ' This holds the room definitions by name (the room creation functions)
		Bitmaps: {} ' This holds the loaded bitmaps by name
		Sounds: {} ' This holds the loaded sounds by name
		Fonts: {} ' This holds the loaded fonts by name

		' These are just placeholder reminders of what functions get added to the game
		' ****Functions****
		Update: invalid
		newEmptyObject: invalid
		drawColliders: invalid

		setBackgroundColor: invalid
		getDeltaTime: invalid
		getRoom: invalid
		getCanvas: invalid
		getScreen: invalid

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
		resetRoom: invalid

		loadBitmap: invalid
		getBitmap: invalid
		unloadBitmap: invalid

		registerFont: invalid
		loadFont: invalid
		unloadFont: invalid
		getFont: invalid

		canvasSetSize: invalid
		canvasGetOffset: invalid
		canvasGetScale: invalid
		canvasIncreaseOffset: invalid
		canvasIncreaseScale: invalid
		canvasSetOffset: invalid
		canvasSetScale: invalid
		canvasSetFollow: invalid
		canvasUnsetFollow: invalid
		canvasFitToScreen: invalid
		canvasCentertoScreen: invalid
		canvasCenterToInstance: Invalid

		musicPlay: invalid
		musicStop: invalid
		musicPause: invalid
		musicResume: invalid
		loadSound: invalid
		playSound: invalid


	}

	' Set up the screen
	UIResolution = game.device.getUIResolution()
	if UIResolution.name = "SD"
		game.screen = CreateObject("roScreen", true, 854, 626)
	else
		game.screen = CreateObject("roScreen", true, 1280, 720)
	end if
	game.compositor.SetDrawTo(game.screen, &h00000000)
	game.screen.SetMessagePort(game.screen_port)
	game.screen.SetAlphaEnable(true)

	if canvas_as_screen_if_possible
		if game.screen.GetWidth() = game.canvas.bitmap.GetWidth() and game.screen.GetHeight() = game.canvas.bitmap.GetHeight()
			game.canvas.bitmap = game.screen
			game.canvas_is_screen = true
		end if
	end if

	' Set up the audioplayer
	game.audioplayer.SetMessagePort(game.music_port)

	' Register all fonts in package
	ttfs_in_package = game.filesystem.FindRecurse("pkg:/fonts/", ".ttf")
	otfs_in_package = game.filesystem.FindRecurse("pkg:/fonts/", ".otf")
	for each font_path in ttfs_in_package
		game.font_registry.Register("pkg:/fonts/"+font_path)
	end for
	for each font_path in otfs_in_package
		game.font_registry.Register("pkg:/fonts/"+font_path)
	end for

	' Create the default font
	game.Fonts["default"] = game.font_registry.GetDefaultFont(28, false, false)

	' ############### Create Initial Object - End ###############





	' ################################################################ Play() function - Begin #####################################################################################################
	game.Play = function() as Void

		m.running = true

		while m.running

			if m.input_instance <> invalid and m.getInstanceByID(m.input_instance) = invalid
				m.input_instance = invalid
			end if
			m.current_input_instance = m.input_instance
			m.compositor.Draw() ' For some reason this has to be called or the colliders don't remove themselves from the compositor ¯\(°_°)/¯
			if not m.canvas_is_screen
				m.screen.Clear(&h000000FF) 
				if m.background_color <> invalid then
					m.canvas.bitmap.Clear(m.background_color)
				end if
			else
				if m.background_color <> invalid then
					m.screen.Clear(m.background_color)
				else
					m.screen.Clear(&h000000FF)
				end if
			end if


			m.dt = m.dtTimer.TotalMilliseconds()/1000
			if m.FakeDT <> invalid
				m.dt = m.FakeDT
			end if
			m.dtTimer.Mark()
			url_msg = m.url_port.GetMessage()
	        screen_msg = m.screen_port.GetMessage()
            if type(screen_msg) = "roUniversalControlEvent" then
            	if screen_msg.GetInt() < 100
            		m.buttonHeldTimer.Mark()
            	else
            		m.buttonHeldTime = m.buttonHeldTimer.TotalMilliseconds()
            	end if
            end if
	        music_msg = m.music_port.GetMessage()
			m.fpsTicker = m.fpsTicker + 1
			if m.fpsTimer.TotalMilliseconds() > 1000 then
				m.FPS = m.fpsTicker
				m.fpsTicker = 0
				m.fpsTimer.Mark()
			end if

			' --------------------------Add object to the appropriate position in the draw_depths array-----------------
			sorted_instances = []
			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					instance = m.Instances[object_key][instance_key]
					if sorted_instances.Count() > 0 then
						inserted = false
						for i = sorted_instances.Count()-1 to 0 step -1
							if not inserted and instance.depth > sorted_instances[i].depth then
								ArrayInsert(sorted_instances, i+1, instance)
								inserted = true
								exit for
							end if
						end for
						if not inserted then
							sorted_instances.Unshift(instance)
						end if
					else
						sorted_instances.Unshift(instance)
					end if
				end for
			end for

			' --------------------Begin giant loop for processing all game objects----------------
			' There is a goto after every call to an override function, this is so if the instance deleted itself no futher calls will be attempted on the instance.
			for i = sorted_instances.Count()-1 to 0 step -1
				instance = sorted_instances[i]
				if instance = invalid or instance.id = invalid or not instance.enabled then : goto end_of_for_loop  : end if
				if m.paused and instance.pauseable then: goto draw_instance : end if
				

				' --------------------First process the onButton() function--------------------
		        if type(screen_msg) = "roUniversalControlEvent" then
			        if m.current_input_instance = invalid or m.current_input_instance = instance.id
			        	instance.onButton(screen_msg.GetInt())
			        end if
		        	if screen_msg.GetInt() < 100
		        		m.buttonHeld = screen_msg.GetInt()
		        	else
		        		m.buttonHeld = -1
		        	end if
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if

					if screen_msg.GetChar() <> 0 and screen_msg.GetChar() = screen_msg.GetInt()
						instance.onECPKeyboard(Chr(screen_msg.GetChar()))
					end if
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
		        end if
		        if m.buttonHeld <> -1 then
		        	' Button release codes are 100 plus the button press code
		        	' This shows a button held code as 1000 plus the button press code
		        	if m.current_input_instance = invalid or m.current_input_instance = instance.id
			        	instance.onButton(1000+m.buttonHeld)
			        end if
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
		        end if


		        ' -------------------Then send the audioplayer event msg if applicable-------------------
		        if type(music_msg) = "roAudioPlayerEvent" then
		        	instance.onAudioEvent(music_msg)
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
		        end if



		        ' -------------------Then send the urltransfer event msg if applicable-------------------
		        if type(url_msg) = "roUrlEvent" then
		        	instance.onUrlEvent(url_msg)
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
		        end if


		        ' -------------------Then process the onUpdate() function----------------------
				instance.onUpdate(m.dt)
				if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if

		        
				' -------------------- Then handle the object movement--------------------
				if m.shouldUseIntegerMovement
					instance.x = instance.x + cint(instance.xspeed*m.dt)
					instance.y = instance.y + cint(instance.yspeed*m.dt)
				else
					instance.x = instance.x + instance.xspeed*m.dt
					instance.y = instance.y + instance.yspeed*m.dt
				end if



				' -------------------Then handle collisions and call onCollision() for each collision---------------------------
				for each collider_key in instance.colliders
					collider = instance.colliders[collider_key]
					if collider <> invalid then
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
									if other_collider_data.instance_id <> instance.id and m.Instances[other_collider_data.object_name].DoesExist(other_collider_data.instance_id)
										instance.onCollision(collider_key, other_collider_data.collider_name, m.Instances[other_collider_data.object_name][other_collider_data.instance_id])
										if instance = invalid or instance.id = invalid then : exit for : end if
									end if
								end for
								if instance = invalid or instance.id = invalid then : exit for : end if
							end if
						else
							collider.compositor_object.SetMemberFlags(99)
							collider.compositor_object.SetCollidableFlags(99)
						end if
					else
						if instance.colliders.DoesExist(collider_key)
							instance.colliders.Delete(collider_key)
						end if
					end if
				end for
				if instance = invalid or instance.id = invalid then : goto end_of_for_loop : end if

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


				draw_instance:
				' ----------------------Then draw all of the instances and call onDrawBegin() and onDrawEnd()-------------------------
				instance.onDrawBegin(m.canvas.bitmap)
				if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
				for each image in instance.images
					if image.enabled then
						if image.alpha > 255 then : image.alpha = 255 : end if
						image.draw_to.DrawScaledObject(instance.x+image.offset_x-(image.origin_x*image.scale_x), instance.y+image.offset_y-(image.origin_y*image.scale_y), image.scale_x, image.scale_y, image.region, (image.color << 8)+int(image.alpha))
					end if
				end for
				instance.onDrawEnd(m.canvas.bitmap)
				if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if

				end_of_for_loop:

			end for

			' ------------------Destroy the UrlTransfer object if it has returned an event------------------
			if type(url_msg) = "roUrlEvent"
				url_transfer_id_string = url_msg.GetSourceIdentity().ToStr()
		    	if m.urltransfers.DoesExist(url_transfer_id_string) then
		        	m.urltransfers.Delete(url_transfer_id_string)
					if m.debug then : print "Destroyed UrlTransfer Object - " ; url_transfer_id_string : end if
		        end if
		    end if


			' --------------------Then do canvas magic if it's set to follow----------------------------
			if m.canvas.follow <> invalid
				if m.canvas.follow.id <> invalid and m.Instances[m.canvas.follow.name].DoesExist(m.canvas.follow.id)
					m.canvasCenterToInstance(m.canvas.follow, m.canvas.follow_mode)
				else
					m.canvas.follow = invalid
				end if
			end if


			' -------------------Draw everything to the screen----------------------------
			if not m.canvas_is_screen
				m.screen.DrawScaledObject(m.canvas.offset_x, m.canvas.offset_y, m.canvas.scale_x, m.canvas.scale_y, m.canvas.bitmap)
			end if
			for i = sorted_instances.Count()-1 to 0 step -1
				instance = sorted_instances[i]
				if instance.id <> invalid
					instance.onDrawGui(m.screen)
				end if
			end for
			if m.debug then
				m.screen.DrawRect(10-4, 10, 100, 32, &h000000FF)
				m.screen.DrawText("FPS: "+m.FPS.ToStr(), 10, 10, &hFFFFFFFF, m.Fonts.default)
			end if
			m.screen.SwapBuffers()


		end while

		for each object_key in m.Instances
			for each instance_key in m.Instances[object_key]
				instance = m.Instances[object_key][instance_key]
				if instance.id <> invalid and instance.name <> m.currentRoom.name then
					m.destroyInstance(instance, false)
				end if
			end for
		end for
		if m.currentRoom <> invalid and m.currentRoom.id <> invalid then 
			m.destroyInstance(m.currentRoom, false)
		end if

	end function
	' ################################################################ Play() function - End #####################################################################################################



	' ################################################################ newEmptyObject() function - Begin #####################################################################################################
	game.newEmptyObject = function(object_name as String) as Object
		m.currentID = m.currentID + 1
		new_object = {
			' -----Constants-----
			name: object_name
			id: m.currentID.ToStr()
			game: m

			' -----Variables-----
			enabled: true
			persistent: false
			pauseable: true
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
	        onUrlEvent: invalid
	        onDestroy: invalid
	        addColliderCircle: invalid
	        addColliderRectangle: invalid
	        removeCollider: invalid
	        addImage: invalid
	        removeImage: invalid
		}

		' These empty functions are placeholders, they are to be overwritten by the user
		new_object.onCreate = function(args)
		end function

		new_object.onUpdate = function(deltaTime)
		end function

		new_object.onCollision = function(collider, other_collider, other_instance)
		end function

		new_object.onDrawBegin = function(canvas)
		end function

		new_object.onDrawEnd = function(canvas)
		end function

		new_object.onDrawGui = function(screen)
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

		new_object.onECPKeyboard = function(char)
		end function

		new_object.onAudioEvent = function(msg)
		end function

		new_object.onUrlEvent = function(msg)
		end function

		new_object.onGameEvent = function(event, data)
		end function

		new_object.onChangeRoom = function(new_room)
		end function

		new_object.onDestroy = function()
		end function


		new_object.addColliderCircle = function(collider_name, radius, offset_x = 0, offset_y = 0, enabled = true)
			collider = {
				type: "circle",
				name: collider_name,
				enabled: enabled,
				radius: radius,
				offset_x: offset_x,
				offset_y: offset_y,
				compositor_object: invalid
			}
			region = CreateObject("roRegion", m.game.empty_bitmap, 0, 0, 1, 1)
			region.SetCollisionType(2)
			region.SetCollisionCircle(offset_x, offset_y, radius)
			collider.compositor_object = m.game.compositor.NewSprite(m.x, m.y, region)
			collider.compositor_object.SetDrawableFlag(false)
			collider.compositor_object.SetData({collider_name: collider_name, object_name: m.name, instance_id: m.id})
			if m.colliders[collider_name] = invalid then
				m.colliders[collider_name] = collider
			else
				if m.game.debug then : print "addColliderCircle() - Collider Name Already Exists" : end if
			end if
		end function

		new_object.addColliderRectangle = function(collider_name, offset_x, offset_y, width, height, enabled = true)
			collider = {
				type: "rectangle",
				name: collider_name,
				enabled: enabled,
				offset_x: offset_x,
				offset_y: offset_y,
				width: width,
				height: height,
				compositor_object: invalid
			}
			region = CreateObject("roRegion", m.game.empty_bitmap, 0, 0, 1, 1)
			region.SetCollisionType(1)
			region.SetCollisionRectangle(offset_x, offset_y, width, height)
			collider.compositor_object = m.game.compositor.NewSprite(m.x, m.y, region)
			collider.compositor_object.SetDrawableFlag(false)
			collider.compositor_object.SetData({collider_name: collider_name, object_name: m.name, instance_id: m.id})
			if m.colliders[collider_name] = invalid then
				m.colliders[collider_name] = collider 
			else
				if m.game.debug then : print "addColliderRectangle() - Collider Name Already Exists" : end if
			end if
		end function

		new_object.getCollider = function(collider_name)
			if m.colliders.DoesExist(collider_name)
				return m.colliders[collider_name]
			else
				if m.game.debug then : print "getCollider() - Collider with that name doesn't exist" : end if
				return invalid
			end if
		end function

		new_object.removeCollider = function(collider_name)
			if m.colliders[collider_name] <> invalid then
				if type(m.colliders[collider_name].compositor_object) = "roSprite" then : m.colliders[collider_name].compositor_object.Remove() : end if
				m.colliders.Delete(collider_name)
			else
				if m.game.debug then : print "removeCollider() - Collider Doesn't Exist" : end if
			end if
		end function

		new_object.addImage = function(image, args = {}, insert_position = invalid)
			image_object = {
				' --------------Values That Can Be Changed------------
				name: "main" ' Name must be unique
				offset_x: 0 ' The offset of the image.
				offset_y: 0 
				origin_x: 0 ' The image origin (where it will be drawn from). This helps for keeping an image in the correct position even when scaling.
				origin_y: 0
				scale_x: 1.0 ' The image scale.
				scale_y: 1.0
				color: &hFFFFFF ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
				alpha: 255 ' Change the image alpha (transparency).
				enabled: true ' Whether or not the image will be drawn.
				draw_to: m.game.getCanvas()

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

			for i = 0 to m.images.Count()-1
				if image_object.name = m.images[i].name
					if m.game.debug then : print "addImage() - An image named -"+image_object.name+"- already exists" : end if
					return false
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

			if insert_position = invalid
				insert_position = m.images.Count()
			end if

			if insert_position = 0
				m.images.Unshift(image_object)
			else if insert_position < m.images.Count()
				ArrayInsert(m.images, insert_position, image_object)
			else
				m.images.push(image_object)
			end if

			return true
		end function

		new_object.getImage = function(image_name = "main")
			for each image in m.images
				if image.name = image_name
					return image
				end if
			end for
			return invalid
		end function

		new_object.removeImage = function(image_name = "main")
			deleted_something = false
			if m.images.Count() > 0
				for i = 0 to m.images.Count()-1
					if m.images[i].name = image_name
						m.images.Delete(i)
						deleted_something = true
						exit for
					end if
				end for
			end if
			if m.game.debug and not deleted_something then : print "removeImage() - No images found with name "+image_name : end if
		end function

		m.Instances[new_object.name][new_object.id] = new_object

		return new_object
	end function
	' ################################################################ newEmptyObject() function - End #####################################################################################################



	' ############### DrawColliders() function - Begin ###############
	game.drawColliders = function(instance as Object, color = &hFF0000FF as Integer) as Void
		for each collider_key in instance.colliders
			collider = instance.colliders[collider_key]
			if collider.enabled then
				if collider.type = "circle" then
					' This function is slow as I'm making draw calls for every section of the line.
					' It's for debugging purposes only!
					DrawCircle(m.canvas.bitmap, 100, instance.x+collider.offset_x, instance.y+collider.offset_y, collider.radius, color)
				end if
				if collider.type = "rectangle" then
					m.canvas.bitmap.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y, 1, collider.height, color)
					m.canvas.bitmap.DrawRect(instance.x+collider.offset_x+collider.width-1, instance.y+collider.offset_y, 1, collider.height, color)
					m.canvas.bitmap.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y, collider.width, 1, color)
					m.canvas.bitmap.DrawRect(instance.x+collider.offset_x, instance.y+collider.offset_y+collider.height-1, collider.width, 1, color)
				end if
			end if
		end for
	end function
	' ############### DrawColliders() function - End ###############



	' ############### DrawSafeZones() function - End ###############
	game.drawSafeZones = function() as Void
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()
		if m.device.GetDisplayAspectRatio() = "4x3" then
			action_offset = {w: 0.033*screen_width, h: 0.035*screen_height}
			title_offset = {w: 0.067*screen_width, h: 0.05*screen_height}
		else
			action_offset = {w: 0.035*screen_width, h: 0.035*screen_height}
			title_offset = {w: 0.1*screen_width, h: 0.05*screen_height}
		end if
		action_safe_zone = {x1: action_offset.w, y1: action_offset.h, x2: screen_width-action_offset.w, y2: screen_height-action_offset.h}
		title_safe_zone = {x1: title_offset.w, y1: title_offset.h, x2: screen_width-title_offset.w, y2: screen_height-title_offset.h}

		m.screen.DrawRect(action_safe_zone.x1, action_safe_zone.y1, action_safe_zone.x2-action_safe_zone.x1, action_safe_zone.y2-action_safe_zone.y1, &hFF00003F)
		m.screen.DrawRect(title_safe_zone.x1, title_safe_zone.y1, title_safe_zone.x2-title_safe_zone.x1, title_safe_zone.y2-title_safe_zone.y1, &h0000FF3F)
		m.screen.DrawText("Action Safe Zone", m.screen.GetWidth()/2-m.getFont("default").GetOneLineWidth("Action Safe Zone", 1000)/2, action_safe_zone.y1+10, &hFF0000FF, m.getFont("default"))
		m.screen.DrawText("Title Safe Zone", m.screen.GetWidth()/2-m.getFont("default").GetOneLineWidth("Title Safe Zone", 1000)/2, action_safe_zone.y1+50, &hFF00FFFF, m.getFont("default"))
	end function
	' ############### DrawSafeZones() function - End ###############

	
	
	' ############### End() function - Begin ###############
	game.End = function() as Void
		m.running = false
	end function
	' ############### End() function - End ###############



	' ############### Pause() function - Begin ###############
	game.Pause = function() as Void
		if not m.paused then
			m.paused = true
			m.pauseTimer.Mark()
		end if
	end function
	' ############### Pause() function - End ###############



	' ############### Resume() function - Begin ###############
	game.Resume = function() as Dynamic
		if m.paused then
			m.paused = false
			return m.pauseTimer.TotalMilliseconds()
		end if
		return invalid
	end function
	' ############### Resume() function - End ###############



	' ############### isPaused() function - Begin ###############
	game.isPaused = function() as Boolean
		return m.paused
	end function
	' ############### isPaused() function - End ###############



	' ############### setBackgroundColor() function - Begin ###############
	game.setBackgroundColor = function(color as Dynamic) as Void
		m.background_color = color
	end function
	' ############### setBackgroundColor() function - Begin ###############



	' ############### getDeltaTime() function - Begin ###############
	game.getDeltaTime = function() as Float
		return m.dt
	end function
	' ############### getDeltaTime() function - Begin ###############


	' ############### getRoom() function - Begin ###############
	game.getRoom = function() as Object
		return m.currentRoom
	end function
	' ############### getRoom() function - Begin ###############



	' ############### getCanvas() function - Begin ###############
	game.getCanvas = function() as Object
		return m.canvas.bitmap
	end function
	' ############### getCanvas() function - Begin ###############



	' ############### getScreen() function - Begin ###############
	game.getScreen = function() as Object
		return m.screen
	end function
	' ############### getScreen() function - Begin ###############



	' ############### resetScreen() function - Begin ###############
	game.resetScreen = function() as Void
		UIResolution = m.device.getUIResolution()
		if UIResolution.name = "SD"
			m.screen = CreateObject("roScreen", true, 854, 626)
		else
			m.screen = CreateObject("roScreen", true, 1280, 720)
		end if
		m.compositor.SetDrawTo(m.screen, &h00000000)
		m.screen.SetMessagePort(m.screen_port)
		m.screen.SetAlphaEnable(true)
		if m.canvas_is_screen
			m.canvas.bitmap = m.screen
		end if
	end function
	' ############### resetScreen() function - Begin ###############



	' ############### getUrlTransfer() function - Begin ###############
	game.getUrlTransfer = function() as Object
		return m.urltransfer
	end function
	' ############### getUrlTransfer() function - Begin ###############


	' --------------------------------Begin Object Functions----------------------------------------


	' ############### defineObject() function - Begin ###############
	game.defineObject = function(object_name as String, object_creation_function as Function) as Void
		m.Objects[object_name] = object_creation_function
		m.Instances[object_name] = {}
	end function
	' ############### defineObject() function - End ###############



	' ############### createInstance() function - Begin ###############
	game.createInstance = function(object_name as String, args = {} as Object) as Dynamic
		if m.Objects.DoesExist(object_name)
			new_instance = m.newEmptyObject(object_name)
			m.Objects[object_name](new_instance)
			new_instance.onCreate(args)
			if m.debug then : print "createInstance() - Creating instance: "+new_instance.id : end if
			return new_instance
		else
			if m.debug then : print "createInstance() - No objects registered with the name - " ; object_name : end if
			return invalid
		end if
	end function
	' ############### createInstance() function - End ###############



	' ############### getInstanceByID() function - Begin ###############
	game.getInstanceByID = function(instance_id as String) as Dynamic
		for each object_key in m.Instances
			if m.Instances[object_key].DoesExist(instance_id) then
				return m.Instances[object_key][instance_id]
			end if
		end for
		if m.debug then : print "getInstanceByID() - No instance exists with id - " ; instance_id : end if
		return invalid
	end function
	' ############### getInstanceByID() function - End ###############



	' ############### getInstanceByName() function - Begin ###############
	game.getInstanceByName = function(object_name as String) as Dynamic
		if m.Instances.DoesExist(object_name) then
			for each instance_key in m.Instances[object_name]
				return m.Instances[object_name][instance_key] ' Obviously only retrieves the first value
			end for
		end if
		if m.debug then : print "getInstanceByName() - No instance exists with name - " ; object_name : end if
		return invalid
	end function
	' ############### getInstanceByName() function - End ###############



	' ############### getAllInstances() function - Begin ###############
	game.getAllInstances = function(object_name as String) as Dynamic
		if m.Instances.DoesExist(object_name) then
			array = []
			for each instance_key in m.Instances[object_name]
				array.Push(m.Instances[object_name][instance_key])
			end for
			return array
		else
			if m.debug then : print "getAllInstances() - No object defined with name - " ; object_name : end if
			return invalid
		end if
	end function
	' ############### getAllInstances() function - Begin ###############



	' ############### destroyInstance() function - Begin ###############
	game.destroyInstance = function(instance as Object, call_on_destroy = true) as Void
		if instance.id <> invalid and m.Instances[instance.name].DoesExist(instance.id) then
			if m.debug then : print "destroyInstance() - Destroying Instance: "+instance.id : end if
			for each collider_key in instance.colliders
				collider = instance.colliders[collider_key]
				if type(collider.compositor_object) = "roSprite" then 
					collider.compositor_object.Remove()
				end if
			end for
			if call_on_destroy
				instance.onDestroy()
			end if
			if instance.id <> invalid and m.Instances[instance.name].DoesExist(instance.id) ' This redundency is here because if somebody would try to change rooms within the onDestroy() method the game would break.
				m.Instances[instance.name].Delete(instance.id)
				instance.Clear()
				instance.id = invalid
			end if
		else
			if m.debug then : print "destroyInstance() - Object was previously destroyed" : end if
		end if
	end function
	' ############### destroyInstance() function - End ###############



	' ############### destroyAllInstances() function - Begin ###############
	game.destroyAllInstances = function(object_name as String) as Void
		for each instance_key in m.Instances[object_name]
			m.destroyInstance(m.Instances[object_name][instance_key])
		end for
	end function
	' ############### destroyAllInstances() function - End ###############



	' ############### instanceCount() function - Begin ###############
	game.instanceCount = function(object_name as String) as Integer
		return m.Instances[object_name].Count()
	end function 
	' ############### instanceCount() function - End ###############


	' --------------------------------Begin Room Functions----------------------------------------


	' ############### defineRoom() function - Begin ###############
	game.defineRoom = function(room_name as String, room_creation_function as Function) as Void
		m.Rooms[room_name] = room_creation_function
		m.Instances[room_name] = {}
		if m.debug then : print "defineRoom() - Room function has been added" : end if
	end function
	' ############### defineRoom() function - Begin ###############



	' ############### changeRoom() function - Begin ###############
	game.changeRoom = function(room_name as String, args = {} as Object) as Boolean
		if m.Rooms[room_name] <> invalid then
			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					instance = m.Instances[object_key][instance_key]
					if instance <> invalid and instance.id <> invalid then
						instance.onChangeRoom(room_name)
					end if
				end for
			end for
			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					instance = m.Instances[object_key][instance_key]
					if instance.id <> invalid and not instance.persistent and instance.name <> m.currentRoom.name then
						m.destroyInstance(instance, false)
					end if
				end for
			end for
			if m.currentRoom <> invalid and m.currentRoom.id <> invalid then 
				m.destroyInstance(m.currentRoom, false)
			end if
			m.currentRoom = m.newEmptyObject(room_name)
			m.Rooms[room_name](m.currentRoom)
			m.currentRoomArgs = args
			m.currentRoom.onCreate(args)
			return true
		else
			if m.debug then : print "changeRoom() - A room named " + room_name + " hasn't been defined" : end if
			return false
		end if
	end function
	' ############### changeRoom() function - End ###############



	' ############### resetRoom() function - End ###############
	game.resetRoom = function() as Void
		m.changeRoom(m.currentRoom.name, m.currentRoomArgs)
	end function
	' ############### resetRoom() function - End ###############


	' --------------------------------Begin Bitmap Functions----------------------------------------


	' ############### loadBitmap() function - Begin ###############
	game.loadBitmap = function(bitmap_name as String, path as Dynamic) as Boolean
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
	game.getBitmap = function(bitmap_name as String) as Dynamic
		if m.Bitmaps.DoesExist(bitmap_name)
			return m.Bitmaps[bitmap_name]
		else
			return invalid
		end if
	end function
	' ############### getBitmap() function - End ###############



	' ############### unloadBitmap() function - Begin ###############
	game.unloadBitmap = function(bitmap_name as String) as Boolean
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
	game.registerFont = function(path as String) as Boolean
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
	game.loadFont = function(font_name as String, font as String, size as Integer, italic as Boolean, bold as Boolean) as Void
		m.Fonts[font_name] = m.font_registry.GetFont(font, size, italic, bold)
	end function
	' ############### loadFont() function - End ###############



	' ############### unloadFont() function - Begin ###############
	game.unloadFont = function(font_name as String) as Void
		m.Fonts[font_name] = invalid
	end function
	' ############### unloadFont() function - End ###############



	' ############### getFont() function - Begin ###############
	game.getFont = function(font_name as String) as Object
		return m.Fonts[font_name]
	end function
	' ############### getFont() function - End ###############


	' --------------------------------Begin Canvas Functions----------------------------------------
	' Note, canvas functions can be complicated to use manually, because the "canvas" is actually a single
	' bitmap that is being scaled and positioned. 


	' ############### canvasSetSize() function - Begin ###############
	game.canvasSetSize = function(canvas_width as Integer, canvas_height as Integer) as Void
		m.canvas.bitmap = CreateObject("roBitmap", {width: canvas_width, height: canvas_height, AlphaEnable: true})
	end function
	' ############### canvasSetSize() function - Begin ###############


	' ############### canvasGetOffset() function - Begin ###############
	game.canvasGetOffset = function() as Object
		return {x: m.canvas.offset_x, y: m.canvas.offset_y}
	end function
	' ############### canvasGetOffset() function - Begin ###############


	' ############### canvasGetScale() function - Begin ###############
	game.canvasGetScale = function() as Object
		return {x: m.canvas.scale_x, y: m.canvas.scale_y}
	end function
	' ############### canvasGetScale() function - Begin ###############


	' ############### canvasIncreaseOffset() function - Begin ###############
	' This is as Float to allow incrementing by less than 1 pixel, it is converted to integer internally
	game.canvasIncreaseOffset = function(x as Float, y as Float) as Void
		m.canvas.offset_x = m.canvas.offset_x + x
		m.canvas.offset_y = m.canvas.offset_y + y
	end function
	' ############### canvasIncreaseOffset() function - End ###############



	' ############### canvasIncreaseScale() function - Begin ###############
	game.canvasIncreaseScale = function(scale_x as Float, scale_y = invalid as Dynamic) as Void
		if scale_y = invalid
			scale_y = scale_x
		end if
		m.canvas.scale_x = m.canvas.scale_x + scale_x
		m.canvas.scale_y = m.canvas.scale_y + scale_y
		if m.canvas.scale_x < 0 then : m.canvas.scale_x = 0 : end if
		if m.canvas.scale_y < 0 then : m.canvas.scale_y = 0 : end if
	end function
	' ############### canvasIncreaseScale() function - End ###############



	' ############### canvasSetOffset() function - Begin ###############
	' This is as Float to allow incrementing by less than 1 pixel, it is converted to integer internally
	game.canvasSetOffset = function(x as Float, y as Float) as Void
		m.canvas.offset_x = x
		m.canvas.offset_y = y
	end function
	' ############### canvasSetOffset() function - End ###############



	' ############### canvasSetScale() function - Begin ###############
	game.canvasSetScale = function(scale_x as Float, scale_y = invalid as Dynamic) as Void
		if scale_y = invalid
			scale_y = scale_x
		end if
		m.canvas.scale_x = scale_x
		m.canvas.scale_y = scale_y
	end function
	' ############### canvasSetScale() function - End ###############



	' ############### canvasSetFollow() function - Begin ###############
	game.canvasSetFollow = function(instance as Object, mode = 0 as Integer) as Void
		m.canvas.follow = instance
		m.canvas.follow_mode = mode
	end function
	' ############### canvasSetFollow() function - End ###############



	' ############### canvasUnsetFollow() function - Begin ###############
	game.canvasUnsetFollow = function() as Void
		m.canvas.follow = invalid
	end function
	' ############### canvasUnsetFollow() function - End ###############



	' ############### canvasFitToScreen() function - Begin ###############
	game.canvasFitToScreen = function() as Void
		canvas_width = m.canvas.bitmap.GetWidth()
		canvas_height = m.canvas.bitmap.GetHeight()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()
		if screen_width/screen_height < canvas_width/canvas_height then
			m.canvas.scale_x = screen_width/canvas_width
			m.canvas.scale_y = m.canvas.scale_x
			m.canvas.offset_x = 0
			m.canvas.offset_y = (screen_height-(screen_width/(canvas_width/canvas_height)))/2
		else if screen_width/screen_height > canvas_width/canvas_height then
			m.canvas.scale_x = screen_height/canvas_height
			m.canvas.scale_y = m.canvas.scale_x
			m.canvas.offset_x = (screen_width-(screen_height*(canvas_width/canvas_height)))/2
			m.canvas.offset_y = 0
		else
			m.canvas.offset_x = 0
			m.canvas.offset_y = 0
			scale_difference = screen_width/canvas_width
			m.canvas.scale_x = 1*scale_difference
			m.canvas.scale_y = 1*scale_difference
		end if
	end function
	' ############### canvasFitToScreen() function - End ###############



	' ############### canvasCenterToScreen() function - Begin ###############
	game.canvasCenterToScreen = function() as Void
		m.canvas.offset_x = m.screen.GetWidth()/2-(m.canvas.scale_x*m.canvas.bitmap.GetWidth())/2
		m.canvas.offset_y = m.screen.GetHeight()/2-(m.canvas.scale_y*m.canvas.bitmap.GetHeight())/2
	end function
	' ############### canvasCenterToScreen() function - End ###############



	' ############### canvasCenterToInstance() function - Begin ###############
	game.canvasCenterToInstance = function(instance as Object, mode = 0 as Integer) as dynamic

		if instance = invalid or instance.id = invalid
			if m.debug then : print "canvasCenterToInstance() - Provided instance doesn't exist" : end if
			return invalid
		end if
		canvas_width = m.canvas.bitmap.GetWidth()
		canvas_height = m.canvas.bitmap.GetHeight()
		screen_width = m.screen.GetWidth()
		screen_height = m.screen.GetHeight()

		offset_x = 0-instance.x*m.canvas.scale_x+screen_width/2
		offset_y = 0-instance.y*m.canvas.scale_y+screen_height/2

		if mode = 0
			minimum_offset_x = -((canvas_width*m.canvas.scale_x)-screen_width)
			minimum_offset_y = -((canvas_height*m.canvas.scale_y)-screen_height)

			if offset_x >= minimum_offset_x and offset_x <= 0
				m.canvas.offset_x = offset_x
			else if not offset_x >= minimum_offset_x
				m.canvas.offset_x = minimum_offset_x
			else if not offset_x <= 0 
				m.canvas.offset_x = 0
			end if

			if offset_y >= minimum_offset_y and offset_y <=0
				m.canvas.offset_y = offset_y
			else if not offset_y >= minimum_offset_y
				m.canvas.offset_y = minimum_offset_y
			else if not offset_y <= 0
				m.canvas.offset_y = 0
			end if

			if canvas_width*m.canvas.scale_x < screen_width
				m.canvas.offset_x = (screen_width-canvas_width*m.canvas.scale_x)/2
			end if

			if canvas_height*m.canvas.scale_y < screen_height
				m.canvas.offset_y = (screen_height-canvas_height*m.canvas.scale_y)/2
			end if

		else if mode = 1

			m.canvas.offset_x = offset_x
			m.canvas.offset_y = offset_y
			
		end if

	end function
	' ############### canvasCenterToInstance() function - End ###############


	' --------------------------------Begin Audio Functions----------------------------------------


	' ############### musicPlay() function - Begin ###############
	game.musicPlay = function(path as String, loop = false as Boolean) as Boolean
		if m.filesystem.Exists(path) then
			m.audioplayer.stop()
			m.audioplayer.ClearContent()
		    song = {}
		    song.url = path
		    m.audioplayer.AddContent(song)
		    m.audioplayer.SetLoop(loop)
		    m.audioPlayer.play()
			return true
			if m.debug then : print "musicPlay() - Playing music from path: " ; path : end if
		else
			if m.debug then : print "musicPlay() - No file exists at path: " ; path : end if
			return false
		end if
	end function
	' ############### musicPlay() function - End ###############



	' ############### musicStop() function - Begin ###############
	game.musicStop = function() as Void
		m.audioplayer.stop()
	end function
	' ############### musicStop() function - End ###############



	' ############### musicPause() function - Begin ###############
	game.musicPause = function() as Void
		m.audioplayer.pause()
	end function
	' ############### musicPause() function - End ###############



	' ############### musicResume() function - Begin ###############
	game.musicResume = function() as Void
		m.audioplayer.resume()
	end function
	' ############### musicResume() function - End ###############



	' ############### loadSound() function - Begin ###############
	game.loadSound = function(sound_name as String, path as String) as Void
		m.Sounds[sound_name] = CreateObject("roAudioResource", path)
	end function
	' ############### loadSound() function - End ###############



	' ############### playSound() function - Begin ###############
	game.playSound = function(sound_name as String, volume = 100 as Integer) as Boolean
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



	' ############### newAsyncUrlTransfer() function - Begin ###############
	game.newAsyncUrlTransfer = function()
		UrlTransfer = CreateObject("roUrlTransfer")
		UrlTransfer.SetMessagePort(m.url_port)
		m.urltransfers[UrlTransfer.GetIdentity().ToStr()] = UrlTransfer
		return UrlTransfer
	end function
	' ############### newAsyncUrlTransfer() function - End ###############

	' ############### setInputInstance() function - Begin ###############
	game.setInputInstance = function(instance)
		m.input_instance = instance.id
	end function
	' ############### setInputInstance() function - End ###############

	' ############### unsetInputInstance() function - Begin ###############
	game.unsetInputInstance = function()
		m.input_instance = invalid
	end function
	' ############### unsetInputInstance() function - End ###############

	' ############### postGameEvent() function - Begin ###############
	game.postGameEvent = function(event, data = {})
		for each object_key in m.Instances
			for each instance_key in m.Instances[object_key]
				instance = m.Instances[object_key][instance_key]
				if instance <> invalid and instance.id <> invalid
					instance.onGameEvent(event, data)
				end if
			end for
		end for
	end function
	' ############### postGameEvent() function - End ###############

	return game
end function


' -----------------------Utilities Used By Game Engine---------------------------

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
