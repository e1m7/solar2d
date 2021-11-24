
-- Основной файл main.lua
-- 1) composer = библиотека для созданяи сцен
-- 2) скрыть статус-бар
-- 3) случайные случайные числа
-- 4) перейти к сцене menu (загрузить menu.lua)

local composer = require("composer")
display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())
composer.gotoScene("menu")