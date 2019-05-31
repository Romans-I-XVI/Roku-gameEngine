Roku-gameEngine
======
An object oriented game engine for the Roku

The purpose of this project is to make it easy to develop games for the Roku in an object oriented fasion. Similar to how you would with an engine such as Gamemaker or Unity (minus any visual software that is).

First start by creating the gameEngine object

##### game = new_game(canvas_width as Integer, canvas_height as Integer, canvas_as_screen_if_possible = false as Boolean) as Object
Creates the main game object, the canvas width and height create an empty bitmap of that size that the game is drawn to. If canvas_as_screen_if_possible is set the game will draw to the roScreen directly if the canvas dimensions are the same as the screen dimensions, this improves performance but makes it so you can't do various canvas manipulations (such as screen shake or taking screenshots).


Game
------
###### ---General Methods---
##### Play() as Void
After setting up your game, call this method to execute it.
##### End() as Void
This will end your game. All existing instances will be destroyed before exiting (meaning onDestroy() will be called).
##### Pause() as Void
This will pause your game. Note: all instances that have _pauseable = false_ will continue to execute. Also keep in mind that onDrawBegin, onDrawEnd, and onDrawGui are _always_ executed even when the game is paused.
##### Resume() as Dynamic
This will resume your paused game. Returns how long the game was paused in milliseconds if the game was paused, otherwise returns invalid if the game wasn't paused.
##### isPaused()
Returns true if the game is paused.
##### getDeltaTime() as Float
Returns the delta time. Note: Delta time is automatically applied to the built in instance xspeed and yspeed. Delta time is also automatically passed to the onUpdate(dt) function in every instance for convenience.
##### getRoom() as Object
Returns the current room.
##### getCanvas() as Object
Returns the canvas bitmap object.
##### getScreen() as Object
Returns the screen object.
##### resetScreen() as Void
*Important* This function is here because of a bug with the Roku. If you ever try to use a component that displays something on the screen aside from roScreen, such as roKeyboardScreen, roMessageDialog, etc. the screen will flicker after you return to your game. You should always call this method after using a screen that's outside of roScreen in order to prevent this bug.
##### newEmptyObject(object_name as String) as Object
This method is primarily for internal use, but may be called manually if desired. It returns an empty game object.
##### debugDrawColliders(enabled as Boolean) as Void
This enables or disables the drawing of all colliders.
##### debugDrawSafeZones(enabled as Boolean) as Void
This enables or disables the drawing of safe zones.
##### debugLimitFrameRate(limit_frame_rate as Integer) as Void
This sets the frame rate limit for the testing game behavior under such circumstances. Default is 0, which is no limit.
##### drawColliders(instance as Object) as Void
This method is for debugging purposes, it will draw the colliders associated with the provided instance.
##### drawSafeZones() as Void
This method is for debugging purposes, when called in an object's onDrawGui() method it will display the Action Safe Zone and Title Safe Zone. Helps with ensuring elements will not be cut off by overscan. 

###### ---Game Object Methods---
##### defineObject(object_name as String, object_creation_function as Function) as Void
Define a new game object. The function provided will be called when an instance of the object is created, the function provided receives an empty object and modifies it as necessary.
##### defineInterface(interface_name as String, interface_creation_function as Function) as Void
Define a new interface. The function provided will be called when an instance of a game object calls addInterface, a roAssociativeArray with the property "owner" will be passed in to the defined function.
##### createInstance(object_name as String, [args as AssociativeArray]) as Dynamic
Creates a new instance of an object that has been defined using defineObject(). The args AssociativeArray is optional, it will be passed to the onCreate() method.

If the instance is created successfully, the instance is returned. Otherwise returns invalid.
##### getInstanceByID(instance_id as String) as Object
Returns the instance associated with the provided ID.
##### getInstanceByName(object_name as String) as Object
Returns the first instance of an object of the specified name. (note: If more than one instance exists, only the first one will be returned)
##### getAllInstances(object_name as String) as Array
Returns array containing all instances of the specified name.
##### destroyInstance(instance as Object) as Void
Destroys the provided instance.
##### destroyAllInstances(object_name as String) as Void
Destroys all instances of the specified name.
##### instanceCount(object_name as String) as Integer
Returns the number of instances of the specified name.

