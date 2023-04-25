
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

--- Viewing image with text label
---@param img Image
---@param name string
local function show(img, name)
  viewer:clear()
  viewer:addImage(img)
  viewer:addText(name, textDec)
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
  viewer:addImage(img)
  textDec:setSize(20)

  local minRectangles = blueObjects:getBoundingBoxOriented(H)
  local centers, widths, heights, _ = minRectangles:getRectangleParameters()
  for i = 1, #centers do
    local longSide = math.max(widths[i], heights[i])

    local label = math.floor(longSide * 10) / 10
    textDec:setPosition(centers[i]:getX(), centers[i]:getY())

    -- Draw feedback overlay
    viewer:addShape(minRectangles, decoration)
    viewer:addText(tostring(label), textDec)
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
