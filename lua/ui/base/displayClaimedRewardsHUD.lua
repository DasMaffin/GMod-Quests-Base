local FADE_TIME = 4
local FADE_DURATION = 1
local DISPLAY_TIME = 5
local TEXT_POS_X = ScrW() * 0.9
local TEXT_POS_Y = ScrH() * 0.3

local currentPoints = {
    normal = 0,
    donator = 0,
    xp = 0
}

local lastUpdateTime = 0
local textAlpha = 255
local isVisible = false

-- Colors
local COLOR_NORMAL = Color(0, 255, 0)    -- Green
local COLOR_DONATOR = Color(255, 165, 0)  -- Orange
local COLOR_XP = Color(50, 206, 237)     -- Light blue

-- The main hook function
hook.Add("sendClaimedRewards", "PointDisplaySystem", function(rewards)
    local currentTime = CurTime()
    
    if not isVisible or (currentTime - lastUpdateTime) > DISPLAY_TIME then
        currentPoints.normal = rewards[1]
        currentPoints.donator = rewards[2]
        currentPoints.xp = rewards[3]
        textAlpha = 255
        isVisible = true
    else
        currentPoints.normal = currentPoints.normal + rewards[1]
        currentPoints.donator = currentPoints.donator + rewards[2]
        currentPoints.xp = currentPoints.xp + rewards[3]
    end
    
    lastUpdateTime = currentTime
end)

-- Drawing hook
hook.Add("HUDPaint", "PointDisplayPaint", function()
    if not isVisible then return end
    
    local currentTime = CurTime()
    local timeSinceUpdate = currentTime - lastUpdateTime
    
    -- Handle fading
    if timeSinceUpdate > FADE_TIME then
        local fadeProgress = (timeSinceUpdate - FADE_TIME) / FADE_DURATION
        textAlpha = math.max(255 * (1 - fadeProgress), 0)
        
        if textAlpha <= 0 then
            isVisible = false
            return
        end
    end
    
    -- Draw the text
    local function DrawPointText(text, color, yOffset)
        color = Color(color.r, color.g, color.b, textAlpha)
        draw.SimpleText(text, "DermaLargeCustom", TEXT_POS_X, TEXT_POS_Y + yOffset, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    
    -- Draw each point type if it exists
    if tonumber(currentPoints.normal) > 0 then
        DrawPointText("+" .. currentPoints.normal, COLOR_NORMAL, 0)
    end
    if tonumber(currentPoints.donator) > 0 then
        DrawPointText("+" .. currentPoints.donator, COLOR_DONATOR, 30)
    end
    if tonumber(currentPoints.xp) > 0 then
        DrawPointText("+" .. currentPoints.xp, COLOR_XP, 60)
    end
end)
