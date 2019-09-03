function Collisions_CircleRotatedRect(cx as integer, cy as integer, cr as float, rx as integer, ry as integer, rw as integer, rh as integer, rotation_origin_x as integer, rotation_origin_y as integer, degrees as integer) as boolean
    circle_center = Math_NewVector(cx, cy)
    rotation_point = Math_NewVector(rx + rotation_origin_x, ry + rotation_origin_y)
    new_circle_pos = Math_RotateVectorAroundVector(circle_center, rotation_point, -Math_DegreesToRadians(degrees))

    return Collisions_CircleRect(new_circle_pos.x, new_circle_pos.y, cr, rx, ry, rw, rh)
end function

function Collisions_CircleRect(cx as integer, cy as integer, cr as float, rx as integer, ry as integer, rw as integer, rh as integer)
    circle_distance_x = Abs(cx - rx - rw / 2)
    circle_distance_y = Abs(cy - ry - rh / 2)

    if (circle_distance_x > (rw / 2 + cr) or circle_distance_y > (rh / 2 + cr))
        return false
    else if (circle_distance_x <= (rw / 2) or circle_distance_y <= (rh / 2))
        return true
    end if

    return (circle_distance_x - rw / 2)^2 + (circle_distance_y - rh / 2)^2 <= cr^2
end function

function CollisionTranslating_CircleRect(cx as double, cy as double, cr as double, rx as double, ry as double, rw as double, rh as double)
    circle = Math_NewCircle(cx, cy, cr)
    rectangle = Math_NewRectangle(rx, ry, rw, rh)
    distances = CollisionTranslating_CircleRectDistances(cx, cy, cr, rx, ry, rw, rh)
    is_colliding_with_flat = false
    if (circle.x > rectangle.Left() and circle.x < rectangle.Right()) or (circle.y > rectangle.Top() and circle.y < rectangle.Bottom())
        is_colliding_with_flat = true
    end if

    if is_colliding_with_flat
        smallest_distance_key = invalid
        for each key in distances
            if smallest_distance_key = invalid
                smallest_distance_key = key
            else if Abs(distances[key]) < Abs(distances[smallest_distance_key])
                smallest_distance_key = key
            end if
        end for

        new_pos = Math_NewVector(cx, cy)
        if smallest_distance_key = "left" or smallest_distance_key = "right"
            new_pos.x += distances[smallest_distance_key]
        else
            new_pos.y += distances[smallest_distance_key]
        end if
        return new_pos
    else
        smallest_distance_key_x = "right"
        smallest_distance_key_y = "bottom"
        if Abs(distances["left"]) < Abs(distances[smallest_distance_key_x])
            smallest_distance_key_x = "left"
        end if
        if Abs(distances["top"]) < Abs(distances[smallest_distance_key_y])
            smallest_distance_key_y = "top"
        end if

        collision_corner_vector = rectangle[smallest_distance_key_y + smallest_distance_key_x]()
        translation_angle_radians = Math_GetAngle(collision_corner_vector, circle.Center())
        translation_hypotenuse = circle.radius
        translation_x = Cos(translation_angle_radians) * translation_hypotenuse
        translation_y = Sin(translation_angle_radians) * translation_hypotenuse
        translation_vector = Math_NewVector(translation_x, translation_y)

        new_pos = Math_AddVectors(collision_corner_vector, translation_vector)
        return new_pos
    end if
end function

function CollisionTranslating_CircleRectDistances(cx as double, cy as double, cr as double, rx as double, ry as double, rw as double, rh as double)
    circle = Math_NewCircle(cx, cy, cr)
    rectangle = Math_NewRectangle(rx, ry, rw, rh)

    distances = {
        left: (rectangle.Left() - circle.radius) - circle.x
        right: (rectangle.Right() + circle.radius) - circle.x
        top: (rectangle.Top() - circle.radius) - circle.y
        bottom: (rectangle.Bottom() + circle.radius) - circle.y
    }
    return distances
end function

function CollisionTranslating_GetClosestCornerToPoint(vector as object, rectangle as object) as object
    corners = {
        top_left: rectangle.TopLeft()
        top_right: rectangle.TopRight()
        bottom_left: rectangle.BottomLeft()
        bottom_right: rectangle.BottomRight()
    }

    closest_corner_key = invalid
    for each key in corners
        if closest_corner_key = invalid
            closest_corner_key = key
        else if Math_TotalDistance(vector, corners[key]) < Math_TotalDistance(vector, corners[closest_corner_key])
            closest_corner_key = key
        end if
    end for

    return corners[closest_corner_key]
end function
