-- @namespace MapMaker
-- @class PathHighlighter:
-- Highlight the path that the path checker is attempting to validate
local MapMaker = {}; function MapMaker.newPathHighlighter(mapHeight, mapWidth, startY, startX)

	-- Constructor
	local this =
	{
		mapHeight = mapHeight,
		mapWidth = mapWidth,
		startY = startY,
		startX = startX,

		path = {}
	}

	-- Direction enum
	local Direction =
	{
		NORTH = 1,
		EAST  = 2,
		SOUTH = 3,
		WEST  = 4,
		HOME  = 5
	}

	-- Start at start point, follow path, return a path table when the end
	-- of the current attempted path is found
	function this.HighlightPath(map)

		local x, y
		local startDirection, next
		local foundEnd = false

		local px, py
		for py = 1, this.mapHeight do
			this.path[py] = {}
			for px = 1, this.mapWidth do
				this.path[py][px] = 0
			end
		end

		local blankPath = this.path

		-- Get start direction from start coordinate
		y = tonumber(this.startY); x = tonumber(this.startX)
		if     map[y][x] == '^' then startDirection = Direction.NORTH
		elseif map[y][x] == '>' then startDirection = Direction.EAST
		elseif map[y][x] == 'v' then startDirection = Direction.SOUTH
		elseif map[y][x] == '<' then startDirection = Direction.WEST
		elseif map[y][x] == '.' then return blankPath
		end

		this.path[y][x] = 1

		next = startDirection

		-- Follow map path, return path or blankPath when finished
		local limiter = (this.mapHeight * this.mapWidth)
		local counter = 0
		repeat
			if     counter > limiter then return blankPath end
			if     next == Direction.NORTH then y = y - 1
			elseif next == Direction.EAST  then x = x + 1
			elseif next == Direction.SOUTH then y = y + 1
			elseif next == Direction.WEST  then x = x - 1
			end

			if y < 1 or x < 1 then return blankPath end
			if y > this.mapHeight
				or x > this.mapWidth then
					return blankPath end

			if     map[y][x] == '^' then next = Direction.NORTH
			elseif map[y][x] == '>' then next = Direction.EAST
			elseif map[y][x] == 'v' then next = Direction.SOUTH
			elseif map[y][x] == '<' then next = Direction.WEST
			elseif map[y][x] == '*' then next = Direction.HOME
				if this.startY == y and this.startX == x then
					return blankPath
				else foundEnd = true end
			elseif map[y][x] == '.' then return blankPath
			end

			this.path[y][x] = 1

			counter = counter + 1
		until foundEnd

		return this.path
	end

	return this
end

return MapMaker
