function atan2(y, x)
    if x > 0
        collision_angle = Atn(y/x)
    else if y >= 0 and x < 0
        collision_angle = Atn(y/x)+3.14159265359
    else if y < 0 and x < 0
        collision_angle = Atn(y/x)-3.14159265359
    else if y > 0 and x = 0
        collision_angle = 3.14159265359/2
    else if y < 0 and x = 0
        collision_angle = (3.14159265359/2)*-1
    else
        collision_angle = 0
    end if
    
    return collision_angle
end function

Function HSVtoRGB(h%,s%,v%,a = invalid) As Integer
   ' Romans_I_XVI port (w/ a few tweaks) of:
   ' http://schinckel.net/2012/01/10/hsv-to-rgb-in-javascript/
    
	h% = h% MOD 360
   
	rgb = [ 0, 0, 0 ]
	if s% = 0 then
		rgb = [v%/100, v%/100, v%/100]
	else
		s = s%/100 : v = v%/100 : h = h%/60 : i = int(h)

		data = [v*(1-s), v*(1-s*(h-i)), v*(1-s*(1-(h-i)))]
     
		if i = 0 then
			rgb = [v, data[2], data[0]]
		else if i = 1 then
			rgb = [data[1], v, data[0]]   
		else if i = 2 then
			rgb = [data[0], v, data[2]]
		else if i = 3 then
			rgb = [data[0], data[1], v]
		else if i = 4 then
			rgb = [data[2], data[0], v]
		else
			rgb = [v, data[0], data[1]]
		end if
	end if

	for c = 0 to rgb.count()-1 : rgb[c] = int(rgb[c] * 255) : end for
	if a <> invalid then
		color% = (rgb[0] << 24) + (rgb[1] << 16) + (rgb[2] << 8) + a
	else
		color% = (rgb[0] << 16) + (rgb[1] << 8) + rgb[2]
	end if

	return color%
End Function

function registryWrite(registry_section as String, key as String, value as Dynamic) as Void
    section = CreateObject("roRegistrySection", registry_section)
    section.Write(key, FormatJson(value))
    section.Flush()
end function

function registryRead(registry_section as String, key as String, default_value = "" as Dynamic) as Dynamic
	section = CreateObject("roRegistrySection", registry_section)
    if section.Exists(key) then
        return ParseJson(section.Read(key))
    else
    	section.Write(key, FormatJson(default_value))
    	section.Flush()
    	return default_value
    end if
end function

function DrawText(draw2d as Object, text as String, x as Integer, y as Integer, font as Object, alignment = "left" as String, color = &hFFFFFFFF as Integer) as Void
	if alignment = "left"
		draw2d.DrawText(text, x, y, color, font)
	else if alignment = "right"
		draw2d.DrawText(text, x-font.GetOneLineWidth(text, 10000), y, color, font)
	else if alignment = "center"
		draw2d.DrawText(text, x-font.GetOneLineWidth(text, 10000)/2, y, color, font)
	end if
end function