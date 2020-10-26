function Math_Clamp(number, min, max)
	if number < min
		return min
	else if number > max
		return max
	else
		return number
	end if
end function

function Math_PI()
	return 3.1415926535897932384626433832795
end function

function Math_Atan2(y as float, x as float)
    if x > 0
		angle = Atn(y/x)
	else if y >= 0 and x < 0
		angle = Atn(y/x)+3.14159265359
	else if y < 0 and x < 0
		angle = Atn(y/x)-3.14159265359
	else if y > 0 and x = 0
		angle = 3.14159265359/2
	else if y < 0 and x = 0
		angle = (3.14159265359/2)*-1
	else
		angle = 0
	end if

	return angle
end function

function Math_IsIntegerEven(number as integer) as boolean
	return (number MOD 2 = 0)
end function

function Math_IsIntegerOdd(number as integer) as boolean
	return (number MOD 2 <> 0)
end function

function Math_DegreesToRadians(degrees as float) as float
	return (degrees / 180) * Math_PI()
end function

function Math_RadiansToDegrees(radians as float) as float
	return (180 / Math_PI()) * radians
end function

function Math_RandomRange(lowest_int as integer, highest_int as integer) as integer
	return rnd(highest_int - (lowest_int - 1)) + (lowest_int - 1)
end function

function Math_RotateVectorAroundVector(vector1 as object, vector2 as object, radians as float) as object
	v = Math_NewVector(vector1.x, vector1.y)
	s = sin(radians)
	c = cos(radians)

    v.x -= vector2.x
    v.y -= vector2.y

    new_x = v.x * c + v.y * s
    new_y = -v.x * s + v.y * c

    v.x = new_x + vector2.x
    v.y = new_y + vector2.y
    
    return v
end function

function Math_NewVector(x = 0, y = 0) as object
	return {x: x, y: y}
end function

function Math_NewRectangle(x as integer, y as integer, width as integer, height as integer) as object
	rect = {
		x: x
		y: y
		width: width
		height: height
	}

	rect.Right = function() as integer
		return m.x + m.width
	end function

	rect.Left = function() as integer
		return m.x
	end function

	rect.Top = function() as integer
		return m.y
	end function

	rect.Bottom = function() as integer
		return m.y + m.height
	end function

	rect.Center = function() as object
		return {x: m.x + m.width / 2, y: m.y + m.height / 2}
	end function

	rect.Copy = function() as object
		return Math_NewRectangle(m.x, m.y, m.width, m.height)
	end function

	return rect
end function

function Math_NewCircle(x as integer, y as integer, radius as float) as object
	return {x: x, y: y, radius: radius}
end function

function Math_TotalDistance(vector1 as object, vector2 as object) as object
	x_distance = vector1.x - vector2.x
	y_distance = vector1.y - vector2.y
	total_distance = Sqr(x_distance * x_distance + y_distance * y_distance)
	return total_distance
end function

function Math_GetAngle(vector1 as object, vector2 as object) as float
	x_distance = vector1.x - vector2.x
	y_distance = vector1.y - vector2.y
	return Math_Atan2(y_distance, x_distance) + Math_PI()
end function
