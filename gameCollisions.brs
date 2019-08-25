function Collisions_CircleRotatedRect(cx as integer, cy as integer, cr as float, rx as integer, ry as integer, rw as integer, rh as integer, degrees as integer)

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