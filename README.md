Roku-gameEngine
======
An object oriented game engine for the Roku

The purpose of this project is to make it easy to develop game for the Roku in an object oriented fasion. Similar to how you would with an engine such as Gamemaker or Unity (minus any visual software that is).

First start by creating the gameEngine object

##### gameEngine = gameEngine_init()


gameEngine
------
###### ---General Methods---
##### Update() as Void
This method must be called in your main while loop in order for the game to execute.
##### newEmptyObject(object_name as String) as Object
This method is primarily for internal use, but may be called manually if desired. It returns an empty game object.
##### getDeltaTime() as Float
Returns the delta time. Note: Delta time is automatically applied to the built in instance xspeed and yspeed. Delta time is also automatically passed to the onUpdate(dt) function in every instance for convenience.
##### drawColliders(instance as Object) as Void
This method is for debugging purposes, it will draw the colliders associated with the provided instance.

###### ---Game Object Methods---
##### defineObject(object_name as String, object_creation_function as Function) as Void
Define a new game object. The function provided will be called when an instance of the object is created, the function provided receives an empty object and modifies it as necessary.
##### createInstance(object_name as String, [args as AssociativeArray]) as Dynamic
Creates a new instance of an object that has been defined using defineObject(). The args AssociativeArray is optional, if args is provided, all key/value pairs will be added to the instance.

If the instance is created successfully, the instance is returned. Otherwise returns invalid.
##### getInstanceByID(instance_id as String) as Object
Returns the instance associated with the provided ID.
##### getInstanceByName(object_name as String) as Object
Returns the first instance of an object with the provided name. (note: If more than one instance exists, only the first one will be returned)
##### getAllInstances(object_name as String) as Array
Returns array containing all instances with the specified name.
##### destroyInstance(instance as Object) as Void
Destroys the provided instance.
##### destroyAllInstances(object_name as String) as Void
Destroys all instances with the specified name.
##### instanceCount(object_name as String) as Integer
Returns the number of instances with the specified name.

##### defineRoom(room_name as String, room_creation_function as Function) as Void
Define a new room. The function provided will be called when the room is switched to, the function provided receives an empty object and modifies it as necessary. This is the same as defineObject() except it is used for rooms.
##### changeRoom(room_name as String, [args as AssociativeArray]) as Boolean
Switches to a room that has been defined using defineRoom(). The args AssociativeArray is optional, if args is provided, all key/value pairs will be added to the instance.

Returns false if the room switch failed.

###### ---Bitmap Methods---
##### loadBitmap(bitmap_name as String, path as String) as Boolean
Loads a bitmap into memory and makes it available by name with the getBitmap() function. The path can also be an associative array structured like so {width: 10, height: 10, AlphaEnable: true}, doing this will create an empty bitmap. Returns true if successful.
##### getBitmap(bitmap_name as String) as Dynamic
Returns the bitmap associated with the provided name. Returns invalid if a bitmap with the provided name hasn't been loaded.
##### unloadBitmap(bitmap_name as String) as Boolean
Unloads the bitmap associated with the provided name from memory. Returns true if successful.

###### ---Font Methods---
##### registerFont(path as String) as Boolean
Registers the font at the provided path. Returns true if successful. Note: All fonts in the directory pkg:/fonts/ automatically get registered.
##### loadFont(font_name as String, size as Integer, italic as Boolean, bold as Boolean) as Void
Loads the font with the provided name into memory. Note: The font must be registered first and the font_name must be the same as the filename prefix.
##### unloadFont(font_name as String) as Void
Unloads the font associated with the provided name from memory.
##### getFont(font_name as String) as Object
Returns the font associated with the provided name. Font must have been previously loaded using loadFont().

###### ---Camera Methods---
##### cameraIncreaseOffset(x as Float, y as Float) as Void
Increase the camera x and y positions by the provided amounts.
##### cameraIncreaseZoom(zoom as Float) as Void
Increase the camera zoom by the provided amount.
##### cameraIncreaseZoom(zoom_x as Float, zoom_y as Float) as Void
When zoom_y is provided, the zoom can be different for x and y, meaning the image will be stretched.
##### cameraSetOffset(x as Float, y as Float) as Void
Set the camera x and y positions. Note: positions are absolute and not in relation to the current scale, you should take scale into account when manually setting the positions.
##### cameraSetZoom(zoom as Float) as Void
Set the camera zoom to the provided amount.
##### cameraSetZoom(zoom_x as Float, zoom_y as Float) as Void
When zoom_y is provided, the zoom can be different for x and y, meaning the image will be stretched.
##### cameraSetFollow(instance as Object, [mode as Integer]) as Void
Sets the camera to follow the provided instance. Mode can be 0 or 1, the default is 0. In mode 0, the camera will not move beyond the frame boundaries. In mode 1, the camera will keep the instance centered no matter what, meaning if the instance is towards the edge of the frame, black will be shown.
##### cameraUnsetFollow() as Void
Stops following the instance if one was being followed.
##### cameraFitToScreen() as Void
This fits the game to the screen regardless of the screen aspect ratio. This makes it so a game can be made at any size and black bars will be shown on the top/bottom or left/right if the game aspect ratio is not the same as the TV's.
##### cameraCenterToInstance(instance as Object, [mode as Integer]) as Void
This function is used internally when the camera is set to follow an instance, however it can be used manually if you want to center to an object only once. See cameraSetFollow() for a description of mode options.

