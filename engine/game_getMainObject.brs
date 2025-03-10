function game_getMainObject(canvas_width as integer, canvas_height as integer) as object
    bitmap = CreateObject("roBitmap", { width: canvas_width, height: canvas_height, AlphaEnable: true })
    sound = CreateObject("roAudioResource", "select")

    mainObject = {
        ' ****BEGIN - For Internal Use, Do Not Manually Alter****
        debugging: {
            draw_colliders: false
            draw_safe_zones: false
            limit_frame_rate: 0
            showFps: false
        }
        canvas_is_screen: false
        background_color: &h000000FF
        max_sound_channels: sound.MaxSimulStreams()
        running: true
        paused: false
        isSoundEnabled: true
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
        currentIDs: {} ' holds uniq ids by group name, can be used for objects creation, to get uniq id on creation
        shouldUseIntegerMovement: false
        empty_bitmap: CreateObject("roBitmap", { width: 1, height: 1, AlphaEnable: false })
        device: CreateObject("roDeviceInfo")
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
            bitmap: bitmap
            region: CreateObject("roRegion", bitmap, 0, 0, canvas_width, canvas_height)
            offsetX: 0
            offsetY: 0
            scaleX: 1.0
            scaleY: 1.0
        }
        ' ****END - For Internal Use, Do Not Manually Alter****

        ' ****Variables****
        currentRoom: invalid
        currentRoomArgs: {}
        Instances: {} ' This holds all of the game object instances
        Objects: {} ' This holds the object definitions by name (the object creation functions)
        Rooms: {} ' This holds the room definitions by name (the room creation functions)
        Sounds: {} ' This holds the loaded sounds by name
        staticBitmaps: {}
        staticAtlases: {}
        imagesTextures: {}
        labelsTextures: {}
        artsConfig: {}
    }

    mainObject.audioplayer.SetMessagePort(mainObject.music_port)
	mainObject.ecp_input.SetMessagePort(mainObject.ecp_input_port)
    mainObject.audioplayer.SetMessagePort(mainObject.music_port)

    bitmap = invalid
    sound = invalid

    return mainObject
end function