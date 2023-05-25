# Camera Module - object_camera

This README is aimed at providing guidance on how to use the exported `createObjectCam` function from the `object_camera` module in the FiveM framework using Lua.

## Installation

1. Download the `object_camera` resource.
2. Extract the `object_camera` folder into your server's `resources` directory.
3. Add `start object_camera` to your server's `server.cfg` file.

You should now be able to use the `createObjectCam` function in your scripts: `exports['object_camera']:createObjectCam(object, options)`

## Export

`exports("createObjectCam", createObjectCam)`

## Functions

### createObjectCam(object, options)

- `object`: The entity at which the camera is pointed.
- `options`: A table with camera settings, including `rotationSpeed`, `zoomClamp`, `startingZoom`, and `zoomStep`.

Default camera options:

```lua
local defaultCamOptions = {
    rotationSpeed = 0.15,
    zoomClamp = {min = 0.25, max = 3.0},
    startingZoom = 3.0,
    zoomStep = 0.05,
}
```

If options are not provided, these default options are used.

## Usage

First, ensure the `object_camera` module script is running on your server.

The `createObjectCam` function can be used in any Lua script on the server or client side as follows:

```lua
local object = --[[@ Your target entity]]
local options = {
    rotationSpeed = 0.3,
    zoomClamp = {min = 0.25, max = 10.0},
    startingZoom = 5.0,
    zoomStep = 0.25,
}

exports['object_camera']:createObjectCam(object, options)
```

## Test Command

A command `testObjectCam` is registered in this module to test the camera functionality. Usage: `/testObjectCam model`, replace `model` with the hash of the model you want to spawn and view.

```lua
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
```

## Controls

While in the camera view, the following controls apply:
- Zoom in: Scroll Up
- Zoom out: Scroll Down
- Exit camera view: ESC

## Note

The camera will be locked on the entity even if it moves. The camera's perspective will not change unless the entity does.