##### defineRoom(room_name as String, room_creation_function as Function) as Void
Define a new room. The function provided will be called when the room is switched to, the function provided receives an empty object and modifies it as necessary. This is the same as defineObject() except it is used for rooms.
##### changeRoom(room_name as String, [args as AssociativeArray]) as Boolean
Switches to a room that has been defined using defineRoom(). The args AssociativeArray is optional, it will be passed to the onCreate() method.
##### resetRoom() as Void
Resets the current room, retaining the original args.

###### ---Bitmap Methods---
##### loadBitmap(bitmap_name as String, path as Dynamic) as Boolean
Loads a bitmap into memory and makes it available by name with the getBitmap() function. The path can also be an associative array structured like so {width: 10, height: 10, AlphaEnable: true}, doing this will create an empty bitmap. Returns true if successful.
##### getBitmap(bitmap_name as String) as Dynamic
Returns the bitmap associated with the provided name. Returns invalid if a bitmap with the provided name hasn't been loaded.
##### unloadBitmap(bitmap_name as String) as Boolean
Unloads the bitmap associated with the provided name from memory. Returns true if successful.

###### ---Font Methods---
##### registerFont(path as String) as Boolean
Registers the font at the provided path. Returns true if successful. Note: All fonts in the directory pkg:/fonts/ automatically get registered.
##### loadFont(font_name as String, font as String, size as Integer, italic as Boolean, bold as Boolean) as Void
Loads the font into memory and makes it accessable by the provided name. Note: The font must be registered first and "font" must be the filename prefix.
##### unloadFont(font_name as String) as Void
Unloads the font associated with the provided name from memory.
##### getFont(font_name as String) as Object
Returns the font associated with the provided name. Font must have been previously loaded using loadFont().

###### ---Canvas Methods---
##### canvasSetSize(canvas_width as Integer, canvas_height as Integer) as Void
Modifies the canvas size with the provided width and height. 
##### canvasGetOffset() as Object
Returns an associative array with the current canvas offset. Will contain values for x and y.
##### canvasGetScale() as Object
Returns an associative array with the current canvas scale. Will contain values for x and y.
##### canvasSetOffset(x as Float, y as Float) as Void
Set the canvas x and y positions. Note: positions are absolute and not in relation to the current scale, you should take scale into account when manually setting the positions.
##### canvasSetScale(scale_x as Float, [scale_y as Float]) as Void
Sets the canvas scale to the given amount, if only scale_x is given, scale_y will be set to the same amount. The scale_y parameter is only necessary if you want to stretch the canvas.
##### canvasFitToScreen() as Void
This fits the game canvas to the screen regardless of the screen aspect ratio. This makes it so a game can be made at any size and black bars will be shown on the top/bottom or left/right if the game aspect ratio is not the same as the TV's.
##### canvasCenterToScreen() as Void
This centers the game canvas.

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

###### ---Async Methods---
##### newAsyncUrlTransfer() as Object
Returns a roUrlTransfer object that can be used to asynchronously request data from a server. The response message is then passed to the gameObject onUrlEvent method. The roUrlTransfer object _must be used only once_ for a url request as it will be automatically destroyed upon recieving a response. A new roUrlTransfer object should be retrieved for each independent transfer request. This allows for multiple transfers to occur simultaneously.


Game Object
------
A game object is an object that has been created using the function newEmptyObject(), this is usually done internally by defining a new object using defineObject() and then creating a new instance of it using createInstance(). Instructions on doing this can be found above. 

The basic game object structure looks like this.
```brightscript
new_object = {
	' -----Constants-----
	name: object_name
	id: m.currentID.ToStr()
	game: m

	' -----Variables-----
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
	(Methods will be described below)
}
```

###### ---Constants---
* name: This is the object name as declared by defineObject(). For example - A "ball" object can be defined, all instances of the object will have the name "ball" but will have different IDs.
* id: This is the ID for this specific instance.
* game: This is a reference to the game so that every object instance can easily access its methods.

