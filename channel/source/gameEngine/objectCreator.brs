function gameEngine_newObject(objectHandler, name = "")
	new_object = {
		name: name,
		id: objectHandler.setID(),
		x: 0,
		y: 0,
        colliders: {},
        images: [],
		data: {}
	}

	' These empty functions are placeholders, they are to be overwritten by the user
	new_object.onCollision = function(collider_name, other_object)
	end function

	new_object.onUpdate = function(dt)
	end function

	new_object.onDrawBegin = function()
	end function

	new_object.onDrawEnd = function()
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

	objectHandler.Add(new_object)
	return new_object
end function