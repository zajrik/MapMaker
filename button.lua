-- @namespace MapMaker
-- @class Button: A clickable button. Buttons can have a dynamic
-- width but have a fixed height of 25 pixels
local MapMaker = {}; function MapMaker.newButton(text, x, y, width, enabled)

	-- Constructor
	local this =
	{
		text    = text,
		x       = x,
		y       = y,
		width   = width,
		enabled = enabled or true,

		height = 25,
		active = false
	}

	local font = love.graphics.newFont(14)

	local colors =
	{
		white = {255, 255, 255},
		black = {0,   0,   0  },

		bg_normal = {30,  30,  30 },
		bg_active = {50,  50,  50 },

		overlay = {0, 0, 0, 175},
	}

	-- Handle display of the button
	function this.Show()
		-- Draw button
		love.graphics.setColor(this.active and
			colors.bg_active or colors.bg_normal)
		love.graphics.rectangle(
			'fill', this.x, this.y, this.width, this.height)

		-- Print text, centered on button
		love.graphics.setColor(colors.white)
		love.graphics.print(
			this.text,
			math.floor((this.width / 2) - (font:getWidth(this.text) / 2) + this.x),
			math.floor((this.height / 2) - (font:getHeight()/2) + this.y)
		)

		-- Draw disabled button overlay
		if not this.enabled then
			love.graphics.setColor(colors.overlay)
			love.graphics.rectangle(
				'fill', this.x, this.y, this.width, this.height)
		end
	end

	-- Check for button mouseover via current position
	-- or position provided via method parameters
	local function Mouseover(px, py)
		local mx, my
		if px and py then mx, my = px, py
		else mx, my = love.mouse.getPosition() end
		return  mx > this.x and my > this.y
			and mx < this.x + this.width
			and my < this.y + this.height
	end

	-- Handle mouse press, show button click feedback
	function this.mousepressed(clickx, clicky, button)
		this.active = Mouseover() and this.enabled
	end

	-- Handle mouse release,
	function this.mousereleased(clickx, clicky, button, clickHandler)
		this.active = false
		if Mouseover(clickx, clicky) and this.enabled then
			(clickHandler)() end
	end
	return this
end

return MapMaker
