function new_emptyGameObject(game as object, object_name as string) as object
	newObject = {
		' -----Constants-----
		name: object_name
		id: game.getNewUniqId("object")
		game: game

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
		drawableObjects: []
		labelsAA: {}
		images: []
		imagesAA: {}
	}

	newObject.onCreate = sub(args) : end sub

	newObject.addRandomNameImage = function(config as object) as dynamic
		imageName = m.name + "_" + GetRandomHexString(10)
		return m.addImage(imageName, config)
	end function

	newObject.addImage = function(name as string, config as object) as dynamic
		if m.getImage(name) <> invalid
			print "addImageObject() - An image named - " + name + " - already exists"
			return m.getImage(name)
		end if

		imageObject = {
			' --------------Values That Can Be Changed------------
			id: m.game.getNewUniqId("image")
			name: name
			type: "image"
			x: 0
			y: 0
			offsetX: 0 ' The offset of the image, to be added to position
			offsetY: 0
			scaleX: 1.0 ' The image scale.
			scaleY: 1.0
			transformCenterX: 0.5 ' 0 to 1
			transformCenterY: 0.5
			scaleMode: 0 ' 0 - fast or 1 - smooth
			rotation: 0 ' degrees
			color: &hFFFFFF ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
			opacity: 1 ' Change the image opacity.
			enabled: true ' Whether or not the image will be drawn.
			priority: invalid
			drawTo: m.game.getCanvas()
			index: 0 ' This would not normally be changed manually, but if you wanted to stop on a specific image in the spritesheet this could be set.
			spriteSourceSize: []
			regions: []
			animationSpeed: 0 ' The time in milliseconds for a single cycle through the animation to play.
			pauseable: true ' false - continue animation if game paused
			animationTween: "LinearTween"

			' -------------Never To Be Manually Changed-----------------
			' These values should never need to be manually changed.
			animation_timer: CreateObject_GameTimeSpan()
			tweensReference: GetTweens()
			owner: m
			game: m.game
		}

		if asBoolean(config.isAnimation)
			imageObject.Draw = sub()
				if m.animationSpeed > 0 and (not m.pauseable or not m.owner.game.isPaused())
					m.Animate()
				end if
				DrawImage(m)
			end sub

			imageObject.Animate = sub()
				frame_count = m.regions.Count()
				current_time = m.animation_timer.TotalMilliseconds()
				if current_time > m.animationSpeed
					time_to_remove = int(current_time / m.animationSpeed) * m.animationSpeed
					current_time -= time_to_remove
					m.animation_timer.RemoveTime(time_to_remove)
				end if
				m.index = m.tweensReference[m.animationTween](0, frame_count, current_time, m.animationSpeed)
				if m.index > frame_count - 1
					m.index = frame_count - 1
				else if m.index < 0
					m.index = 0
				end if
			end sub

			imageObject.onResume = sub(paused_time as integer)
				m.animation_timer.RemoveTime(paused_time)
			end sub

		else
			imageObject.Draw = sub()
				DrawImage(m)
			end sub
		end if

		imageObject.load = sub()
			regionsObj = m.game.loadImageTexture(m)
			m.spriteSourceSizes = regionsObj.spriteSourceSizes
			m.regions = regionsObj.regions
		end sub

		imageObject.unload = sub()
			regionsObj = m.game.unloadImageTexture(m)
			m.spriteSourceSizes = invalid
			m.regions = []
		end sub

		imageObject.getWidth = function() as integer
			return m.getRegion().getWidth()
		end function

		imageObject.getHeight = function() as integer
			return m.getRegion().getHeight()
		end function

		imageObject.getRegion = function() as object
			return m.regions[m.index]
		end function

		imageObject.append(config)

		if imageObject.scale <> invalid
			imageObject.scaleX = imageObject.scale
			imageObject.scaleY = imageObject.scale
		end if

		imageObject.load()

		m.imagesAA[imageObject.name] = imageObject
		m.insertDrawableObject(imageObject, imageObject.priority)

		return imageObject
	end function

	newObject.getImage = function(name) as dynamic
		return m.imagesAA[name]
	end function

	newObject.removeImage = sub(name)
		m.removeDrawableObject(m.imagesAA[name])
		m.imagesAA[name].unload()
		m.imagesAA.Delete(name)
	end sub

	newObject.addNoNameLabel = function(config as object) as dynamic
		textName = m.name + "_" + GetRandomHexString(10)
		return m.addLabel(textName, config)
	end function

	newObject.addLabel = function(name as string, config = {} as object) as dynamic
		if m.getLabel(name) <> invalid
			print "addLabelObject() - An text named - " + name + " - already exists"
			return m.getLabel(name)
		end if

		labelObject = {
			id: m.game.getNewUniqId("label")
			name: name
			type: "text"
			x: 0, y: 0, shadowX: 0, shadowY: 0
			fontSize: 16
			lineHeight: invalid
			text: ""
			align: "center"
			vertAlign: "top" ' top center bottom
			fontName: "default"
			color: &hFFFFFF
			opacity: 1 ' Change the text opacity.
			multiColor: false
			italic: false
			bold: false
			enabled: true ' Whether or not the text will be drawn.
			font: invalid
			priority: invalid
			drawTo: m.game.getCanvas()

			' -------------Never To Be Manually Changed-----------------
			' These values should never need to be manually changed.
			owner: m
			game: m.game
		}

		if config.lineHeight <> invalid
			labelObject.Draw = sub()
				DrawMultilineLabel(m)
			end sub

		else
			labelObject.Draw = sub()
				DrawLabel(m)
			end sub
		end if

		labelObject.getText = function() as string
			if asInteger(m.maxWidth) > 0 and isInteger(m.lineHeight)
				return wrapTextByMaxWidth(m.font, m.text, m.maxWidth)
			end if
			return m.text
		end function

		labelObject.load = sub()
			m.font = m.game.loadLabelTexture(m)
		end sub

		labelObject.unload = sub()
			m.font = invalid
			m.game.unloadLabelTexture(m)
		end sub


		labelObject.Append(config)

		labelObject.fontKey = labelObject.fontName + "_" + asString(labelObject.fontSize)
		labelObject.load()

		m.labelsAA[labelObject.name] = labelObject
		m.insertDrawableObject(labelObject, labelObject.priority)

		return labelObject
	end function

	newObject.getLabel = function(name as string) as object
		return m.labelsAA[name]
	end function

	newObject.removeLabel = sub(name)
		m.removeDrawableObject(m.labelsAA[name])
		m.labelsAA[name].unload()
		m.labelsAA.Delete(name)
	end sub

	newObject.insertDrawableObject = sub(drawable_object as object, insertPosition as dynamic)
		m.drawableObjects.Push(drawable_object)
		m.drawableObjects.SortBy("priority")
	end sub

	newObject.removeDrawableObject = sub(drawable_object as object)
		if m.drawableObjects.Count() > 0
			for i = 0 to m.drawableObjects.Count() - 1
				if m.drawableObjects[i].type = drawable_object.type and m.drawableObjects[i].name = drawable_object.name
					m.drawableObjects.Delete(i)
					drawable_object = invalid
					exit for
				end if
			end for
		end if
	end sub

	newObject.setDepth = sub(depth as integer)
		m.depth = depth
	end sub

	' This is the structure of the methods that can be added to an object
	' newObject.onUpdate = sub(dt) : end sub
	' newObject.onCollision = sub(collider, other_collider, other_instance) : end sub
	' newObject.onDrawBegin = sub(canvas) : end sub
	' newObject.onDrawEnd = sub(canvas) : end sub

	' newObject.onButton = function(code)
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

	' newObject.onECPKeyboard = sub(char) : end sub
	' newObject.onECPInput = sub(data) : end sub
	' newObject.onAudioEvent = sub(msg) : end sub
	' newObject.onPause = sub () : end sub
	' newObject.onResume = sub(pause_time) : end sub
	' newObject.onUrlEvent = sub(msg) : end sub
	' newObject.onGameEvent = sub(event, data) : end sub
	' newObject.onChangeRoom = sub(new_room) : end sub
	' newObject.onDestroy = sub() : end sub

	newObject.addColliderCircle = function(collider_name, radius, offsetX = 0, offsetY = 0, enabled = true)
		collider = {
			type: "circle",
			name: collider_name,
			enabled: enabled,
			radius: radius,
			offsetX: offsetX,
			offsetY: offsetY,
			member_flags: 1
			collidable_flags: 1
			compositor_object: invalid
		}
		region = CreateObject("roRegion", m.game.empty_bitmap, 0, 0, 1, 1)
		region.SetCollisionType(2)
		region.SetCollisionCircle(offsetX, offsetY, radius)
		collider.compositor_object = m.game.compositor.NewSprite(m.x, m.y, region)
		collider.compositor_object.SetDrawableFlag(false)
		collider.compositor_object.SetData({ collider_name: collider_name, object_name: m.name, instance_id: m.id })
		if m.colliders[collider_name] = invalid
			m.colliders[collider_name] = collider
		else
			print "addColliderCircle() - Collider Name Already Exists: " + collider_name
		end if
	end function

	newObject.addColliderRectangle = function(collider_name, offsetX, offsetY, width, height, enabled = true)
		collider = {
			type: "rectangle",
			name: collider_name,
			enabled: enabled,
			offsetX: offsetX,
			offsetY: offsetY,
			width: width,
			height: height,
			member_flags: 1
			collidable_flags: 1
			compositor_object: invalid
		}
		region = CreateObject("roRegion", m.game.empty_bitmap, 0, 0, 1, 1)
		region.SetCollisionType(1)
		region.SetCollisionRectangle(offsetX, offsetY, width, height)
		collider.compositor_object = m.game.compositor.NewSprite(m.x, m.y, region)
		collider.compositor_object.SetDrawableFlag(false)
		collider.compositor_object.SetData({ collider_name: collider_name, object_name: m.name, instance_id: m.id })
		if m.colliders[collider_name] = invalid
			m.colliders[collider_name] = collider
		else
			print "addColliderRectangle() - Collider Name Already Exists: " + collider_name
		end if
	end function

	newObject.getCollider = function(collider_name)
		if m.colliders.DoesExist(collider_name)
			return m.colliders[collider_name]
		else
			return invalid
		end if
	end function

	newObject.removeCollider = function(collider_name)
		if m.colliders[collider_name] <> invalid
			if type(m.colliders[collider_name].compositor_object) = "roSprite" then m.colliders[collider_name].compositor_object.Remove()
			m.colliders.Delete(collider_name)
		end if
	end function

	game.Instances[newObject.name][newObject.id] = newObject
	game.sorted_instances.Push(newObject)

	return newObject
end function