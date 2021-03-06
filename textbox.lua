-- @namespace MapMaker
-- @class TextBox: A simple textbox implementation
local MapMaker = {}; function MapMaker.newTextBox(value, x, y, width)

	-- Constructor
	local this =
	{
		value    = value,
		x        = x,
		y        = y,
		width    = width,

		height   = 20,
		oldValue = value,
		selected = false
	}

	local utf8 = require 'utf8'
	local font = love.graphics.newFont(14)
	local maxTimer, timer = 1.5, 0

	local colors =
	{
		white = {255, 255, 255},
		black = {0,   0,   0  },

		border = {150, 150, 150},
	}

	-- Update timer
	function this.update(dt)
		timer = timer + dt
		if timer >= maxTimer then timer = 0 end
	end

	-- Handle display of the text box
	function this.draw()
		-- Draw border rectangle
		love.graphics.setColor(this.selected and
			colors.black or colors.border)
		love.graphics.rectangle(
			'fill', this.x, this.y, this.width, this.height)

		-- Draw bg rectangle
		love.graphics.setColor(colors.white)
		love.graphics.rectangle(
			'fill', this.x + 1, this.y + 1, this.width - 2, this.height - 2)

		-- Draw textbox text
		love.graphics.setColor(colors.black)
		love.graphics.print(this.value, this.x + 3, this.y + 2)

		-- Draw text cursor
		if timer <= maxTimer / 2 and this.selected then love.graphics.print(
			'|', font:getWidth(this.value) + this.x + 2, this.y + 1) end
	end

	-- Check for textbox mouseover
	local function Mouseover()
		local mx, my = love.mouse.getPosition()
		return  mx > this.x and my > this.y
			and mx < this.x + this.width
			and my < this.y + this.height
	end

	-- Handle mouse press
	function this.mousepressed(clickx, clicky, button)
		this.selected = Mouseover()
		timer = 0
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
		elseif key == 'tab' then timer = 0 end
	end

	return this
end

return MapMaker
