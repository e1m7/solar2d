
-- 1) Создадим сцену Scores
-- 2) Организуем сохранение результатов

--[[

Переменные lives и score, которые используются в game.lua, связаны только с ней
Для сохранения результата надо получить доступ к score из game.lua из highscores.lua
Composer дает следующие команды для передачи данных между сценами
  1) composer.setVariable() = установить переменную сцены для всего приложения
  2) composer.getVariable() = получить такую переменную в сцене
Передавать можно любую переменную (число, строка, таблица, функция)

]]

-- 1) Изменим endGame() в game.lua
-- 2) Создадим highscores.lua из стандартного шаблона scene_template.lua

local composer = require("composer")
display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())
composer.gotoScene("menu")