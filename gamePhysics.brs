function Physics_NewCircle(x as double, y as double, radius as double, xspeed as double, yspeed as double, mass = invalid as dynamic) as object
    circle = Math_NewCircle(x, y, radius)
    circle.speed = Math_NewVector(xspeed, yspeed)
    circle.mass = mass

    circle.Copy = function()
        return Physics_NewCircle(m.x, m.y, m.radius, m.speed.x, m.speed.y, m.mass)
    end function

    return circle
end function

function Physics_NewRectangle(x as double, y as double, width as double, height as double, xspeed as double, yspeed as double, mass = invalid as dynamic) as object
    rectangle = Math_NewRectangle(x, y, width, height)
    rectangle.speed = Math_NewVector(xspeed, yspeed)
    rectangle.mass = mass

    rectangle.Copy = function()
        return Physics_NewRectangle(m.x, m.y, m.width, m.height, m.speed.x, m.speed.y, m.mass)
    end function

    return rectangle
end function

function Physics_CircleCircle(physics_circle_1 as object, physics_circle_2 as object) as object
    ' Credits for this ManageBounce() function go to - http://www.emanueleferonato.com/2007/08/19/managing-ball-vs-ball-collision-with-flash/
    circle_1 = physics_circle_1
    circle_2 = physics_circle_2

    if (circle_1.mass = invalid and circle_2.mass = invalid) or (circle_1.mass <> invalid and circle_1.mass < 0) or (circle_2.mass <> invalid and circle_2.mass < 0)
        print "circles must not have negative mass and at least one must have a mass"
        stop
    end if

    ' Do some fiddling with mass to ensure nothing breaks and handle static circles
    mass_1 = circle_1.mass
    mass_2 = circle_2.mass
    if mass_1 = 0 and mass_2 = 0
        mass_1 = 1
        mass_2 = 1
    else if mass_1 = invalid
        mass_1 = 1
        mass_2 = 0
    else if mass_2 = invalid
        mass_2 = 1
        mass_1 = 0
    end if
    
    ' Save old x and y speeds for later
    old_x_speed_1 = circle_1.speed.x
    old_y_speed_1 = circle_1.speed.y
    old_x_speed_2 = circle_2.speed.x
    old_y_speed_2 = circle_2.speed.y
    
    ' Get the x and y distances between the balls.
    current_distance_vector = Math_NewVector(circle_1.x - circle_2.x, circle_1.y - circle_2.y)
    collision_angle = current_distance_vector.DirectionInRadians()
    
    ' Solve for new velocities (other sides of triangle) using trigonometry
    new_xspeed_1 = circle_1.speed.Magnitude() * cos(circle_1.speed.DirectionInRadians() - collision_angle)
    new_yspeed_1 = circle_1.speed.Magnitude() * sin(circle_1.speed.DirectionInRadians() - collision_angle)
    new_xspeed_2 = circle_2.speed.Magnitude() * cos(circle_2.speed.DirectionInRadians() - collision_angle)
    new_yspeed_2 = circle_2.speed.Magnitude() * sin(circle_2.speed.DirectionInRadians() - collision_angle)
    
    ' Factor in mass to new velocities
    final_xspeed_1 = ((mass_1 - mass_2) * new_xspeed_1 + (mass_2 + mass_2) * new_xspeed_2) / (mass_1 + mass_2)
    final_xspeed_2 = ((mass_1 + mass_1) * new_xspeed_1 + (mass_2 - mass_1) * new_xspeed_2) / (mass_1 + mass_2)
    final_yspeed_1 = new_yspeed_1
    final_yspeed_2 = new_yspeed_2
    
    ' Do some magic
    new_speed_1 = Math_NewVector()
    new_speed_2 = Math_NewVector()
    new_speed_1.x = cos(collision_angle) * final_xspeed_1 + cos(collision_angle + Math_PI() / 2) * final_yspeed_1
    new_speed_1.y = sin(collision_angle) * final_xspeed_1 + sin(collision_angle + Math_PI() / 2) * final_yspeed_1
    new_speed_2.x = cos(collision_angle) * final_xspeed_2 + cos(collision_angle + Math_PI() / 2) * final_yspeed_2
    new_speed_2.y = sin(collision_angle) * final_xspeed_2 + sin(collision_angle + Math_PI() / 2) * final_yspeed_2
    
    result = {
        speed_1: new_speed_1,
        speed_2: new_speed_2
    }
    return result
end function

function Physics_CircleRect(physics_circle as object, physics_rectangle as object) as object
    circle = physics_circle
    rectangle = physics_rectangle

    if (circle.mass = invalid and rectangle.mass = invalid) or (circle.mass <> invalid and circle.mass < 0) or (rectangle.mass <> invalid and rectangle.mass < 0)
        print "circles must not have negative mass and at least one must have a mass"
        stop
    end if

    ' Do some fiddling with mass to ensure nothing breaks and handle static circles
    circle_mass = circle.mass
    rectangle_mass = rectangle.mass
    if circle_mass = 0 and rectangle_mass = 0
        circle_mass = 1
        rectangle_mass = 1
    else if circle_mass = invalid
        circle_mass = 1
        rectangle_mass = 0
    else if rectangle_mass = invalid
        rectangle_mass = 1
        circle_mass = 0
    end if

    distances = CollisionTranslating_CircleRectDistances(circle.x, circle.y, circle.radius, rectangle.x, rectangle.y, rectangle.width, rectangle.height)
    circle_speed = Math_NewVector(circle.speed.x, circle.speed.y)
    rectangle_speed = Math_NewVector(rectangle.speed.x, rectangle.speed.y)

    smallest_distance_key = invalid
    for each key in distances
        if smallest_distance_key = invalid
            smallest_distance_key = key
        else if Abs(distances[key]) < Abs(distances[smallest_distance_key])
            smallest_distance_key = key
        end if
    end for

    if smallest_distance_key = "left" or smallest_distance_key = "right"
        result_1d = Physics_ElasticCollision1D(circle_mass, circle.speed.x, rectangle_mass, rectangle.speed.x)
        circle_speed.x = result_1d.speed_1
        rectangle_speed.x = result_1d.speed_2
    else if smallest_distance_key = "top" or smallest_distance_key = "bottom"
        result_1d = Physics_ElasticCollision1D(circle_mass, circle.speed.y, rectangle_mass, rectangle.speed.y)
        circle_speed.y = result_1d.speed_1
        rectangle_speed.y = result_1d.speed_2
    end if

    result = {
        circle_speed: circle_speed
        rectangle_speed: rectangle_speed
    }
    return result
end function

function Physics_ElasticCollision1D(mass_1 as double, speed_1 as double, mass_2 as double, speed_2 as double) as object
    m1 = mass_1
    vi1 = speed_1
    m2 = mass_2
    vi2 = speed_2

    final_speed_1 = ((m1 - m2) * vi1 + (2 * m2 * vi2)) / (m1 + m2)
    final_speed_2 = ((2 * m1 * vi1) - (m1 - m2) * vi2) / (m1 + m2)

    result = {
        speed_1: final_speed_1
        speed_2: final_speed_2
    }
    return result
end function