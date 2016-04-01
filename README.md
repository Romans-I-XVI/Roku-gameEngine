Roku-gameEngine
======
An object oriented game engine for the Roku

The purpose of this project is to make it easy to develop game for the Roku in an object oriented fasion. Similar to how you would with an engine such as Gamemaker or Unity (minus any visual software that is).

First start by creating the gameEngine object

##### gameEngine = gameEngine_init()

# Methods
There are two objects that provide game specific methods. Let's start with the main gameEngine object.

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

