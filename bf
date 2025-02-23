-- ✅ **Function Forward Declarations**
local moveTo, saveProgress, loadProgress, placeBlock, buildSchematic, restock, refuelTurtle

-- ✅ **Restore Disk Startup for Future Turtles**
if peripheral.find("drive") then
    print("🔄 Restoring disk startup...")
    if fs.exists("/disk/startuptemp.lua") then
        shell.run("mv /disk/startuptemp.lua /disk/startup.lua")
        print("✅ Disk startup restored.")
    end
end

-- ✅ **Material & Fuel Chest Locations (Stacked in Y)**
local materialChests = {
    ["minecraft:wool"] = {x = -5, y = 1, z = -5, dir = 3},
    ["minecraft:clay"] = {x = -5, y = 2, z = -5, dir = 3},
    ["minecraft:dirt"] = {x = -5, y = 3, z = -5, dir = 3},
    ["minecraft:grass"] = {x = -5, y = 4, z = -5, dir = 3},
    ["minecraft:stone"] = {x = -5, y = 5, z = -5, dir = 3},
    ["minecraft:log"] = {x = -5, y = 6, z = -5, dir = 3}
}
local fuelChest = {x = -5, y = 7, z = -5, dir = 3}  

-- ✅ **Find an Open Access Spot (Keeps Trying Until It Gets One)**
local function findChestAccess(chestPos)
    local possiblePositions = {
        {x = chestPos.x + 1, z = chestPos.z, dir = 3},
        {x = chestPos.x - 1, z = chestPos.z, dir = 1},
        {x = chestPos.x, z = chestPos.z + 1, dir = 2},
        {x = chestPos.x, z = chestPos.z - 1, dir = 0}
    }

    while true do
        for _, pos in ipairs(possiblePositions) do
            moveTo(pos)
            if not turtle.detect() then
                return pos
            end
            turtle.back()
        end
        print("⏳ All spots blocked. Retrying in 2 seconds...")
        sleep(2)
    end
end

-- ✅ **Restock Function (Keeps Trying Until Success)**
restock = function(block)
    local blockID = "minecraft:" .. block
    local chestPos = materialChests[blockID]

    if not chestPos then
        print("❌ No chest found for " .. blockID)
        return false
    end

    print("🔄 Finding access point for", blockID)
    local accessPoint = findChestAccess(chestPos)

    print("🔄 Moving to", blockID, "restock point at", accessPoint.x, accessPoint.z)
    moveTo(accessPoint)
    while pos.dir ~= accessPoint.dir do turnLeft() end

    while true do
        for _ = 1, 8 do
            if turtle.suck(64) then
                print("✅ Restocked", blockID)
                return true
            end
        end
        print("⏳ No items in chest. Retrying in 2 seconds...")
        sleep(2)
    end
end

-- ✅ **Refuel Function (Keeps Trying Until Success)**
local function refuelTurtle()
    print("⛽ Checking fuel level...")
    if turtle.getFuelLevel() >= 1000 then return true end 

    print("🔄 Finding access point for fuel chest...")
    local accessPoint = findChestAccess(fuelChest)

    print("⛽ Moving to fuel chest at", accessPoint.x, accessPoint.z)
    moveTo(accessPoint)
    while pos.dir ~= accessPoint.dir do turnLeft() end

    while true do
        for _ = 1, 2 do
            if turtle.suck(1) then
                turtle.refuel()
                print("✅ Refueled!")
                return true
            end
        end
        print("⏳ Fuel chest empty. Retrying in 2 seconds...")
        sleep(2)
    end
end

-- ✅ **Movement System**
local function turnLeft() turtle.turnLeft(); pos.dir = (pos.dir - 1) % 4 end
local function turnRight() turtle.turnRight(); pos.dir = (pos.dir + 1) % 4 end

moveTo = function(target)
    while pos.x ~= target.x do
        if pos.x < target.x then while pos.dir ~= 1 do turnRight() end
        else while pos.dir ~= 3 do turnRight() end
        end
        while not turtle.forward() do
            print("🚧 Block ahead! Trying alternative path...")
            turtle.turnRight()
            if not turtle.forward() then
                turtle.turnLeft()
            end
        end
        pos.x = target.x  
    end

    while pos.z ~= target.z do
        if pos.z < target.z then while pos.dir ~= 0 do turnRight() end
        else while pos.dir ~= 2 do turnRight() end
        end
        while not turtle.forward() do
            print("🚧 Block ahead! Trying alternative path...")
            turtle.turnRight()
            if not turtle.forward() then
                turtle.turnLeft()
            end
        end
        pos.z = target.z  
    end
end

-- ✅ **Updated Place Block Function**
placeBlock = function(block)
    if not refuelTurtle() then return false end 

    local exists, _ = turtle.inspectDown()
    if exists then
        print("⏭ Block already exists, skipping...")
        return true
    end

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:" .. block then
            turtle.select(i)
            if turtle.placeDown() then
                print("✅ Placed", block)
                return true
            end
        end
    end

    print("❌ Out of", block, "restocking...")
    if restock(block) then return placeBlock(block) end
    return false
end

-- ✅ **Build Process**
buildSchematic = function()
    print("🏗 Starting build process...")
    for _, blockData in ipairs(blocks) do
        moveTo(blockData)

        while not placeBlock(blockData[1]) do
            print("🔄 Retrying placement of " .. blockData[1] .. " after restock")
        end
    end
    print("✅ Build complete!")
end

-- ✅ **Start Building**
buildSchematic()
