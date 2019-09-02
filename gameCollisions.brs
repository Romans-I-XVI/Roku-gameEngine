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

function CollisionTranslating_CircleRectUsingDirection(cx as double, cy as double, cr as double, direction_in_degrees as double, rx as double, ry as double, rw as double, rh as double) as object
    translation_distances = CollisionTranslating_CircleRect(cx, cy, cr, rx, ry, rw, rh)
    translation_direction = direction_in_degrees + 180
    while translation_direction > 360
        translation_direction -= 360
    end while
    while translation_direction <= 0
        translation_direction += 360
    end while

    viable_side = ""
    viable_topbottom = ""
    if translation_direction >= 0 and translation_direction <= 90
        viable_side = "right"
        viable_topbottom = "bottom"
    else if translation_direction > 90 and translation_direction <= 180
        viable_side = "left"
        viable_topbottom = "bottom"
    else if translation_direction > 180 and translation_direction <= 270
        viable_side = "left"
        viable_topbottom = "top"
    else
        viable_side = "right"
        viable_topbottom = "top"
    end if

    viable_x = translation_distances[viable_side]
    viable_y = translation_distances[viable_topbottom]
    translation_direction_radians = Math_DegreesToRadians(translation_direction)
    distance_option_1 = viable_y / Sin(translation_direction_radians)
    distance_option_2 = viable_x / Cos(translation_direction_radians)
    distance_to_translate = invalid
    if Abs(distance_option_1) <= Abs(distance_option_2)
        distance_to_translate = distance_option_1
    else
        distance_to_translate = distance_option_2
    end if

    offset = Math_HypotenuseToVector(distance_to_translate, translation_direction_radians)
    new_pos = Math_NewVector(cx + offset.x, cy + offset.y)
    return new_pos  
end function

function CollisionTranslating_CircleRect(cx as double, cy as double, cr as double, rx as double, ry as double, rw as double, rh as double)
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
