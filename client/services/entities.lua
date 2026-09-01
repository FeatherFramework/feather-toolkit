ToolkitEntities = { records = {}, nextId = 0 }

local function Track(owner, entity, kind)
    ToolkitEntities.nextId = ToolkitEntities.nextId + 1
    local id = ('entity:%d'):format(ToolkitEntities.nextId)
    ToolkitEntities.records[id] = { owner = owner, entity = entity, kind = kind }

    return ToolkitResults.Ok({ id = id, entity = entity, kind = kind })
end
function ToolkitEntities.CreateObject(owner, spec)
    if type(spec) ~= 'table' then
        return ToolkitResults.Err('invalid_input', 'Object specification is required.')
    end

    local x, y, z = tonumber(spec.x), tonumber(spec.y), tonumber(spec.z)
    if not x or not y or not z then
        return ToolkitResults.Err('invalid_input', 'Object coordinates are required.')
    end

    local loaded = ToolkitModels.Load(spec.model, spec.timeoutMs)
    if type(loaded) ~= 'table' or loaded.ok ~= true or type(loaded.value) ~= 'table'
        or type(loaded.value.hash) ~= 'number' then
        return loaded
    end

    local modelHash = loaded.value.hash
    local entity = CreateObject(modelHash, x, y, z,
        spec.networked ~= false,
        spec.scriptHost ~= false,
        spec.dynamic == true,
        spec.p7 == true,
        spec.p8 == true)
    if entity == 0 then
        SetModelAsNoLongerNeeded(modelHash)
        return ToolkitResults.Err('create_failed', 'Object creation failed.')
    end

    SetEntityHeading(entity, tonumber(spec.heading) or 0.0)

    if spec.placeOnGround ~= false then
        PlaceObjectOnGroundProperly(entity, true)
    end

    FreezeEntityPosition(entity, spec.frozen ~= false)
    SetModelAsNoLongerNeeded(modelHash)

    return Track(owner, entity, 'object')
end

function ToolkitEntities.CreatePed(owner, spec)
    if type(spec) ~= 'table' then
        return ToolkitResults.Err('invalid_input', 'Ped specification is required.')
    end

    local x, y, z = tonumber(spec.x), tonumber(spec.y), tonumber(spec.z)
    if not x or not y or not z then
        return ToolkitResults.Err('invalid_input', 'Ped coordinates are required.')
    end

    local loaded = ToolkitModels.Load(spec.model, spec.timeoutMs)
    if type(loaded) ~= 'table' or loaded.ok ~= true or type(loaded.value) ~= 'table'
        or type(loaded.value.hash) ~= 'number' then
        return loaded
    end

    local modelHash = loaded.value.hash
    local entity = CreatePed(modelHash, x, y, z,
        tonumber(spec.heading) or 0.0,
        spec.networked ~= false,
        spec.scriptHost ~= false,
        spec.p7 == true,
        spec.p8 == true
    )

    if entity == 0 then
        SetModelAsNoLongerNeeded(modelHash)
        return ToolkitResults.Err('create_failed', 'Ped creation failed.')
    end

    -- SetRandomOutfitVariation
    Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
    SetModelAsNoLongerNeeded(modelHash)

    return Track(owner, entity, 'ped')
end

function ToolkitEntities.Remove(owner, id)
    local record = ToolkitEntities.records[id]
    if not record then
        return ToolkitResults.Err('not_found', 'Owned entity was not found.')
    end

    if record.owner ~= owner then
        return ToolkitResults.Err('forbidden', 'Owned entity belongs to another resource.')
    end

    if DoesEntityExist(record.entity) then
        DeleteEntity(record.entity)
    end

    ToolkitEntities.records[id] = nil

    return ToolkitResults.Ok({ removed = true, id = id })
end

function ToolkitEntities.Cleanup(owner)
    local count = 0
    for id, record in pairs(ToolkitEntities.records) do
        if record.owner == owner then
            if DoesEntityExist(record.entity) then
                DeleteEntity(record.entity)
            end
            ToolkitEntities.records[id] = nil
            count = count + 1
        end
    end
    return count
end
