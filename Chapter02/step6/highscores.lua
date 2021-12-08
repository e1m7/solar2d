
-- Задача данной сцены: 
-- 1) сохранять/извлекать оценки пользователя
-- 2) показывать 10 самых высоких оценок

local composer = require("composer")
local scene = composer.newScene()

-- 1) json = подключаем библиотеку JSON (функция encode() кодирует данные, decode() декодирует данные)
-- 2) scoresTable = пустая таблица для сохраненных данных (очки пользователя)
-- 3) filePath = абсолютный путь к файлу scores.json, в котором будут храниться результаты (внутри приложения)

local json = require("json")
local scoresTable = {}
local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

-- Функция проверки оценок, которые были сохранены ранее
-- 1) file = открыть файл на чтение
-- 2) если файл существует (есть данные), то...
-- 3) content = прочитать данные
-- 4) закрыть файл
-- 5) scoresTable = декодировать данные а таблицу
-- 6) если таблица пуста или ее длина == 0, то...
-- 7) scoresTable = десять нулей (первое прочтение данных)

local function loadScores()
  local file = io.open(filePath, "r")
  if file then
    local contents = file:read("*a")
    io.close(file)
    scoresTable = json.decode(contents)
  end
  if (scoresTable == nil or #scoresTable == 0) then
    scoresTable = {0,0,0,0,0,0,0,0,0,0}
  end
end

-- Функция сохранения данных
-- 1) проходим в цикле от последнего до 11-го элемента с конца
-- 2) удаляем все эти элементы, оставляем только 1-10
-- 3) открываем файл на запись (переписать или новый если не было)
-- 4) записываем туда закодированную json таблицу

local function saveScores()
  for i = #scoresTable, 11, -1 do
    table.remove(scoresTable, i)
  end
  local file = io.open(filePath, "w")
  if file then
    file:write(json.encode(scoresTable))
    io.close(file)
  end
end

local function gotoMenu()
  composer.gotoScene("menu", { time = 800, effect = "crossFade" })
end

-- Создание сцены (подготовка данных к выводу на экран)
-- 1) loadScores() = прочитали записи
-- 2) добавили число в таблицу
-- 3) сбросили его в ноль для следующей игры
-- 4) отсортируем таблицу с данными через функцию compare(a,b)
-- 5) сама сортировка идет методом sort()
-- 6) сохранить отсортированные данные а файл
-- 7) создадим фон
-- 8) создадим текст (через цикл)
-- 9) создадим кнопку вернуть в меню

function scene:create(event)
  local sceneGroup = self.view
  loadScores()                                                          -- добавить
  table.insert(scoresTable, composer.getVariable("finalScore"))         -- добавить
  composer.setVariable("finalScore", 0)                                 -- добавить
  
  local function compare(a, b)
    return a > b
  end
  table.sort(scoresTable, compare)
  saveScores()
  local background = display.newImageRect(sceneGroup, "background.png", 800, 1400)
  background.x = display.contentCenterX
  background.y = display.contentCenterY
  local highScoresHeader = display.newText(sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 44)

  -- По-умолчанию Solar2D рабоатет со всеми объектами с (х,у) как с центром объекта
  -- Нам надо вывести даныне по другому: номер по правому краю, оценка по левому краю
  -- Якоря позволяют указать как выравнивать объекты https://docs.coronalabs.com/images/docs/anchor-diagram.png
  -- Якоря меняются от 0 до 1

  for i = 1, 10 do
    if (scoresTable[i]) then
      local yPos = 150 + (i * 56)
      local rankNum = display.newText(sceneGroup, i .. ")", display.contentCenterX - 50, yPos, native.systemFont, 36)
      rankNum:setFillColor(0.8)
      rankNum.anchorX = 1
      local thisScore = display.newText(sceneGroup, scoresTable[i], display.contentCenterX - 30, yPos, native.systemFont, 36)
      thisScore.anchorX = 0
    end
  end

  local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 44)
  menuButton:setFillColor(0.75, 0.78, 1)
  menuButton:addEventListener("tap", gotoMenu)
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- code
  elseif (phase == "did") then
    -- code
  end
end

function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- code
  elseif (phase == "did") then
    composer.removeScene("highscores")                                    -- добавить
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene