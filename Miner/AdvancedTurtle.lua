local EnumFacing = require("/MinecraftRobotPrograms/Miner/EnumFacing")

-- Be careful when using undo function, in case of some situation which is non-reversible
AdvancedTurtle = {
	origin = vector.new(0,0,0),
	relative = vector.new(0,0,0),
	facing = EnumFacing.north,
	undoStack = {},
}

function AdvancedTurtle.setFacing(facing)
	if (EnumFacing[facing] ~= nil) then
		AdvancedTurtle.facing = EnumFacing[facing]
	else
		error("Wrong Facing Parameter")
	end
end

function AdvancedTurtle.turnLeft(undoable)
	turtle.turnLeft()
	AdvancedTurtle.facing = EnumFacing[AdvancedTurtle.facing.l]
	if (undoable) then
		table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.turnRight)
	end
end

function AdvancedTurtle.turnRight(undoable)
	turtle.turnRight()
	AdvancedTurtle.facing = EnumFacing[AdvancedTurtle.facing.r]
	if (undoable) then
		table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.turnLeft)
	end
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

function AdvancedTurtle.forward(undoable)
	if (turtle.forward()) then
		AdvancedTurtle.relative = AdvancedTurtle.relative + AdvancedTurtle.facing.d
		if (undoable) then
			table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.back)
		end
		return true
	else
		return false
	end
end

function AdvancedTurtle.back(undoable)
	if (turtle.back()) then
		AdvancedTurtle.relative = AdvancedTurtle.relative - AdvancedTurtle.facing.d
		if (undoable) then
			table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.forward)
		end
		return true
	else
		return false
	end
end

function AdvancedTurtle.up(undoable)
	if (turtle.up()) then
		AdvancedTurtle.relative.y = AdvancedTurtle.relative.y + 1
		if (undoable) then
			table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.down)
		end
		return true
	else
		return false
	end
end

function AdvancedTurtle.down(undoable)
	if (turtle.down()) then
		AdvancedTurtle.relative.y = AdvancedTurtle.relative.y - 1
		if (undoable) then
			table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.up)
		end
		return true
	else
		return false
	end
end

function AdvancedTurtle.digForward(timeout, undoable)
	for i = 1,timeout do
		if (AdvancedTurtle.forward(undoable)) then
			return
		end
		turtle.dig()
	end
	error("Timeout Error")
end

function AdvancedTurtle.digUp(timeout, undoable)
	for i = 1,timeout do
		if (AdvancedTurtle.up(undoable)) then
			return
		end
		turtle.digUp()
	end
	error("Timeout Error")
end

function AdvancedTurtle.digDown(timeout, undoable)
	for i = 1,timeout do
		if (AdvancedTurtle.down(undoable)) then
			return
		end
		turtle.digDown()
	end
	error("Timeout Error")
end

function AdvancedTurtle.digBack(timeout, undoable)
	if (not AdvancedTurtle.back(undoable)) then
		AdvancedTurtle.turnBack()
		AdvancedTurtle.digForward(timeout)
		AdvancedTurtle.turnBack()
		if (undoable) then
			table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.forward)
		end
	end
end

function AdvancedTurtle.manhattan()
	return math.abs(AdvancedTurtle.relative.x) + math.abs(AdvancedTurtle.relative.y) + math.abs(AdvancedTurtle.relative.z)
end

function AdvancedTurtle.getAbsolute()
	return vector.new(AdvancedTurtle.origin.x + AdvancedTurtle.relative.x, AdvancedTurtle.origin.y + AdvancedTurtle.relative.y, AdvancedTurtle.origin.z + AdvancedTurtle.relative.z)
end

function AdvancedTurtle.inOrigin()
	return AdvancedTurtle.relative.x == 0 and AdvancedTurtle.relative.y == 0 and AdvancedTurtle.relative.z == 0
end

function AdvancedTurtle.popUndoStack()
	return table.remove(AdvancedTurtle.undoStack, #AdvancedTurtle.undoStack)
end

-- ---------- Inventory Control----------

-- Return: a list of the return values of lambda expression
function AdvancedTurtle.forEachInv(lambda, istart, iend)
	if (istart == nil) then
		istart = 1
	end
	if (iend == nil) then
		iend = 16
	end
	local accumulator = {}
	for i = istart, iend do
		local result = lambda(i)
		if (result ~= nil) then
			table.insert(accumulator, result)
		end
	end
	return accumulator
end

function AdvancedTurtle.findInvItem(name, damage, istart, iend)
	return AdvancedTurtle.forEachInv(function (i)
		local detail = turtle.getItemDetail(i)
		if (detail ~= nil and detail.name == name and (damage == nil or detail.damage == damage)) then
			return i
		end
	end, istart, iend)
end

function AdvancedTurtle.findInvSpace(istart, iend)
	return AdvancedTurtle.forEachInv(function (i)
		if (turtle.getItemCount(i) == 0) then
			return i
		end
	end, istart, iend)
end

return AdvancedTurtle