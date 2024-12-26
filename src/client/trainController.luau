--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local shared = ReplicatedStorage.Shared

local packetdefinitions = shared.packetdefinitions
local trainData = require(packetdefinitions.trainData)

local Templates = ReplicatedStorage.Templates

local trainController = {}
trainController.prefix = `[Train Service]`

local localTrain

local tweenInfo = TweenInfo.new(
    0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In
)

type trainDataType = {
    {
        brickColorName: string, 
        currentWaypointPos: Vector3,
        nextWaypointPos: Vector3
    }
}
export type trainController = {
    prefix: string,

    renderTrain: ({
        trainDataType
    }) -> ();
    spawnTrain: ({
        trainDataType
    }) -> {[number] : Part};
}

function trainController.spawnTrain(trainData : trainDataType)
    localTrain = {}
    for i=1, #trainData do
        local newCarriage = ReplicatedStorage.Templates.Carriage:Clone()
        newCarriage.BrickColor = BrickColor.new(trainData[i].brickColorName)
        newCarriage.CanCollide = false
        newCarriage.Anchored = true
        newCarriage.CFrame = CFrame.new(trainData[i].currentWaypointPos + Vector3.new(0, newCarriage.Size.Y/1.8, 0), trainData[i].nextWaypointPos + Vector3.new(0, newCarriage.Size.Y/1.8, 0))
        newCarriage.Parent = workspace
        newCarriage.carriageSound:Play()
        localTrain[i] = newCarriage
    end
    return localTrain
end

function trainController.renderTrain(trainData)
    if not localTrain then
        localTrain = trainController.spawnTrain(trainData)
        return
    end

    for i=1, #localTrain do
        local currentCarriage = localTrain[i]
        local targetPos = trainData[i].currentWaypointPos + Vector3.new(0, currentCarriage.Size.Y/1.8, 0)
        local lookAtPos = trainData[i].nextWaypointPos + Vector3.new(0, currentCarriage.Size.Y/1.8, 0)
        currentCarriage.CFrame = CFrame.new(targetPos, lookAtPos)
    end
end

trainData.sendTrain.listen(trainController.renderTrain)


return trainController