###### ---Audio Methods---
##### musicPlay(path as String, [loop as Boolean]) as Boolean
Plays music from the provided path. Loop defaults to false. Returns true if the path is valid.
##### musicStop() as Void
Stops the currently playing music.
##### musicPause() as Void
Pauses the currently playing music.
##### musicResume() as Void
Resumes music that is paused.
##### loadSound(sound_name as String, path as String) as Void
Loads a short sound in to memory from the provided path to be triggered by playSound() with the provided name. This is specifically for sound effects, because the sounds are in memory they will be played instantly.
##### playSound(sound_name as String, [volume as Integer]) as Boolean
Plays the sound associated with the name provided, sound must have already been loaded using loadSound(). Returns true if the sound was triggered.

###### ---Registry Methods---
##### registryWriteString(registry_section as String, key as String, value as String) as Void
Writes to the provided registry section the provided key/value pair. The value should be a string.
##### registryWriteFloat(registry_section as String, key as String, value as Float) as Void
Same as registryWriteString() except the value should be a float.
##### registryReadString(registry_section as String, key as String, default_value as String) as String
Reads the provided key from the provided registry section. The default value will be written if the registry section and key have no value yet. Returns the value as a string.
##### registryReadFloat(registry_section as String, key as String, default_value as Float) as Float
Same as registryReadString() except returns the value as a float.


gameObject
------
A game object is an object that has been created using the function newEmptyObject(), this is usually done internally using by defining a new object using defineObject() and then creating a new instance of it using createInstance(). Instructions on doing this can be found above. 

The basic game object structure looks like this.
```brightscript
new_object = {

	' -----Constants-----
	name: name
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
    (Methods will be described below)

}
```

###### ---Constants---
*name: This is the name of the object as declared by defineObject() 
--*example - A "ball" object can be defined, all instances of the object will be named "ball" but will have different IDs.
*id: This is the ID for this specific instance.
*gameEngine: This a reference to the gameEngine so that every object instance can easily access its methods.

###### ---Variables---
*persistent: If true the instance will not be destroyed when the on changeRoom(), default behavior is to destroy all instances on changeRoom().
*depth: Declares the instance draw depth.
*x/y: The x and y positions of the instance.
*xspeed/yspeed: The movement speed of the instance. Note: This is automatically multiplied by delta time.
*colliders: Instances can have multiple colliders, you can modify collider properties here but adding a new collider should be done by the methods described below.
*images: Instances can have multiple images, you can modify image properties here but adding a new image should be done by the methods described below.

###### ---Override Methods---
The override methods are designed to be overridden. They are automatically called by the gameEngine at the approprate times.
Note: For these methods, if an argument is shown, then the override method _must_ accept that argument as well.

##### onCreate()
This method will always be called when the instance is created. Put creation code here.

##### onUpdate(deltaTime)
This method is called every frame. Put code to be constantly ran here. 

##### onCollision(collider, other_collider, other_instance)
This method is called when two object instances collide. collider and other_collider are strings refering to the specific colliders that are in collision.

##### onDrawBegin(screen)
This is called before the instance is drawn and receives the screen as a object that can be drawn to.

##### onDrawEnd(screen)
This is called after the instance is drawn and receives the screen as a object that can be drawn to.

##### onButton(code)
This is called whenever a button is pressed, released, or held.

| Button | When Pressed | When Released | When Held |
|:---:|:---:|:---:|:---:|
| Back | 0 | 100 | 1000 |
| Up | 2 | 102 | 1002 |
| Down | 3 | 103 | 1003 |
| Left | 4 | 104 | 1004 |
| Right | 5 | 105 | 1005 |
| Select | 6 | 106 | 1006 |
| Instant Replay | 7 | 107 | 1007 |
| Rewind | 8 | 108 | 1008 |
| Fast Forward | 9 | 109 | 1009 |
| Info | 10 | 110 | 1010 |
| Play | 13 | 113 | 1013 |

##### onAudioEvent(message)
This is called when an audio event is triggered, the message is passed to the method.

##### onDestroy()
This method will always be called just before the instance is destroyed.

###### ---Creation Methods---
##### addColliderRectangle(collider_name as String, offset_x as Integer, offset_y as Integer, width as Integer, height as Integer, [enabled as Boolean])
Adds a rectangle collider to the instance's colliders associative array with the provided name and properties. Enabled is true by default.
##### addColliderCircle(collider_name, radius, [offset_x as Integer, offset_y as Integer, enabled as Boolean])
Adds a circular collider to the instance's colliders associative array with the provided name and properties. By default offset_x is 0, offset_y is 0, and enabled is true.
##### removeCollider(collider_name)
Removes the collider with the provided name.
##### addImage(image as Object, args as Object)
Adds the provided image to the instance's images array. The image should be of type roBitmap or roRegion. Images are added to an array and are drawn in the order they are added to that array. Args should be an associative array with values to override the defaults. Here are the defaults that can be overridden.

```brightscript
args = {
	offset_x: 0 ' The offset of the image.
	offset_y: 0 
	origin_x: 0 ' The image origin (where it will be drawn from). This helps for keeping an image in the correct position even when scaling.
	origin_y: 0
	scale_x: 1.0 ' The image scale.
	scale_y: 1.0
	color: &hFFFFFF ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
	alpha: 255 ' Change the image alpha (transparency).
	enabled: true ' Whether or not the image will be drawn.

	' The following values should only be changed if the image is a spritesheet that needs to be animated.
	' The spritesheet can have any assortment of multiple columns and rows.
	image_count: 1 ' The number of images in the spritesheet.
	image_width: invalid ' The width of each individual image on the spritesheet.
	image_height: invalid ' The height of each individual image on the spritesheet.
	animation_speed: 0 ' The time in milliseconds for a single cycle through the animation to play.
	animation_position: 0 ' This would not normally be changed manually, but if you wanted to stop on a specific image in the spritesheet this could be set.
}
```
##### removeImage(index as Integer)
Removes the image in the images array that corresponds to the provided index.