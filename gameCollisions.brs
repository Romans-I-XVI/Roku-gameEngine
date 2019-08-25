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