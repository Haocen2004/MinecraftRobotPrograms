local SpiralMiner = {}
local ChainMine = require("/MinecraftRobotPrograms/Miner/ChainMine")
local AdvancedTurtle = require("/MinecraftRobotPrograms/Miner/AdvancedTurtle")

local spiralLength = 3
local distance = 1
function SpiralMiner.main()
	print("Input Robot Direction: ")
	AdvancedTurtle.setFacing(io.read())
	while (not redstone.getInput("back")) do
		AdvancedTurtle.digForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.digUp(15)
		ChainMine.chainMine()
		AdvancedTurtle.down()

		SpiralMiner.checkFuel()
		print("current fuel: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())
		SpiralMiner.checkInv()

		SpiralMiner.updateDirection()
		print("spiralLength: "..spiralLength.." distance: "..distance)
		print("rX: "..AdvancedTurtle.relative.x.." rZ: "..AdvancedTurtle.relative.z)
	end
end

function SpiralMiner.updateDirection()
	distance = distance + 1
	if (distance == spiralLength) then
		distance = 1
		spiralLength = spiralLength + 2
		AdvancedTurtle.turnLeft()
	end
end

local fuel = {
	coal = {
		name = "minecraft:coal",
		value = 80
	}
}
function SpiralMiner.checkFuel()
	local fuelList = AdvancedTurtle.findInvItem(fuel.coal.name)
	for i,v in ipairs(fuelList) do
		local coalRequired = math.floor((turtle.getFuelLimit() - turtle.getFuelLevel())/80)
		local coalToFuel = coalRequired
		if (coalToFuel > 64) then
			coalToFuel = 64
		end

		turtle.select(v)
		turtle.refuel(coalToFuel)
	end

	if (turtle.getFuelLevel() <= AdvancedTurtle.manhattan() + 50) then
		SpiralMiner.goOrigin(
			function()
				error("Out Of Fuel")
			end
		)
	end
end

function SpiralMiner.checkInv()
	if (#AdvancedTurtle.findInvSpace() < 1) then
		if (not SpiralMiner.dumpToBox()) then
			SpiralMiner.goOrigin(SpiralMiner.dumpOrigin)
		end
	end
end

local BoxItem = {
	count = 1,
	name = "ic2:te",
	damage = 111
}
local wastes = {
	-- common wastes
	["minecraft:cobblestone"] = true,
	["minecraft:stone"] = true,
	["minecraft:dirt"] = true,
	["minecraft:gravel"] = true,
	["minecraft:flint"] = true,

	-- mineshaft wastes
	["minecraft:planks"] = true,
	["minecraft:torch"] = true,
	["minecraft:fence"] = true,
}

-- try to dump wastes to ground and valuables to box
-- keep a stack of fuel in inventory
-- Return: a boolean, if there is space in turtle
function SpiralMiner.dumpToBox()
	local iBox = AdvancedTurtle.findInvItem(BoxItem.name, BoxItem.damage)[1]
	if (iBox == nil or turtle.getItemCount(iBox) > 1) then
		error("No Box/More Than One Box")
	end
	turtle.select(iBox)
	turtle.placeUp()
	turtle.digDown()
	local iFuel = AdvancedTurtle.findInvItem(fuel.coal.name)[1]
	AdvancedTurtle.forEachInv(function (i)
		if (i == iFuel or turtle.getItemCount(i) == 0) then
			return
		end
		turtle.select(i)
		if (wastes[turtle.getItemDetail(i).name]) then
			turtle.dropDown()
		else
			turtle.dropUp()
		end
	end)
	turtle.digUp()
	
	return #AdvancedTurtle.findInvSpace() > 0
end

function SpiralMiner.dumpOrigin()
	local iBox = AdvancedTurtle.findInvItem(BoxItem.name, BoxItem.damage)[1]
	if (iBox == nil or turtle.getItemCount(iBox) > 1) then
		error("No Box/More Than One Box")
	end
	turtle.select(iBox)
	turtle.placeUp()
	local iFuel = AdvancedTurtle.findInvItem(fuel.coal.name)[1]
	AdvancedTurtle.forEachInv(function (i)
		while (i ~= iFuel and turtle.getItemCount(i) > 0) do
			turtle.select(i)
			if (not turtle.dropDown()) then
				error("Storage Is Full")
			end
			turtle.suckUp()
		end
	end)
end

function SpiralMiner.goOrigin(todo)
	-- Manage the way back (inevitably destroy some diamonds on the way!)
	while (true) do
		local mov1 = AdvancedTurtle.relative.dot(AdvancedTurtle.relative,AdvancedTurtle.facing.d)
		if (mov1 < 0) then
			AdvancedTurtle.digForward(15, true)
		elseif (mov1 > 0) then
			AdvancedTurtle.digBack(15, true)
		else
			break
		end
	end
	AdvancedTurtle.turnLeft(true)
	while not AdvancedTurtle.inOrigin() do
		AdvancedTurtle.digForward(15, true)
	end

	todo()

	if (turtle.getFuelLevel() <= AdvancedTurtle.manhattan() + 50) then
		error("No Fuel To Return Breakpoint")
	end

	-- Then return to the breakpoint with undo stack
	while (true) do
		local undo = AdvancedTurtle.popUndoStack()
		if (undo ~= null) then
			undo()
		else
			break
		end
	end
end

SpiralMiner.main()

return SpiralMiner