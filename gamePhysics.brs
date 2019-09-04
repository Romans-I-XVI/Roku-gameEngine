function Physics_NewCircle(x as float, y as float, radius as float, xspeed as float, yspeed as float, mass = invalid as dynamic) as object
    circle = Math_NewCircle(x, y, radius)
    circle.speed = Math_NewVector(xspeed, yspeed)
    circle.mass = mass
    
    circle.Copy = function()
        return Physics_NewCircle(m.x, m.y, m.radius, m.speed.x, m.speed.y, m.mass)
    end function
    
    return circle
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