sub game_defineMediaFunctions(game as object)
    game.playBackgroundMusic = sub(name as string)
        if not m.isSoundEnabled then return
        m.musicPlay(m.artsConfig.music[name].localPath, true)
    end sub

    game.musicPlay = function(path as string, loop = false as boolean) as boolean
        if m.filesystem.Exists(path)
            m.audioplayer.stop()
            m.audioplayer.ClearContent()
            m.audioplayer.AddContent({ url: path })
            m.audioplayer.SetLoop(loop)
            m.audioPlayer.play()
            return true
        else
            return false
        end if
    end function

    game.musicStop = sub()
        m.audioplayer.stop()
    end sub

    game.musicPause = sub()
        m.audioplayer.pause()
    end sub

    game.musicResume = sub()
        m.audioplayer.resume()
    end sub

    game.playSound = function(sound_name as string, volume = 100 as integer) as boolean
        if not m.isSoundEnabled then return false

        if not m.Sounds.DoesExist(sound_name)
            print_info("No sound loaded under the name: " + sound_name)
            return false
        end if

        ' Check for playing sounds to interupt
        for each sound in m.Sounds
            if (m.Sounds[sound].resource <> invalid and m.Sounds[sound].resource.IsPlaying() and sound <> sound_name and m.Sounds[sound].index = m.Sounds[sound_name].index)

                if not asBoolean(m.Sounds[sound].interruptible)
                    print_info("not interruptible " + sound + ", interrupter - " + sound_name)
                    return false
                end if

                ' stop active sound
                m.Sounds[sound].resource.Stop()
            end if
        end for

        ' validate sound volume by config
        if volume > m.Sounds[sound_name].maxVolume then volume = m.Sounds[sound_name].maxVolume
        print_info("sound play - " + sound_name + ", volume - " + asString(volume))
        m.Sounds[sound_name].resource.trigger(volume, m.Sounds[sound_name].index)

        return true
    end function

    game.toggleSoundEnabled = sub()
        m.isSoundEnabled = not m.isSoundEnabled
    end sub

    game.setBackgroundColor = sub(color as dynamic)
        m.background_color = color
    end sub
end sub
