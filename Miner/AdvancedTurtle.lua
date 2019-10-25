local EnumFacing = require("/MinecraftRobotPrograms/Miner/EnumFacing")

AdvancedTurtle = {
	origin = vector.new(0,0,0),
	relative = vector.new(0,0,0),
	facing = EnumFacing.north
	-- undoStack = {},
	-- retrivable=false
}

-- function setRetrivable(b)
-- 	AdvancedTurtle.retrivable = b
-- end

-- function clearUndos()
-- 	undoStack = {}
-- end

function AdvancedTurtle.turnLeft()
	turtle.turnLeft()
	AdvancedTurtle.facing = EnumFacing[AdvancedTurtle.facing.l]
end

function AdvancedTurtle.turnRight()
	turtle.turnRight()
	AdvancedTurtle.facing = EnumFacing[AdvancedTurtle.facing.r]
end

function AdvancedTurtle.turnBack(clockwise)
	if (clockwise) then
		AdvancedTurtle.turnRight()
		AdvancedTurtle.turnRight()
	else
		AdvancedTurtle.turnLeft()
		AdvancedTurtle.turnLeft()
	end
end

function AdvancedTurtle.forward()
	if (turtle.forward()) then
		AdvancedTurtle.relative.x = AdvancedTurtle.relative.x + AdvancedTurtle.facing.d.x
		AdvancedTurtle.relative.y = AdvancedTurtle.relative.y + AdvancedTurtle.facing.d.y
		AdvancedTurtle.relative.z = AdvancedTurtle.relative.z + AdvancedTurtle.facing.d.z
		return true
	else
		return false
	end
end

function AdvancedTurtle.back()
	if (turtle.forward()) then
		AdvancedTurtle.relative.x = AdvancedTurtle.relative.x - AdvancedTurtle.facing.d.x
		AdvancedTurtle.relative.y = AdvancedTurtle.relative.y - AdvancedTurtle.facing.d.y
		AdvancedTurtle.relative.z = AdvancedTurtle.relative.z - AdvancedTurtle.facing.d.z
		return true
	else
		return false
	end
end

function AdvancedTurtle.digForward()
	while not AdvancedTurtle.forward() do
		turtle.dig()
	end
end

function AdvancedTurtle.digBack()
	if (not AdvancedTurtle.back()) then
		AdvancedTurtle.turnBack(true)
		AdvancedTurtle.digForward()
		AdvancedTurtle.turnBack(true)
	end
end

function AdvancedTurtle.manhattan()
	return math.abs(AdvancedTurtle.relative.x) + math.abs(AdvancedTurtle.relative.y) + math.abs(AdvancedTurtle.relative.z)
end

function AdvancedTurtle.getAbsolute()
	return vector.new(AdvancedTurtle.origin.x + AdvancedTurtle.relative.x, AdvancedTurtle.origin.y + AdvancedTurtle.relative.y, AdvancedTurtle.origin.z + AdvancedTurtle.relative.z)
end

return AdvancedTurtle