-- @namespace MapMaker
-- @class Button: A clickable button
font = love.graphics.newFont("SourceCodePro-Regular.ttf", 14)
local MapMaker = {}; function MapMaker.newButton(text, x, y, width)
	
	-- Constructor
	local this = 
	{
		text = text,
		x = x,
		y = y,
		width = width,
		active = false
	}

	-- Handle display of the button
	function this.Show()
		if this.active then
			love.graphics.setColor(30, 30, 30, 255)
		else
			love.graphics.setColor(50, 50, 50, 255)
		end
		love.graphics.rectangle('fill', x, y, width, 25)
		love.graphics.setColor(255, 255, 255, 255)
		-- Print text, centered on button
		love.graphics.print(
			text, 
			(this.width / 2) - (font:getWidth(text) / 2) + this.x, 
			this.y + (font:getHeight()/6)
		)
	end

	-- Handle mouse press, show button click feedback
	function this.mousepressed(x, y, button)
		if x > this.x and x < this.x + width and y > this.y and y < this.y + 25 then
			this.active = true
		else
			this.active = false
		end
	end

	-- Handle mouse release, 
	function this.mousereleased(x, y, button, clickHandler)
		this.active = false
		if x > this.x and x < this.x + width and y > this.y and y < this.y + 25 then
			(clickHandler)()
		end
	end
	return this
end

return MapMaker