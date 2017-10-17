local Tools = {
  'GOAL', 'BUILDING', 'SPAWN'
}

local Ed = {
  currentTool = 1,
  selectedEntity = nil,
  draggingEntity = nil,
  currentWave = 1,
  currentEnemyType = '',
  help = true,
  lastRemoved = {
    valid = false,
    entity,
    collection
  },
  waveEnemyKeys = {},
  readingValue = '',
  reading = false,
  readingWaves = false,
  readingEnemyType = false,
  readingEnemyNumbers = false,
  readingEnemyCooldown = false
}

local File = nil

local Level = {
  goals = {},
  spawns = {},
  buildings = {},
  waves = 3
}

local charS, charE = '  ', '\n'

local function printHelp()
  love.graphics.setColor(0, 0, 0, 255)

  -- Global HELP
  if not Ed.reading and not Ed.editingWave then
    love.graphics.print('Press \'SPACE\' to change CURRENT TOOL', 20, 558)
    love.graphics.print('Press \'W\' to change NUMBER OF WAVES for this level', 20, 578)
    -- Exceptional HELP while setting up number of waves
  elseif Ed.readingWaves then
    love.graphics.print('Type in number of waves for this level (integer)...', 20, 518)
  end
  if not Ed.selectedEntity then
    love.graphics.print('Press \'CTRL + S\' to SAVE to file', 870, 518)
    love.graphics.print('Press \'CTRL + Z\' to RESTORE LAST REMOVED entity (only one)', 685, 538)
  end

  -- Help for GOAL TOOL
  if Tools[Ed.currentTool] == 'GOAL' and not Ed.reading then
    love.graphics.print('\'LEFT CLICK\' to create or select a GOAL', 20, 518)
    love.graphics.print('\'RIGHT CLICK\' to remove a GOAL', 20, 538)
  end

  -- Help for BUILDING TOOL
  if Tools[Ed.currentTool] == 'BUILDING' and not Ed.reading then
    love.graphics.print('\'LEFT CLICK\' to create or select a BUILDING', 20, 518)
    love.graphics.print('\'RIGHT CLICK\' to remove a BUILDING', 20, 538)
  end

  -- Help for SPAWN TOOL...
  if Tools[Ed.currentTool] == 'SPAWN' then
    -- If have entity selected
    if Ed.selectedEntity then
      -- If reading values from keyboard
      if Ed.reading then
        if Ed.readingEnemyType then
          love.graphics.print('Type a custom enemy type (string)...', 20, 518)
        elseif Ed.readingEnemyNumbers then
          love.graphics.print('Type in number of enemies for this wave (integer)...', 20, 518)
        elseif Ed.readingEnemyCooldown then
          love.graphics.print('Type in interval of time between spawns (in seconds, float)...', 20, 518)
        end
        -- If editing wave
      elseif Ed.editingWave then
        love.graphics.print('Press \'ESC\' to CANCEL', 20, 518)
        love.graphics.print('Press \'RETURN\' to begin EDIT ENEMY params', 20, 538)
        love.graphics.print('Press \'DELETE\' to REMOVE CURRENT selected enemy', 20, 558)
        love.graphics.print('Press \'N\' to CHANGE CURRENT selected enemy', 20, 578)
      else
        love.graphics.print('Press \'A\' to ADD ENEMY TO WAVE', 20, 518)
        love.graphics.print('Press \'N\' to change CURRENT WAVE', 20, 538)
      end
    else
      love.graphics.print('\'LEFT CLICK\' to create or select a SPAWN', 20, 518)
      love.graphics.print('\'RIGHT CLICK\' to remove a SPAWN', 20, 538)
    end
  end
  love.graphics.setColor(255, 255, 255, 255)
end

