
-- Загрузить фон приложения (голубое небо)
-- 1) background = определение локальной переменной для фона
-- 2) display.newImageRect = API Solar2D (загрузка изображения)
-- 3) 360х570 = действительный размер изображения (можно изменить)
-- 4) по-умолчанию центр объекта = точка (0,0), мы установим центр экрана
-- 5) запустить приложение (Crtl+R перезапуск)

local background = display.newImageRect("background.png", 640, 960)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Загрузить платформу (внизу экрана приложения)
-- 1) platform = определение локальной переменной для платформы
-- 2) 300х50 = действительный размер
-- 3) координата х = середина ширины экрана
-- 4) координата у = высота экрана - 25

local platform = display.newImageRect("platform.png", 300, 50)
platform.x = display.contentCenterX
platform.y = display.contentHeight - 25

-- Загрузить воздушный шарик
-- 1) balloon = определение локальной переменной для шарика
-- 2) 112х112 = действительный размер
-- 3) координаты шарика = центр экрана
-- 4) alpha = прозрачность шарика (80%)

local balloon = display.newImageRect("balloon.png", 112, 112)
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.8

-- Добавим и включим физику в приложение
-- 1) physics = загрузка движка Box2D и связывание его с переменной physics
-- 2) start() = запустить движок Box2D (ничего не произойдет)

local physics = require("physics")
physics.start()

-- Преобразовать загруженные объекты в физические объекты
-- 1) addBody() = добавить физическое тело к изображению (платформа)
-- 2) static = физическое тело будет статическое (гравитация не влияет)
-- 3) addBody() = добавить физическое тело к изображению (шарик)
-- 4) dynamic = на объект действует гравитация и другие объекты
-- 5) radius = зададим радиус
-- 6) bounce = зададим значение отскока (0 = нет, 1 = 100% отскок)
-- 7) все объекты в игре имеют bounce = 0.2 по-умолчанию

physics.addBody(platform, "static")
physics.addBody(balloon, "dynamic", { radius=50, bounce=0.3 })

-- Создадим функцию для подпрыгивания шарика при клике на нем
-- 1) pushBalloon() = функция подпрягивания
-- 2) balloon:applyLinearImpulse() = толчок объекта в направлении
-- 3) x=0, y=-0.75 толкает объект вверх по оси у
-- 4) balloon.x, balloon.y = указание где применить импульс

local function pushBalloon()
  balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
end

-- Добавим прослушивание (перехват) события "кликнули на шарике"
-- 1) addEventListener() = прослушивание события
-- 2) tap = тап на шарике левой кнопкой мыши или пальцем на экране
-- 3) pushBalloon() = какую функцию вызвать когда событие произошло

balloon:addEventListener("tap", pushBalloon)
