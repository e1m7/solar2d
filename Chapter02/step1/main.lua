
-- Описание проекта
-- 1) Название: Star Explorer (звездный исследователь)
-- 2) Описание: маневрировать кораблем в астероидном поле, уничтожая их лазером
-- 3) Управление: клик на корабле - выстрел, перетаскивание влево/вправо - движение
-- 4) Звуки: выстрел - звук, взрыв астероида - звук, столкновение корабля - звук

-- Предустановки
-- 1) размер экрана = 768х1024
-- 2) создать файл build.settings (ориентация приложения для разных устройств)
-- 3) создать файл config.lua (контент, масштаб и проч.)

-- Включаем физику
-- 1) загрузить движок
-- 2) запустить движок
-- 3) установить гравитацию (х=0, у=0)

local physics = require("physics")
physics.start()
physics.setGravity(0,0)

-- Настроим генератор случайных чисел

math.randomseed(os.time())

-- Добавим два графических файла для проекта
-- 1) background.png 800x1400 (таинственный бескрайний космос)
-- 2) gameObjects.png 112x334 (астероиды, корабль, выстрел)
-- Показать сайт https://www.codeandweb.com
-- Показать сайт https://github.com/e1m7

-- Определим таблицу объектов игры и занесем координаты объектов
-- 1) x,y = координата верхнего левого угла
-- 2) width, height = ширина, высота объекта
-- 3) создадим лист изображений = картинка + таблица

local sheetOptions = {
  frames = {
    { x = 0, y = 0, width = 102, height = 85 },   -- астероид 1  (1 кадр)
    { x = 0, y = 85, width = 90, height = 83 },   -- астероид 2  (2 кадр)
    { x = 0, y = 168, width = 100, height = 97 }, -- астероид 3  (3 кадр)
    { x = 0, y = 265, width = 98, height = 79 },  -- корабль     (4 кадр)
    { x = 98, y = 265, width = 14, height = 40 }, -- лазер       (5 кадр)
  },
}
local objectSheet = graphics.newImageSheet("gameObjects.png", sheetOptions)

-- Объявим все переменные проекта

local lives = 3                              -- жизни кораблика
local score = 0                              -- счет убитых астероидов
local died = false                           -- смерть/жизнь игрока
local asteroidsTable = {}                    -- все астероиды на экране (таблица)
local ship                                   -- предварительное объявление
local gameLoopTimer                          -- предварительное объявление
local livesText                              -- предварительное объявление
local scoreText                              -- предварительное объявление

-- Создадим три группы (три прозрачных листа) приложения
-- 1) backGroup = фон
-- 2) mainGroup = корабль, астероиды, лазеры
-- 3) uiGroup = очки и прочее

local backGroup = display.newGroup()         -- 1) дальше всех
local mainGroup = display.newGroup()         -- 2) середина
local uiGroup = display.newGroup()           -- 3) ближе всех

-- Загрузка фона

local background = display.newImageRect(backGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Загрузка кораблика
-- 1) ship = кораблик
-- 2) mainGroup = загружается на второй слой
-- 3) 4 = в таблице objectSheet кораблик под 4-ым индексом
-- 4) 98х79 = ширина/высота кораблика
-- 5) мы не пишем local, т.к. объявили кораблик ранее
-- 6) координата х = по центру экрана
-- 7) координата у = 100 пикселов выше высоты экрана
-- 8) добавить изображение в движок Box2D как круг с радиусом = 30
-- 9) isSensor = true объект "датчик"(сенсор), т.е. он сталкивается, но не отскакивает
-- 10) name = "ship" имя объекта внутри движка

ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody(ship, { radius = 30, isSensor = true })
ship.name = "ship"

-- Добавим надписи: жизни, очки
-- 1) по адресу (200,30) выведем строку "Lives: 3"
-- 2) по адресу (400,30) выведем строку "Score: 0"

livesText = display.newText(uiGroup, "Lives: " .. lives, 200, 30, native.systemFont, 36)
scoreText = display.newText(uiGroup, "Score: " .. lives, 400, 30, native.systemFont, 36)

-- Скрыть строку состояния

display.setStatusBar(display.HiddenStatusBar)

-- Функция для обновления данных про жизни и очки
-- 1) при обновлении lives текст на экране изменится
-- 2) при обновлении score текст на экране изменится

local function updateText()
  livesText.text = "Lives: " .. lives
  scoreText.text = "Score: " .. score
end