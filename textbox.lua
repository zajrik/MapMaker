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
		selected = false
	}

	local utf8 = require 'utf8'

	-- Handle display of the text box
	function this.Show()
		love.graphics.setColor(150, 150, 150, 255)
		if this.selected then love.graphics.setColor(0, 0, 0, 255) else end
		love.graphics.rectangle('fill', this.x, this.y, this.width, 20)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle('fill', this.x+1, this.y+1, this.width-2, 18)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(this.value, this.x + 2, this.y)
		
	end

	-- Handle mouse press
	function this.mousepressed(x, y, button)
		if x > this.x and x < this.x + width 
			and y > this.y and y < this.y + 20 then
				this.selected = true
		else
			this.selected = false
		end
	end

	-- Handle text input
	function this.textinput(text)
		if text:match('%d') and string.len(this.value) < 2 then
			this.value = this.value..text
		end
	end

	-- Handle key press
	function this.keypressed(key)
		if key == 'backspace' then
			local offset = utf8.offset(this.value, -1)

			if offset then
				this.value = string.sub(this.value, 1, offset - 1)
			end
		end
	end

	return this
end

return MapMaker