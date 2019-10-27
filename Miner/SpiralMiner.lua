local SpiralMiner = {}
local ChainMine = require("/MinecraftRobotPrograms/Miner/ChainMine")
local AdvancedTurtle = require("/MinecraftRobotPrograms/Miner/AdvancedTurtle")

local spiralLength = 3
local distance = 1
local INV_SPACE_TO_DUMP = 3
function SpiralMiner.main()
	print("Input Robot Direction: ")
	AdvancedTurtle.setFacing(io.read())

	print("Input Robox Coordinate X: ")
	local x = tonumber(io.read())
	print("Input Robox Coordinate Y: ")
	local y = tonumber(io.read())
	print("Input Robox Coordinate Z: ")
	local z = tonumber(io.read())
	AdvancedTurtle.setOrigin(x, y, z)

	while (not redstone.getInput("back")) do
		AdvancedTurtle.forceForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceUp(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceDown(15)

		SpiralMiner.checkFuel()
		print("current fuel: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())
		SpiralMiner.checkInv()

		SpiralMiner.updateDirection()
		print("spiralLength: "..spiralLength.." distance: "..distance)
		print("rX: "..AdvancedTurtle.relative.x.." rY: "..AdvancedTurtle.relative.y.." rZ: "..AdvancedTurtle.relative.z)
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
		if (coalRequired < 1) then
			break
		end
		if (coalRequired > 64) then
			coalRequired = 64
		end

		turtle.select(v)
		turtle.refuel(coalRequired)
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
	if (#AdvancedTurtle.findInvSpace() < INV_SPACE_TO_DUMP) then
		if (AdvancedTurtle.sortUpInv() <= INV_SPACE_TO_DUMP and (not SpiralMiner.dumpToBox())) then
			SpiralMiner.goOrigin(SpiralMiner.dumpOrigin)
		end
	end
end

local BoxItem = {
	count = 1,
	name = "ic2:te",
	damage = 111
}

-- local BoxItem = {
-- 	count = 1,
-- 	name = "minecraft:white_shulker_box",
-- 	damage = 0
-- }
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
		-- error("No Box/More Than One Box")
		return false
	end
	turtle.select(iBox)
	AdvancedTurtle.forceDigUp(15)
	if (not turtle.placeUp()) then
		error("Failed To Place Box")
	end
	turtle.digDown()
	local iFuel = AdvancedTurtle.findInvItem(fuel.coal.name)[1]
	for i=1,16 do
		if (i ~= iFuel and turtle.getItemCount(i) ~= 0) then
			turtle.select(i)
			if (wastes[turtle.getItemDetail(i).name]) then
				turtle.dropDown()
			else
				turtle.dropUp()
			end
		end
	end
	turtle.digUp()
	
	return #AdvancedTurtle.findInvSpace() > INV_SPACE_TO_DUMP + 1
end

function SpiralMiner.dumpOrigin()
	local iBox = AdvancedTurtle.findInvItem(BoxItem.name, BoxItem.damage)[1]
	if (iBox == nil or turtle.getItemCount(iBox) > 1) then
		local iFuel = AdvancedTurtle.findInvItem(fuel.coal.name)[1]
		AdvancedTurtle.forEachInv(function (i)
			while (i ~= iFuel and turtle.getItemCount(i) > 0) do
				turtle.select(i)
				if (not turtle.dropDown()) then
					error("Storage Is Full")
				end
			end
		end)
		return
	end
	turtle.select(iBox)
	AdvancedTurtle.forceDigUp(15)
	if (not turtle.placeUp()) then
		error("Failed To Place Box")
	end
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
	turtle.digUp()
end

function SpiralMiner.goOrigin(todo)
	-- Manage the way back (inevitably destroy some diamonds on the way!)
	local mov1 = AdvancedTurtle.relative.dot(AdvancedTurtle.relative,AdvancedTurtle.facing.d)
	for i=1, math.abs(mov1) do
		if (mov1 < 0) then
			AdvancedTurtle.forceForward(15, true)
		elseif (mov1 > 0) then
			AdvancedTurtle.forceBack(15, true)
		else
			break
		end
	end
	AdvancedTurtle.turnLeft(true)
	local mov2 = AdvancedTurtle.relative.dot(AdvancedTurtle.relative, vector.new(1,1,1))
	for i = 1, math.abs(mov2) do
		AdvancedTurtle.forceForward(15, true)
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