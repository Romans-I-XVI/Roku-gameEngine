' -------------------------Function To Create Main Game Object------------------------

function new_game(canvas_width, canvas_height, canvas_as_screen_if_possible = false)

	' ############### Create Initial Object - Begin ###############

	' Create the main game engine object
	game = {
		' ****BEGIN - For Internal Use, Do Not Manually Alter****
		debugging: {
			draw_colliders: false
			draw_safe_zones: false
			limit_frame_rate: 0
		}
		canvas_is_screen: false
		background_color: &h000000FF
		running: true
		paused: false
		sorted_instances: []
		buttonHeld: -1
		buttonHeldTime: 0
		input_instance: invalid
		current_input_instance: invalid
		dt: 0
		FakeDT: invalid
		dtTimer: CreateObject("roTimespan")
		pauseTimer: CreateObject("roTimespan")
		buttonHeldTimer: CreateObject("roTimespan")
		currentID: 0
		shouldUseIntegerMovement: false
		enableAudioGuideSuppression: true
		empty_bitmap: CreateObject("roBitmap", {width: 1, height: 1, AlphaEnable: false})
		device: CreateObject("roDeviceInfo")
		urltransfers: {}
		url_port: CreateObject("roMessagePort")
		ecp_input_port: CreateObject("roMessagePort")
		ecp_input: CreateObject("roInput")
		compositor: CreateObject("roCompositor")
		filesystem: CreateObject("roFileSystem")
		screen_port: CreateObject("roMessagePort")
		audioplayer: CreateObject("roAudioPlayer")
		music_port: CreateObject("roMessagePort")
		font_registry: CreateObject("roFontRegistry")
		screen: invalid
		canvas: {
			bitmap: CreateObject("roBitmap", {width: canvas_width, height: canvas_height, AlphaEnable: true})
			offset_x: 0
			offset_y: 0
			scale_x: 1.0
			scale_y: 1.0
		}
		' ****END - For Internal Use, Do Not Manually Alter****

		' ****Variables****
		currentRoom: invalid
		currentRoomArgs: {}
		Instances: {} ' This holds all of the game object instances
		Statics: {} ' This holds all static variables for a given object type
		Objects: {} ' This holds the object definitions by name (the object creation functions)
		Rooms: {} ' This holds the room definitions by name (the room creation functions)
		Interfaces: {} ' This holds the interface definitions by name.
		Bitmaps: {} ' This holds the loaded bitmaps by name
		Sounds: {} ' This holds the loaded sounds by name
		Fonts: {} ' This holds the loaded fonts by name

		' These are just placeholder reminders of what functions get added to the game
		' ****Functions****
		Update: invalid
		newEmptyObject: invalid
		drawColliders: invalid

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
		canvasSetOffset: invalid
		canvasSetScale: invalid
		canvasFitToScreen: invalid
		canvasCentertoScreen: invalid
		canvasCenterToInstance: invalid

		musicPlay: invalid
		musicStop: invalid
		musicPause: invalid
		musicResume: invalid
		loadSound: invalid
		playSound: invalid


	}

	' Set up the screen
	UIResolution = game.device.getUIResolution()
	SupportedResolutions = game.device.GetSupportedGraphicsResolutions()
	FHD_Supported = false
	for i = 0 to SupportedResolutions.Count() - 1
		if SupportedResolutions[i].name = "FHD"
			FHD_Supported = true
		end if
	end for

	if UIResolution.name = "SD"
		game.screen = CreateObject("roScreen", true, 854, 626)
	else
		if canvas_width <= 854
			game.screen = CreateObject("roScreen", true, 854, 480)
		else if canvas_width <= 1280 or not FHD_Supported
			game.screen = CreateObject("roScreen", true, 1280, 720)
		else
			game.screen = CreateObject("roScreen", true, 1920, 1080)
		end if
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

	' Set up the input port
	game.ecp_input.SetMessagePort(game.ecp_input_port)

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
	game.Play = function() as void

		audio_guide_suppression_roURLTransfer = CreateObject("roURLTransfer")
		audio_guide_suppression_roURLTransfer.SetUrl("http://localhost:8060/keydown/Backspace")
		audio_guide_suppression_ticker = 0

		m.running = true

		while m.running

			if m.input_instance <> invalid and m.getInstanceByID(m.input_instance) = invalid
				m.input_instance = invalid
			end if
			m.current_input_instance = m.input_instance
			m.compositor.Draw() ' For some reason this has to be called or the colliders don't remove themselves from the compositor ¯\(°_°)/¯

			m.dt = m.dtTimer.TotalMilliseconds()/1000
			if m.FakeDT <> invalid
				m.dt = m.FakeDT
			end if
			m.dtTimer.Mark()
			url_msg = m.url_port.GetMessage()
			universal_control_events = []
			screen_msg = m.screen_port.GetMessage()
			ecp_msg = m.ecp_input_port.GetMessage()
			while screen_msg <> invalid
				if type(screen_msg) = "roUniversalControlEvent" and screen_msg.GetInt() <> 11
					universal_control_events.Push(screen_msg)
					if screen_msg.GetInt() < 100
						m.buttonHeld = screen_msg.GetInt()
						m.buttonHeldTimer.Mark()
					else
						m.buttonHeld = -1
						if m.enableAudioGuideSuppression
							if screen_msg.GetInt() = 110
								audio_guide_suppression_ticker++
								if audio_guide_suppression_ticker = 3
									audio_guide_suppression_roURLTransfer.AsyncPostFromString("")
									audio_guide_suppression_ticker = 0
								end if
							else
								audio_guide_suppression_ticker = 0
							end if
						end if
						m.buttonHeldTime = m.buttonHeldTimer.TotalMilliseconds()
					end if
				end if
				screen_msg = m.screen_port.GetMessage()
			end while

			music_msg = m.music_port.GetMessage()


			' --------------------Begin giant loop for processing all game objects----------------
			' There is a goto after every call to an override function, this is so if the instance deleted itself no futher calls will be attempted on the instance.
			started_paused = m.paused
			for i = m.sorted_instances.Count()-1 to 0 step -1
				instance = m.sorted_instances[i]
				if instance = invalid or instance.id = invalid or not instance.enabled or (started_paused and instance.pauseable) : goto end_of_for_loop  : end if


				' --------------------First process the onButton() function--------------------
				for each msg in universal_control_events
					if instance.onButton <> invalid and (m.current_input_instance = invalid or m.current_input_instance = instance.id)
						instance.onButton(msg.GetInt())
						if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
					end if

					if instance.onECPKeyboard <> invalid and msg.GetChar() <> 0 and msg.GetChar() = msg.GetInt()
						instance.onECPKeyboard(Chr(msg.GetChar()))
						if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
					end if
				end for
				if m.buttonHeld <> -1 then
					' Button release codes are 100 plus the button press code
					' This shows a button held code as 1000 plus the button press code
					if instance.onButton <> invalid and (m.current_input_instance = invalid or m.current_input_instance = instance.id)
						instance.onButton(1000+m.buttonHeld)
						if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
					end if
				end if

				' -------------------Then send the audioplayer event msg if applicable-------------------
				if instance.onAudioEvent <> invalid and type(music_msg) = "roAudioPlayerEvent" then
					instance.onAudioEvent(music_msg)
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
				end if

				' -------------------Then send the ecp input events if applicable-------------------
				if instance.onECPInput <> invalid and type(ecp_msg) = "roInputEvent" and ecp_msg.isInput()
					instance.onECPInput(ecp_msg.GetInfo())
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
				end if

				' -------------------Then send the urltransfer event msg if applicable-------------------
				if instance.onUrlEvent <> invalid and type(url_msg) = "roUrlEvent" then
					instance.onUrlEvent(url_msg)
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
				end if


				' -------------------Then process the onUpdate() function----------------------
				if instance.onUpdate <> invalid
					instance.onUpdate(m.dt)
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
				end if


				' -------------------- Then handle the object movement--------------------
				if m.shouldUseIntegerMovement
					instance.x = instance.x + cint(instance.xspeed * 60 * m.dt)
					instance.y = instance.y + cint(instance.yspeed * 60 * m.dt)
				else
					instance.x = instance.x + instance.xspeed * 60 * m.dt
					instance.y = instance.y + instance.yspeed * 60 * m.dt
				end if

				' ---------------- Give a space for any processing to happen just before collision checking occurs ------------
				if instance.onPreCollision <> invalid
					instance.onPreCollision()
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
				end if

				' -------------------Then handle collisions and call onCollision() for each collision---------------------------
				if instance.onCollision <> invalid
					for each collider_key in instance.colliders
						collider = instance.colliders[collider_key]
						if collider <> invalid then
							if collider.enabled then
								collider.compositor_object.SetMemberFlags(collider.member_flags)
								collider.compositor_object.SetCollidableFlags(collider.collidable_flags)
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
								collider.compositor_object.SetMemberFlags(0)
								collider.compositor_object.SetCollidableFlags(0)
							end if
						else
							if instance.colliders.DoesExist(collider_key)
								instance.colliders.Delete(collider_key)
							end if
						end if
					end for
				end if
				if instance = invalid or instance.id = invalid then : goto end_of_for_loop : end if

				' ---------------- Give a space for any processing to happen just after collision checking occurs ------------
				if instance.onPostCollision <> invalid
					instance.onPostCollision()
					if instance = invalid or instance.id = invalid then : goto end_of_for_loop  : end if
				end if

				' --------------Adjust compositor collider at end of loop so collider is accurate for collision checking from other objects-------------
				for each collider_key in instance.colliders
					collider = instance.colliders[collider_key]
					if collider <> invalid then
						if collider.enabled then
							collider.compositor_object.SetMemberFlags(collider.member_flags)
							collider.compositor_object.SetCollidableFlags(collider.collidable_flags)
							if collider.type = "circle" then
								collider.compositor_object.GetRegion().SetCollisionCircle(collider.offset_x, collider.offset_y, collider.radius)
							else if collider.type = "rectangle" then
								collider.compositor_object.GetRegion().SetCollisionRectangle(collider.offset_x, collider.offset_y, collider.width, collider.height)
							end if
							collider.compositor_object.MoveTo(instance.x, instance.y)
						else
							collider.compositor_object.SetMemberFlags(0)
							collider.compositor_object.SetCollidableFlags(0)
						end if
					else
						if instance.colliders.DoesExist(collider_key)
							instance.colliders.Delete(collider_key)
						end if
					end if
				end for

				end_of_for_loop:

				if instance = invalid or instance.id = invalid then
					m.sorted_instances.Delete(i)
				end if

			end for

			' ----------------------Clear the screen before drawing instances-------------------------
			if m.background_color <> invalid
				m.canvas.bitmap.Clear(m.background_color)
			end if

			' ----------------------Then draw all of the instances and call onDrawBegin() and onDrawEnd()-------------------------
			m.sorted_instances.SortBy("depth")
			for i = m.sorted_instances.Count()-1 to 0 step -1
				instance = m.sorted_instances[i]
				if instance = invalid or instance.id = invalid : goto end_of_draw_loop : end if
				if instance.onDrawBegin <> invalid
					instance.onDrawBegin(m.canvas.bitmap)
					if instance = invalid or instance.id = invalid : goto end_of_draw_loop  : end if
				end if
				for each image in instance.images
					image.Draw()
				end for
				if instance.onDrawEnd <> invalid
					instance.onDrawEnd(m.canvas.bitmap)
				end if
				end_of_draw_loop:
			end for

			' Draw Debug Related Items
			if m.debugging.draw_colliders
				for i = m.sorted_instances.Count()-1 to 0 step -1
					instance = m.sorted_instances[i]
					if instance <> invalid and instance.id <> invalid and instance.colliders <> invalid
						m.drawColliders(instance)
					end if
				end for
			end if

			' -------------------Draw everything to the screen----------------------------
			if not m.canvas_is_screen
				m.screen.DrawScaledObject(m.canvas.offset_x, m.canvas.offset_y, m.canvas.scale_x, m.canvas.scale_y, m.canvas.bitmap)
			end if

			if m.debugging.draw_safe_zones
				m.drawSafeZones()
			end if

			m.screen.SwapBuffers()

			if m.debugging.limit_frame_rate > 0 and m.dtTimer.TotalMilliseconds() > 0
				while 1000 / m.dtTimer.TotalMilliseconds() > m.debugging.limit_frame_rate
					sleep(1)
				end while
			end if

			' ------------------Destroy the UrlTransfer object if it has returned an event------------------
			if type(url_msg) = "roUrlEvent"
				url_transfer_id_string = url_msg.GetSourceIdentity().ToStr()
				if m.urltransfers.DoesExist(url_transfer_id_string) then
					m.urltransfers.Delete(url_transfer_id_string)
				end if
			end if

		end while

	end function
	' ################################################################ Play() function - End #####################################################################################################



	' ################################################################ newEmptyObject() function - Begin #####################################################################################################
	game.newEmptyObject = function(object_name as string) as object
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
			images_aa_reference: {}

			' -----Methods-----
			onUpdate: invalid
			onPreCollision: invalid
			onCollision: invalid
			onPostCollision: invalid
			onDrawBegin: invalid
			onDrawEnd: invalid
			onButton: invalid
			onECPKeyboard: invalid
			onECPInput: invalid
			onAudioEvent: invalid
			onPause: invalid
			onResume: invalid
			onUrlEvent: invalid
			onGameEvent: invalid
			onChangeRoom: invalid
			onDestroy: invalid
			addColliderCircle: invalid
			addColliderRectangle: invalid
			removeCollider: invalid
			addImage: invalid
			addAnimatedImage: invalid
			addImageObject: invalid
			removeImage: invalid
			getStaticVariable: invalid
			setStaticVariable: invalid
			addInterface: invalid
			hasInterface: invalid
		}

		new_object.onCreate = function(args)
		end function

		' This is the structure of the methods that can be added to an object

		' new_object.onUpdate = function(deltaTime)
		' end function

		' new_object.onCollision = function(collider, other_collider, other_instance)
		' end function

		' new_object.onDrawBegin = function(canvas)
		' end function

		' new_object.onDrawEnd = function(canvas)
		' end function

		' new_object.onButton = function(code)
		' 	' -------Button Code Reference--------
		' 	' Button  When pressed  When released When Held

		' 	' Back  0  100 1000
		' 	' Up  2  102 1002
		' 	' Down  3  103 1003
		' 	' Left  4  104 1004
		' 	' Right  5  105 1005
		' 	' Select  6  106 1006
		' 	' Instant Replay  7  107 1007
		' 	' Rewind  8  108 1008
		' 	' Fast  Forward  9  109 1009
		' 	' Info  10  110 1010
		' 	' Play  13  113 1013
		' end function

		' new_object.onECPKeyboard = function(char)
		' end function

		' new_object.onECPInput = function(data)
		' end function

		' new_object.onAudioEvent = function(msg)
		' end function

		' new_object.onPause = function()
		' end function

		' new_object.onResume = function(pause_time)
		' end function

		' new_object.onUrlEvent = function(msg)
		' end function

		' new_object.onGameEvent = function(event, data)
		' end function

		' new_object.onChangeRoom = function(new_room)
		' end function

		' new_object.onDestroy = function()
		' end function


		new_object.addColliderCircle = function(collider_name, radius, offset_x = 0, offset_y = 0, enabled = true)
			collider = {
				type: "circle",
				name: collider_name,
				enabled: enabled,
				radius: radius,
				offset_x: offset_x,
				offset_y: offset_y,
				member_flags: 1
				collidable_flags: 1
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
				print "addColliderCircle() - Collider Name Already Exists: " + collider_name
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
				member_flags: 1
				collidable_flags: 1
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
				print "addColliderRectangle() - Collider Name Already Exists: " + collider_name
			end if
		end function

		new_object.getCollider = function(collider_name)
			if m.colliders.DoesExist(collider_name)
				return m.colliders[collider_name]
			else
				return invalid
			end if
		end function

		new_object.removeCollider = function(collider_name)
			if m.colliders[collider_name] <> invalid then
				if type(m.colliders[collider_name].compositor_object) = "roSprite" then : m.colliders[collider_name].compositor_object.Remove() : end if
				m.colliders.Delete(collider_name)
			end if
		end function

		new_object.addImage = function(image_name as string, region as object, args = {} as object, insert_position = invalid as dynamic) as dynamic
			image_object = {
				' --------------Values That Can Be Changed------------
				offset_x: 0 ' The offset of the image.
				offset_y: 0
				scale_x: 1.0 ' The image scale.
				scale_y: 1.0
				rotation: 0
				color: &hFFFFFF ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
				alpha: 255 ' Change the image alpha (transparency).
				enabled: true ' Whether or not the image will be drawn.
				draw_to: m.game.getCanvas()
				Draw: invalid ' The draw method

				' -------------Never To Be Manually Changed-----------------
				' These values should never need to be manually changed.
				owner: m
				region: region
			}

			image_object.Draw = function()
				if m.enabled
					x = m.owner.x + m.offset_x
					y = m.owner.y + m.offset_y
					rgba = (m.color << 8) + int(m.alpha)
					if m.scale_x = 1 and m.scale_y = 1 and m.rotation = 0
						m.draw_to.DrawObject(x, y, m.region, rgba)
					else if m.rotation = 0
						m.draw_to.DrawScaledObject(x, y, m.scale_x, m.scale_y, m.region, rgba)
					else
						m.draw_to.DrawRotatedObject(x, y, -m.rotation, m.region, rgba)
					end if
				end if
			end function

			image_object.Append(args)

			return m.addImageObject(image_name, image_object, insert_position)
		end function

		new_object.addAnimatedImage = function(image_name as string, regions as object, args = {} as object, insert_position = invalid as dynamic) as dynamic
			image_object = {
				' --------------Values That Can Be Changed------------
				offset_x: 0 ' The offset of the image.
				offset_y: 0
				scale_x: 1.0 ' The image scale.
				scale_y: 1.0
				rotation: 0
				color: &hFFFFFF ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
				alpha: 255 ' Change the image alpha (transparency).
				enabled: true ' Whether or not the image will be drawn.
				draw_to: m.game.getCanvas()
				Draw: invalid ' The draw method

				' -------------Only To Be Changed For Animation---------------
				' The following values should only be changed if the image is a spritesheet that needs to be animated.
				' The spritesheet can have any assortment of multiple columns and rows.
				index: 0 ' This would not normally be changed manually, but if you wanted to stop on a specific image in the spritesheet this could be set.
				regions: regions
				animation_speed: 0 ' The time in milliseconds for a single cycle through the animation to play.
				animation_tween: "LinearTween"
				Animate: invalid ' The method that handles animation
				onResume: invalid ' This is called when the game is resumed, paused_time as integer is passed in

				' -------------Never To Be Manually Changed-----------------
				' These values should never need to be manually changed.
				owner: m
				animation_timer: CreateObject_GameTimeSpan()
				_tweens_reference: GetTweens()
			}

			image_object.Draw = function()
				if m.enabled
					if m.animation_speed > 0 and not m.owner.game.isPaused()
						m.Animate()
					end if

					region = m.regions[m.index]
					x = m.owner.x + m.offset_x
					y = m.owner.y + m.offset_y
					rgba = (m.color << 8) + int(m.alpha)
					if m.scale_x = 1 and m.scale_y = 1 and m.rotation = 0
						m.draw_to.DrawObject(x, y, region, rgba)
					else if m.rotation = 0
						m.draw_to.DrawScaledObject(x, y, m.scale_x, m.scale_y, region, rgba)
					else
						m.draw_to.DrawRotatedObject(x, y, -m.rotation, region, rgba)
					end if
				end if
			end function

			image_object.Animate = function()
				frame_count = m.regions.Count()
				current_time = m.animation_timer.TotalMilliseconds()
				if current_time > m.animation_speed
					current_time -= m.animation_speed
					m.animation_timer.RemoveTime(m.animation_speed)
				end if
				m.index = m._tweens_reference[m.animation_tween](0, frame_count, current_time, m.animation_speed)
				if m.index > frame_count - 1
					m.index = frame_count - 1
				else if m.index < 0
					m.index = 0
				end if
			end function

			image_object.onResume = function(paused_time as integer)
				m.animation_timer.RemoveTime(paused_time)
			end function

			image_object.Append(args)

			return m.addImageObject(image_name, image_object, insert_position)
		end function

		new_object.addImageObject = function(image_name as string, image_object as object, insert_position = invalid as dynamic) as dynamic
			image_object.name = image_name

			if m.getImage(image_object.name) <> invalid
				print "addImageObject() - An image named - " + image_object.name + " - already exists"
				return invalid
			end if

			m.images_aa_reference[image_object.name] = image_object
			if insert_position = invalid
				m.images.Push(image_object)
			else if insert_position = 0
				m.images.Unshift(image_object)
			else if insert_position < m.images.Count()
				ArrayInsert(m.images, insert_position, image_object)
			else
				m.images.Push(image_object)
			end if

			return image_object
		end function

		new_object.getImage = function(image_name) as dynamic
			return m.images_aa_reference[image_name]
		end function

		new_object.removeImage = function(image_name)
			m.images_aa_reference.Delete(image_name)
			if m.images.Count() > 0
				for i = 0 to m.images.Count()-1
					if m.images[i].name = image_name
						m.images.Delete(i)
						exit for
					end if
				end for
			end if
		end function

		new_object.getStaticVariable = function(static_variable_name as string)
			if m.game.Statics.DoesExist(m.name) and m.game.Statics[m.name].DoesExist(static_variable_name)
				return m.game.Statics[m.name][static_variable_name]
			else
				return invalid
			end if
		end function

		new_object.setStaticVariable = function(static_variable_name as string, static_variable_value)
			if m.game.Statics.DoesExist(m.name)
				m.game.Statics[m.name][static_variable_name] = static_variable_value
			end if
		end function

		new_object.addInterface = function(interface_name as string) as void
			interface = {owner: m}
			m.game.Interfaces[interface_name](interface)
			m[interface_name] = interface
		end function

		new_object.hasInterface = function(interface_name as string) as boolean
			return (m.DoesExist(interface_name) and m[interface_name] <> invalid)
		end function

		m.Instances[new_object.name][new_object.id] = new_object
		m.sorted_instances.Push(new_object)

		return new_object
	end function
	' ################################################################ newEmptyObject() function - End #####################################################################################################



	' ############### DebugDrawColliders() function - Begin ###############
	game.debugDrawColliders = function(enabled as boolean) as void
		m.debugging.draw_colliders = enabled
	end function
	' ############### DebugDrawColliders() function - End ###############

	' ############### DebugDrawSafeZones() function - Begin ###############
	game.debugDrawSafeZones = function(enabled as boolean) as void
		m.debugging.draw_safe_zones = enabled
	end function
	' ############### DebugDrawSafeZones() function - End ###############

	' ############### DebugLimitFrameRate() function - Begin ###############
	game.debugLimitFrameRate = function(limit_frame_rate as integer) as void
		m.debugging.limit_frame_rate = limit_frame_rate
	end function
	' ############### DebugLimitFrameRate() function - End ###############

	' ############### DrawColliders() function - Begin ###############
	game.drawColliders = function(instance as object, color = &hFF0000FF as integer) as void
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
	game.drawSafeZones = function() as void
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
	game.End = function() as void
		m.running = false
	end function
	' ############### End() function - End ###############



	' ############### Pause() function - Begin ###############
	game.Pause = function() as void
		if not m.paused then
			m.paused = true

			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					instance = m.Instances[object_key][instance_key]
					if instance <> invalid and instance.id <> invalid and instance.onPause <> invalid
						instance.onPause()
					end if
				end for
			end for

			m.pauseTimer.Mark()
		end if
	end function
	' ############### Pause() function - End ###############



	' ############### Resume() function - Begin ###############
	game.Resume = function() as dynamic
		if m.paused then
			m.paused = false
			paused_time = m.pauseTimer.TotalMilliseconds()

			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					instance = m.Instances[object_key][instance_key]
					for each image in instance.images
						if image.DoesExist("onResume") and image.onResume <> invalid
							image.onResume(paused_time)
						end if
					end for
					if instance <> invalid and instance.id <> invalid and instance.onResume <> invalid
						instance.onResume(paused_time)
					end if
				end for
			end for

			return paused_time
		end if
		return invalid
	end function
	' ############### Resume() function - End ###############



	' ############### isPaused() function - Begin ###############
	game.isPaused = function() as boolean
		return m.paused
	end function
	' ############### isPaused() function - End ###############

	' ############### setBackgroundColor() function - Begin ###############
	game.setBackgroundColor = function(color as dynamic) as void
		m.background_color = color
	end function
	' ############### setBackgroundColor() function - Begin ###############

	' ############### getDeltaTime() function - Begin ###############
	game.getDeltaTime = function() as float
		return m.dt
	end function
	' ############### getDeltaTime() function - Begin ###############


	' ############### getRoom() function - Begin ###############
	game.getRoom = function() as object
		return m.currentRoom
	end function
	' ############### getRoom() function - Begin ###############



	' ############### getCanvas() function - Begin ###############
	game.getCanvas = function() as object
		return m.canvas.bitmap
	end function
	' ############### getCanvas() function - Begin ###############



	' ############### getScreen() function - Begin ###############
	game.getScreen = function() as object
		return m.screen
	end function
	' ############### getScreen() function - Begin ###############



	' ############### resetScreen() function - Begin ###############
	game.resetScreen = function() as void
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

			' This is so all instances that have images that draw to the screen get updated with the new screen.
			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					instance = m.Instances[object_key][instance_key]
					if instance <> invalid and instance.id <> invalid and instance.DoesExist("images")
						for each image in instance.images
							if type(image.draw_to) = "roScreen"
								image.draw_to = m.screen
							end if
						end for
					end if
				end for
			end for
		end if
	end function
	' ############### resetScreen() function - Begin ###############


	' --------------------------------Begin Object Functions----------------------------------------


	' ############### defineObject() function - Begin ###############
	game.defineObject = function(object_name as string, object_creation_function as function) as void
		m.Objects[object_name] = object_creation_function
		m.Instances[object_name] = {}
		m.Statics[object_name] = {}
	end function
	' ############### defineObject() function - End ###############



	' ############### defineInterface() function - Begin ###############
	game.defineInterface = function(interface_name as string, interface_creation_function as function) as void
		m.Interfaces[interface_name] = interface_creation_function
	end function
	' ############### defineInterface() function - End ###############



	' ############### createInstance() function - Begin ###############
	game.createInstance = function(object_name as string, args = {} as object) as dynamic
		if m.Objects.DoesExist(object_name)
			new_instance = m.newEmptyObject(object_name)
			m.Objects[object_name](new_instance)
			new_instance.onCreate(args)
			return new_instance
		else
			return invalid
		end if
	end function
	' ############### createInstance() function - End ###############



	' ############### getInstanceByID() function - Begin ###############
	game.getInstanceByID = function(instance_id as string) as dynamic
		for each object_key in m.Instances
			if m.Instances[object_key].DoesExist(instance_id) then
				return m.Instances[object_key][instance_id]
			end if
		end for
		return invalid
	end function
	' ############### getInstanceByID() function - End ###############



	' ############### getInstanceByName() function - Begin ###############
	game.getInstanceByName = function(object_name as string) as dynamic
		if m.Instances.DoesExist(object_name) then
			for each instance_key in m.Instances[object_name]
				return m.Instances[object_name][instance_key] ' Obviously only retrieves the first value
			end for
		end if
		return invalid
	end function
	' ############### getInstanceByName() function - End ###############



	' ############### getAllInstances() function - Begin ###############
	game.getAllInstances = function(object_name as string) as dynamic
		if m.Instances.DoesExist(object_name) then
			array = []
			for each instance_key in m.Instances[object_name]
				array.Push(m.Instances[object_name][instance_key])
			end for
			return array
		else
			return invalid
		end if
	end function
	' ############### getAllInstances() function - Begin ###############



	' ############### getAllInstancesWithInterface() function - Begin ###############
	game.getAllInstancesWithInterface = function(interface_name as string) as dynamic
		if m.Interfaces.DoesExist(interface_name)
			array = []
			for each instance in m.sorted_instances
				if instance <> invalid and instance.id <> invalid and instance.hasInterface(interface_name)
					array.Push(instance)
				end if
			end for

			return array
		else
			return invalid
		end if
	end function
	' ############### getAllInstancesWithInterface() function - Begin ###############



	' ############### destroyInstance() function - Begin ###############
	game.destroyInstance = function(instance as object, call_on_destroy = true) as void
		if instance <> invalid and instance.id <> invalid and m.Instances[instance.name].DoesExist(instance.id) then
			for each collider_key in instance.colliders
				collider = instance.colliders[collider_key]
				if type(collider.compositor_object) = "roSprite" then
					collider.compositor_object.Remove()
				end if
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
	end function
	' ############### destroyInstance() function - End ###############



	' ############### destroyAllInstances() function - Begin ###############
	game.destroyAllInstances = function(object_name as string, call_on_destroy = true) as void
		for each instance_key in m.Instances[object_name]
			m.destroyInstance(m.Instances[object_name][instance_key], call_on_destroy)
		end for
	end function
	' ############### destroyAllInstances() function - End ###############



	' ############### instanceCount() function - Begin ###############
	game.instanceCount = function(object_name as string) as integer
		return m.Instances[object_name].Count()
	end function
	' ############### instanceCount() function - End ###############


	' --------------------------------Begin Room Functions----------------------------------------


	' ############### defineRoom() function - Begin ###############
	game.defineRoom = function(room_name as string, room_creation_function as function) as void
		m.Rooms[room_name] = room_creation_function
		m.Instances[room_name] = {}
		m.Statics[room_name] = {}
	end function
	' ############### defineRoom() function - Begin ###############



	' ############### changeRoom() function - Begin ###############
	game.changeRoom = function(room_name as string, args = {} as object) as boolean
		if m.Rooms[room_name] <> invalid then
			for each object_key in m.Instances
				for each instance_key in m.Instances[object_key]
					instance = m.Instances[object_key][instance_key]
					if instance <> invalid and instance.id <> invalid and instance.onChangeRoom <> invalid then
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
			print "changeRoom() - A room named " + room_name + " hasn't been defined"
			return false
		end if
	end function
	' ############### changeRoom() function - End ###############



	' ############### resetRoom() function - End ###############
	game.resetRoom = function() as void
		m.changeRoom(m.currentRoom.name, m.currentRoomArgs)
	end function
	' ############### resetRoom() function - End ###############


	' --------------------------------Begin Bitmap Functions----------------------------------------


	' ############### loadBitmap() function - Begin ###############
	game.loadBitmap = function(bitmap_name as string, path as dynamic) as boolean
		if type(path) = "roAssociativeArray" then
			if path.width <> invalid and path.height <> invalid and path.AlphaEnable <> invalid then
				m.Bitmaps[bitmap_name] = CreateObject("roBitmap", path)
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
				return true
			else
				print "loadBitmap() - Bitmap not loaded, file must be of type .png or .jpg"
				return false
			end if
		else
			print "loadBitmap() - Bitmap not created, invalid path or object properties provided"
			return false
		end if
	end function
	' ############### loadBitmap() function - End ###############



	' ############### getBitmap() function - Begin ###############
	game.getBitmap = function(bitmap_name as string) as dynamic
		return m.Bitmaps[bitmap_name]
	end function
	' ############### getBitmap() function - End ###############



	' ############### unloadBitmap() function - Begin ###############
	game.unloadBitmap = function(bitmap_name as string)
		m.Bitmaps[bitmap_name] = invalid
	end function
	' ############### unloadBitmap() function - End ###############


	' --------------------------------Begin Font Functions----------------------------------------


	' ############### registerFont() function - Begin ###############
	game.registerFont = function(path as string) as boolean
		if m.filesystem.Exists(path) then
			path_object = CreateObject("roPath", path)
			parts = path_object.Split()
			if parts.extension = ".ttf" or parts.extension = ".otf" then
				m.font_registry.register(path)
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
	game.loadFont = function(font_name as string, font as string, size as integer, italic as boolean, bold as boolean) as void
		m.Fonts[font_name] = m.font_registry.GetFont(font, size, italic, bold)
	end function
	' ############### loadFont() function - End ###############



	' ############### unloadFont() function - Begin ###############
	game.unloadFont = function(font_name as string) as void
		m.Fonts[font_name] = invalid
	end function
	' ############### unloadFont() function - End ###############



	' ############### getFont() function - Begin ###############
	game.getFont = function(font_name as string) as object
		return m.Fonts[font_name]
	end function
	' ############### getFont() function - End ###############


	' --------------------------------Begin Canvas Functions----------------------------------------

	' ############### canvasSetSize() function - Begin ###############
	game.canvasSetSize = function(canvas_width as integer, canvas_height as integer) as void
		m.canvas.bitmap = CreateObject("roBitmap", {width: canvas_width, height: canvas_height, AlphaEnable: true})
	end function
	' ############### canvasSetSize() function - Begin ###############


	' ############### canvasGetOffset() function - Begin ###############
	game.canvasGetOffset = function() as object
		return {x: m.canvas.offset_x, y: m.canvas.offset_y}
	end function
	' ############### canvasGetOffset() function - Begin ###############


	' ############### canvasGetScale() function - Begin ###############
	game.canvasGetScale = function() as object
		return {x: m.canvas.scale_x, y: m.canvas.scale_y}
	end function
	' ############### canvasGetScale() function - Begin ###############


	' ############### canvasSetOffset() function - Begin ###############
	' This is as Float to allow incrementing by less than 1 pixel, it is converted to integer internally
	game.canvasSetOffset = function(x as float, y as float) as void
		m.canvas.offset_x = x
		m.canvas.offset_y = y
	end function
	' ############### canvasSetOffset() function - End ###############


	' ############### canvasSetScale() function - Begin ###############
	game.canvasSetScale = function(scale_x as float, scale_y = invalid as dynamic) as void
		if scale_y = invalid
			scale_y = scale_x
		end if
		m.canvas.scale_x = scale_x
		m.canvas.scale_y = scale_y
	end function
	' ############### canvasSetScale() function - End ###############


	' ############### canvasFitToScreen() function - Begin ###############
	game.canvasFitToScreen = function() as void
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
	game.canvasCenterToScreen = function() as void
		m.canvas.offset_x = m.screen.GetWidth()/2-(m.canvas.scale_x*m.canvas.bitmap.GetWidth())/2
		m.canvas.offset_y = m.screen.GetHeight()/2-(m.canvas.scale_y*m.canvas.bitmap.GetHeight())/2
	end function
	' ############### canvasCenterToScreen() function - End ###############


	' --------------------------------Begin Audio Functions----------------------------------------


	' ############### musicPlay() function - Begin ###############
	game.musicPlay = function(path as string, loop = false as boolean) as boolean
		if m.filesystem.Exists(path) then
			m.audioplayer.stop()
			m.audioplayer.ClearContent()
			song = {}
			song.url = path
			m.audioplayer.AddContent(song)
			m.audioplayer.SetLoop(loop)
			m.audioPlayer.play()
			return true
		else
			print "musicPlay() - No file exists at path: " ; path
			return false
		end if
	end function
	' ############### musicPlay() function - End ###############



	' ############### musicStop() function - Begin ###############
	game.musicStop = function() as void
		m.audioplayer.stop()
	end function
	' ############### musicStop() function - End ###############



	' ############### musicPause() function - Begin ###############
	game.musicPause = function() as void
		m.audioplayer.pause()
	end function
	' ############### musicPause() function - End ###############



	' ############### musicResume() function - Begin ###############
	game.musicResume = function() as void
		m.audioplayer.resume()
	end function
	' ############### musicResume() function - End ###############



	' ############### loadSound() function - Begin ###############
	game.loadSound = function(sound_name as string, path as string) as void
		m.Sounds[sound_name] = CreateObject("roAudioResource", path)
	end function
	' ############### loadSound() function - End ###############



	' ############### playSound() function - Begin ###############
	game.playSound = function(sound_name as string, volume = 100 as integer) as boolean
		if m.Sounds.DoesExist(sound_name) then
			m.Sounds[sound_name].trigger(volume)
			return true
		else
			print "playSound() - No sound has been loaded under the name: " ; sound_name
			return false
		end if
	end function
	' ############### playSound() function - End ###############



	' ############### newAsyncUrlTransfer() function - Begin ###############
	game.newAsyncUrlTransfer = function() as object
		UrlTransfer = CreateObject("roUrlTransfer")
		UrlTransfer.SetMessagePort(m.url_port)
		m.urltransfers[UrlTransfer.GetIdentity().ToStr()] = UrlTransfer
		return UrlTransfer
	end function
	' ############### newAsyncUrlTransfer() function - End ###############

	' ############### setInputInstance() function - Begin ###############
	game.setInputInstance = function(instance as object) as void
		m.input_instance = instance.id
	end function
	' ############### setInputInstance() function - End ###############

	' ############### unsetInputInstance() function - Begin ###############
	game.unsetInputInstance = function() as void
		m.input_instance = invalid
	end function
	' ############### unsetInputInstance() function - End ###############

	' ############### postGameEvent() function - Begin ###############
	game.postGameEvent = function(event as string, data = {} as object) as void
		object_keys = m.Instances.Keys()
		for each object_key in object_keys
			instance_keys = m.Instances[object_key].Keys()
			for each instance_key in instance_keys
				instance = m.Instances[object_key][instance_key]
				if instance <> invalid and instance.id <> invalid and instance.onGameEvent <> invalid
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
