local ChainMine = {}

local oreList = {
	nameWithoutMetas = {
		"minecraft:coal_ore",
		"minecraft:iron_ore",
		"minecraft:gold_ore",
		v1="minecraft:diamond_ore",
		"minecraft:redstone_ore",
		"minecraft:lit_redstone_ore",
		"minecraft:lapis_ore",
		"minecraft:emerald_ore",
		"minecraft:quartz_ore",
		"biomsoplenty:biome_block"
	},
	nameWithMetas = {
		{name="ic2:resource",metas={1,2,3,4}},
		{name="biomsoplenty:gem_ore",metas={0,1,2,3,4,5,6,7}},
	}
}

function ChainMine.isOre (success, dat)
	if (not success) then
		return false, false
	end
	for k, v in ipairs(oreList.nameWithoutMetas) do
		if (dat.name == v) then
			return true, (k ~= nil and string.find(k,"v"))
		end
	end
	for k1, v1 in ipairs(oreList.nameWithMetas) do
		if (dat.name == v1.name) then
			for k2, v2 in ipairs(v1.metas) do
				if (dat.metadata == v2) then
					return true, (k2 ~= nil and string.find(k2,"v"))
				end
			end
		end
	end
	return false
end

function ChainMine.digForward()
	while not turtle.forward() do
		turtle.dig()
	end
end

function ChainMine.digUp()
	while not turtle.up() do
		turtle.digUp()
	end
end

function ChainMine.chainMine()
	if (ChainMine.isOre(turtle.inspectUp())) then
		ChainMine.digUp()
		ChainMine.chainMine()
		turtle.down()
	end
	if (ChainMine.isOre(turtle.inspectDown())) then
		turtle.digDown()
		turtle.down()
		ChainMine.chainMine()
		turtle.up()
	end
	if (ChainMine.isOre(turtle.inspect())) then
		ChainMine.digForward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		ChainMine.digForward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		ChainMine.digForward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		ChainMine.digForward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
end

return ChainMine
