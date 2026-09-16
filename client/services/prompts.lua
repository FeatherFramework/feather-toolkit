ToolkitPrompts = { records = {}, nextId = 0 }

function ToolkitPrompts.Create(owner, spec)
    if type(spec) ~= 'table' or not tonumber(spec.control) then
        return ToolkitResults.Err('invalid_input', 'Prompt control is required.')
    end

    local handle = UiPromptRegisterBegin()
    UiPromptSetControlAction(handle, tonumber(spec.control))
    UiPromptSetText(handle, CreateVarString(10, 'LITERAL_STRING', tostring(spec.label or 'Interact')))
    UiPromptSetEnabled(handle, spec.enabled ~= false and 1 or 0)
    UiPromptSetVisible(handle, spec.visible ~= false and 1 or 0)

    if spec.groupId then
        UiPromptSetGroup(handle, tonumber(spec.groupId), tonumber(spec.tabIndex) or 0)
    end

    if spec.mode == 'hold' then
        UiPromptSetStandardizedHoldMode(handle, spec.holdMode or 'MEDIUM_TIMED_EVENT')
    else
        UiPromptSetStandardMode(handle, 1)
    end

    UiPromptSetUrgentPulsingEnabled(handle, spec.pulsing ~= false)
    UiPromptRegisterEnd(handle)
    ToolkitPrompts.nextId = ToolkitPrompts.nextId + 1

    local id = ('prompt:%d'):format(ToolkitPrompts.nextId)
    ToolkitPrompts.records[id] = { owner = owner, handle = handle, mode = spec.mode or 'click', completedAt = 0 }

    return ToolkitResults.Ok({ id = id, handle = handle })
end

function ToolkitPrompts.Completed(owner, id)
    local v = ToolkitPrompts.records[id]
    if not v then
        return ToolkitResults.Err('not_found', 'Prompt was not found.')
    end

    if v.owner ~= owner then
        return ToolkitResults.Err('forbidden', 'Prompt belongs to another resource.')
    end

    local now = GetGameTimer()
    if now - v.completedAt < 500 then return ToolkitResults.Ok({ completed = false }) end
    local completed = v.mode == 'hold' and UiPromptHasHoldModeCompleted(v.handle)
        or UiPromptHasStandardModeCompleted(v.handle, 0)
    if completed then v.completedAt = now end

    return ToolkitResults.Ok({ completed = completed and true or false })
end

function ToolkitPrompts.SetEnabled(owner, id, enabled)
    local v = ToolkitPrompts.records[id]
    if not v then
        return ToolkitResults.Err('not_found', 'Prompt was not found.')
    end

    if v.owner ~= owner then
        return ToolkitResults.Err('forbidden', 'Prompt belongs to another resource.')
    end

    UiPromptSetEnabled(v.handle, enabled == true and 1 or 0)
    UiPromptSetVisible(v.handle, enabled == true and 1 or 0)

    return ToolkitResults.Ok({ enabled = enabled == true })
end

function ToolkitPrompts.Remove(owner, id)
    local v = ToolkitPrompts.records[id]
    if not v then
        return ToolkitResults.Err('not_found', 'Prompt was not found.')
    end

    if v.owner ~= owner then
        return ToolkitResults.Err('forbidden', 'Prompt belongs to another resource.')
    end

    UiPromptDelete(v.handle)
    ToolkitPrompts.records[id] = nil

    return ToolkitResults.Ok({ removed = true, id = id })
end

function ToolkitPrompts.Cleanup(owner)
    local n = 0
    for id, v in pairs(ToolkitPrompts.records) do
        if v.owner == owner then
            UiPromptDelete(v.handle)
            ToolkitPrompts.records[id] = nil
            n = n + 1
        end
    end
    return n
end

function ToolkitPrompts.CleanupAll()
    local count = 0
    for id, record in pairs(ToolkitPrompts.records) do
        UiPromptDelete(record.handle)
        ToolkitPrompts.records[id] = nil
        count = count + 1
    end
    return count
end

exports('ShowPromptGroup', function(groupId, label)
    groupId = tonumber(groupId)
    if not groupId then
        return ToolkitResults.Err('invalid_input', 'Prompt group id is required.')
    end

    UiPromptSetActiveGroupThisFrame(groupId,
        CreateVarString(10, 'LITERAL_STRING', tostring(label or 'Interactions')), 1, 0, 0, 0)

    return ToolkitResults.Ok({ shown = true, groupId = groupId })
end)
