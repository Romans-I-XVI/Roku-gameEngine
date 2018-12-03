'IMPORTS=
' ******************************************************
' Copyright Steven Kean 2010-2015
' All Rights Reserved.
' ******************************************************
Function CreateTweenObject(start_data as object, dest_data as object, duration as integer, tween as string)
    tween_data = {
        start: {}
        current: {}
        dest: {}
        duration: duration
        timer: invalid
        tween: tween
    }
    for each key in start_data
        tween_data.start[key] = start_data[key]
        tween_data.current[key] = start_data[key]
    end for
    for each key in dest_data
        tween_data.dest[key] = dest_data[key]
    end for
    tween_data.timer = CreateObject_GameTimespan()

    return tween_data
End Function

Function GetTweenObjectPercentState(tween_object as object)
    key = invalid
    largest_start_dest_difference = 0
    for each k in tween_object.start
        start_dest_difference = (tween_object.start[k] - tween_object.dest[k])
        if start_dest_difference > largest_start_dest_difference
            largest_start_dest_difference = start_dest_difference
            key = k
        end if
    end for

    if (tween_object.start[key] - tween_object.dest[key]) = 0
        return 1.0
    end if

    if key = invalid
        return 0
    end if

    return (tween_object.start[key] - tween_object.current[key]) / (tween_object.start[key] - tween_object.dest[key])
End Function

Function HandleTween(tween_data)

    ' Example
    ' m.movement_data = {
    '     start: {x: x, y: y}
    '     current: {x: x, y: y}
    '     dest: {x: x, y: y}
    '     duration: 90
    '     timer: CreateObject("roTimespan")
    '     tween: "LinearTween"
    ' }


    tween = "LinearTween"
    if tween_data.DoesExist("tween")
        tween = tween_data.tween
    end if

    current_time = tween_data.timer.TotalMilliseconds()
    for each key in tween_data.start
        tween_data.current[key] = m.tweens[tween](tween_data.start[key], tween_data.dest[key], current_time, tween_data.duration)
    end for

    return current_time >= tween_data.duration

End Function

Function ChangeTweenDest(tween_data, dest_data)
    tween_data.timer.Mark()
    for each key in dest_data
        tween_data.start[key] = tween_data.current[key]
        tween_data.dest[key] = dest_data[key]
    end for
End Function

Function GetTweens() As Object
    If m.tweens = invalid Then
        m.tweens = {
            LinearTween:            LinearTween
            QuadraticTween:         QuadraticTween
            QuadraticEaseIn:        QuadraticEaseIn
            QuadraticEaseOut:       QuadraticEaseOut
            QuadraticEaseInOut:     QuadraticEaseInOut
            QuadraticEaseOutIn:     QuadraticEaseOutIn
            SquareTween:            SquareTween
            SquareEaseIn:           SquareEaseIn
            SquareEaseOut:          SquareEaseOut
            SquareEaseInOut:        SquareEaseInOut
            SquareEaseOutIn:        SquareEaseOutIn
            CubicTween:             CubicTween
            CubicEaseIn:            CubicEaseIn
            CubicEaseOut:           CubicEaseOut
            CubicEaseInOut:         CubicEaseInOut
            CubicEaseOutIn:         CubicEaseOutIn
            QuarticTween:           QuarticTween
            QuarticEaseIn:          QuarticEaseIn
            QuarticEaseOut:         QuarticEaseOut
            QuarticEaseInOut:       QuarticEaseInOut
            QuarticEaseOutIn:       QuarticEaseOutIn
            QuinticTween:           QuinticTween
            QuinticEaseIn:          QuinticEaseIn
            QuinticEaseOut:         QuinticEaseOut
            QuinticEaseInOut:       QuinticEaseInOut
            QuinticEaseOutIn:       QuinticEaseOutIn
            SinusoidalTween:        SinusoidalTween
            SinusoidalEaseIn:       SinusoidalEaseIn
            SinusoidalEaseOut:      SinusoidalEaseOut
            SinusoidalEaseInOut:    SinusoidalEaseInOut
            SinusoidalEaseOutIn:    SinusoidalEaseOutIn
            ExponentialTween:       ExponentialTween
            ExponentialEaseIn:      ExponentialEaseIn
            ExponentialEaseOut:     ExponentialEaseOut
            ExponentialEaseInOut:   ExponentialEaseInOut
            ExponentialEaseOutIn:   ExponentialEaseOutIn
            CircularTween:          CircularTween
            CircularEaseIn:         CircularEaseIn
            CircularEaseOut:        CircularEaseOut
            CircularEaseInOut:      CircularEaseInOut
            CircularEaseOutIn:      CircularEaseOutIn
            ElasticTween:           ElasticTween
            ElasticEaseIn:          ElasticEaseIn
            ElasticEaseOut:         ElasticEaseOut
            ElasticEaseInOut:       ElasticEaseInOut
            ElasticEaseOutIn:       ElasticEaseOutIn
            OvershootTween:         OvershootTween
            OvershootEaseIn:        OvershootEaseIn
            OvershootEaseOut:       OvershootEaseOut
            OvershootEaseInOut:     OvershootEaseInOut
            OvershootEaseOutIn:     OvershootEaseOutIn
            BounceTween:            BounceTween
            BounceEaseIn:           BounceEaseIn
            BounceEaseOut:          BounceEaseOut
            BounceEaseInOut:        BounceEaseInOut
            BounceEaseOutIn:        BounceEaseOutIn            
        }
    End If
    Return m.tweens
