
-- Создать сцену game

local composer = require("composer")
local scene = composer.newScene()

-- Первоначальные настройки
-- Первоначальные настройки
-- Первоначальные настройки

-- insert #1
local physics = require("physics")
physics.start()
physics.setGravity(0,0)
-- insert #1

-- insert #2
local sheetOptions = {
  frames = {
    { x = 0, y = 0, width = 102, height = 85 },
    { x = 0, y = 85, width = 90, height = 83 },
    { x = 0, y = 168, width = 100, height = 97 },
    { x = 0, y = 265, width = 98, height = 79 },
    { x = 98, y = 265, width = 14, height = 40 },
  },
}
local objectSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)
-- insert #2

-- insert #3
local lives = 3
local score = 0
local died = false
local asteroidsTable = {}
local ship
local gameLoopTimer
local livesText
local scoreText
-- insert #3

-- === Изменения ===
-- В старой версии тут были три группы объектов
-- В новой версии тут будут группы просмотра сцены (composer)
-- Они получает свойства позже, пока просто опишем их 

-- insert #4
local backGroup
local mainGroup
local uiGroup
-- insert #4

-- Первоначальные настройки
-- Первоначальные настройки
-- Первоначальные настройки


-- Функции сцены
-- Функции сцены
-- Функции сцены

-- insert #5
local function updateText()
  livesText.text = "Lives: " .. lives
  scoreText.text = "Score: " .. score
end
-- insert #5

-- insert #6
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
-- insert #6

-- insert #7
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
-- insert #7

-- === Изменения === 
-- Функции прослушки поведения объектов не должны быть вставлены
-- Функции прослушки поведения объектов не должны быть вставлены
-- Функции прослушки поведения объектов не должны быть вставлены
-- Функции прослушки поведения объектов не должны быть вставлены

-- ship:addEventListener("tap", fireLaser)
-- ship:addEventListener("touch", dragShip)
-- gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
-- Runtime:addEventListener("collision", onCollision)

-- Функции прослушки поведения объектов не должны быть вставлены
-- Функции прослушки поведения объектов не должны быть вставлены
-- Функции прослушки поведения объектов не должны быть вставлены
-- Функции прослушки поведения объектов не должны быть вставлены

-- insert #8
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
-- insert #8

-- insert #9
local function gameLoop()
  createAsteroid()
  for i = #asteroidsTable, 1, -1 do
    local thisAsteroid = asteroidsTable[i]
    if ( thisAsteroid.x < -100 or
         thisAsteroid.x > display.contentWidth + 100 or
         thisAsteroid.y < -100 or
         thisAsteroid.y > display.contentHeight + 100 ) 
    then
      display.remove(thisAsteroid)
      table.remove(asteroidsTable, i)
    end
  end
end
-- insert #9

-- insert #10
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
-- insert #10

-- функция endGame() = коенц игры
-- 1) возврат в меню (с эффектом перехода)

local function endGame(event)
  composer.gotoScene("menu", { time = 800, effect = "crossFade" })
end

-- функция onCollision() = обнаружение столкновений
-- 1) если жизни == 0, то надо удалить кораблик
-- 2) если жизни == 0, то надо вызвать функцию endGame() через 2 секунды

-- insert #11
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
          timer.performWithDelay(2000, endGame)                       -- добавить строчку
        else
          ship.alpha = 0
          timer.performWithDelay(1000, restoreShip)
        end
      end
    end
  end
end
-- insert #11

-- Функции сцены
-- Функции сцены
-- Функции сцены

-- here

-- Начинаем создавать сцену
-- Начинаем создавать сцену
-- Начинаем создавать сцену

-- 1) остановим физику (создать группы, расставить объекты)
-- 2) создадим три группы (фон, кораблик + астероид + лазер, надписи)
-- 3) в итоге на сцене одновременно находятся три группы объектов
-- 4) в первую группу загружаем фоновое изображение
-- 5) во вторую группу добавим кораблик + два тестовых объекта
-- 6) в третью группу добавим две надписи
-- 7) все объекты (в этом блоке) были определены ранее, остальные функции будут их "видеть"
-- 8) добавим слушатели событий для кораблика: движение + стрельба

function scene:create(event)
  local sceneGroup = self.view

  physics.pause()
  backGroup = display.newGroup()
  sceneGroup:insert(backGroup)
  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)
  uiGroup = display.newGroup()
  sceneGroup:insert(uiGroup)

  local background = display.newImageRect(backGroup, "background.png", 800, 1400)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100
  physics.addBody(ship, { radius = 30, isSensor = true })
  ship.myName = "ship"

  livesText = display.newText(uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36)
  scoreText = display.newText(uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36)

  ship:addEventListener("tap", fireLaser)
  ship:addEventListener("touch", dragShip)
end

-- Замечание: scene:create() вызывается один раз (на сцену все расставляется)
-- Замечание: scene:show() вызывается два раза (каком именно раз показывает event.phase)
-- 1) когда сцена готова к показу, сразу после scene:create() (это фаза event.phase == "will")
-- 2) сразу после показа сцены, когда переход между сценами завершен (это фаза event.phase == "did")
-- 3) когда сцена появилась на экране мы делам три вещи:
--  а) перезапускаем движок (был выключен при создании сцены)
--  б) запускаем поиск столкновений
--  в) запускаем игровой цикл

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- нет кода, не надо ничего делать когда сцена появляется
  elseif (phase == "did") then
    physics.start()
    Runtime:addEventListener("collision", onCollision)
    gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
  end
end

-- правим scene:hide()
-- 1) когда фаза == will, надо остановить игровой таймер
-- 2) когда фаза == did, надо 
--   а) остановить прослушивание столкновений
--   б) поставить физику на паузу
-- 3) удалить сцену из памяти

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    timer.cancel(gameLoopTimer)
  elseif (phase == "did") then
    Runtime:removeEventListener("collision", onCollision)
    physics.pause()
    composer.removeScene("game")
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
  -- Код для сцены, которая удаляется
end

-- Прослушивание всех функций

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- Вернуть сцену

return scene

