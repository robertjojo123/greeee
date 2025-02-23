-- ✅ Open Rednet on the Modem (Wireless Advanced Turtle Required)
rednet.open("right") -- Adjust if the modem is on another side

-- ✅ Function: Wait for Previous Worker Turtle to be Removed
local function waitForTurtleRemoval()
    print("⏳ Waiting for previous Worker Turtle to be removed...")
    while turtle.detect() do
        sleep(2)
    end
    print("✅ Worker Turtle removed! Placing next one.")
end

-- ✅ Function: Place and Setup New Worker Turtle
local function deployWorker(turtleIndex)
    print("📦 Placing Worker Turtle for `output_" .. turtleIndex .. ".lua`")

    -- Wait for space before placing
    waitForTurtleRemoval()

    -- ✅ Place the Worker Turtle
    if not turtle.place() then
        print("❌ ERROR: Failed to place Worker Turtle!")
        return
    end

    -- Sleep to allow Turtle to initialize
    sleep(2)

    -- ✅ Turn On Worker Turtle (it will run the startup program from the Disk)
    print("🔄 Turning on Worker Turtle...")
    peripheral.call("front", "turnOn")

    -- ✅ Wait for the Worker Turtle to reboot (handled by disk startup)
    sleep(5)

    -- ✅ Send Block Data Index to Worker Turtle and Wait for Confirmation
    local receivedConfirmation = false
    while not receivedConfirmation do
        print("📡 Transmitting Block Data Index:", turtleIndex)
        rednet.transmit(200, "BlockIndex", turtleIndex)

        -- ✅ Wait for confirmation response
        local senderID, message, protocol = rednet.receive("BlockConfirm", 5)
        if message == "Received" then
            print("✅ Worker Turtle confirmed receiving Block Data Index!")
            receivedConfirmation = true
        else
            print("⚠️ No confirmation received, retrying...")
        end
    end

    print("✅ Worker Turtle setup complete! Waiting for next one to be removed...")
end

-- ✅ Main Loop: Deploy Worker Turtles Sequentially
local totalFiles = 122

for i = 1, totalFiles do
    deployWorker(i)
end

print("🎉 All Worker Turtles deployed!")
rednet.close()
