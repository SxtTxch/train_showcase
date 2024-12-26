--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage.Shared

local ByteNet = require(shared.Packages.bytenet)

return ByteNet.defineNamespace("train", function()
    local carriageStruct = ByteNet.struct({
        brickColorName = ByteNet.string,
        currentWaypointIndex = ByteNet.uint16,
        currentWaypointPos = ByteNet.vec3,
        nextWaypointPos = ByteNet.vec3
    })

    local trainPacket = ByteNet.definePacket({
        value = ByteNet.array(carriageStruct)
    })

    return {
        sendTrain = trainPacket
    }
end)