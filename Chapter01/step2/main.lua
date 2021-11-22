
-- Заведем переменную для количества нажатий

local tapCount = 0

local background = display.newImageRect("background.png", 640, 960)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Поместим ее на экран после фона, чтобы она была видна
-- 1) tapText = переменная для вывода числа на экран
-- 2) display.newText = API Solar2D (создание текстового объекта)
-- 3) tapCount = начальное значение
-- 4) display.contentCenterX, 20 = по центру экрана от верха на 20 пикселов
-- 5) native.systemFont = системный шрифт (цвет по-умолчанию белый)
-- 6) 80 = размер шрифта
-- 7) setFillColor(0,0,0) = черный цвет


local tapText = display.newText(tapCount, display.contentCenterX, 220, native.systemFont, 80)
tapText:setFillColor(1,1,1)

local platform = display.newImageRect("platform.png", 300, 50)
platform.x = display.contentCenterX
platform.y = display.contentHeight - 25

local balloon = display.newImageRect("balloon.png", 112, 112)
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.8

local physics = require("physics")
physics.start()

physics.addBody(platform, "static")
physics.addBody(balloon, "dynamic", { radius=50, bounce=0.3 })

local function pushBalloon()
  balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
  tapCount = tapCount + 1                                            -- добавить
  tapText.text = tapCount                                            -- добавить
end

balloon:addEventListener("tap", pushBalloon)
