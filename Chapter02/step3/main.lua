
-- 1) Создадим игровой цикл
-- 2) Вызывем игровой цикл с частотой 1/2 секунды
-- 3) Создадим обработку столкновений
--  а) астероид Х кораблик
--  б) лазер Х астероид

-- Есть два вида столкновений: локальные и глобальные
-- Локальные столкновения = объект столкнулся с чкем-то с помощью своего прослушивателя
-- Глобальные столкновения = объект столкнулся с чем-то с помощью прослушивателя времени выполнения
-- Локальные надо использовать: 1 Х многими (1 игрок Х со многими вещами)
-- Глобальные надо использовать: много Х много (много героев Х много врагов)
-- В данном случае лучше всего глобальная обработка (много лазеров + кораблик Х много астероидов)

-- 4) Функция восстановления корабля
-- 5) Функция столкновения астероида и лазера
-- 6) Функция столкновения астероида и корабля
-- 7) Запустить прослушивание коллизий (столкновений)

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
local gameLoopTimer                               -- вызов игрового цикла (каждые 1/2 сек)
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

ship:addEventListener("tap", fireLaser)

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

ship:addEventListener("touch", dragShip)

-- Игровой цикл приложения
-- 1) вызываем создание астероида
-- 2) создаем цикл для просмотра таблицы астероидов
-- 3) #asteroidsTable = число астероидов (будет все время меняться)
-- 4) thisAsteroid = текущий астероид, который мы рассматриваем
-- 5) если координаты текущего астероида "вылетели", то
--  а) удаляем его с экрана
--  б) удаляем его из таблицы

local function gameLoop()
  createAsteroid()
  for i = #asteroidsTable, 1, -1 do
    local thisAsteroid = asteroidsTable[i]
    if ( thisAsteroid.x < -100 or
         thisAsteroid.x > display.contentWidth + 100 or
         thisAsteroid.y < -100 or
         thisAsteroid.y > display.contentHeight + 100 ) 
    then
      display.remove(thisAsteroid)               -- 1) удалить с экрана
      table.remove(asteroidsTable, i)            -- 2) удалить из памяти
    end
  end
end

-- Вызов игрового цикла
-- 1) gameLoopTimer = переменная, объявленная ранее (старт/стоп)
-- 2) timer.performWithDelay() = функция вызова функции через интервал времени
-- 3) 500 = старт времени отсчета до вызова функции
-- 4) 0 = выполнить когда счетчик дойдет до значения (если нет этого параметра, то 1 раз)
-- 5) gameLoop = функция, которая будет вызвана

gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)

-- Обработка столкновений
-- Обработка столкновений
-- Обработка столкновений

-- Функция восстановления корабля
-- 1) ship.isBodyActive = false удаляем корабль из физики (он не взаимодействует с объектами)
-- 2) меняем координаты х, у (чуть ниже середины экрана)
-- 3) transition = 4 секунды на проявление корабля + возвращает физику + died=false

local function restoreShip()
  ship.isBodyActive = false
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100

  transition.to(ship, { alpha = 1, time = 4000, 
    onComplete = function()
      ship.isBodyActive = true
      died = false
    end
  })
end

-- Функция столкновения лазера и астероида
-- 1) смотрим в какой стадии столкновение (began || ended)
-- 2) если наша стадия == began, то мы сохраняем переменные obj1, obj2
-- 3) у каждого объекта на экране есть свойство myName = его типу (было ранее)
-- 4) если лазар Х астероид или астероид Х лазер, то удалить их оба (с экрана)
-- 5) чтобы удалить астероид из таблицы запускаем цикл всех астероидов
-- 6) если очередной астероид внутри цикла == 1 или 2 объекту, то удалить его
-- 7) сразу после этого можно выходить из цикла break
-- 8) увеличим значение score
-- 9) обновим значение score на экране

-- 10) иначе если астероид Х корабль или корабль Х астероид, то обработаем их столкновение
-- 11) если игро находится не в состоянии смерти, то переведем его туда (временно)
-- 12) уменьшим значение переменной lives и выведем ее на экран
-- 13) если жизни == 0, то удалим кораблик
-- 14) если жизни != 0, то делаем корабль невидимым на 1 сек и вызываем функцию restoreShip

local function onCollision(event)
  if (event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2
    
    if ( (obj1.myName == "laser" and obj2.myName == "asteroid") or
         (obj1.myName == "asteroid" and obj2.myName == "laser") )
    then
      display.remove(obj1)
      display.remove(obj2)
      for i = #asteroidsTable, 1, -1 do
        if (asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2) then
          table.remove(asteroidsTable, i)
          break
        end
      end
      score = score + 100
      scoreText.text = "Score: " .. score
    elseif ( (obj1.myName == "ship" and obj2.myName == "asteroid") or
             (obj1.myName == "asteroid" and obj2.myName == "ship") )
    then
      if (died == false) then
        died = true
        lives = lives - 1
        livesText.text = "Lives: " .. lives
        if (lives == 0) then
          display.remove(ship)
        else
          ship.alpha = 0
          timer.performWithDelay(1000, restoreShip)
        end
      end
    end
  end
end

-- Запустить прослушивание столкновений

Runtime:addEventListener("collision", onCollision)