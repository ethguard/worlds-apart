-- Infinite floating canvas inspired by sarodscommits/hyprland-infinitie-desktop-v2.
-- Runs entirely in Hyprland: no input-device permissions or polling subprocesses.
-- Offline verification has no monitor; skip runtime setup in that process.
if not hl.get_active_monitor() then return {} end
local canvas = {}
local statePath = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/teigu-canvas-"
    .. (os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or "session") .. ".lua"
local ok, restored = pcall(dofile, statePath)
local states = ok and type(restored) == "table" and restored or {}
local panning, pointerLast = false, nil
local timer
local panRules, activePanRule = {}, nil

local function serialize(value)
    if type(value) == "table" then
        local fields = {}
        for k, v in pairs(value) do
            fields[#fields + 1] = "[" .. serialize(k) .. "]=" .. serialize(v)
        end
        return "{" .. table.concat(fields, ",") .. "}"
    elseif type(value) == "string" then
        return string.format("%q", value)
    elseif type(value) == "number" or type(value) == "boolean" then
        return tostring(value)
    end
    return "nil"
end

local function save()
    local f = io.open(statePath .. ".tmp", "w")
    if not f then return end
    f:write("return " .. serialize(states) .. "\n")
    f:close()
    os.rename(statePath .. ".tmp", statePath)
end

local function activeWorkspace()
    local special = hl.get_active_special_workspace()
    return special or hl.get_active_workspace()
end

local function workspaceId(id)
    local ws = activeWorkspace()
    return id or (ws and ws.id)
end

local function windows(id)
    local result = {}
    for _, w in ipairs(hl.get_windows()) do
        if w.mapped and not w.hidden and not w.pinned and w.workspace and w.workspace.id == id then
            result[#result + 1] = w
        end
    end
    return result
end

local function selector(w) return "address:" .. w.address end
local function xy(v) return v.x or v[1], v.y or v[2] end
local function move(w, x, y)
    hl.dispatch(hl.dsp.window.move({ window = selector(w), x = math.floor(x), y = math.floor(y), relative = false }))
end
local function resize(w, width, height)
    hl.dispatch(hl.dsp.window.resize({ window = selector(w), x = math.max(80, math.floor(width)), y = math.max(60, math.floor(height)), relative = false }))
end
local function snapshot(w)
    local x, y = xy(w.at)
    local width, height = xy(w.size)
    return { x = x, y = y, width = width, height = height, floating = w.floating,
             fullscreen = w.fullscreen, fullscreenClient = w.fullscreen_client, identity = tostring(w.stable_id) }
end

local function center()
    local m = hl.get_active_monitor()
    return m.x + m.width / m.scale / 2, m.y + m.height / m.scale / 2
end

local function stopPanning()
    if activePanRule then
        activePanRule:set_enabled(false)
        activePanRule = nil
    end
    panning, pointerLast = false, nil
end

function canvas.enabled(id)
    id = workspaceId(id)
    return id ~= nil and states[id] ~= nil
end

local function refreshTimer()
    stopPanning()
    if timer then timer:set_enabled(canvas.enabled()) end
end

function canvas.toggle(id, quiet)
    id = workspaceId(id)
    if not id then return end
    stopPanning()
    local list = windows(id)
    local state = states[id]
    if state then
        states[id] = nil
        -- Retile original tiled windows; preserve original floating dialogs and geometry.
        for _, w in ipairs(list) do
            local old = state[w.address]
            if old and old.identity == tostring(w.stable_id) then
                hl.dispatch(hl.dsp.window.fullscreen_state({ window = selector(w), internal = 0, client = 0 }))
                hl.dispatch(hl.dsp.window.float({ window = selector(w), action = old.floating and "set" or "unset" }))
                if old.floating then
                    resize(w, old.width, old.height)
                    move(w, old.x, old.y)
                end
                if old.fullscreen and old.fullscreen > 0 then
                    hl.dispatch(hl.dsp.window.fullscreen_state({ window = selector(w), internal = old.fullscreen, client = old.fullscreenClient or old.fullscreen }))
                end
            end
        end
    else
        state = { __zoom = 1 }
        states[id] = state
        for _, w in ipairs(list) do state[w.address] = snapshot(w) end
        for _, w in ipairs(list) do
            local old = state[w.address]
            hl.dispatch(hl.dsp.window.fullscreen_state({ window = selector(w), internal = 0, client = 0 }))
            hl.dispatch(hl.dsp.window.float({ window = selector(w), action = "set" }))
            if old.floating then
                resize(w, old.width, old.height)
                move(w, old.x, old.y)
            else
                local m = hl.get_active_monitor()
                local cx, cy = center()
                local width = math.min(old.width, 900, m.width / m.scale * 0.48)
                local height = math.min(old.height, 600, m.height / m.scale * 0.56)
                -- Smaller windows with more breathing room, centered around the viewport.
                local x = cx + (old.x + old.width / 2 - cx) * 1.3 - width / 2
                local y = cy + (old.y + old.height / 2 - cy) * 1.3 - height / 2
                resize(w, width, height)
                move(w, x, y)
            end
        end
    end
    save()
    refreshTimer()
    if not quiet then
        hl.exec_cmd(canvas.enabled(id)
            and "notify-send 'Infinite desktop on' 'Hold Super+Alt and move the mouse to pan. Super+arrows navigates. Super+Shift+3 returns to tiling.'"
            or "notify-send 'Infinite desktop off' 'Normal tiling restored on this workspace.'")
    end
end

function canvas.pan(dx, dy, id)
    id = workspaceId(id)
    if not canvas.enabled(id) then return end
    for _, w in ipairs(windows(id)) do
        if w.floating and w.fullscreen == 0 then
            local x, y = xy(w.at)
            move(w, x + dx, y + dy)
        end
    end
end

function canvas.zoom(factor, id)
    id = workspaceId(id)
    if not canvas.enabled(id) then return end
    local state = states[id]
    local previous = state.__zoom or 1
    local nextZoom = math.max(0.1, math.min(1.8, previous * factor))
    factor = nextZoom / previous
    if math.abs(factor - 1) < 0.001 then return end
    local cx, cy = center()
    for _, w in ipairs(windows(id)) do
        if w.floating and w.fullscreen == 0 then
            local x, y = xy(w.at)
            local width, height = xy(w.size)
            local nextWidth, nextHeight = math.max(80, width * factor), math.max(60, height * factor)
            local nx = cx + (x + width / 2 - cx) * factor - nextWidth / 2
            local ny = cy + (y + height / 2 - cy) * factor - nextHeight / 2
            resize(w, nextWidth, nextHeight)
            move(w, nx, ny)
        end
    end
    state.__zoom = nextZoom
    save()
end

function canvas.resetZoom()
    local id = workspaceId()
    if canvas.enabled(id) then canvas.zoom(1 / (states[id].__zoom or 1), id) end
end

local vectors = { left = {-1, 0}, right = {1, 0}, up = {0, -1}, down = {0, 1} }
function canvas.navigate(direction)
    if not canvas.enabled() then
        hl.dispatch(hl.dsp.focus({ direction = direction }))
        return
    end
    local focused = hl.get_active_window()
    local cx, cy = center()
    local fx, fy = cx, cy
    if focused then
        local x, y = xy(focused.at)
        local width, height = xy(focused.size)
        fx, fy = x + width / 2, y + height / 2
    end
    local v = vectors[direction]
    local best, score
    for _, w in ipairs(windows(workspaceId())) do
        if w.floating and (not focused or w.address ~= focused.address) then
            local x, y = xy(w.at)
            local width, height = xy(w.size)
            local dx, dy = x + width / 2 - fx, y + height / 2 - fy
            local forward, sideways = dx * v[1] + dy * v[2], math.abs(dx * v[2] - dy * v[1])
            local candidate = forward + sideways * 2
            if forward > 1 and (not score or candidate < score) then best, score = w, candidate end
        end
    end
    if best then
        local x, y = xy(best.at)
        local width, height = xy(best.size)
        canvas.pan(cx - x - width / 2, cy - y - height / 2)
        hl.dispatch(hl.dsp.focus({ window = selector(best) }))
    end
end

function canvas.moveWindow(direction)
    if not canvas.enabled() then
        hl.dispatch(hl.dsp.window.move({ direction = direction }))
        return
    end
    local w = hl.get_active_window()
    if not w or not w.floating then return end
    local v = vectors[direction]
    local x, y = xy(w.at)
    move(w, x + v[1] * 90, y + v[2] * 90)
end

function canvas.resizeWindow(direction)
    local w = hl.get_active_window()
    if not canvas.enabled() or not w or not w.floating then return end
    local v = vectors[direction]
    local width, height = xy(w.size)
    resize(w, width + v[1] * 60, height + v[2] * 60)
end

-- Native key state and cursor coordinates provide unlimited panning without evdev.
-- Keep the hardware cursor free; warp only at the screen edge for unlimited travel.
timer = hl.timer(function()
    if not canvas.enabled() then refreshTimer(); return end
    local held = (hl.is_key_down("Super_L") or hl.is_key_down("Super_R"))
        and (hl.is_key_down("Alt_L") or hl.is_key_down("Alt_R"))
    if not held then stopPanning(); return end
    local cursor = hl.get_cursor_pos()
    if not cursor then return end
    if not panning then
        pointerLast = {x = cursor.x, y = cursor.y}
        local id = workspaceId()
        if not panRules[id] then
            panRules[id] = hl.window_rule({
                name = "teigu-canvas-pan-" .. tostring(id),
                match = { workspace = tostring(id), float = true },
                no_anim = true,
                enabled = false,
            })
        end
        activePanRule = panRules[id]
        activePanRule:set_enabled(true)
        hl.exec_scheduled_prop_refresh_immediately()
        panning = true
    else
        local dx, dy = cursor.x - pointerLast.x, cursor.y - pointerLast.y
        if dx ~= 0 or dy ~= 0 then canvas.pan(dx, dy) end
    end
    pointerLast = {x = cursor.x, y = cursor.y}
    local m = hl.get_active_monitor()
    local right, bottom = m.x + m.width / m.scale, m.y + m.height / m.scale
    if cursor.x < m.x + 24 or cursor.x > right - 24
        or cursor.y < m.y + 24 or cursor.y > bottom - 24 then
        local cx, cy = center()
        hl.dispatch(hl.dsp.cursor.move({ x = cx, y = cy }))
        pointerLast = {x = cx, y = cy}
    end
-- Sample faster than the 280 Hz display; movement rules bypass animation trailing.
end, { timeout = 3, type = "repeat" })
refreshTimer()

hl.on("config.unload", stopPanning)
hl.on("workspace.active", refreshTimer)
hl.on("workspace.special_active", refreshTimer)
hl.on("monitor.focused", refreshTimer)
hl.on("window.open", function(w)
    if not w or not w.workspace or not canvas.enabled(w.workspace.id) then return end
    local address, id = w.address, w.workspace.id
    hl.timer(function()
        if not states[id] then return end
        for _, candidate in ipairs(windows(id)) do
            if candidate.address == address then
                states[id][address] = snapshot(candidate)
                hl.dispatch(hl.dsp.window.fullscreen_state({window = selector(candidate), internal = 0, client = 0}))
                hl.dispatch(hl.dsp.window.float({window = selector(candidate), action = "set"}))
                local cx, cy = center()
                local m = hl.get_active_monitor()
                local width, height = xy(candidate.size)
                local zoom = states[id].__zoom or 1
                width = math.min(width, 900, m.width / m.scale * 0.48) * zoom
                height = math.min(height, 600, m.height / m.scale * 0.56) * zoom
                resize(candidate, width, height)
                move(candidate, cx - width / 2, cy - height / 2)
                save()
                break
            end
        end
    end, { timeout = 50, type = "oneshot" })
end)

-- Replace only the workspace-3 move shortcut requested for the canvas toggle.
hl.unbind("SUPER + SHIFT + 3")
hl.bind("SUPER + SHIFT + 3", function() canvas.toggle() end, { description = "Toggle infinite desktop" })
hl.bind("SUPER + CTRL + SHIFT + 3", hl.dsp.window.move({workspace = 3}), { description = "Move window to workspace 3" })
for direction, vector in pairs(vectors) do
    local d, v = direction, vector
    hl.unbind("SUPER + " .. d)
    hl.bind("SUPER + " .. d, function() canvas.navigate(d) end)
    hl.bind("SUPER + SHIFT + " .. d, function() canvas.moveWindow(d) end, { repeating = true })
    hl.bind("SUPER + CTRL + " .. d, function() canvas.resizeWindow(d) end, { repeating = true })
    hl.bind("SUPER + ALT + " .. d, function() canvas.pan(-v[1] * 220, -v[2] * 220) end, { repeating = true })
end
hl.bind("SUPER + ALT + mouse_up", function() canvas.zoom(1.12) end, { description = "Zoom canvas in" })
hl.bind("SUPER + ALT + mouse_down", function() canvas.zoom(1 / 1.12) end, { description = "Zoom canvas out" })
hl.bind("SUPER + ALT + 0", function() canvas.resetZoom() end, { description = "Reset canvas zoom" })
return canvas
