-- @namespace MapMaker
-- @class Button: A clickable button. Buttons can have a dynamic
-- width but have a fixed height of 25 pixels
local MapMaker = {}; function MapMaker.newButton(text, x, y, width)
	
	-- Constructor
	local this = 
	{
		text   = text,
		x      = x,
		y      = y,
		width  = width,
		height = 25,
		active = false
	}

	local font = love.graphics.newFont(14)

	-- Handle display of the button
	function this.Show()
		if this.active then
			love.graphics.setColor(30, 30, 30, 255)
		else
			love.graphics.setColor(50, 50, 50, 255)
		end
		love.graphics.rectangle('fill', this.x, this.y, this.width, this.height)
		love.graphics.setColor(255, 255, 255, 255)
		-- Print text, centered on button
		love.graphics.print(
			this.text, 
			(this.width / 2) - (font:getWidth(this.text) / 2) + this.x, 
			(this.height / 2) - (font:getHeight()/2) + this.y - 1
		)
	end

	-- Handle mouse press, show button click feedback
	function this.mousepressed(x, y, button)
		if x > this.x and x < this.x + width 
			and y > this.y and y < this.y + this.height then
				this.active = true
		else
			this.active = false
		end
	end

	-- Handle mouse release, 
	function this.mousereleased(x, y, button, clickHandler)
		this.active = false
		if x > this.x and x < this.x + width 
			and y > this.y and y < this.y + this.height then
				(clickHandler)()
		end
	end
	return this
end

return MapMaker