
Utils = require('utils')
local Help = require('help')
local InputHandler = require('input_handler')
local MouseHandler = require('mouse_handler')
local DrawHandler = require('draw_handler')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Tools = { 'GATE', 'BUILDING_POINT', 'SPAWN_POINT' }

local Key = false
local Mouse = {{pressed = false, down = false}, {pressed = false, down = false}, lastButton = 0}

local Ed = {
  help = true,
  currentTool = 1,
  selectedEntity = nil,
  draggingEntity = nil,
  -- Spawn options
  currentWave = 1,
  currentEnemyType = '',
  -- Edit spawn
  waveEnemyKeys = {},
  editingSpawnWave = false,
  -- Ctrl-Z
  lastRemoved = {
    valid = false,
    entity,
    collection
  },
  -- Reading values
  readingValue = '',
  reading = false,
  readingWaves = false,
  readingEnemyType = false,
  readingEnemyNumbers = false,
  readingEnemyCooldown = false,
}

local File = nil

local Lvl = {
  gates = {},
  spawnPoints = {},
  buildingPoints = {},
  waves = 3
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function love.load()
  InputHandler.init(Ed, Lvl, Tools)
  DrawHandler.init(Ed, Lvl, Tools)
  MouseHandler.init(Ed, Lvl, Tools)
  Ed.map = love.graphics.newImage('/res/test.png')
end

--------------------------------------------------------------------------------

function love.update(dt)
  local tool = Tools[Ed.currentTool]
  local hasSelected = (Ed.selectedEntity or Ed.draggingEntity) and true or false
  local editing = Ed.editingSpawnWave
  local reading = Utils.getReadingItem(
    Ed.reading, Ed.readingWaves, Ed.readingEnemyType,
    Ed.readingEnemyNumbers, Ed.readingEnemyCooldown
  )

  if Key then
    InputHandler.update(Key, tool, hasSelected, editing, reading)
    Key = false
  end

  if Mouse.lastButton ~= 0 then
    if not reading and not editing then
      MouseHandler.update(Mouse[Mouse.lastButton], Mouse.lastButton, tool)
    end
    Mouse[Mouse.lastButton].pressed = false
    Mouse.lastButton = 0
  end

  Help:update(tool, hasSelected, editing, reading)
end

--------------------------------------------------------------------------------

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(Ed.map, 0, 0)

  -- ENTITIES
  local color = {r = 0, g = 0, b = 255}
  love.graphics.setColor(0, 0, 255, 255)
  for _, goal in ipairs(Lvl.gates) do
    DrawHandler.drawEntity(goal, color)
  end
  color = {r = 0, g = 255, b = 0}
  love.graphics.setColor(0, 255, 0, 255)
  for _, building in ipairs(Lvl.buildingPoints) do
    DrawHandler.drawEntity(building, color)
  end
  color = {r = 255, g = 0, b = 0}
  love.graphics.setColor(255, 0, 0, 255)
  for _, spawn in ipairs(Lvl.spawnPoints) do
    DrawHandler.drawEntity(spawn, color)
  end
  -- ENTITIES END

  -- DRAGGED ENTITY
  if Ed.draggingEntity then
    love.graphics.setColor(255, 255, 0, 160)
    local x, y = love.mouse.getPosition()
    love.graphics.circle('fill', x, y, 25 )
  end
  -- DRAGGED ENTITY END
  love.graphics.setColor(255, 255, 255, 255)

  DrawHandler.drawSettings()

  love.graphics.setColor(255, 255, 255, 255)
  DrawHandler.drawSpawnOptions()

  if Ed.help then
    Help:draw()
  end

  if Ed.reading then
    do
      love.graphics.setColor(0, 0, 0, 255)
      local x, y = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
      local w, h = 200, 40
      love.graphics.rectangle('fill', x - w / 2, y - h / 2, w, h)
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.printf(Ed.readingValue, x - w / 2, y - h / 5, w, 'center')
    end
  end

  love.graphics.setColor(255, 255, 255, 255)
end
-- DRAW END

--------------------------------------------------------------------------------

-- MOUSEPRESSED
function love.mousepressed(x, y, button, isTouch)
  Mouse[button].x, Mouse[button].y = x, y
  Mouse[button].pressed = true
  Mouse[button].down = true
  Mouse.lastButton = button

  -- if Ed.reading or Ed.editingSpawnWave then
  --   return
  -- end
  --
  -- if Ed.selectedEntity and (x - Ed.selectedEntity.x)^2 + (y - Ed.selectedEntity.y)^2 > 25^2 then
  --   Ed.selectedEntity = nil
  --   return
  -- end
  --
  -- local entities = Tools[Ed.currentTool] == 'GATE' and Lvl.gates or
  -- Tools[Ed.currentTool] == 'BUILDING_POINT' and Lvl.buildingPoints or
  -- Tools[Ed.currentTool] == 'SPAWN_POINT' and Lvl.spawnPoints or nil
  --
  -- if not entities then return end
  --
  -- for i, e in ipairs(entities) do
  --   if (x - e.x)^2 + (y - e.y)^2 < 25^2 then
  --     if button == 1 then
  --       Ed.draggingEntity = e
  --       return
  --     else
  --       -- Ed.lastRemoved.entity = e
  --       -- Ed.lastRemoved.collection = entities
  --       -- Ed.lastRemoved.valid = true
  --       -- table.remove(entities, i)
  --       -- return
  --     end
  --   end
  -- end
  -- if button == 1 then
  --   local newEntity = {x = x, y = y}
  --   if Tools[Ed.currentTool] == 'SPAWN_POINT' then
  --     newEntity.waves = {}
  --     for i = 1, Lvl.waves do
  --       newEntity.waves[i] = 0
  --     end
  --   end
  --   table.insert(entities, newEntity)
  -- end
end
-- MOUSEPRESSED END

--------------------------------------------------------------------------------

-- MOUSERELEASED
function love.mousereleased(x, y, button, isTouch)
  Mouse[button].x, Mouse[button].y = x, y
  Mouse[button].down = false
  Mouse.lastButton = button

  -- if Ed.draggingEntity then
  --   local e = Ed.draggingEntity
  --   if math.abs(x - e.x) > 25 or math.abs(y - e.y) > 25 then
  --     e.x, e.y = x, y
  --   end
  --   Ed.selectedEntity = e
  --   Ed.draggingEntity = nil
  -- end
end
-- MOUSERELEASED END

--------------------------------------------------------------------------------

-- KEYPRESSED
function love.keypressed(key, scancode, isrepeat)
  Key = key
end
-- KEYPRESSED END
