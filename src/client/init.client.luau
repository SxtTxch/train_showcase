local prefix = `$[Client Bootstrapper]`

print(`{prefix} starting.`)

local controllers = script:GetChildren()

for i, controller in controllers do
   if not controller:IsA("ModuleScript") then continue end

   local success, returnedValue = pcall(require, controller)

   if not success then warn(`{prefix}: an error occured while trying to require controller {controller.Name}, errormessage: {returnedValue}`); continue end
   local currentController = returnedValue

   if currentController.init then
        print(`{prefix}: initializing {currentController.prefix}!`)
        task.spawn(currentController.init)
   end
end