###### ---Variables---
* persistent: If true the instance will not be destroyed when the on changeRoom(), default behavior is to destroy all instances on changeRoom().
* pauseable: If set to false the instance will continue to execute even when the game is paused. Default is set to true, in which case only onDrawBegin(), onDrawEnd() and onDrawGui() will be called when the game is paused.
* depth: Declares the instance draw depth.
* x/y: The x and y positions of the instance.
* xspeed/yspeed: The movement speed of the instance. Note: This is automatically multiplied by delta time.
* colliders: Instances can have multiple colliders, you can modify collider properties here but adding a new collider should be done by the methods described below.
* images: Instances can have multiple images, you can modify image properties here but adding a new image should be done by the methods described below.

###### ---Override Methods---
The override methods are designed to be overridden. They are automatically called by the game at the approprate times.
Note: For these methods, if an argument is shown, then the override method _must_ accept that argument as well.

##### onCreate(args)
This method will always be called when the instance is created. Put creation code here. Must receive args as an associative array, this is the same associative array that is passed as args when calling createInstance().

##### onUpdate(deltaTime)
This method is called every frame. Put code to be constantly ran here. 

##### onPreCollision()
This method is called just before collision checking occurs, any important pre-collision check adjustments can be made here.

##### onCollision(collider, other_collider, other_instance)
This method is called when two object instances collide. collider and other_collider are strings refering to the specific colliders that are in collision. other_instance is the object instance that has been collided with.

##### onPostCollision()
This method is called just after collision checking occurs, any post-collision processing can be put here.

##### onDrawBegin(canvas)
This is called before the instance is drawn and receives the canvas as a object that can be drawn to. 

##### onDrawEnd(canvas)
This is called after the instance is drawn and receives the canvas as a object that can be drawn to. 

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

##### onECPKeyboard(character)
This can be used to receive text input from ECP keyboard events.

##### onAudioEvent(message)
This is called when an audio event is triggered, the message is passed to the method.

##### onPause()
This is called when the game is paused via Pause()

##### onResume(pause_time)
This is called when the game is resumed via Resume, the amount of time the game was paused (in milliseconds) is passed to the method.

##### onUrlEvent(message)
This is called when a URL event is triggered by a roUrlTransfer object retrieved from newAsyncUrlTransfer(). The message is passed to the method, then the roUrlTransfer object is automatically destroyed.

##### onGameEvent(event, data)
This method will be called on all objects whenever PostGameEvent(event as String, data = {} as Object) is called. It is a basic event system for objects to inform other objects of events.

##### onChangeRoom(new_room_name)
This method will be called when the room is changed and recieves the name of the new room

##### onDestroy()
This method will always be called just before the instance is destroyed.

###### ---Creation Methods---
##### addColliderRectangle(collider_name as String, offset_x as Integer, offset_y as Integer, width as Integer, height as Integer, [enabled as Boolean])
Adds a rectangle collider to the instance's colliders associative array with the provided name and properties. Enabled is true by default.
##### addColliderCircle(collider_name, radius, [offset_x as Integer, offset_y as Integer, enabled as Boolean])
Adds a circular collider to the instance's colliders associative array with the provided name and properties. By default offset_x is 0, offset_y is 0, and enabled is true.
##### getCollider(collider_name as String) as Object
Returns the collider with the provided name, returns invalid if it doesn't exist.
##### removeCollider(collider_name)
Removes the collider with the provided name.
##### addImage(image_name as String, region as Object, [args as Object, insert_position as Integer])
Adds the provided  roRegion to the instance's images array. By default images are added to the end of the images array but you can also choose to insert the image to a specific position in the array with the insert_position argument. Images are drawn in the order they exist in the instance's images array. Args is an associative array with values to override the defaults. Here are the defaults that can be overridden.

