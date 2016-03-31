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
##### newEmptyObject(name as String) as Object
This method is primarily for internal use, but may be called manually if desired. It returns an empty game object.
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
Registers the font at the given path. Returns true if successful. Note: All fonts in the directory pkg:/fonts/ automatically get registered.
##### loadFont(name as String, size as Integer, italic as Boolean, bold as Boolean) as Void
Loads the font with the provided name into memory. The font must be registered first.
##### unloadFont(name as String) as Void
Unloads the font associated with the provided name from memory.
##### getFont(name as String) as Object
Returns the font associated with the provided name. Font must have been previously loaded using loadFont().

###### ---Camera Methods---
##### cameraIncreaseOffset()
##### cameraIncreaseZoom()
##### cameraSetOffset()
##### cameraSetZoom()
##### cameraSetFollow()
##### cameraUnsetFollow()
##### cameraFitToScreen()
##### cameraCenterToInstance()

###### ---Audio Methods---
##### musicPlay()
##### musicStop()
##### musicPause()
##### musicResume()
##### addSound()
##### playSound()