local function saveToFile(file, table, indent)
  local indentation = ''
  for i = 1, indent do indentation = indentation .. charS end

  for k, v in pairs(table) do
    file:write(charS)
    if type(v) == 'table' then
      file:write(indentation)
      if type(k) ~= 'number' then
        file:write(k .. ' = ')
      end
      file:write('{' .. charE)
      saveToFile(file, v, indent + 1)
      file:write(indentation .. charS .. '},')
    else
      if type(k) ~= 'number' then
        file:write(indentation .. k .. ' = ')
      end
      file:write(v .. ',')
    end
    file:write(charE)
  end
end

local function nextTool()
  Ed.currentTool = Ed.currentTool + 1 > #Tools and 1 or Ed.currentTool + 1
end

function love.load()
  Ed.map = love.graphics.newImage('/res/test.png')
end

function love.update(dt)
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(Ed.map, 0, 0)

  -- ENTITIES
  love.graphics.setColor(0, 0, 255, 255)
  for _, goal in ipairs(Level.goals) do
    if goal ~= Ed.draggingEntity then
      if goal == Ed.selectedEntity then
        love.graphics.setColor(255, 0, 255, 255)
        love.graphics.setLineWidth(3)
        love.graphics.circle('line', goal.x, goal.y, 26)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(0, 0, 255, 255)
      end
      love.graphics.circle('fill', goal.x, goal.y, 25 )
    end
  end
  love.graphics.setColor(0, 255, 0, 255)
  for _, building in ipairs(Level.buildings) do
    if building ~= Ed.draggingEntity then
      if building == Ed.selectedEntity then
        love.graphics.setColor(255, 0, 255, 255)
        love.graphics.setLineWidth(3)
        love.graphics.circle('line', building.x, building.y, 26)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(0, 255, 0, 255)
      end
      love.graphics.circle('fill', building.x, building.y, 25 )
    end
  end
  love.graphics.setColor(255, 0, 0, 255)
  for _, spawn in ipairs(Level.spawns) do
    if spawn ~= Ed.draggingEntity then
      if spawn == Ed.selectedEntity then
        love.graphics.setColor(255, 0, 255, 255)
        love.graphics.setLineWidth(3)
        love.graphics.circle('line', spawn.x, spawn.y, 26)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255, 0, 0, 255)
      end
      love.graphics.circle('fill', spawn.x, spawn.y, 25 )
    end
  end
  -- ENTITIES END

  -- DRAGGED ENTITY
  if Ed.draggingEntity then
    love.graphics.setColor(255, 255, 0, 160)
    local x, y = love.mouse.getPosition()
    love.graphics.circle('fill', x, y, 25 )
  end
  -- DRAGGED ENTITY END

  -- EDITOR SETTINGSor diselect
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.print('SlectedTool = ' .. Tools[Ed.currentTool], 20, 20)
  love.graphics.print('#Waves = ' .. Level.waves, 20, 40)
  -- EDITOR SETTINGS END

  -- SPAWN OPTIONS
  if Tools[Ed.currentTool] == 'SPAWN' and Ed.selectedEntity then
    do
      local x = Ed.selectedEntity.x < love.graphics.getWidth() / 2 and love.graphics.getWidth() - 320 or 20
      local y = Ed.selectedEntity.y < love.graphics.getHeight() / 2 and love.graphics.getHeight() - 220 or 20
      love.graphics.setColor(130, 130, 130, 200)
      love.graphics.rectangle('fill', x, y, 300, 200)

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.print('CurrentWave = ' .. Ed.currentWave, x + 10, y + 10)
      local isWaveActive = Ed.selectedEntity.waves[Ed.currentWave] and 'YES' or 'NO'
      love.graphics.print('Is active = ' .. isWaveActive, x + 150, y + 10)

      love.graphics.print('EnemyType', x + 10, y + 30)
      love.graphics.print('Numbers', x + 110, y + 30)
      love.graphics.print('Cooldown', x + 210, y + 30)

      -- Print enemy types
      if Ed.selectedEntity.waves[Ed.currentWave] ~= 0 then
        local i = 1
        for enemy, params in pairs(Ed.selectedEntity.waves[Ed.currentWave]) do
          love.graphics.print(enemy, x + 10, y + 30 + 20 * i)
          love.graphics.print(params.number, x + 110, y + 30 + 20 * i)
          love.graphics.print(params.cooldown, x + 210, y + 30 + 20 * i)
          if enemy == Ed.waveEnemyKeys[Ed.currentEnemyIndex] then
            love.graphics.line(x + 280, y + 30 + 20 * i + 6, x + 290, y + 30 + 20 * i + 6)
          end
          i = i + 1
        end
        love.graphics.print('#EnemyTypes = ' .. i - 1, x + 10, y + 30 + 20 * i)
      end
    end
  end
  -- SPAWN OPTIONS END

  -- HELP DIALOG
  if Ed.help then
    love.graphics.setColor(130, 130, 130, 130)
    love.graphics.rectangle('fill', 0, 508, 1080, 100)
    printHelp()
  end
  -- HELP DIALOG END

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

