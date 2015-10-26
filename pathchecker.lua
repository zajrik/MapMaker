-- @namespace MapMaker
-- @class PathChecker: 
-- Check map for valid path. If there are any problems with the map prior
-- to parsing that primary logic misses, PathChecker will catch it. 
-- Nothing gets past PathChecker. (At least not in testing.)
local MapMaker = {}; function MapMaker.newPathChecker(mapHeight, mapWidth, startY, startX)
	
	-- Constructor
	local this = 
	{
		mapHeight = mapHeight,
		mapWidth = mapWidth,
		startY = startY,
		startX = startX
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

	-- Start at start point, follow path, return true/false for valid/invalid path
	function this.CheckPath(map)

		local x, y
		local startDirection, next
		local foundEnd = false

		-- Get start direction from start coordinate
		y = tonumber(this.startY); x = tonumber(this.startX)
		if     map[y][x] == '^' then startDirection = Direction.NORTH
		elseif map[y][x] == '>' then startDirection = Direction.EAST
		elseif map[y][x] == 'v' then startDirection = Direction.SOUTH
		elseif map[y][x] == '<' then startDirection = Direction.WEST
		elseif map[y][x] == '.' then return false
		end

		next = startDirection

		-- Follow map path, return false if invalid path
		local limiter = (this.mapHeight * this.mapWidth)
		local counter = 0
		repeat
			if     counter > limiter then return false end
			if     next == Direction.NORTH then y = y - 1
			elseif next == Direction.EAST  then x = x + 1
			elseif next == Direction.SOUTH then y = y + 1
			elseif next == Direction.WEST  then x = x - 1
			end

			if y < 1 or x < 1 then return false end
			if y > this.mapHeight
				or x > this.mapWidth then
					return false end

			if     map[y][x] == '^' then next = Direction.NORTH
			elseif map[y][x] == '>' then next = Direction.EAST
			elseif map[y][x] == 'v' then next = Direction.SOUTH
			elseif map[y][x] == '<' then next = Direction.WEST
			elseif map[y][x] == '*' then next = Direction.HOME
				if this.startY == y and this.startX == x then
					return false
				else
					foundEnd = true
				end
			elseif map[y][x] == '.' then return false
			else end

			counter = counter + 1
		until foundEnd

		if not foundEnd then return false
		else return true end
	end

	return this
end

return MapMaker