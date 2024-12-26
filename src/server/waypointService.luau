--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage.Shared

local WaypointsGenerated = shared.WaypointsGenerated

local threadflow = require(shared.threadflow)

local waypointService = {}
waypointService.prefix = `[Waypoint Service]`

local count = 10000
local center = Vector3.zero
local radius = 50

export type waypointService = {
    prefix: string,

    new: (pos: Vector3) -> waypoint,
    getWaypoint: (n: number) -> waypoint
}

waypointService.__index = waypointService
function waypointService.new(pos : Vector3)
    local newWaypoint = {}
    newWaypoint.pos = pos or Vector3.zero
    return newWaypoint
end

function waypointService.getWaypoint(n)
    return waypointService.waypointArray[n]
end

export type waypoint = typeof(waypointService.new(...))

waypointService.waypointArray = {} :: {[number] : waypoint}

-- init

function waypointService.init()
    local angleIncrement = math.pi * 2 / count
    local newThreadPool = threadflow.new(1000, 1)
    
    for i = 1, count do
        newThreadPool:run(function()
            local angle = i * angleIncrement
            local x = center.X + math.cos(angle) * radius
            local z = center.Z + math.sin(angle) * radius
            local waypoint = waypointService.new(Vector3.new(x, center.Y, z))
            waypointService.waypointArray[i] = waypoint
        end)
    end

    waypointService.createTrainTracks()

    WaypointsGenerated:Fire()
end

function waypointService.createTrainTracks()
    local tieSpacing = 1
    local tieLength = 4
    local tieWidth = 1 
    local railWidth = 0.5
    local railHeight = 1
    local ballastHeight = 0.2 

    for i = 1, count - 1 do
        local waypoint1 = waypointService.waypointArray[i]
        local waypoint2 = waypointService.waypointArray[i + 1]

        local trackPart = Instance.new("Part")
        trackPart.Size = Vector3.new(1, 1, (waypoint2.pos - waypoint1.pos).Magnitude)
        trackPart.Position = (waypoint1.pos + waypoint2.pos) / 2
        trackPart.Anchored = true
        trackPart.CanCollide = false
        trackPart.BrickColor = BrickColor.new("Dark stone grey")
        trackPart.Parent = workspace

        local direction = (waypoint2.pos - waypoint1.pos).Unit
        trackPart.CFrame = CFrame.new(trackPart.Position, trackPart.Position + direction)

        local tieCount = math.floor(trackPart.Size.Z / tieSpacing)
        for tieIndex = 1, tieCount do
            local tie = Instance.new("Part")
            tie.Size = Vector3.new(tieLength, tieWidth, tieSpacing)
            tie.Anchored = true
            tie.CanCollide = true
            tie.BrickColor = BrickColor.new("Reddish brown") 
            tie.CFrame = trackPart.CFrame * CFrame.new(0, -1, (tieIndex - 1) * tieSpacing)
            tie.Parent = workspace
        end

    
        local rail1 = Instance.new("Part")
        rail1.Size = Vector3.new(trackPart.Size.Z, railHeight, railWidth)
        rail1.BrickColor = BrickColor.new("Institutional white")
        rail1.Anchored = true
        rail1.CFrame = trackPart.CFrame * CFrame.new(-2, 0, 0)
        rail1.Parent = workspace

        local rail2 = Instance.new("Part")
        rail2.Size = Vector3.new(trackPart.Size.Z, railHeight, railWidth)
        rail2.BrickColor = BrickColor.new("Institutional white")
        rail2.Anchored = true
        rail2.CFrame = trackPart.CFrame * CFrame.new(2, 0, 0)
        rail2.Parent = workspace

        local ballast = Instance.new("Part")
        ballast.Size = Vector3.new(trackPart.Size.Z, ballastHeight, railWidth * 3)
        ballast.BrickColor = BrickColor.new("Reddish brown")
        ballast.Anchored = true
        ballast.CFrame = trackPart.CFrame
        ballast.Parent = workspace
    end
end


return waypointService