--[[----------------------------------------------------------------------------

  Application Name:
  ColorBlobLength
                                                                                             
  Description:
  Finding blue plastic tubes and measuring their lengths.
  
  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  To run this sample a device with SICK Algorithm API is necessary.
  For example InspectorP or SIM4000 with latest firmware. Alternatively the
  Emulator on AppStudio 2.2 or higher can be used.

  More Information:
  Tutorial "Algorithms - Color".

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 500

-- Create viewer
local viewer = View.create()

-- Setup graphical overlay attributes
local decoration = View.ShapeDecoration.create()
decoration:setLineColor(0, 230, 0) -- Green
decoration:setLineWidth(3)
decoration:setFillColor(0, 0, 230, 128) -- Transparent blue

local textDec = View.TextDecoration.create()
textDec:setSize(40)
textDec:setPosition(20, 50)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

-- Viewing image with text label
--@show(img:Image, name:string)
local function show(img, name)
  viewer:clear()
  local imid = viewer:addImage(img)
  viewer:addText(name, textDec, nil, imid)
  viewer:present()
  Script.sleep(DELAY * 2) -- for demonstration purpose only
end

local function main()
  local img = Image.load('resources/ColorBlobLength.bmp')
  show(img, 'Input image')

  -- Converting to HSV color space (Hue, Saturation, Value)
  local H, S, V = img:toHSV()
  show(H, 'Hue') -- View image with text label and delay
  show(S, 'Saturation')
  show(V, 'Value')

  -- Threshold on brightness and hue to find blue regions
  local allRegion = V:threshold(100, 255)
  show(allRegion:toImage(V), 'Bright regions')

  local blueRegion = H:threshold(100, 120, allRegion)
  show(blueRegion:toImage(H), 'Blue regions')

  -- Labelling blue objects (blobs)
  local blueObjects = blueRegion:findConnected(100)

  -- Measuring length and drawing bounding box
  viewer:clear()
  local imid = viewer:addImage(img)
  textDec:setSize(20)

  for i = 1, #blueObjects do
    local minRectangle = blueObjects[i]:getBoundingBoxOriented(H)
    local center, width, height, _ = minRectangle:getRectangleParameters()
    local longSide = math.max(width, height)

    local label = math.floor(longSide * 10) / 10
    textDec:setPosition(center:getX(), center:getY())

    -- Draw feedback overlay
    viewer:addShape(minRectangle, decoration, nil, imid)
    viewer:addText(tostring(label), textDec, nil, imid)
    viewer:present() -- presenting single steps
    print('Length ' .. i .. ': ' .. label)
    Script.sleep(DELAY) -- for demonstration purpose only
  end

  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
