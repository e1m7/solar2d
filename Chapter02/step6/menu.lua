
local composer = require("composer")
local scene = composer.newScene()

local function gotoGame()
  composer.gotoScene("game", { time = 800, effect = "crossFade" })
end

local function gotoHighScores()
  composer.gotoScene("highscores", { time = 800, effect = "crossFade" })
end

function scene:create(event)
  local sceneGroup = self.view
  local background = display.newImageRect(sceneGroup, "background.png", 800, 1400)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local title = display.newImageRect(sceneGroup, "title.png", 500, 80)
  title.x = display.contentCenterX
  title.y = 200

  local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, 700, native.sustemFont, 44)
  playButton:setFillColor(0.82, 0.86, 1)

  local highScoresButton = display.newText(sceneGroup, "High Scores", display.contentCenterX, 810, native.sustemFont, 44)
  playButton:setFillColor(0.75, 0.78, 1)

  playButton:addEventListener("tap", gotoGame)
  highScoresButton:addEventListener("tap", gotoHighScores)
end

function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- code
  elseif ( phase == "did" ) then
    -- code
  end
end


function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- code
  elseif ( phase == "did" ) then
    -- code
  end
end

function scene:destroy(event)
  local sceneGroup = self.view
  -- code
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
