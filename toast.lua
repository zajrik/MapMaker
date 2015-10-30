-- @namespace MapMaker
-- @class Toast: A dynamically sized, dismissable toast message. Bound to the
-- top right of the screen. If a click handler is provided it will be executed
-- on left click. Right click to dismiss. Toasts are meant to be displayed once
-- and recycled the next time a toast is needed.
local MapMaker = {}; function MapMaker.newToast(text, clickHandler)
	
	-- Constructor
	local this = {}

	local text = text or nil
	local clickHandler = clickHandler or nil
	local active = false

	local font_normal = love.graphics.newFont(14)
	local font_medium = love.graphics.newFont(11)

	local canvas_toast

	local maxWidth = 200
	local x, y
	local width, lines
	local height

	local maxTimer, timer = .15, 0
	local alpha = 0
	local visible = false

	-- Error on nil text
	assert(text ~= nil, 'Toast must have a message.')

	love.graphics.setFont(font_medium)

	width, lines = font_medium:getWrap(text, maxWidth)
	height = font_medium:getHeight()

	width = width + 6
	height = (height * lines) + 8

	winW, winH = love.window.getDimensions()
	x = winW - width - 5
	y = 5

	-- Draw canvas content
	canvas_toast = love.graphics.newCanvas(width, height)
	canvas_toast:renderTo(function()
		-- Draw tooltip box
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('fill', 0, 0, width, height)
		love.graphics.setColor(75, 75, 75, 255)
		love.graphics.rectangle(
			'fill', 1, 1, width - 2, height - 2)

		-- Draw tooltip text
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf(
			text,
			4, 4, maxWidth, 'left')
	end)

	love.graphics.setFont(font_normal)


	-- Ensure a number stays inside min/max boundaries
	local function InRange(num, min, max)
		return math.max(min, math.min(num, max))
	end
	
	-- TODO: Give toast a duration, passable as parameter with a default value

	-- Update timer
	function this.update(dt)
		timer = InRange((visible and timer + dt or timer - dt), 0, maxTimer)
		local percent = timer / maxTimer
		alpha = 255 * percent
	end

	-- Add the toast to view. Will be displayed when Show() is called.
	function this.Add()
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.draw(canvas_toast, x, y)
	end

	-- Show the toast
	function this.Show()
		visible = true and text ~= nil
	end

	-- Dismiss the toast
	function this.Dismiss()
		visible = false
	end

	-- If the toast is actively being clicked
	function this.IsActive()
		return active
	end


	-- Handle mouse press, show button click feedback
	function this.mousepressed(clickx, clicky, button)
		if clickx > x and clickx < x + width 
			and clicky > y and clicky < y + height 
				and visible then
					active = true
		else
			active = false
		end
	end

	-- Handle mouse release, 
	function this.mousereleased(clickx, clicky, button)
		active = false
		if clickx > x and clickx < x + width 
			and clicky > y and clicky < y + height 
				and visible then
					if button == 'r' then
						visible = false
						print('bar')
					elseif button == 'l' then
						if clickHandler ~= nil then
							(clickHandler)()
							visible = false end
						print('foo')
					end
		end
	end

	return this
end

-- Return an empty class containing blank methods with init(). This allows the recyclable
-- toast object to be initialized so that it can be added to love.draw/update/etc without
-- causing crashes, effectively serving as a placeholder until the object is declared
-- with newToast()
function MapMaker.Add() end
function MapMaker.IsActive() end
function MapMaker.Show() end
function MapMaker.Dismiss() end
function MapMaker.update() end
function MapMaker.mousepressed() end
function MapMaker.mousereleased() end
function MapMaker.init() return MapMaker end

return MapMaker