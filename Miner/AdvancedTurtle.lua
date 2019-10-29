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

function AdvancedTurtle.setOrigin(x, y, z)
	AdvancedTurtle.origin = vector.new(x, y, z)
end

function AdvancedTurtle.turnLeft(undoable)
	turtle.turnLeft()
	AdvancedTurtle.facing = AdvancedTurtle.facing.l
	if (undoable) then
		table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.turnRight)
	end
end

function AdvancedTurtle.turnRight(undoable)
	turtle.turnRight()
	AdvancedTurtle.facing = AdvancedTurtle.facing.r
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

function AdvancedTurtle.forceForward(timeout, undoable)
	if (timeout == nil) then
		timeout = 15
	end
	for i = 1,timeout do
		if (turtle.forward()) then
			AdvancedTurtle.relative = AdvancedTurtle.relative + AdvancedTurtle.facing.d
			if (undoable) then
				table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.forceBack)
			end
			return
		end
		turtle.dig()
		turtle.attack()
	end
	error("Timeout Error")
end

function AdvancedTurtle.forceBack(timeout, undoable)
	if (timeout == nil) then
		timeout = 15
	end
	if (not turtle.back()) then
		AdvancedTurtle.turnBack()
		AdvancedTurtle.forceForward(timeout)
		AdvancedTurtle.turnBack()
		if (undoable) then
			table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.forceForward)
		end
	else
		AdvancedTurtle.relative = AdvancedTurtle.relative - AdvancedTurtle.facing.d
		if (undoable) then
			table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.forceForward)
		end
	end
end

function AdvancedTurtle.forceUp(timeout, undoable)
	if (timeout == nil) then
		timeout = 15
	end
	for i = 1,timeout do
		if (turtle.up()) then
			AdvancedTurtle.relative.y = AdvancedTurtle.relative.y + 1
			if (undoable) then
				table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.forceDown)
			end
			return
		end
		turtle.digUp()
		turtle.attackUp()
	end
	error("Timeout Error")
end

function AdvancedTurtle.forceDigUp(timeout)
	if (timeout == nil) then
		timeout = 15
	end
	for i = 1,timeout do
		if (turtle.detectUp()) then
			turtle.digUp()
			turtle.attackUp()
		else
			return
		end
	end
	error("Timeout Error")
end

function AdvancedTurtle.forceDown(timeout, undoable)
	if (timeout == nil) then
		timeout = 15
	end
	for i = 1,timeout do
		if (turtle.down()) then
			AdvancedTurtle.relative.y = AdvancedTurtle.relative.y - 1
			if (undoable) then
				table.insert(AdvancedTurtle.undoStack, AdvancedTurtle.forceUp)
			end
			return
		end
		turtle.digDown()
		turtle.attackDown()
	end
	error("Timeout Error")
end

function AdvancedTurtle.manhattan()
	return math.abs(AdvancedTurtle.relative.x) + math.abs(AdvancedTurtle.relative.y) + math.abs(AdvancedTurtle.relative.z)
end

function AdvancedTurtle.getAbsolute()
	return AdvancedTurtle.origin + AdvancedTurtle.relative
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

function AdvancedTurtle.sameItem(i1, i2)
	if ((i1 == nil and i2 ~= nil) or (i1 ~= nil and i2 == nil)) then
		return false
	end
	if (i1 == nil and i2 == nil) then
		return true
	end
	return (i1.name == i2.name and i1.damage == i2.damage)
end

function AdvancedTurtle.sortUpInv()
	for i=1,16 do
		local item = turtle.getItemDetail(i)
		-- if empty, move the last item here
		if (item == nil) then
			for j=16,i+1,-1 do
				if (turtle.getItemCount(j) > 0) then
					turtle.select(j)
					turtle.transferTo(i)
					break
				end
			end
		end
		item = turtle.getItemDetail(i)
		if (item == nil) then 
			return #AdvancedTurtle.findInvSpace()
		end

		-- try to merge same item
		if (item.count < 64) then
			local similarList = AdvancedTurtle.findInvItem(item.name, item.damage, i+1, 16)
			if (#similarList > 0) then
				for j=#similarList,1,-1 do
					turtle.select(similarList[j])
					if ((not turtle.transferTo(i)) or turtle.getItemCount(i) == 64) then
						break
					end
				end
			end
		end
	end
	return #AdvancedTurtle.findInvSpace()
end

return AdvancedTurtle