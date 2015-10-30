-- @namespace MapMaker
-- @class Button: A clickable button. Buttons can have a dynamic
-- width but have a fixed height of 25 pixels
local MapMaker = {}; function MapMaker.newButton(text, x, y, width, ...)
	local args = {...}

	-- Constructor
	local this = 
	{
		text    = text,
		x       = x,
		y       = y,
		width   = width,
		enabled = 
			((args[1] == nil) and true or 
				((args[1].enabled == nil) and true 
					or args[1].enabled)),

		height = 25,
		active = false
	}

	local font = love.graphics.newFont(14)

	-- Handle display of the button
	function this.Show()
		-- Draw button
		if this.active then
			love.graphics.setColor(30, 30, 30, 255)
		else
			love.graphics.setColor(50, 50, 50, 255)
		end
		love.graphics.rectangle('fill', this.x, this.y, this.width, this.height)

		-- Print text, centered on button
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(
			this.text, 
			math.floor((this.width / 2) - (font:getWidth(this.text) / 2) + this.x), 
			math.floor((this.height / 2) - (font:getHeight()/2) + this.y)
		)

		-- Draw disabled button overlay
		if not this.enabled then
			love.graphics.setColor(0, 0, 0, 175)
			love.graphics.rectangle('fill', this.x, this.y, this.width, this.height)
		end
	end

	-- Check for button mouseover
	local function Mouseover()
		local x, y = love.mouse.getPosition()
		return  x > this.x and y > this.y
			and x < this.x + this.width
			and y < this.y + this.height
	end

	-- Handle mouse press, show button click feedback
	function this.mousepressed(x, y, button)
		this.active = Mouseover() and this.enabled
	end

	-- Handle mouse release, 
	function this.mousereleased(x, y, button, clickHandler)
		this.active = false
		if Mouseover() and this.enabled then 
			(clickHandler)() end
	end
	return this
end

return MapMaker