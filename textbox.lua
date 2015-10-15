-- @namespace MapMaker
-- @class TextBox: A simple textbox implementation
local MapMaker = {}; function MapMaker.newTextBox(value, x, y, width)
	
	-- Constructor
	local this = 
	{
		x        = x,
		y        = y,
		width    = width,
		value    = value,
		height   = 20,
		selected = false
	}

	local utf8 = require 'utf8'
	local font = love.graphics.newFont("SourceCodePro-Regular.ttf", 14)
	local timer = 0

	-- Update timer
	function this.update(dt)
		timer = timer + dt
		if timer >= 1.5 or not this.selected
			then timer = 0 end
	end

	-- Handle display of the text box
	function this.Show()
		if this.selected then love.graphics.setColor(0, 0, 0, 255) 
		else love.graphics.setColor(150, 150, 150, 255) end
		love.graphics.rectangle(
			'fill', this.x, this.y, this.width, this.height)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle(
			'fill', this.x + 1, this.y + 1, this.width - 2, this.height - 2)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(this.value, this.x + 2, this.y)
		if timer <= .75 and this.selected then
			love.graphics.print('|', font:getWidth(this.value) + this.x, this.y - 1)
		else end
	end

	-- Handle mouse press
	function this.mousepressed(x, y, button)
		if x > this.x and x < this.x + width 
			and y > this.y and y < this.y + this.height then
				this.selected = true
		else
			this.selected = false
		end
	end

	-- Handle text input
	function this.textinput(text)
		if text:match('%d') and string.len(this.value) < 2 then
			this.value = this.value..text
			timer = 0
		end
	end

	-- Handle key press
	function this.keypressed(key)
		if key == 'backspace' then
			local offset = utf8.offset(this.value, -1)
			if offset then
				this.value = string.sub(this.value, 1, offset - 1)
				timer = 0
			end
		end
	end

	return this
end

return MapMaker