```brightscript
{
	offset_x: 0 ' The offset of the image.
	offset_y: 0 
	scale_x: 1.0 ' The image scale.
	scale_y: 1.0
	rotation: 0 ' The image rotation in degrees
	color: &hFFFFFF ' This can be used to tint the image with the provided color if desired. White makes no change to the original image.
	alpha: 255 ' Change the image alpha (transparency).
	enabled: true ' Whether or not the image will be drawn.
}
```
* Note 1: You cannot rotate and scale an image at the same time as Roku does not provide a function for doing so.
* Note 2: The origin property has been removed from images, instead to handle origins the user should pass in roRegions with SetPretranslation set.
##### addAnimatedImage(image_name as String, regions as Object, [args as Object, insert_position as Integer])
addAnimatedImage functions the same as addImage except that it accepts an array of roRegions and contains additional properties for handling animations. Here are the additional properties, which can be overriden with ***args***.
```brightscript
{
	index: 0 ' The index of the region to be shown. This would not normally be changed manually, but if you wanted to stop on a specific image in the spritesheet this could be set.
	animation_speed: 0 ' The time in milliseconds for a single cycle through the animation to play. If the animation speed is left as 0 the image will not animate automatically and it will be up to the user to manually set the appropriate index.
	animation_tween: "LinearTween" ' The tween method (from the list in tweens.brs) to use in cycling through the animation.
}
```
##### addImageObject(image_name as string, image_object as object, [insert_position as Integer])
This method is used internally by addImage and addAnimatedImage to add the image object to the ***images*** array. However, this method could also be used to provide an image object with a customized structure. The image object must be an roAssociativeArray and must have a Draw() method that will automatically get called by the engine.
##### getImage(image_name as String) as Object
Returns the image with the provided image name.
##### removeImage(image_name as String)
Removes the image matching the provided image name.
##### setStaticVariable(variable_name as String, variable_value)
Sets a variable for an object type that is persistent across all objects of this type (based on the concept of static variables)
##### getStaticVariable(variable_name as String)
Returns a static variable, returns invalid if static variable has not been set.
##### addInterface(interface_name as String) as Void
Adds a previously defined interface to the instance.
##### hasInterface(interface_name as String) as Boolean
Returns true if the instance has the interface.

Other Utilities
------
This area will be a collection of functions that I've found useful for game development.

##### ArrayInsert(array, index, value) 
This function is used internally. It will insert a value to the specified index of an array and shift all subsequent values.
##### DrawCircle(draw2d, line_count, x, y, radius, color)
This function is used interally when DrawColliders() is called. It will draw an empty circle to the screen, however this is extremely expensive and is meant for debugging purposes only.
##### atan2(y, x)
This is here because brightscript unfortunately doesn't provide an atan2 math function.
##### HSVtoRGB(hue, saturation, value, [alpha])
This will convert a hue, saturation, value color to a red, green, blue color hex. If alpha is provided the returned hex will be in RGBA format instead of RGB.
These registry functions make it easy to read and write to the registry, they should be mostly self exlanitory.
##### registryWrite(registry_section as String, key as String, value as Dynamic) as Void
Writes to the provided registry section the provided key/value pair. Data types supported are booleans, integer and floating point numbers, strings, roArray, and roAssociativeArray objects.
##### registryRead(registry_section as String, key as String, [default_value as Dynamic]) as Dynamic
Reads the provided key from the provided registry section. The default value will be written if the registry section and key have no value yet.
##### DrawText(draw2d as Object, text as String, x as Integer, y as Integer, font as Object, alignment = "left" as String, color = &hEBEBEBFF as Integer)
Gives a convenient way to draw text with halignement set as "left", "right", or "center"
##### DrawScaledAndRotatedObject(draw2d as object, x as float, y as float, scale_x as float, scale_y as float, theta as float, drawable as object, color = &hFFFFFFFF as integer)
WARNING: This is potentially unsafe and always slow by comparison to normal draw calls. It attempts to both scale and rotate an image when drawing, I say attempts because in order to do both actions it must create a separate roBitmap and do the scaled draw to that before then doing to rotated draw to the draw2d destination. If the scaling is large enough that the created roBitmap is too big or consumes too much video memory this could potentially be breaking.
##### CreateObject_GameTimeSpan() as Object
This basically creates an improved roTimespan object which adds the AddTime and RemoveTime methods which are useful when pausing/resuming gameplay (used automatically with the addAnimatedImage timer).
##### TexturePacker_GetRegions(atlas as dynamic, bitmap as object)
Automatically parses a JSON Hash type data export from TexturePacker to return an roAssociativeArray with roRegions mapped to the provided bitmap. SetPretranslation will be applied automatically on the regions if pivot points have been enabled in TexturePacker. atlas can be either parsed or unparsed JSON.

