ToolkitPrompts={records={},nextId=0}
function ToolkitPrompts.Create(owner,spec)
    if type(spec)~='table' or not tonumber(spec.control) then return ToolkitResults.Err('invalid_input','Prompt control is required.') end
    local handle=PromptRegisterBegin(); PromptSetControlAction(handle,tonumber(spec.control))
    PromptSetText(handle,CreateVarString(10,'LITERAL_STRING',tostring(spec.label or 'Interact')))
    PromptSetEnabled(handle,spec.enabled~=false);PromptSetVisible(handle,spec.visible~=false)
    if spec.groupId then PromptSetGroup(handle,tonumber(spec.groupId),0) end
    if spec.mode=='hold' then Citizen.InvokeNative(0x74C7D7B72ED0D3CF,handle,spec.holdMode or 'MEDIUM_TIMED_EVENT')
    else PromptSetStandardMode(handle,true) end
    Citizen.InvokeNative(0xC5F428EE08FA7F2C,handle,spec.pulsing~=false);PromptRegisterEnd(handle)
    ToolkitPrompts.nextId=ToolkitPrompts.nextId+1;local id=('prompt:%d'):format(ToolkitPrompts.nextId)
    ToolkitPrompts.records[id]={owner=owner,handle=handle,mode=spec.mode or 'click'}
    return ToolkitResults.Ok({id=id,handle=handle})
end
function ToolkitPrompts.Completed(owner,id)
    local v=ToolkitPrompts.records[id];if not v then return ToolkitResults.Err('not_found','Prompt was not found.') end
    if v.owner~=owner then return ToolkitResults.Err('forbidden','Prompt belongs to another resource.') end
    local completed=v.mode=='hold' and Citizen.InvokeNative(0xE0F65F0640EF0617,v.handle)
        or Citizen.InvokeNative(0xC92AC953F0A982AE,v.handle)
    return ToolkitResults.Ok({completed=completed==true})
end
function ToolkitPrompts.SetEnabled(owner,id,enabled)
    local v=ToolkitPrompts.records[id];if not v then return ToolkitResults.Err('not_found','Prompt was not found.') end
    if v.owner~=owner then return ToolkitResults.Err('forbidden','Prompt belongs to another resource.') end
    PromptSetEnabled(v.handle,enabled==true);PromptSetVisible(v.handle,enabled==true);return ToolkitResults.Ok({enabled=enabled==true})
end
function ToolkitPrompts.Remove(owner,id)
    local v=ToolkitPrompts.records[id];if not v then return ToolkitResults.Err('not_found','Prompt was not found.') end
    if v.owner~=owner then return ToolkitResults.Err('forbidden','Prompt belongs to another resource.') end
    Citizen.InvokeNative(0x00EDE88D4D13CF59,v.handle);ToolkitPrompts.records[id]=nil;return ToolkitResults.Ok({removed=true,id=id})
end
function ToolkitPrompts.Cleanup(owner) local n=0;for id,v in pairs(ToolkitPrompts.records) do if v.owner==owner then Citizen.InvokeNative(0x00EDE88D4D13CF59,v.handle);ToolkitPrompts.records[id]=nil;n=n+1 end end;return n end
exports('ShowPromptGroup',function(groupId,label)
    groupId=tonumber(groupId)
    if not groupId then return ToolkitResults.Err('invalid_input','Prompt group id is required.') end
    PromptSetActiveGroupThisFrame(groupId,CreateVarString(10,'LITERAL_STRING',tostring(label or 'Interactions')),1,0)
    return ToolkitResults.Ok({shown=true,groupId=groupId})
end)
