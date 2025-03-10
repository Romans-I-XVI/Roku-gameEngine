function DrawCircle(draw2d, line_count, x, y, radius, color)
	previous_x = radius
	previous_y = 0
	for i = 0 to line_count
		degrees = 360 * (i / line_count)
		current_x = cos(degrees * .01745329) * radius
		current_y = sin(degrees * .01745329) * radius
		draw2d.DrawLine(x + previous_x, y + previous_y, x + current_x, y + current_y, color)
		previous_x = current_x
		previous_y = current_y
	end for
end function
