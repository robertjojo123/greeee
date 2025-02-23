-- ✅ Load Libraries & Initialize
local moveTo, savePosition, returnToLastPosition, restock, placeBlock, buildSchematic, refuelTurtle

print("🔄 Checking for block data...")
if not fs.exists("output.lua") then
    print("🔄 No block data found. Waiting for Rednet assignment...")
    rednet.open("right")  -- Worker Turtle's Rednet Modem is on the right
    local _, turtleID = rednet.receive("turtle_id")  -- Wait for ID
    
    print("✅ Received Turtle ID:", turtleID)
    local dataURL = "https://raw.githubusercontent.com/robertjojo123/olympus2/main/output_" .. turtleID .. ".lua"

    print("🌐 Downloading block data from", dataURL)
    shell.run("wget " .. dataURL .. " output.lua")

    if fs.exists("output.lua") then
        print("✅ Block data downloaded successfully.")
    else
        print("❌ Failed to download block data. Exiting.")
        return
    end
end

print("🔄 Loading block data...")
local blocks = dofile("output.lua")

-- ✅ Move Forward 4 Blocks to Set (0,0,0)
for i = 1, 4 do
    if not turtle.forward() then
        print("❌ Movement blocked, stopping.")
        return
    end
end
print("✅ Build position set at", 4, 0, 0)

-- ✅ **Position Tracking**
local pos = {x = 0, y = 0, z = 0, dir = 0}
local lastPos = {x = 0, y = 0, z = 0, dir = 0}

-- ✅ **Material Chest Locations**
local materialChests = {
    ["minecraft:wool"] = {x = -1, y = 0, z = -4, dir = 3},
    ["minecraft:clay"] = {x = -1, y = 0, z = 0, dir = 3},
    ["minecraft:dirt"] = {x = -1, y = 0, z = -1, dir = 3},
    ["minecraft:grass"] = {x = -1, y = 0, z = -2, dir = 3},
    ["minecraft:stone"] = {x = -1, y = 0, z = -3, dir = 3},
    ["minecraft:log"] = {x = -1, y = 0, z = -6, dir = 3}
}

-- ✅ **Fuel Chest Location**
local fuelChest = {x = -1, y = 0, z = -5, dir = 3}
local fuelItem = "projecte:aeternus_fuel_block"

-- ✅ **Movement Functions**
local function turnLeft() turtle.turnLeft(); pos.dir = (pos.dir - 1) % 4 end
local function turnRight() turtle.turnRight(); pos.dir = (pos.dir + 1) % 4 end

local function moveForward()
    if turtle.forward() then
        if pos.dir == 0 then pos.z = pos.z + 1
        elseif pos.dir == 1 then pos.x = pos.x + 1
        elseif pos.dir == 2 then pos.z = pos.z - 1
        elseif pos.dir == 3 then pos.x = pos.x - 1
        end
        return true
    end
    return false
end

moveTo = function(target)
    while pos.x ~= target.x do
        if pos.x < target.x then while pos.dir ~= 1 do turnRight() end
        else while pos.dir ~= 3 do turnRight() end
        end
        moveForward()
    end
    while pos.z ~= target.z do
        if pos.z < target.z then while pos.dir ~= 0 do turnRight() end
        else while pos.dir ~= 2 do turnRight() end
        end
        moveForward()
    end
end

-- ✅ **Save and Return to Position**
savePosition = function()
    lastPos = {x = pos.x, y = pos.y, z = pos.z, dir = pos.dir}
end

returnToLastPosition = function()
    moveTo(lastPos)
    while pos.dir ~= lastPos.dir do turnRight() end
end

-- ✅ **Restock Function**
restock = function(block)
    local blockID = "minecraft:" .. block
    local chestPos = materialChests[blockID]

    if not chestPos then
        print("❌ No chest found for " .. blockID)
        return false
    end

    print("🔄 Restocking " .. blockID)

    savePosition()
    moveTo(chestPos)
    while pos.dir ~= chestPos.dir do turnLeft() end

    for _ = 1, 8 do
        if turtle.suck(64) then
            print("✅ Restocked " .. blockID)
            break
        end
    end

    returnToLastPosition()
    return true
end

-- ✅ **Place Block Function**
placeBlock = function(block)
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

-- ✅ **Build Function**
buildSchematic = function()
    for _, blockData in ipairs(blocks) do
        moveTo(blockData)
        placeBlock(blockData[1])
    end
    print("✅ Build complete!")
end

-- ✅ **Start Building**
buildSchematic()
