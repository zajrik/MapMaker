-- @namespace MapMaker
-- @class MapEditor:
-- Serves as the visual editor for the map itself. Performs all the actions
-- necessary to create the map table and draw the appropriate markers on the
-- grid based on the inputs passed to the MapEditor instance.
local MapMaker = {}; function MapMaker.newMapEditor(h, w)

	-- Constructor
	local this =
	{
		map = {},

		h = h,
		w = w,

		startSet  = false,
		finishSet = false,

		startY = 0,
		startX = 0,

		finishY = 0,
		finishX = 0
	}

	local colors =
	{
		white  = {255, 255, 255},
		black  = {0,   0,   0  },
		yellow = {223, 229, 123},
		green  = {0,   255, 0  },

		blank  = {0, 0, 0, 0}
	}

	local cellSize = 30

	local clickY, clickX   = 0, 0
	local rclickY, rclickX = 0, 0

	local canvas_activeCells
	local canvas_arrow
	local canvas_star

	-- Build empty map
	for y = 1, this.h do
		this.map[y] = {}
		for x = 1, this.w do
			this.map[y][x] = '.'
		end
	end

	-- Prepare the canvas for active direction marker cells
	canvas_activeCells = love.graphics.newCanvas(
		this.w * cellSize, this.h * cellSize)

	-- Prepare the cell marker canvases and draw their markers
	canvas_arrow = love.graphics.newCanvas(cellSize, cellSize)
	canvas_arrow:renderTo(function()
		love.graphics.setLineWidth(2)
		love.graphics.setColor(colors.black)
		love.graphics.line(8,16,  15,8,  22,16)
		love.graphics.line(15,10,  15,22)
	end)
	canvas_star = love.graphics.newCanvas(cellSize, cellSize)
	canvas_star:renderTo(function()
		love.graphics.setLineWidth(2)
		love.graphics.setColor(colors.black)
		love.graphics.line(9,11,  21,19)
		love.graphics.line(9,19,  21,11)
		love.graphics.line(15,8,  15,22)
	end)



	-- Make number fit a map coord (1-index)
	local function ToMapCoord(number)
		return math.floor((number / cellSize) + 1)
	end

	-- Make number fit a grid coord (0-index)
	local function ToGridCoord(number)
		return math.floor((number / cellSize))
	end

	-- Make a coord fit a cell
	local function ToCell(number)
		return number * cellSize
	end

	-- Check if direction cell overwrites finish cell, overwrite it if so
	-- Parameters must be map coordinates
	local function CheckCell(y, x)
		if y == this.finishY and x == this.finishX then
			this.finishSet = false; this.finishY = 0; this.finishX = 0 end
	end

	-- Draw the chosen movement cell marker
	local function MarkCell(dir, y, x)
		-- Draw cell background
		love.graphics.setColor(
			(this.startX == x and this.startY == y and this.startSet) and
				colors.blank or colors.yellow)
		love.graphics.rectangle(
			'fill', ToCell(x - 1), ToCell(y - 1), cellSize, cellSize)
		love.graphics.setColor(colors.black)

		local r = 0
		if     dir == '^' then r = 0
		elseif dir == '>' then r = 90
		elseif dir == 'v' then r = 180
		elseif dir == '<' then r = 270
		elseif dir == '*' then love.graphics.draw(
			canvas_star, ToCell(x - 1), ToCell(y - 1)) end
		if dir ~= '*' then love.graphics.draw(
			canvas_arrow, ToCell(x - .5), ToCell(y - .5), math.rad(r),
			1, 1, cellSize / 2, cellSize / 2) end
	end

	-- Update the activeCells canvas
	function this.UpdateCells()

		canvas_activeCells:renderTo(function()
			canvas_activeCells:clear()
			-- Draw chosen start coord cell
			if this.startSet then
				love.graphics.setColor(colors.green)
				love.graphics.rectangle('fill',
					ToCell(ToGridCoord(clickX)),
					ToCell(ToGridCoord(clickY)),
					cellSize, cellSize)
			end

			-- Draw movement marker cells
			for y = 1, #this.map do
				for x = 1, #this.map[y] do
					if this.map[y][x] ~= '.' then
						MarkCell(this.map[y][x], y, x) end
				end
			end
		end)

	end

	-- Draw active direction cells canvas
	function this.draw()
		love.graphics.setColor(colors.white)
		love.graphics.draw(canvas_activeCells, 0, 0)
	end


	-- Handle mouse press events
	function this.mousepressed(x, y, button)
		-- Handle left click
		if button == 'l' then
			-- Clicked out of bounds
			if x > this.w * cellSize
				or y > (this.h * cellSize) - 1 then

			-- Clicked grid
			else clickX = x; clickY = y
				this.startX = ToMapCoord(clickX)
				this.startY = ToMapCoord(clickY)
				this.startSet = true; this.UpdateCells()
			end
		end

		-- Handle right click
		if button == 'r' then
			-- Clicked out of bounds
			if x > w * cellSize
				or y > (h * cellSize) - 1 then

			-- Clicked grid
			else rclickX = x; rclickY = y
				-- Clicked the start cell, remove it
				if ToMapCoord(x) == this.startX
					and ToMapCoord(y) == this.startY
						then this.startSet = false end

				-- Clicked the finish cell, remove it
				if ToMapCoord(x) == this.finishX
					and ToMapCoord(y) == this.finishY
						then this.finishSet = false end

				-- Clicked any cell, remove it
				this.map[ToMapCoord(rclickY)][ToMapCoord(rclickX)] = '.'
				this.UpdateCells()
			end
		end
	end

	-- Handle key press events
	function this.keypressed(key)
		-- Handle map move direction input keys
		local x, y = love.mouse.getPosition()
		local validPos = true

		if ToMapCoord(x) > w then validPos = false
		else x = ToMapCoord(x) end

		if ToMapCoord(y) > h then validPos = false
		else y = ToMapCoord(y) end

		if validPos then
			if     key == 'w' then this.map[y][x] = '^'; CheckCell(y, x)
			elseif key == 'd' then this.map[y][x] = '>'; CheckCell(y, x)
			elseif key == 's' then this.map[y][x] = 'v'; CheckCell(y, x)
			elseif key == 'a' then this.map[y][x] = '<'; CheckCell(y, x)
			elseif key == 'x' then
				if this.finishSet then
					this.map[this.finishY][this.finishX] = '.'
					this.map[y][x] = '*'
					this.finishY = y
					this.finishX = x
				else
					this.map[y][x] = '*'
					this.finishY = y
					this.finishX = x
					this.finishSet = true
				end
			end
			this.UpdateCells()
		end
	end


	return this
end

return MapMaker
