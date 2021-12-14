
local composer = require("composer")
display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())
audio.reserveChannels(1)                             -- резервируем канал для фоновой музыки
audio.setVolume(0.5, { channel = 1 })                -- уменьшаем громкость музыки до 50%
composer.gotoScene("menu")