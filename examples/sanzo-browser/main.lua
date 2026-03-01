local sanzo = require("sanzo")

local SS      = 36   -- swatch size
local GAP     = 2
local STEP    = SS + GAP
local COLS    = 14
local GX      = 10
local GY      = 10
local LABEL_H = 16
local GRP_GAP = 10
local PANEL_X = GX + COLS * STEP + 20
local PANEL_W = 1200 - PANEL_X - 10

local WIN_H       = 750
local COMBO_TOP   = GY + 116   -- y where combo list starts
local COMBO_BOT   = WIN_H - 10 -- y where combo list ends

local SWATCH_NAMES = {
    "Reds / Pinks / Browns",
    "Yellows / Creams",
    "Greens",
    "Blues",
    "Purples / Lavenders",
    "Neutrals",
}

local groups      = {}
local hovered     = nil
local prevHovered = nil
local colorCombos = {}
local scrollY     = 0

local fontSm, fontMd, fontLg

function love.load()
    fontSm = love.graphics.newFont(11)
    fontMd = love.graphics.newFont(14)
    fontLg = love.graphics.newFont(22)

    local y = GY
    for swatch = 1, 6 do
        local group = { label = SWATCH_NAMES[swatch], labelY = y, rects = {} }
        y = y + LABEL_H + 3
        local col  = 0
        local rowY = y
        for i = 1, 159 do
            local c = sanzo.color(i)
            if c.swatch == swatch then
                group.rects[#group.rects + 1] = { x = GX + col * STEP, y = rowY, index = i, color = c }
                col = col + 1
                if col >= COLS then col = 0; rowY = rowY + STEP end
            end
        end
        y = rowY + SS + GRP_GAP
        groups[#groups + 1] = group
    end

    local nameToIdx = {}
    for i = 1, 159 do nameToIdx[sanzo.color(i).name] = i end
    for i = 1, 159 do colorCombos[i] = {} end
    for id = 1, 348 do
        local ok, palette = pcall(sanzo.combination, id)
        if ok and palette then
            for _, c in ipairs(palette) do
                local idx = nameToIdx[c.name]
                if idx then colorCombos[idx][#colorCombos[idx] + 1] = id end
            end
        end
    end
end

function love.update()
    local mx, my = love.mouse.getPosition()
    hovered = nil
    for _, group in ipairs(groups) do
        for _, r in ipairs(group.rects) do
            if mx >= r.x and mx < r.x + SS and my >= r.y and my < r.y + SS then
                hovered = r.index
                return
            end
        end
    end
end

function love.wheelmoved(x, y)
    if not hovered then return end
    scrollY = scrollY - y * 40
    if scrollY < 0 then scrollY = 0 end
end

function love.draw()
    love.graphics.setBackgroundColor(0.10, 0.10, 0.12)
    love.graphics.clear()

    -- Grid
    for _, group in ipairs(groups) do
        love.graphics.setFont(fontSm)
        love.graphics.setColor(0.45, 0.45, 0.50)
        love.graphics.print(group.label, GX, group.labelY)

        for _, r in ipairs(group.rects) do
            local c = r.color
            love.graphics.setColor(c.rgb[1], c.rgb[2], c.rgb[3])
            love.graphics.rectangle("fill", r.x, r.y, SS, SS)

            if hovered == r.index then
                love.graphics.setColor(1, 1, 1, 0.95)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", r.x - 1, r.y - 1, SS + 2, SS + 2)
                love.graphics.setLineWidth(1)
            end
        end
    end

    -- Divider
    love.graphics.setColor(0.25, 0.25, 0.28)
    love.graphics.rectangle("fill", PANEL_X - 12, 0, 1, WIN_H)

    -- Info panel
    if not hovered then
        love.graphics.setFont(fontMd)
        love.graphics.setColor(0.35, 0.35, 0.38)
        love.graphics.print("Hover over a color to see details", PANEL_X, 350)
        return
    end

    -- Reset scroll when hovering a new color
    if hovered ~= prevHovered then
        scrollY = 0
        prevHovered = hovered
    end

    local c  = sanzo.color(hovered)
    local px = PANEL_X
    local py = GY

    -- Large swatch
    love.graphics.setColor(c.rgb[1], c.rgb[2], c.rgb[3])
    love.graphics.rectangle("fill", px, py, 72, 72)

    -- Name + info
    love.graphics.setFont(fontLg)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(c.name, px + 84, py)

    love.graphics.setFont(fontMd)
    love.graphics.setColor(0.6, 0.6, 0.65)
    love.graphics.print(c.hex:upper() .. "   #" .. hovered, px + 84, py + 28)
    love.graphics.print(SWATCH_NAMES[c.swatch], px + 84, py + 48)

    -- Combinations label
    local combos = colorCombos[hovered]
    love.graphics.setFont(fontMd)
    love.graphics.setColor(0.7, 0.7, 0.72)
    love.graphics.print("Appears in " .. #combos .. " combination" .. (#combos == 1 and "" or "s") .. ":", px, py + 90)

    -- Scrollable combo list
    local CSW   = 28
    local ROW_H = CSW + fontSm:getHeight() + 10

    -- Clamp scroll
    local totalH = #combos * ROW_H
    local maxScroll = math.max(0, totalH - (COMBO_BOT - COMBO_TOP))
    if scrollY > maxScroll then scrollY = maxScroll end

    love.graphics.setScissor(PANEL_X, COMBO_TOP, PANEL_W, COMBO_BOT - COMBO_TOP)

    local cy = COMBO_TOP - scrollY

    for _, id in ipairs(combos) do
        if cy + ROW_H > COMBO_TOP - ROW_H then  -- skip if above visible area
            -- Combo number
            love.graphics.setFont(fontSm)
            love.graphics.setColor(0.4, 0.4, 0.44)
            love.graphics.print(string.format("%3d", id), px, cy + 8)

            -- Color swatches flush together
            local sx = px + 34
            local palette = sanzo.combination(id)
            for _, pc in ipairs(palette) do
                love.graphics.setColor(pc.rgb[1], pc.rgb[2], pc.rgb[3])
                love.graphics.rectangle("fill", sx, cy, CSW, CSW)
                sx = sx + CSW
            end

            -- Color names
            local nameParts = {}
            for _, pc in ipairs(palette) do nameParts[#nameParts + 1] = pc.name end
            love.graphics.setFont(fontSm)
            love.graphics.setColor(0.45, 0.45, 0.50)
            love.graphics.print(table.concat(nameParts, "  ·  "), px + 34, cy + CSW + 2)
        end

        cy = cy + ROW_H
    end

    love.graphics.setScissor()
end
