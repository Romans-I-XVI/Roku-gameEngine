function gameEngine_collisionRectRect(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end function

function gameEngine_collisionCircleCircle(x1,y1,r1, x2,y2,r2)
	dist = Sqr((x1 - x2)^2 + (y1 - y2)^2)
	return dist <= r1 + r2
end function

function gameEngine_collisionCircleRect( cx, cy, cr, rx, ry, rw, rh )
	circle_distance_x = Abs(cx - rx - rw/2)
	circle_distance_y = Abs(cy - ry - rh/2)

	if circle_distance_x > (rw/2 + cr) or circle_distance_y > (rh/2 + cr) then
		return false
	elseif circle_distance_x <= (rw/2) or circle_distance_y <= (rh/2) then
		return true
	end if

	return ((circle_distance_x - rw/2)^2 + (circle_distance_y - rh/2)^2) <= cr^2
end function