-- MOUSEPRESSED
function love.mousepressed(x, y, button, isTouch)
  if Ed.reading or Ed.editingWave then
    return
  end

  if Ed.selectedEntity and (x - Ed.selectedEntity.x)^2 + (y - Ed.selectedEntity.y)^2 > 25^2 then
    Ed.selectedEntity = nil
    return
  end

  Ed.selectedEntity = nil

  local entities = Tools[Ed.currentTool] == 'GOAL' and Level.goals or
  Tools[Ed.currentTool] == 'BUILDING' and Level.buildings or
  Tools[Ed.currentTool] == 'SPAWN' and Level.spawns or nil

  if not entities then return end

  for i, e in ipairs(entities) do
    if (x - e.x)^2 + (y - e.y)^2 < 25^2 then
      if button == 1 then
        Ed.draggingEntity = e
        return
      else
        Ed.lastRemoved.entity = e
        Ed.lastRemoved.collection = entities
        Ed.lastRemoved.valid = true
        table.remove(entities, i)
        return
      end
    end
  end
  if button == 1 then
    local newEntity = {x = x, y = y}
    if Tools[Ed.currentTool] == 'SPAWN' then
      newEntity.waves = {}
      for i = 1, Level.waves do
        newEntity.waves[i] = 0
      end
    end
    table.insert(entities, newEntity)
  end
end
-- MOUSEPRESSED END


-- MOUSERELEASED
function love.mousereleased(x, y, button, isTouch)
  if Ed.draggingEntity then
    local e = Ed.draggingEntity
    if math.abs(x - e.x) > 25 or math.abs(y - e.y) > 25 then
      e.x, e.y = x, y
    end
    Ed.selectedEntity = e
    Ed.draggingEntity = nil
  end
end
-- MOUSERELEASED END