End Function

Function LinearTween(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*t/d + b
    time = currentTime / duration
    Return change * time + start
End Function

' ****************
' Quadratic
' ****************
Function QuadraticTween(start, finish, currentTime, duration)
    Return QuadraticEaseInOut(start, finish, currentTime, duration)
End Function

Function QuadraticEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*(t/=d)*t + b
    time = currentTime / duration
    Return change * time * time + start
End Function

Function QuadraticEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' -c *(t/=d)*(t-2) + b
    time = currentTime / duration
    Return -change * time * (time - 2) + start
End Function

Function QuadraticEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if ((t/=d/2) < 1) return c/2*t*t + b;
    ' return -c/2 * ((--t)*(t-2) - 1) + b;
    time = currentTime / (duration / 2)
    If time < 1 Then
        Return change / 2 * time * time + start
    Else
        time = time - 1
        Return -change / 2 * (time * (time - 2) - 1) + start
    End If
End Function

Function QuadraticEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return QuadraticEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return QuadraticEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Square
' ****************
Function SquareTween(start, finish, currentTime, duration)
    Return SquareEaseInOut(start, finish, currentTime, duration)
End Function

Function SquareEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*(t/=d)*t*t*t + b
    time = currentTime / duration
    Return change * time * time + start
End Function

Function SquareEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' -c * ((t=t/d-1)*t*t*t - 1) + b
    time = (currentTime / duration) - 1
    Return -change * (time * time - 1) + start
End Function

Function SquareEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
    ' return -c/2 * ((t-=2)*t*t*t - 2) + b;
    time = currentTime / (duration / 2)
    If time < 1 Then
        Return change / 2 * time * time + start
    Else
        time = time - 2
        Return -change / 2 * (time * time - 2) + start
    End If
End Function

Function SquareEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return SquareEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return SquareEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Cubic
' ****************
Function CubicTween(start, finish, currentTime, duration)
    Return CubicEaseInOut(start, finish, currentTime, duration)
End Function

Function CubicEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*(t/=d)*t*t + b
    time = currentTime / duration
    Return change * time * time * time + start
End Function

Function CubicEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*((t=t/d-1)*t*t + 1) + b
    time = (currentTime / duration) - 1
    Return change * (time * time * time + 1) + start
End Function

Function CubicEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if ((t/=d/2) < 1) return c/2*t*t*t + b;
    ' return c/2*((t-=2)*t*t + 2) + b
    time = currentTime / (duration / 2)
    If time < 1 Then
        Return change / 2 * time * time * time + start
    Else
        time = time - 2
        Return change / 2 * (time * time * time + 2) + start
    End If
End Function

Function CubicEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return CubicEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return CubicEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Quartic
' ****************
Function QuarticTween(start, finish, currentTime, duration)
    Return QuarticEaseInOut(start, finish, currentTime, duration)
End Function

Function QuarticEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*(t/=d)*t*t*t + b
    time = currentTime / duration
    Return change * time * time * time * time + start
End Function

Function QuarticEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' -c * ((t=t/d-1)*t*t*t - 1) + b
    time = (currentTime / duration) - 1
    Return -change * (time * time * time * time - 1) + start
End Function

Function QuarticEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
    ' return -c/2 * ((t-=2)*t*t*t - 2) + b;
    time = currentTime / (duration / 2)
    If time < 1 Then
        Return change / 2 * time * time * time * time + start
    Else
        time = time - 2
        Return -change / 2 * (time * time * time * time - 2) + start
    End If
End Function

Function QuarticEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return QuarticEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return QuarticEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Quintic
' ****************
Function QuinticTween(start, finish, currentTime, duration)
    Return QuinticEaseInOut(start, finish, currentTime, duration)
End Function

Function QuinticEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*(t/=d)*t*t*t*t + b
    time = currentTime / duration
    Return change * time * time * time * time * time + start
End Function

Function QuinticEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c*((t=t/d-1)*t*t*t*t + 1) + b
    time = (currentTime / duration) - 1
    Return change * (time * time * time * time * time + 1) + start
End Function

Function QuinticEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
    ' return c/2*((t-=2)*t*t*t*t + 2) + b;
    time = currentTime / (duration / 2)
    If time < 1 Then
        Return change / 2 * time * time * time * time * time + start
    Else
        time = time - 2
        Return change / 2 * (time * time * time * time * time + 2) + start
    End If
End Function

Function QuinticEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return QuinticEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return QuinticEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Sinusoidal
' ****************
Function SinusoidalTween(start, finish, currentTime, duration)
    Return SinusoidalEaseInOut(start, finish, currentTime, duration)
End Function

Function SinusoidalEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    pi = 3.1415926535897932384626433832795
    change = finish - start
    ' -c * Math.cos(t/d * (Math.PI/2)) + c + b
    time = currentTime / duration
    Return -change * Cos(time * (pi / 2)) + change + start
End Function

Function SinusoidalEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    pi = 3.1415926535897932384626433832795
    change = finish - start
    ' c * Math.sin(t/d * (Math.PI/2)) + b
    time = currentTime / duration
    Return change * Sin(time * (pi / 2)) + start
End Function

Function SinusoidalEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    pi = 3.1415926535897932384626433832795
    change = finish - start
    ' -c/2 * (Math.cos(Math.PI*t/d) - 1) + b
    time = currentTime / duration
    Return -change / 2 * (Cos(pi * time) - 1) + start
End Function

Function SinusoidalEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return SinusoidalEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return SinusoidalEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Exponential
' ****************
Function ExponentialTween(start, finish, currentTime, duration)
    Return ExponentialEaseInOut(start, finish, currentTime, duration)
End Function

Function ExponentialEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b
    If currentTime = 0 Then
        Return start
    Else
        Return change * (2 ^ (10 * (currentTime / duration - 1))) + start
    End If
End Function

Function ExponentialEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b
    If currentTime = duration Then
        Return start + change
    Else
        Return change * (-(2 ^ (-10 * currentTime / duration)) + 1) + start
    End If
End Function

Function ExponentialEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if (t==0) return b;
    ' if (t==d) return b+c;
    ' if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
    ' return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
    time = currentTime / (duration / 2)
    If currentTime = 0 Then
        Return start
    Else If currentTime = duration Then
        Return start + change
    Else If time < 1 Then
        Return change / 2 * (2 ^ (10 * (time - 1))) + start
    Else
        time = time - 1
        Return change / 2 * (-(2 ^ (-10 * time)) + 2) + start
    End If
End Function

Function ExponentialEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if (t==0) return b;
    ' if (t==d) return b+c;
    ' if ((t/=d/2) < 1) return c/2 * (-Math.pow(2, -10 * t/1) + 1) + b;
    ' return c/2 * (Math.pow(2, 10 * (t-2)/1) + 1) + b;
    time = currentTime / (duration / 2)
    If currentTime = 0 Then
        Return start
    Else If currentTime = duration Then
        Return start + change
    Else If time < 1 Then
        Return change / 2 * (-(2 ^ (-10 * time / 1)) + 1) + start
    Else
        Return change / 2 * (2 ^ (10 * (time - 2) / 1) + 1) + start
    End If
End Function

' ****************
' Circular
' ****************
Function CircularTween(start, finish, currentTime, duration)
    Return CircularEaseInOut(start, finish, currentTime, duration)
End Function

Function CircularEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b
    time = currentTime / duration
    Return -change * (Sqr(1 - time * time) - 1) + start
End Function

Function CircularEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' c * Math.sqrt(1 - (t=t/d-1)*t) + b
    time = (currentTime / duration) - 1
    Return change * Sqr(1 - time * time) + start
End Function

Function CircularEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
    ' return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
    time = currentTime / (duration / 2)
    If time < 1 Then
        Return -change / 2 * (Sqr(1 - time * time) - 1) + start
    Else
        time = time - 2
        Return change / 2 * (Sqr(1 - time * time) + 1) + start 
    End If
End Function

Function CircularEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return CircularEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return CircularEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Elastic
' ****************
Function ElasticTween(start, finish, currentTime, duration)
    Return ElasticEaseInOut(start, finish, currentTime, duration)
End Function

Function ElasticEaseIn(start, finish, currentTime, duration, amplitude = invalid As Dynamic, period = invalid As Dynamic)
    If currentTime > duration Or duration = 0 Then Return finish
    pi = 3.1415926535897932384626433832795
    change = finish - start
    ' if (t==0) return b;  
    ' if ((t/=d)==1) return b+c;  
    ' if (!p) p=d*.3;
    ' if (!a || a < Math.abs(c)) { a=c; var s=p/4; }
    ' else var s = p/(2*Math.PI) * Math.asin (c/a);
    ' return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
    time = currentTime / duration
    If currentTime = 0 Then
        Return start
    Else If time = 1 Then
        Return start + change
    End If
    If period = invalid Then
        period = duration * .3
    End If
    speed = period / 4
    If amplitude = invalid Or amplitude < Abs(change) Then
        amplitude = change
    Else    
        speed = period / (2 * pi) * Asin(change / amplitude)
    End If
    time = time - 1
    Return -(amplitude * (2 ^ (10 * time)) * Sin((time * duration - speed) * (2 * pi) / period)) + start
End Function

Function ElasticEaseOut(start, finish, currentTime, duration, amplitude = invalid As Dynamic, period = invalid As Dynamic)
    If currentTime > duration Or duration = 0 Then Return finish
    pi = 3.1415926535897932384626433832795
    change = finish - start
    ' if (t==0) return b;
    ' if ((t/=d)==1) return b+c;
    ' if (!p) p=d*.3;
    ' if (!a || a < Math.abs(c)) { a=c; var s=p/4; }
    ' else var s = p/(2*Math.PI) * Math.asin (c/a);
    ' return (a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b);
    time = currentTime / duration
    If currentTime = 0 Then
        Return start
    Else If time = 1 Then
        Return start + change
    End If
    If period = invalid Then
        period = duration * .3
    End If
    speed = period / 4
    If amplitude = invalid Or amplitude < Abs(change) Then
        amplitude = change
    Else    
        speed = period / (2 * pi) * Asin(change / amplitude)
    End If
    Return (amplitude * (2 ^ (-10 * time)) * Sin((time * duration - speed) * (2 * pi) / period) + change + start)
End Function

Function ElasticEaseInOut(start, finish, currentTime, duration, amplitude = invalid As Dynamic, period = invalid As Dynamic)
    If currentTime > duration Or duration = 0 Then Return finish
    pi = 3.1415926535897932384626433832795
    change = finish - start
    ' if (t==0) return b;
    ' if ((t/=d/2)==2) return b+c;
    ' if (!p) p=d*(.3*1.5);
    ' if (!a || a < Math.abs(c)) { a=c; var s=p/4; }
    ' else var s = p/(2*Math.PI) * Math.asin (c/a);
    ' if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
    ' return (a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b);
    time = currentTime / (duration / 2)
    If currentTime = 0 Then
        Return start
    Else If time = 2 Then
        Return start + change
    End If
    If period = invalid Then
        period = duration * (.3 * 1.5)
    End If
    speed = period / 4
    If amplitude = invalid Or amplitude < Abs(change) Then
        amplitude = change
    Else    
        speed = period / (2 * pi) * Asin(change / amplitude)
    End If
    time = time - 1
    If time < 0 Then
        Return -.5 * (amplitude * (2 ^ (10 * time)) * Sin((time * duration - speed) * (2 * pi) / period)) + start
    Else
        Return (amplitude * (2 ^ (-10 * time)) * Sin((time * duration - speed) * (2 * pi) / period) * .5 + change + start)
    End If
End Function

Function ElasticEaseOutIn(start, finish, currentTime, duration, amplitude = invalid As Dynamic, period = invalid As Dynamic)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return ElasticEaseOut(0, change, currentTime * 2, duration, amplitude, period) * .5 + start
    Else
        Return ElasticEaseIn(0, change, currentTime * 2 - duration, duration, amplitude, period) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Overshoot
' ****************
Function OvershootTween(start, finish, currentTime, duration)
    Return OvershootEaseInOut(start, finish, currentTime, duration)
End Function

Function OvershootEaseIn(start, finish, currentTime, duration, overshoot = 1.70158 As Float)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if (s == undefined) s = 1.70158;
    ' return c*(t/=d)*t*((s+1)*t - s) + b;
    time = currentTime / duration
    Return change * time * time * ((overshoot + 1) * time - overshoot) + start
End Function

Function OvershootEaseOut(start, finish, currentTime, duration, overshoot = 1.70158 As Float)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if (s == undefined) s = 1.70158;
    ' return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
    time = (currentTime / duration) - 1
    Return change * (time * time * ((overshoot + 1) * time + overshoot) + 1) + start
End Function

Function OvershootEaseInOut(start, finish, currentTime, duration, overshoot = 1.70158 As Float)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    ' if (s == undefined) s = 1.70158;
    ' if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
    ' return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b
    time = currentTime / (duration / 2)
    overshoot = overshoot * 1.525
    If time < 1 Then
        Return change / 2 * (time * time * ((overshoot + 1) * time - overshoot)) + start
    Else
        time = time - 2
        Return change / 2 * (time * time * ((overshoot + 1) * time + overshoot) + overshoot) + start
    End If
End Function

Function OvershootEaseOutIn(start, finish, currentTime, duration, overshoot = 1.70158 As Float)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return OvershootEaseOut(0, change, currentTime * 2, duration, overshoot) * .5 + start
    Else
        Return OvershootEaseIn(0, change, currentTime * 2 - duration, duration, overshoot) * .5 + (change * .5) + start
    End If
End Function

' ****************
' Bounce
' ****************
Function BounceTween(start, finish, currentTime, duration)
    Return BounceEaseInOut(start, finish, currentTime, duration)
End Function

Function BounceEaseIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    Return change - BounceEaseOut(0, change, duration - currentTime, duration) + start 
End Function

Function BounceEaseOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    time = currentTime / duration
    If time < (1 / 2.75) Then
        Return change * (7.5625 * time * time) + start
    Else If time < (2 / 2.75) Then
        time = time - (1.5 / 2.75)
        Return change * (7.5625 * time * time + .75) + start
    Else If time < (2.5 / 2.75) Then
        time = time - (2.25 / 2.75)
        Return change * (7.5625 * time * time + .9375) + start
    Else
        time = time - (2.625 / 2.75)
        Return change * (7.5625 * time * time + .984375) + start
    End If
End Function

Function BounceEaseInOut(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return BounceEaseIn(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return BounceEaseOut(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function

Function BounceEaseOutIn(start, finish, currentTime, duration)
    If currentTime > duration Or duration = 0 Then Return finish
    change = finish - start
    If currentTime < duration / 2 Then
        Return BounceEaseOut(0, change, currentTime * 2, duration) * .5 + start
    Else
        Return BounceEaseIn(0, change, currentTime * 2 - duration, duration) * .5 + (change * .5) + start
    End If
End Function
