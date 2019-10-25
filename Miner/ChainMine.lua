local ChainMine = {}

local oreList = {
	nameWithoutMetas = {
		"minecraft:coal_ore",
		"minecraft:iron_ore",
		"minecraft:gold_ore",
		"minecraft:diamond_ore",
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
		return false
	end
	for k, v in ipairs(oreList.nameWithoutMetas) do
		if (dat.name == v) then
			return true
		end
	end
	for k1, v1 in ipairs(oreList.nameWithMetas) do
		if (dat.name == v1.name) then
			for k2, v2 in ipairs(v1.metas) do
				if (dat.metadata == v2) then
					return true
				end
			end
		end
	end
	return false
end

function ChainMine.chainMine()
	if (ChainMine.isOre(turtle.inspectUp())) then
		turtle.digUp()
		turtle.up()
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
		turtle.dig()
		turtle.forward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		turtle.dig()
		turtle.forward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		turtle.dig()
		turtle.forward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		turtle.dig()
		turtle.forward()
		ChainMine.chainMine()
		turtle.back()
	end
	turtle.turnLeft()
end

return ChainMine
