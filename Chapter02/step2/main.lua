
-- 1) Создадим астероид
-- 2) Добавим стрельбу лазером
-- 3) Добавим кораблю возможность стрелять
-- 4) Добавим кораблю возможность двигаться влево/вправо

local physics = require("physics")
physics.start()
physics.setGravity(0,0)

math.randomseed(os.time())

local sheetOptions = {
  frames = {
    { x = 0, y = 0, width = 102, height = 85 },   -- астероид 1
    { x = 0, y = 85, width = 90, height = 83 },   -- астероид 2
    { x = 0, y = 168, width = 100, height = 97 }, -- астероид 3
    { x = 0, y = 265, width = 98, height = 79 },  -- корабль
    { x = 98, y = 265, width = 14, height = 40 }, -- лазер
  },
}
local objectSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)

local lives = 3                                   -- жизни кораблика
local score = 0                                   -- счет убитых астероидов
local died = false                                -- смерть/жизнь игрока
local asteroidsTable = {}                         -- все астероиды на экране (таблица)
local ship                                        -- кораблик
local gameLoopTimer                               -- предварительное объявление
local livesText                                   -- текст "Lives"
local scoreText                                   -- текст "Score"

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local background = display.newImageRect(backGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody(ship, { radius = 30, isSensor = true })
ship.myName = "ship"

livesText = display.newText(uiGroup, "Lives: " .. lives, 200, 30, native.systemFont, 36)
scoreText = display.newText(uiGroup, "Score: " .. score, 400, 30, native.systemFont, 36)

display.setStatusBar(display.HiddenStatusBar)

local function updateText()
  livesText.text = "Lives: " .. lives
  scoreText.text = "Score: " .. score
end

-- Создание астероида
-- 1) newAsteroid = новый астероид из списка объектов (индекс = 1)
-- 2) добавим новый астероид в таблицу астероидов asteroidsTable
-- 3) добавим новый астероид в физику (как новое тело)
-- 4) он будет динамический (может двигаться и сталкиваться)
-- 5) он будет радиусом = 40
-- 6) он будет отталкиваться с 80% энергии
-- 7) он будет иметь имя "asteroid"
-- 8) whereFrom = 1-3 (слева, центр, справа) будет появляться астероид
--  а) Область слева это область за пределами экрана слева (х=-60, у=1-500)
--  б) Область центр это область за пределами экрана по центру (х=0-ширины, у=-60)
--  в) Область справа это область за пределами экрана справа (х=ширина+60, у=1-500)
-- 9) заставим астероид двигатсья с постоянной скоростью в точку (х,у)
-- 10) заставим астероид вращаться вокруг своего центра (-6,6)

local function createAsteroid()
  local newAsteroid = display.newImageRect(mainGroup, objectSheet, 1, 102, 85)
  table.insert(asteroidsTable, newAsteroid)
  physics.addBody(newAsteroid, "dynamic", { radius = 40, bounce = 0.8 })
  newAsteroid.myName = "asteroid"
  local whereFrom = math.random(3)
  if (whereFrom == 1) then
    newAsteroid.x = -60
    newAsteroid.y = math.random(500)
    newAsteroid:setLinearVelocity(math.random(40,120), math.random(20,60))
  elseif (whereFrom == 2) then
    newAsteroid.x = math.random(display.contentWidth)
    newAsteroid.y = -60
    newAsteroid:setLinearVelocity(math.random(-40,40), math.random(40,120))
  elseif (whereFrom == 3) then
    newAsteroid.x = display.contentWidth + 60
    newAsteroid.y = math.random(500)
    newAsteroid:setLinearVelocity(math.random(-120,-40), math.random(20,60))
  end
  newAsteroid:applyTorque(math.random(-6,6))
end

-- Проверка летящего астероида
createAsteroid()

-- Создание лазера
-- 1) newLaser = переменная-лазер
-- 2) делаем из него динамический объект-сенсор
-- 3) устнавливаем ему свойство isBullet (ищет столкновения)
-- 4) устанавливаем ему имя "laser"
-- 5) устанавливаем ему координаты == кораблику (картинки накладываются)
-- 6) кладем лазер за кораблем (все происходит на слое mainGroup)
-- 7) начнем перемещение лазера от исходной точки до заданной
--  а) newLaser = объект перемещения
--  б) y = -40 вертикальное направление, почти до верха экрана
--  в) time = 500 миллисекунд на перемещение (1/2 секунды)
-- 8) Реализуем удаление лазера, который достиг верха экрана (параметр transition)
--  г) когда переход будет выполнен, то будет запущена onComplete

local function fireLaser()
  local newLaser = display.newImageRect(mainGroup, objectSheet, 5, 14, 40)
  physics.addBody(newLaser, "dynamic", { isSensor = true })
  newLaser.isBullet = true
  newLaser.myName = "laser"
  newLaser.x = ship.x
  newLaser.y = ship.y
  newLaser:toBack()
  transition.to(newLaser, { y = -40, time = 500, onComplete = function() display.remove(newLaser) end })
end

-- Корабль может стрелять

ship:addEventListener("tap", fireLaser)

-- Движение кораблика
-- 1) параметр event (таблица) = для какого объекта вызывается функция
-- 2) ship = event.target переименуем объект, к которому прикоснулись (для удобства)
-- 3) касания пользователя бывают
--  а) began = первое прикосновение к экрану
--  б) moved = касание передвигало объект
--  в) ended = прикосновение закончилось
--  г) cancelled = система отменила слежку за касаниями
-- 4) phase = тип касания, которое мы обрабатываем
-- 5) если тип был == began, то привязываем фокус касания к кораблику
-- 6) touchOffsetX = сохраним разность между точкой касания и центром кораблика
-- 7) если тип бьыл == moved, то перемещаем кораблик влево/вправо - коррекция touchOffsetX
-- 8) если тип был == ended || cancelled, то отпускаем фокус с кораблика
-- 9) функция возвращает результат работы == true (не дает касанию идти на другие объекты)

local function dragShip(event)
  local ship = event.target
  local phase = event.phase
  if ("began" == phase) then
    display.currentStage:setFocus(ship)
    ship.touchOffsetX = event.x - ship.x
  elseif ("moved" == phase) then
    ship.x = event.x - ship.touchOffsetX
  elseif ("ended" == phase or "cancelled" == phase) then
    display.currentStage:setFocus(nil)
  end
  return true
end

-- Корабль может двигаться

ship:addEventListener("touch", dragShip)