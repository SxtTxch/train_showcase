local prefix = `$[Server Bootstrapper]`

print(`{prefix} starting.`)

local services = script:GetChildren()

for i, service in services do
   if not service:IsA("ModuleScript") then continue end

   local success, returnedValue = pcall(require, service)

   if not success then warn(`{prefix}: an error occured while trying to require service {service.Name}, errormessage: {returnedValue}`); continue end
   local currentService = returnedValue

   if currentService.init then
        print(`{prefix}: initializing {currentService.prefix}!`)
        task.spawn(currentService.init)
   end
end