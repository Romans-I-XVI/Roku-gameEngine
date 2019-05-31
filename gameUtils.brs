function atan2(y, x)
	return Math_Atan2(y, x)
end function

function HSVtoRGB(h%,s%,v%,a = invalid) as integer
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
end function

function registryWrite(registry_section as string, key as string, value as dynamic) as void
	section = CreateObject("roRegistrySection", registry_section)
	section.Write(key, FormatJson(value))
	section.Flush()
end function

function registryRead(registry_section as string, key as string, default_value = invalid as dynamic) as dynamic
	section = CreateObject("roRegistrySection", registry_section)
	if section.Exists(key) then
		return ParseJson(section.Read(key))
	else
		if default_value <> invalid
			section.Write(key, FormatJson(default_value))
			section.Flush()
		end if
		return default_value
	end if
end function

function DrawText(draw2d as object, text as string, x as integer, y as integer, font as object, alignment = "left" as string, color = &hEBEBEBFF as integer) as void
	if alignment = "left"
		draw2d.DrawText(text, x, y, color, font)
	else if alignment = "right"
		draw2d.DrawText(text, x-font.GetOneLineWidth(text, 10000), y, color, font)
	else if alignment = "center"
		draw2d.DrawText(text, x-font.GetOneLineWidth(text, 10000)/2, y, color, font)
	end if
end function

' NOTE: This function is unsafe! It creates an roBitmap of the required size to be able to both scale and rotate the drawing, this action requires free video memory of the appropriate amount.
function DrawScaledAndRotatedObject(draw2d as object, x as float, y as float, scale_x as float, scale_y as float, theta as float, drawable as object, color = &hFFFFFFFF as integer) as void
	new_width = Abs(int(drawable.GetWidth() * scale_x))
	new_height = Abs(int(drawable.GetHeight() * scale_y))
	if new_width <> 0 and new_height <> 0
		new_drawable = CreateObject("roBitmap", {width: new_width, height: new_height, AlphaEnable: true})
		scaled_draw_x = 0
		scaled_draw_y = 0
		if scale_x < 0
			scaled_draw_x = new_width
		end if
		if scale_y < 0
			scaled_draw_y = new_height
		end if
		new_drawable.DrawScaledObject(scaled_draw_x, scaled_draw_y, scale_x, scale_y, drawable)
		draw2d.ifDraw2D.DrawRotatedObject(x, y, theta, new_drawable, color)
		new_drawable = invalid
	end if
end function

function CreateObject_GameTimeSpan() as object
	timer = {
		internal_roku_timer: CreateObject("roTimespan")
		total_milliseconds_modifier: 0
	}
	timer.Mark = function()
		m.internal_roku_timer.Mark()
		m.total_milliseconds_modifier = 0
	end function

	timer.TotalMilliseconds = function()
		return m.internal_roku_timer.TotalMilliseconds() + m.total_milliseconds_modifier
	end function

	timer.TotalSeconds = function()
		return m.internal_roku_timer.TotalSeconds() + cint(m.total_milliseconds_modifier / 1000)
	end function

	timer.GetSecondsToISO8601Date = function(date as string)
		return m.internal_roku_timer.GetSecondsToISO8601Date(date)
	end function

	timer.AddTime = function(milliseconds as integer)
		m.total_milliseconds_modifier += milliseconds
	end function

	timer.RemoveTime = function(milliseconds as integer)
		m.total_milliseconds_modifier -= milliseconds
	end function

	return timer
end function

function TexturePacker_GetRegions(atlas as dynamic, bitmap as object) as object
	if type(atlas) = "String" or type(atlas) = "roString"
		atlas = ParseJson(atlas)
	end if

	regions = {}
	for each key in atlas.frames
		item = atlas.frames[key]
		region = CreateObject("roRegion", bitmap, item.frame.x, item.frame.y, item.frame.w, item.frame.h)

		if item.DoesExist("pivot")
			translation_x = item.spriteSourceSize.x - item.sourceSize.w * item.pivot.x
			translation_y = item.spriteSourceSize.y - item.sourceSize.h * item.pivot.y
			region.SetPretranslation(translation_x, translation_y)
		end if

		regions[key] = region
	end for

	return regions
end function
