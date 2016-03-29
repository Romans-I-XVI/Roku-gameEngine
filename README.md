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

###### Update() as Void
	This method must be called in your main while loop in order for the game to execute.
###### newEmptyObject(name as String) as Object
	This method is primarily for internal use, but may be called manually if desired. It returns an empty game object.
###### DrawColliders(game_object as Object) as Void
	This method is for debugging purposes, it will draw the colliders associated with the provided game object.

###### defineObject(object_name as String, object_creation_function as Function) as Void
	Define a new game object. The function provided will be called when an instance of the object is created, the function provided receives and empty object and modifies it as necessary.
###### newInstance(object_name as String, [args as AssociativeArray]) as Dynamic
	Creates a new instance of an object that has been defined using defineObject(object_name, object_creation_function). The args AssociativeArray is optional, if args is provided, all key/value pairs will be added to the instance.

	If the instance is created successfully, the instance id is returned as String. Otherwise returns invalid.
###### getInstanceByID(object_id as String) as Object
	Returns the instance associated with the provided ID.
###### getInstanceByName(object_name as String) as Object
	Returns the first instance of an object with the provided name. (note: If more than one instance exists, only the first one will be returned)
###### getAllInstances(object_name as String) as Array
	Returns array containing all instances with the specified name.
###### removeInstance(object_id as String) as Void
	Destroyes the instance with the specified ID.
###### removeAllInstances(object_name as String) as Void
	Destroys all instances with the specified name.
###### instanceExists(object_id as String) as Boolean
	Returns true if an instance with the specified ID exists.
###### instanceCount(object_name as String) as Integer
	Returns the number of instances with the specified name.
###### listObjects() as Array
	Returns an array of the the defined game objects.

###### addRoom()
###### changeRoom()

###### loadBitmap()
###### getBitmap()
###### unloadBitmap()

###### registerFont()
###### loadFont()
###### unloadFont()
###### getFont()

###### cameraIncreaseOffset()
###### cameraIncreaseZoom()
###### cameraSetOffset()
###### cameraSetZoom()
###### cameraSetFollow()
###### cameraUnsetFollow()
###### cameraFitToScreen()
###### cameraCenterToObject()

###### musicPlay()
###### musicStop()
###### musicPause()
###### musicResume()

###### addSound()
###### playSound()
