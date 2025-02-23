local rednetSide = "right"  -- Placer Turtle's Rednet Modem is on the right
local turtleCount = 122  -- Total worker turtles
local bootTime = 5  -- Time to wait for boot, copying, and reboot

rednet.open(rednetSide)

for i = 1, turtleCount do
    turtle.select(1) -- Ensure turtle is selected
    if turtle.place() then
        print("✅ Placed worker turtle #" .. i)

        -- Turn on the turtle (it will run startup from the disk)
        peripheral.call("front", "turnOn")

        -- Wait for startup.lua to copy build.lua and reboot
        print("⏳ Waiting " .. bootTime .. " seconds for reboot...")
        sleep(bootTime)

        -- Send unique block data index to the worker turtle
        print("📡 Sending Turtle ID #" .. i .. " via Rednet")
        rednet.broadcast(i, "turtle_id")

        -- Short delay before placing the next turtle
        sleep(1)
    else
        print("❌ Failed to place turtle #" .. i)
        break
    end
end

print("✅ All worker turtles placed and initialized.")
