local resourceName=GetCurrentResourceName()
local function Owner() local owner=GetInvokingResource();if type(owner)~='string' or owner=='' then return nil end;return owner end
local function Capabilities() return ToolkitResults.Ok({resource=resourceName,contract=1,version=GetResourceMetadata(resourceName,'version',0) or '0.0.0',features={models=1,entities=1,blips=1,keys=1,prompts=1,render=1,clipboard=1}}) end
exports('GetCapabilities',Capabilities)
exports('LoadModel',ToolkitModels.Load)
exports('CreateObject',function(spec)local o=Owner();return o and ToolkitEntities.CreateObject(o,spec) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('CreatePed',function(spec)local o=Owner();return o and ToolkitEntities.CreatePed(o,spec) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('RemoveEntity',function(id)local o=Owner();return o and ToolkitEntities.Remove(o,id) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('CreateBlip',function(spec)local o=Owner();return o and ToolkitBlips.Create(o,spec) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('RemoveBlip',function(id)local o=Owner();return o and ToolkitBlips.Remove(o,id) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('RegisterKeyListener',function(control,cb,mode)local o=Owner();return o and ToolkitKeys.Register(o,control,cb,mode) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('RemoveKeyListener',function(id)local o=Owner();return o and ToolkitKeys.Remove(o,id) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('CreatePrompt',function(spec)local o=Owner();return o and ToolkitPrompts.Create(o,spec) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('IsPromptCompleted',function(id)local o=Owner();return o and ToolkitPrompts.Completed(o,id) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('SetPromptEnabled',function(id,v)local o=Owner();return o and ToolkitPrompts.SetEnabled(o,id,v) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('RemovePrompt',function(id)local o=Owner();return o and ToolkitPrompts.Remove(o,id) or ToolkitResults.Err('unauthenticated','Calling resource is required.') end)
exports('DrawText2D',ToolkitRender.Text2D);exports('DrawText3D',ToolkitRender.Text3D);exports('CopyToClipboard',ToolkitClipboard.Copy)
AddEventHandler('onClientResourceStop',function(owner) if owner==resourceName then return end;ToolkitEntities.Cleanup(owner);ToolkitBlips.Cleanup(owner);ToolkitKeys.Cleanup(owner);ToolkitPrompts.Cleanup(owner) end)
RegisterCommand('ToolkitContractSmokeTest',function()
    local caps=Capabilities();local invalid=ToolkitModels.Load(nil)
    local owned=ToolkitKeys.Register('smoke-owner',0x760A9C6F,function() end)
    local cross=owned.ok and ToolkitKeys.Remove('other-owner',owned.value.id) or nil
    local cleaned=ToolkitKeys.Cleanup('smoke-owner')
    local tests={{'capabilities',caps.ok and caps.value.contract==1},{'feature surface',caps.ok and caps.value.features.prompts==1 and caps.value.features.clipboard==1},{'invalid model rejected',not invalid.ok and invalid.code=='invalid_input'},{'cross owner denied',cross and not cross.ok and cross.code=='forbidden'},{'owner cleanup',cleaned==1}}
    local passed=0;for _,t in ipairs(tests) do if t[2] then passed=passed+1 end;print(('[ToolkitContractSmokeTest] %-24s %s'):format(t[1],t[2] and 'PASS' or 'FAIL')) end
    print(('[ToolkitContractSmokeTest] done %d/%d passed'):format(passed,#tests))
end,false)
RegisterCommand('ToolkitClipboardSmokeTest',function(_,args)
    local value=table.concat(args,' ');if value=='' then value='Feather Toolkit clipboard test' end
    local result=ToolkitClipboard.Copy(value)
    print(('[ToolkitClipboardSmokeTest] dispatch %s -- copy and paste to verify'):format(result.ok and 'PASS' or 'FAIL'))
end,false)
