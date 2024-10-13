local composer = require("composer")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
-- create()
function scene:create(event)
    local sceneGroup = self.view
    -- Background image
    bg = display.newImage(sceneGroup, "assets/background.png", display.contentCenterX, display.contentCenterY,
        display.actualContentWidth, display.actualContentHeight);

    -- Doodle image (optional to show it on the menu)
    doodle = display.newImage(sceneGroup, "assets/player.png", display.contentCenterX, display.contentCenterY, 87, 85);
    doodle.xScale = 0.5;
    doodle.yScale = 0.5;

    -- Title text "Doodle Jump"
    local title = display.newText({
        parent = sceneGroup,
        text = "Doodle Jump",
        x = display.contentCenterX,
        y = display.contentCenterY - 90,
        font = native.systemFontBold,
        fontSize = 30
    })
    title:setFillColor(0, 0, 0)

    -- Play button
    local playButton = display.newText({
        parent = sceneGroup,
        text = "Play",
        x = display.contentCenterX,
        y = display.contentCenterY + 100,
        font = native.systemFontBold,
        fontSize = 36
    })
    playButton:setFillColor(0, 0.5, 1) -- blue text color

    -- Text at bottom left corner
    local creditText = display.newText({
        parent = sceneGroup,
        text = "created by aji mustofa @pepega90",
        x = display.contentCenterX,
        y = display.contentHeight - 30,
        font = native.systemFont,
        fontSize = 12
    })
    creditText:setFillColor(0, 0, 0) -- white text color

    -- Function to transition to the game scene when the play button is tapped
    local function goToGame(event)
        if event.phase == "ended" then
            composer.gotoScene("game", { effect = "zoomInOutFade", time = 800 })
        end
    end

    -- Add event listener to the play button
    playButton:addEventListener("touch", goToGame)
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
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
