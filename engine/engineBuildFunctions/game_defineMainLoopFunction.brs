sub game_defineMainLoopFunction(game as object)
    game.Play = sub()

        m.running = true

        while m.running

            if m.input_instance <> invalid and m.getInstanceByID(m.input_instance) = invalid
                m.input_instance = invalid
            end if
            m.current_input_instance = m.input_instance
            m.compositor.Draw() ' For some reason this has to be called or the colliders don't remove themselves from the compositor ¯\(°_°)/¯

            m.dt = m.dtTimer.TotalMilliseconds() / 1000
            if m.FakeDT <> invalid then m.dt = m.FakeDT
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
                        m.buttonHeldTime = m.buttonHeldTimer.TotalMilliseconds()
                    end if
                end if
                screen_msg = m.screen_port.GetMessage()
            end while

            music_msg = m.music_port.GetMessage()

            ' --------------------Begin giant loop for processing all game objects----------------
            ' There is a goto after every call to an override function, this is so if the instance deleted itself no futher calls will be attempted on the instance.
            started_paused = m.paused
            buttonHandled = false
            for i = m.sorted_instances.Count() - 1 to 0 step -1
                instance = m.sorted_instances[i]
                if instance = invalid or instance.id = invalid or not instance.enabled or (started_paused and instance.pauseable) then goto end_of_for_loop

                ' --------------------First process the onButton() function--------------------
                for each msg in universal_control_events
                    if instance.onButton <> invalid and (m.current_input_instance = invalid or m.current_input_instance = instance.id) and not buttonHandled
                        buttonHandled = instance.onButton(msg.GetInt())
                        if instance = invalid or instance.id = invalid then goto end_of_for_loop
                    end if

                    if instance.onECPKeyboard <> invalid and msg.GetChar() <> 0 and msg.GetChar() = msg.GetInt()
                        instance.onECPKeyboard(Chr(msg.GetChar()))
                        if instance = invalid or instance.id = invalid then goto end_of_for_loop
                    end if
                end for
                if m.buttonHeld <> -1
                    ' Button release codes are 100 plus the button press code
                    ' This shows a button held code as 1000 plus the button press code
                    if instance.onButton <> invalid and (m.current_input_instance = invalid or m.current_input_instance = instance.id) and not buttonHandled
                        buttonHandled = instance.onButton(1000 + m.buttonHeld)
                        if instance = invalid or instance.id = invalid then goto end_of_for_loop
                    end if
                end if

                ' -------------------Then send the audioplayer event msg if applicable-------------------
                if instance.onAudioEvent <> invalid and type(music_msg) = "roAudioPlayerEvent"
                    instance.onAudioEvent(music_msg)
                    if instance = invalid or instance.id = invalid then goto end_of_for_loop
                end if

                ' -------------------Then send the ecp input events if applicable-------------------
                if instance.onECPInput <> invalid and type(ecp_msg) = "roInputEvent" and ecp_msg.isInput()
                    instance.onECPInput(ecp_msg.GetInfo())
                    if instance = invalid or instance.id = invalid then goto end_of_for_loop
                end if

                ' -------------------Then send the urltransfer event msg if applicable-------------------
                if instance.onUrlEvent <> invalid and type(url_msg) = "roUrlEvent"
                    instance.onUrlEvent(url_msg)
                    if instance = invalid or instance.id = invalid then goto end_of_for_loop
                end if

                ' -------------------Then process the onUpdate() function----------------------
                if instance.onUpdate <> invalid
                    instance.onUpdate(m.dt)
                    if instance = invalid or instance.id = invalid then goto end_of_for_loop
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
                    if instance = invalid or instance.id = invalid then goto end_of_for_loop
                end if

                ' -------------------Then handle collisions and call onCollision() for each collision---------------------------
                if instance.onCollision <> invalid
                    for each collider_key in instance.colliders
                        collider = instance.colliders[collider_key]
                        if collider <> invalid
                            if collider.enabled
                                collider.compositor_object.SetMemberFlags(collider.member_flags)
                                collider.compositor_object.SetCollidableFlags(collider.collidable_flags)
                                if collider.type = "circle"
                                    collider.compositor_object.GetRegion().SetCollisionCircle(collider.offsetX, collider.offsetY, collider.radius)
                                else if collider.type = "rectangle"
                                    collider.compositor_object.GetRegion().SetCollisionRectangle(collider.offsetX, collider.offsetY, collider.width, collider.height)
                                end if
                                collider.compositor_object.MoveTo(instance.x, instance.y)
                                multiple_collisions = collider.compositor_object.CheckMultipleCollisions()
                                if multiple_collisions <> invalid
                                    for each other_collider in multiple_collisions
                                        other_collider_data = other_collider.GetData()
                                        if other_collider_data.instance_id <> instance.id and m.Instances[other_collider_data.object_name].DoesExist(other_collider_data.instance_id)
                                            instance.onCollision(collider_key, other_collider_data.collider_name, m.Instances[other_collider_data.object_name][other_collider_data.instance_id])
                                            if instance = invalid or instance.id = invalid then exit for
                                        end if
                                    end for
                                    if instance = invalid or instance.id = invalid then exit for
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
                if instance = invalid or instance.id = invalid then goto end_of_for_loop

                ' ---------------- Give a space for any processing to happen just after collision checking occurs ------------
                if instance.onPostCollision <> invalid
                    instance.onPostCollision()
                    if instance = invalid or instance.id = invalid then goto end_of_for_loop
                end if

                ' --------------Adjust compositor collider at end of loop so collider is accurate for collision checking from other objects-------------
                for each collider_key in instance.colliders
                    collider = instance.colliders[collider_key]
                    if collider <> invalid
                        if collider.enabled
                            collider.compositor_object.SetMemberFlags(collider.member_flags)
                            collider.compositor_object.SetCollidableFlags(collider.collidable_flags)
                            if collider.type = "circle"
                                collider.compositor_object.GetRegion().SetCollisionCircle(collider.offsetX, collider.offsetY, collider.radius)
                            else if collider.type = "rectangle"
                                collider.compositor_object.GetRegion().SetCollisionRectangle(collider.offsetX, collider.offsetY, collider.width, collider.height)
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

                if instance = invalid or instance.id = invalid
                    m.sorted_instances.Delete(i)
                end if

            end for

            ' ----------------------Clear the screen before drawing instances-------------------------
            if m.background_color <> invalid
                m.canvas.bitmap.Clear(m.background_color)
            end if

            ' ----------------------Then draw all of the instances and call onDrawBegin() and onDrawEnd()-------------------------
            m.sorted_instances.SortBy("depth")
            for i = m.sorted_instances.Count() - 1 to 0 step -1
                instance = m.sorted_instances[i]
                if instance = invalid or instance.id = invalid then goto end_of_draw_loop
                if instance.onDrawBegin <> invalid
                    instance.onDrawBegin(m.canvas.bitmap)
                    if instance = invalid or instance.id = invalid then goto end_of_draw_loop
                end if

                for each objToDraw in instance.drawableObjects
                    objToDraw.Draw()
                end for
                if instance.onDrawEnd <> invalid
                    instance.onDrawEnd(m.canvas.bitmap)
                end if
                end_of_draw_loop:
            end for

            ' Draw Debug Related Items
            if m.debugging.draw_colliders
                for i = m.sorted_instances.Count() - 1 to 0 step -1
                    instance = m.sorted_instances[i]
                    if instance <> invalid and instance.id <> invalid and instance.colliders <> invalid
                        m.drawColliders(instance)
                    end if
                end for
            end if

            ' -------------------Draw everything to the screen----------------------------
            if not m.canvas_is_screen
                m.canvas.bitmap.finish()
                m.screen.DrawScaledObject(m.canvas.offsetX, m.canvas.offsetY, m.canvas.scaleX, m.canvas.scaleY, m.canvas.region)
            end if

            if m.debugging.draw_safe_zones
                m.drawSafeZones()
            end if

            if m.debugging.showFps
                text = "FPS: " + (1 / m.dt).ToStr()
                m.screen.DrawText(text, 30, 30, &hffffffff, m.getDefaultFont())
            end if

            m.screen.SwapBuffers()

            if m.debugging.limit_frame_rate > 0 and m.dtTimer.TotalMilliseconds() > 0
                while 1000 / m.dtTimer.TotalMilliseconds() > m.debugging.limit_frame_rate
                    sleep(1)
                end while
            end if

        end while

    end sub

    game.End = sub()
        m.running = false
    end sub
end sub