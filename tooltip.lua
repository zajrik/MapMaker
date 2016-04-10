-- @namespace MapMaker
-- @class Tooltip: A dynamic tooltip that is bound to an on-screen object.
-- Will be displayed when the parent object is moused over if the tooltip
-- text has been set. The tooltip will be centered above the parent object
-- unless forced to overlap the parent object by window constraints, in
-- which case it will be moved to the lower left-hand corner of the grid.
-- The tooltip text can be changed via the SetText() method.
local MapMaker = {}; function MapMaker.newTooltip(parent)

	-- Constructor
	local this =
	{
		parent = parent or nil,
		text = nil
	}

	local font_normal = love.graphics.newFont(14)
	local font_medium = love.graphics.newFont(11)

	local colors =
	{
		white = {255, 255, 255},
		black = {0,   0,   0  },

		bg_gray = {75, 75, 75},

		alpha = {255, 255, 255, 0}
	}

	local canvas_tooltip = love.graphics.newCanvas(2, 2)

	local maxWidth = 200
	local x, y
	local width, lines
	local height

	local maxTimer, timer = .075, 0
	local visible = false

	-- Error if missing parent
	assert(parent ~= nil, "Tooltip requires a parent object.")

	-- Check if mouse is within the bounds of parent object
	local function ParentMouseover()
		local mx, my = love.mouse.getPosition()
		return  mx > this.parent.x
			and my > this.parent.y
			and mx < this.parent.x + this.parent.width
			and my < this.parent.y + this.parent.height
	end

	-- Ensure a number stays inside min/max boundaries
	local function InRange(num, min, max)
		return math.max(min, math.min(num, max))
	end

	-- Update timer
	function this.update(dt)
		timer = InRange((visible and timer + dt or timer - dt), 0, maxTimer)
		local percent = timer / maxTimer
		colors.alpha[4] = 255 * percent
	end

	-- Add tooltip to view, show when parent is moused over
	function this.Add()
		visible = (ParentMouseover() and this.text ~= nil)
		love.graphics.setColor(colors.alpha)
		love.graphics.draw(canvas_tooltip, x, y)
	end

	-- Set the tooltip text and re-initialize the tooltip canvas
	function this.SetText(text)
		this.text = text

		-- Tooltip will not draw if text is set to nil
		if this.text == nil then return end

		love.graphics.setFont(font_medium)

		width, lines = font_medium:getWrap(this.text, maxWidth)
		lines = #lines
		height = font_medium:getHeight()

		width = width + 6
		height = (height * lines) + 8

		x = this.parent.x + math.floor((this.parent.width / 2) - (width / 2))
		y = this.parent.y - (height + 5)

		-- Enforce drawing within window bounds
		local winW, winH = love.graphics.getDimensions()
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
			love.graphics.setColor(colors.black)
			love.graphics.rectangle('fill', 0, 0, width, height)
			love.graphics.setColor(colors.bg_gray)
			love.graphics.rectangle(
				'fill', 1, 1, width - 2, height - 2)

			-- Draw tooltip text
			love.graphics.setColor(colors.white)
			love.graphics.printf(
				this.text,
				4, 4, maxWidth, 'left')
		end)

		love.graphics.setFont(font_normal)
	end

	return this
end

return MapMaker