-- KEYPRESSED
function love.keypressed(key, scancode, isrepeat)
  if Ed.reading then
    if key == 'return' then
      if #Ed.readingValue == 0 then return end
      Ed.reading = false
      if Ed.readingWaves then
        local number = tonumber(Ed.readingValue)
        if number then
          Level.waves = number
          Ed.currentWave = 1
          -- Update waves of every spawnpoint to adjust to new number of waves
          for _, spawn in ipairs(Level.spawns) do
            local waves = {}
            for i = 1, Level.waves do
              if spawn.waves[i] == nil then
                spawn.waves[i] = 0
              end
              table.insert(waves, spawn.waves[i])
            end
            spawn.waves = waves
          end
        end
        Ed.readingWaves = false
      elseif Ed.readingEnemyType then
        local enemyType = Ed.readingValue .. ''
        if Ed.selectedEntity.waves[Ed.currentWave] == 0 then
          Ed.selectedEntity.waves[Ed.currentWave] = {}
        end
        Ed.selectedEntity.waves[Ed.currentWave][enemyType] = { number = 0, cooldown = 0}
        Ed.currentEnemyType = enemyType
        Ed.reading = true
        Ed.readingEnemyType = false
        Ed.readingEnemyNumbers = true
      elseif Ed.readingEnemyNumbers then
        local number = tonumber(Ed.readingValue)
        Ed.selectedEntity.waves[Ed.currentWave][Ed.currentEnemyType].number = number or 0
        Ed.reading = true
        Ed.readingEnemyNumbers = false
        Ed.readingEnemyCooldown = true
      elseif Ed.readingEnemyCooldown then
        local number = tonumber(Ed.readingValue)
        Ed.selectedEntity.waves[Ed.currentWave][Ed.currentEnemyType].cooldown = number or 0
        Ed.readingEnemyCooldown = false
      end
      Ed.readingValue = ''
      return
    end

    if key == 'backspace' then
      Ed.readingValue = string.sub(Ed.readingValue, 1, #Ed.readingValue - 1)
      return
    end

    if key == 'space' then
      Ed.readingValue = Ed.readingValue .. ' '
      return
    end

    if #key ~= 1 then return end

    Ed.readingValue = Ed.readingValue .. key
    return
  end

  if key == 'escape' then
    Ed.selectedEntity = nil
    Ed.currentEnemyIndex = 0
  end

  if (key == 'z' or key == 'z') and love.keyboard.isDown('lctrl') and Ed.lastRemoved.valid then
    table.insert(Ed.lastRemoved.collection, Ed.lastRemoved.entity)
    Ed.lastRemoved.valid = false
  end

  if key == 'space' and not Ed.editingWave then
    nextTool()
    Ed.selectedEntity = nil
    if Ed.editingWave then
      Ed.editingWave = false
      Ed.currentEnemyIndex = 0
    end
    return
  end

  if (key == 'w' or key == 'W') and not Ed.selectedEntity then
    Ed.readingWaves = true
    Ed.reading = true
    return
  end

  if Tools[Ed.currentTool] == 'SPAWN' and Ed.selectedEntity then
    if Ed.editingWave then

      if key == 'escape' then
        Ed.editingWave = false
        Ed.currentEnemyIndex = 0
      end

      if key == 'return' then
        if Ed.selectedEntity.waves[Ed.currentWave][Ed.waveEnemyKeys[Ed.currentEnemyIndex]] then
          Ed.currentEnemyType = Ed.waveEnemyKeys[Ed.currentEnemyIndex]
          Ed.reading = true
          Ed.readingEnemyNumbers = true
          Ed.editingWave = false
          Ed.currentEnemyIndex = 0
        end
      end

      if key == 'n' or key == 'N' then
        Ed.currentEnemyIndex = Ed.currentEnemyIndex + 1 > #Ed.waveEnemyKeys and 1 or Ed.currentEnemyIndex + 1
      end

      if key == 'delete' then
        Ed.selectedEntity.waves[Ed.currentWave][Ed.waveEnemyKeys[Ed.currentEnemyIndex]] = nil
        Ed.editingWave = false
        Ed.currentEnemyIndex = 0
      end

      return
    end

    if key == 'n' or key == 'N' then
      Ed.currentWave = Ed.currentWave + 1 > Level.waves and 1 or Ed.currentWave + 1
    end

    if key == 'a' or key == 'A' then
      Ed.readingEnemyType = true
      Ed.reading = true
    end

    if key == 'e' or key == 'E' then
      if Ed.selectedEntity.waves[Ed.currentWave] ~= 0 then
        Ed.waveEnemyKeys = {}
        for k, _ in pairs(Ed.selectedEntity.waves[Ed.currentWave]) do
          table.insert(Ed.waveEnemyKeys, k)
        end
        if #Ed.waveEnemyKeys > 0 then
          Ed.editingWave = true
          Ed.currentEnemyIndex = 1
        end
      end
    end

    return
  end

  if key == 'h' or key == 'H' then
    Ed.help = not Ed.help
  end

  if not Ed.selectedEntity then
    if (key == 's' or key == 'S') and love.keyboard.isDown('lctrl') then
      File = io.open('res/result.lua', 'w')
      if File then
        File:write('return {' .. charE)
        saveToFile(File, Level, 0)
        File:write('}')
        File:close()
      end
      return
    end
  end
end
-- KEYPRESSED END
