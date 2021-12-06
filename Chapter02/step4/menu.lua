
-- Файл меню menu.lua
-- 1) подключить composer
-- 2) создать сцену
-- 3) создать функции

local composer = require("composer")
local scene = composer.newScene()

-- Объявление функции gotoGame = переход к игре
local function gotoGame()
  composer.gotoScene("game")
end

-- Объявление функции gotoHighScores = переход к рекордам
local function gotoHighScores()
  composer.gotoScene("highscores")
end

--[[
  Функции событий сцены
  - создать (сцена впервые создается, но еще не на экране)
  - показать (до появления сцены на экране и после появления сцены на экране)
  - спрятать (до завершения сцены на экране и после завершения сцены на экране)
  - удалить/разрушить (если сцена удалена/разрушена)
]]

-- Функция create (создать)
-- Это функция для переменной scene (см. выше)
-- event = таблица с данными сцены
-- sceneGroup = self.view создает локальную ссылку на группу сцены (все объекты сцены)
-- вставляем в центр сцены фоновое изображение
-- вставляем заголовок игры чуть ниже центра
-- создадим кнопку "Play"
-- создадим кнопку "High Scores"
-- добавим обработчики кнопок

function scene:create(event)
  local sceneGroup = self.view
  local background = display.newImageRect(sceneGroup, "background.png", 800, 1400)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local title = display.newImageRect(sceneGroup, "title.png", 500, 80)
  title.x = display.contentCenterX
  title.y = 200

  local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44)
  playButton:setFillColor(0.82, 0.86, 1)

  local highScoresButton = display.newText(sceneGroup, "High Scores", display.contentCenterX, 810, native.systemFont, 44)
  highScoresButton:setFillColor(0.75, 0.78, 1)

  playButton:addEventListener("tap", gotoGame)
  highScoresButton:addEventListener("tap", gotoHighScores)
end

-- Функция show (показать)
-- Есть, но не работает

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- Code
  elseif (phase == "did") then
    -- code
  end
end

-- Функция hide (скрыть)
-- Есть, но не работает

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- code
  elseif (phase == "did") then
    -- code
  end
end

-- Функция destroy (уничтожить)
-- Есть, но не работает

function scene:destroy(event)
  local sceneGroup = self.view
  -- code
end

-- Прослушивать все функции

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- Вернуть сцену при вызове

return scene