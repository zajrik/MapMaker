-- @namespace MapMaker
-- @class TextBox: A simple textbox implementation
local MapMaker = {}; function MapMaker.newTextBox(value, x, y, width)
	
	-- Constructor
	local this = 
	{
		x = x,
		y = y,
		width = width,
		value = value,
		selected = false
	}

	local utf8 = require 'utf8'

	-- Handle display of the text box
	function this.Show()
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle('fill', this.x, this.y, this.width, 20)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(this.value, this.x + 2, this.y)
		love.graphics.setColor(150, 150, 150, 255)
		love.graphics.setLineWidth(1)
		if this.selected then love.graphics.setColor(0, 0, 0, 255) else end
		love.graphics.rectangle('line', this.x, this.y, this.width, 20)
	end

	-- Handle mouse press
	function this.mousepressed(x, y, button)
		if x > this.x and x < this.x + width and y > this.y and y < this.y + 20 then
			this.selected = true
			print('clicked: textbox')
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