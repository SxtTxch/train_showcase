--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local shared = ReplicatedStorage.Shared

local WaypointsGenerated = shared.WaypointsGenerated

local packetdefinitions = shared.packetdefinitions
local trainData = require(packetdefinitions.trainData)

local waypointService = require(script.Parent.waypointService)


local trainService = {}
trainService.prefix = `[Train Service]`

export type trainService = {
    prefix: string,

    new: (pos: Vector3) -> train,
}

export type carriage = {
    brickColorName: string,
    currentWaypointIndex: number,
    currentWaypointPos: Vector3,
    nextWaypointPos: Vector3
}

trainService.__index = trainService

local ConstantWaypointIncrementMultiplication = 445.7179 * 1.2
function trainService.new(length: number)
    local newTrain = {}
    for i=1, length do
        newTrain[i] = {
            brickColorName = BrickColor.random().Name,
             currentWaypointIndex = math.round(i * ConstantWaypointIncrementMultiplication),
             currentWaypointPos = waypointService.getWaypoint(
                math.round(i * ConstantWaypointIncrementMultiplication)
            ).pos,
             nextWaypointPos = waypointService.getWaypoint(
                math.round(i * ConstantWaypointIncrementMultiplication) + 10
            ).pos
            } :: carriage
    end
    trainData.sendTrain.sendToAll(newTrain)
    return newTrain
end


function trainService.advanceWaypoint(trainObject : train)
    for i=1, #trainObject do
        local currentCarriage = trainObject[i]
        currentCarriage.currentWaypointIndex += 10
        currentCarriage.currentWaypointIndex %= #waypointService.waypointArray
        currentCarriage.currentWaypointPos = waypointService.getWaypoint(
            math.max(1,currentCarriage.currentWaypointIndex % #waypointService.waypointArray)
        ).pos
        currentCarriage.nextWaypointPos = waypointService.getWaypoint(
            math.max(1,(currentCarriage.currentWaypointIndex + 10) % #waypointService.waypointArray)
        ).pos
    end
    trainData.sendTrain.sendToAll(trainObject)
end
export type train = typeof(trainService.new(...))

-- init

function trainService.init()
    WaypointsGenerated.Event:Wait()

    local newTrain = trainService.new(10) :: train
    RunService.Heartbeat:Connect(function()
        trainService.advanceWaypoint(newTrain)
    end)
end

return trainService