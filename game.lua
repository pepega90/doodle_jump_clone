local composer = require("composer")
local physics = require("physics")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

physics.start()
physics.setGravity(0, 20)

-- Local variables
local player, scoreText, game_over, platforms
local score = 0
local finalScoreText, restartButton

-- Function to update the score
local function updateScore()
    score = score + 1
    scoreText.text = tostring(score)
end

-- Function to create a new platform
local function createPlatform(sceneGroup, x, y)
    local platformWidth = math.random(40, 120)
    local p = display.newImageRect(sceneGroup, "assets/platform.png", 85 * .6, 15 * .6)
    p.x = x
    p.y = y
    p.type = "platform"
    p:setFillColor(0, math.random(200, 255), 0) -- varied green shades
    physics.addBody(p, "static", { isSensor = true })
    table.insert(platforms, p)
end

-- Function to check platform overlap
local function isPlatformOverlapping(x, y, spacing)
    for i = 1, #platforms do
        local platform = platforms[i]
        local distance = math.sqrt((platform.x - x) ^ 2 + (platform.y - y) ^ 2)
        if distance < spacing then
            return true
        end
    end
    return false
end

-- Function to generate platforms
local function generatePlatforms(sceneGroup, numPlatforms, minYSpacing)
    local initialY = display.contentHeight
    for i = 1, numPlatforms do
        local x, y
        repeat
            x = math.random(50, display.contentWidth - 50)
            y = initialY - (i * minYSpacing)
        until not isPlatformOverlapping(x, y, 70)
        createPlatform(sceneGroup, x, y)
    end
end

-- Function to handle player movement
local function playerMovement(event)
    local _, py = player:getLinearVelocity()
    if event.phase == "began" or event.phase == "moved" then
        if event.x < display.contentCenterX then
            player:setLinearVelocity(-200, py)
            player.xScale = -1
        else
            player:setLinearVelocity(200, py)
            player.xScale = 1
        end
    end
    return true
end

-- Function to handle player jumping
local function playerJump(event)
    local playerVelocityX, playerVelocityY = player:getLinearVelocity()
    if event.phase == "began" then
        if event.other.type == "platform" then
            if playerVelocityY > 0 and player.y <= event.other.y then
                player:setLinearVelocity(playerVelocityX, -600)
            else
                event.other.isSensor = true
            end
        end
    elseif event.phase == "ended" then
        event.other.isSensor = false
    end
end

-- Function to handle game over
local function onGameOver(sceneGroup)
    finalScoreText = display.newText(sceneGroup, "Score: " .. tostring(score), display.contentCenterX,
        display.contentCenterY - 50, native.systemFontBold, 24)
    finalScoreText:setFillColor(0, 0, 0)

    restartButton = display.newText(sceneGroup, "Restart", display.contentCenterX, display.contentCenterY + 50,
        native.systemFontBold, 24)
    restartButton:setFillColor(0, 0, 0)

    player:setLinearVelocity(0, 0)
    Runtime:removeEventListener("touch", playerMovement)
    player:removeEventListener("collision", playerJump)
    Runtime:removeEventListener("enterFrame", gameLoop)

    local function restartGame(event)
        if event.phase == "ended" then
            finalScoreText:removeSelf()
            restartButton:removeSelf()

            player.x = 100
            player.y = display.contentHeight - 100
            score = 0
            scoreText.text = tostring(score)

            for i = #platforms, 1, -1 do
                platforms[i]:removeSelf()
                table.remove(platforms, i)
            end

            createPlatform(sceneGroup, 100, display.contentHeight - 50)
            generatePlatforms(sceneGroup, 20, 70)

            game_over = false
            Runtime:addEventListener("touch", playerMovement)
            player:addEventListener("collision", playerJump)
            Runtime:addEventListener("enterFrame", gameLoop)
        end
        return true
    end

    restartButton:addEventListener("touch", restartGame)
end

-- Game loop function
function gameLoop()
    if player.y < display.contentCenterY then
        updateScore()
        local delta = display.contentCenterY - player.y
        player.y = display.contentCenterY
        for i = 1, #platforms do
            platforms[i].y = platforms[i].y + delta
        end
    end

    if player.y > display.contentHeight + 150 then
        game_over = true
    end

    -- print("player x = " .. tostring(player.x) .. ", player y = " .. tostring(player.y))

    if game_over then
        onGameOver(scene.view)
    end

    player.x = (player.x - 1) % display.contentWidth + 1

    for i = #platforms, 1, -1 do
        if platforms[i].y > display.contentHeight then
            platforms[i]:removeSelf()
            table.remove(platforms, i)
        end
    end

    while #platforms < 20 do
        local highestPlatform = platforms[1]
        for i = 1, #platforms do
            if platforms[i].y < highestPlatform.y then
                highestPlatform = platforms[i]
            end
        end
        createPlatform(scene.view, math.random(50, display.contentWidth - 50), highestPlatform.y - 100)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create(event)
    local sceneGroup = self.view

    -- Background
    local bg = display.newImageRect(sceneGroup, "assets/background.png", display.actualContentWidth,
        display.actualContentHeight)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    -- Player
    player = display.newImageRect(sceneGroup, "assets/player.png", 87 * .5, 85 * .5)
    player.x = 100
    player.y = 100
    physics.addBody(player, "dynamic", { bounce = 0 })
    player.isFixedRotation = true

    -- Score text
    scoreText = display.newText(sceneGroup, score, 75, 30, native.systemFontBold,
        20)
    scoreText:setFillColor(0, 0, 0)

    platforms = {}
    createPlatform(sceneGroup, 100, display.contentHeight - 50)
    generatePlatforms(sceneGroup, 20, 70)
end

function scene:show(event)
    local phase = event.phase
    if phase == "will" then
        player:addEventListener("collision", playerJump)
    end
    if phase == "did" then
        Runtime:addEventListener("touch", playerMovement)
        player:addEventListener("collision", playerJump)
        Runtime:addEventListener("enterFrame", gameLoop)
    end
end

function scene:hide(event)
    local phase = event.phase
    if phase == "will" then
        Runtime:removeEventListener("touch", playerMovement)
        player:removeEventListener("collision", playerJump)
        Runtime:removeEventListener("enterFrame", gameLoop)
    end
end

function scene:destroy(event)
    -- Clean up scene resources here
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
