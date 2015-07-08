require 'cairo'

even = false

function conky_draw_meter()
	if not conky_window then
		return
	end

	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
	local cr = cairo_create(cs)
	
	draw_cpu_bars(cr,conky_window.width-400,conky_window.height-100,400,200)
	even = not even
	--draw_ram(cr,conky_window.width-190,conky_window.height-280,250)
end

function draw_ram(cr,left,bottom,width,height)
	local value

	cairo_move_to(cr,left+width,bottom)
	cairo_line_to(cr,left+width,bottom-height)
	cairo_line_to(cr,left+width*(2/3),bottom)
	cairo_line_to(cr,left+width,bottom)
	cairo_set_source_rgba(cr,1,1,1,0.25)
	cairo_stroke(cr)

	value = tonumber(conky_parse('${memperc}'))
	if value then
		if even and value > 80 then
			cairo_set_source_rgba(cr,1,0,0,1.00)
		else
			cairo_set_source_rgba(cr,247/255,154/255,66/255,1.00)
		end
		cairo_move_to(cr,left+width,bottom-height)
		cairo_line_to(cr,left+width,bottom-(1-value/100)*height)
		cairo_line_to(cr,left+width*(2+value/100)/3,bottom)
		cairo_line_to(cr,left+width*(2/3),bottom)
		cairo_fill(cr)
	end
end

function draw_cpu_bars(cr,left,bottom,width,height)
	cairo_set_line_cap(cr,CAIRO_LINE_CAP_SQUARE)
	cairo_set_line_width(cr,1)
	local value, x1,y1, x2,y2
	for i=0,7,1 do
		x1 = left+(i*width/12)
		x2 = left+(i*width/12)+(width/3)
		y1 = bottom
		y2 = bottom - height

		cairo_set_source_rgba(cr,1,1,1,0.25)
		draw_bar(cr,x1,y1,x2,y2)

		cairo_fill(cr)
		value = tonumber(conky_parse('${cpu cpu'..i..'}'))
		if value then
			cairo_set_source_rgba(cr,1,1,1,1.00)
			draw_bar(cr,x1,y1,lerp(x1,x2,value/100),lerp(y1,y2,value/100))
			cairo_fill(cr)
		end
	end
	draw_ram(cr,left-8,bottom,width,height)
end

function lerp(a,b,percent)
	return a*(1-percent)+b*percent
end

function draw_bar(cr,x1,y1,x2,y2)
	local lineSize = 8
	cairo_move_to(cr,x1-lineSize,y1)
	cairo_line_to(cr,x1+lineSize,y1)
	cairo_line_to(cr,x2+lineSize,y2)
	cairo_line_to(cr,x2-lineSize,y2)
end

