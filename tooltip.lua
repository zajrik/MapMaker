-- @namespace MapMaker
-- @class Tooltip: A dynamic tooltip that is bound to an on-screen object.
-- Will be displayed when the parent object is moused over if the tooltip
-- text has been set. The tooltip will be centered above the parent object
-- unless forced to overlap the parent object by window constraints, in
-- which case it will be moved to the lower left-hand corner of the grid.
local MapMaker = {}; function MapMaker.newTooltip(parent)
	
	-- Constructor
	local this = 
	{
		parent = parent,
		text = nil
	}

	local font_normal = love.graphics.newFont(14)
	local font_medium = love.graphics.newFont(11)

	local canvas_tooltip = love.graphics.newCanvas(2, 2)

	local maxWidth = 200
	local x, y
	local width, lines
	local height

	local maxTimer, timer = .075, 0
	local alpha = 0
	local visible = false

	-- Check if mouse is within the bounds of parent object
	local function CheckParentBounds()
		local x, y = love.mouse.getPosition()
		return  x > this.parent.x
			and y > this.parent.y
			and x < this.parent.x + this.parent.width
			and y < this.parent.y + this.parent.height
	end

	-- Ensure a number stays inside min/max boundaries
	local function InRange(num, min, max)
		return math.max(min, math.min(num, max))
	end
	
	-- Update timer
	function this.update(dt)
		timer = InRange((visible and timer + dt or timer - dt), 0, maxTimer)
		local percent = timer / maxTimer
		alpha = 255 * percent
	end

	-- Add tooltip to view, show when parent is moused over
	function this.Add()
		visible = (CheckParentBounds() and this.text ~= nil)
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.draw(canvas_tooltip, x, y)
	end

	-- Set the tooltip text and re-initialize the tooltip canvas
	function this.SetText(text)
		this.text = text

		-- Tooltip will not draw if text is set to nil
		if this.text == nil then return end

		love.graphics.setFont(font_medium)

		width, lines = font_medium:getWrap(this.text, maxWidth)
		height = font_medium:getHeight()

		width = width + 6
		height = (height * lines) + 8

		x = this.parent.x + math.floor((this.parent.width / 2) - (width / 2))
		y = this.parent.y - (height + 5)

		-- Enforce drawing within window bounds
		winW, winH = love.window.getDimensions()
		x = InRange(x, 5, (winW - width) - 5)
		y = InRange(y, 5, (winH - height) - 57)

		-- Move tooltip to lower left corner if it obscures parent
		if      x < this.parent.x + this.parent.width
			and y < this.parent.y + this.parent.height
			and this.parent.x < x + width
			and this.parent.y < y + height then
				x, y = 5, (winH - height) - 57
		end

		-- Redraw canvas content
		canvas_tooltip = love.graphics.newCanvas(width, height)
		canvas_tooltip:renderTo(function()
			-- Draw tooltip box
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.rectangle('fill', 0, 0, width, height)
			love.graphics.setColor(75, 75, 75, 255)
			love.graphics.rectangle(
				'fill', 1, 1, width - 2, height - 2)

			-- Draw tooltip text
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.printf(
				this.text,
				4, 4, maxWidth, 'left')
		end)

		love.graphics.setFont(font_normal)
	end

	return this
end

return MapMaker
