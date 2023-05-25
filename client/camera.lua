local objectCam
local rotationX
local rotationY
local currentZoom

--change how you would like
local defaultCamOptions = {
    rotationSpeed = 0.15,
    zoomClamp = {min = 0.25, max = 3.0},
    startingZoom = 3.0,
    zoomStep = 0.05,
}

local function ShowHelpNotification(text)
    AddTextEntry('HelpMsg', text)
    BeginTextCommandDisplayHelp('HelpMsg')
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local function camControl(object, coords, rotationSpeed, zoomStep, zoomClamp)
        if IsDisabledControlPressed(2, 241) then
            currentZoom -= zoomStep
        end

        if IsDisabledControlPressed(2, 242) then
            currentZoom += zoomStep
        end

        if currentZoom > zoomClamp.max then
            currentZoom = zoomClamp.max
        end

        if currentZoom < zoomClamp.min then
            currentZoom = zoomClamp.min
        end

        local mouseX = GetDisabledControlNormal(0, 1) * rotationSpeed
        local mouseY = GetDisabledControlNormal(0, 2) * rotationSpeed

        rotationX = math.clamp(rotationX - mouseY, -math.pi / 2, math.pi / 2)
        rotationY = rotationY - mouseX

        local camX = coords.x + currentZoom * math.cos(rotationY) * math.cos(rotationX)
        local camY = coords.y + currentZoom * math.sin(rotationY) * math.cos(rotationX)
        local camZ = coords.z + currentZoom * math.sin(rotationX)

        SetCamCoord(objectCam, camX, camY, camZ)
        PointCamAtEntity(objectCam, object, 0.0, 0.0, 0.0, true)
end

local function handleCamUpdates(object, coords, options)
    local rotationSpeed = options?.rotationSpeed or defaultCamOptions.rotationSpeed
    local zoomStep = options?.zoomStep or defaultCamOptions.zoomStep
    local zoomClamp = options?.zoomClamp or defaultCamOptions.zoomClamp
    CreateThread(function()
        while DoesEntityExist(object) do
            Wait(0)

            DisablePlayerFiring(PlayerPedId(), true)
            DisableAllControlActions(0)

            camControl(object, coords, rotationSpeed, zoomStep, zoomClamp)


            ShowHelpNotification(
                'Press ~INPUT_CURSOR_SCROLL_UP~ Zoom +'..
                '~n~Press ~INPUT_CURSOR_SCROLL_DOWN~ Zoom -'..
                '~n~Press ~INPUT_FRONTEND_PAUSE_ALTERNATE~ Exit'
            )

            if IsDisabledControlJustPressed(0, 200) then --[[@ESC]]
                FreezeEntityPosition(PlayerPedId(), false)
                DestroyCam(objectCam, true)
                RenderScriptCams(false, false, 0, true, true)
                CreateThread(function()
                    while not IsDisabledControlJustReleased(0, 200) do
                        Wait(0)
                        DisableAllControlActions(0)
                    end
                end)
                break
            end
        end
    end)
end

local function createObjectCam(object, options)
    local coords = GetEntityCoords(object)
    local heading = GetEntityHeading(object)

    rotationX = 0.0
    rotationY = math.rad(heading) + math.pi / 2
    currentZoom = options?.startingZoom or defaultCamOptions.startingZoom

    local forwardVector = GetEntityForwardVector(object)
    local cameraX = coords.x + currentZoom * forwardVector.x
    local cameraY = coords.y + currentZoom * forwardVector.y
    local cameraZ = coords.z + currentZoom * forwardVector.z

    objectCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(objectCam, cameraX, cameraY, cameraZ)
    PointCamAtEntity(objectCam, object, 0.0, 0.0, 0.0, true)
    SetCamActive(objectCam, true)
    RenderScriptCams(true, false, 0, true, true)
    handleCamUpdates(object, coords, options)
end


exports("createObjectCam", createObjectCam)

RegisterCommand("testObjectCam", function(source, args)
    local model = joaat(args[1])
    RequestModel(model)
    local timer = 50
    while not HasModelLoaded(model) and timer > 0 do
        timer -= 1
        RequestModel(model)
        Wait(100)
    end
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 3.0, 0.0)
    local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(object, true)
    createObjectCam(object, {
        rotationSpeed = 0.3,
        zoomClamp = {min = 0.25, max = 10.0},
        startingZoom = 5.0,
        zoomStep = 0.25,
    })
end, false)