
local InputHandler = {
}

local Ed, Lvl, Tools

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Private Functions
local function handleReading(key, item)
  if key == 'escape' then
    Ed.reading = false
  end

  if key == 'backspace' then
    Ed.readingValue = string.sub(Ed.readingValue, 1, #Ed.readingValue - 1)
    return
  end

  if key == 'space' then
    Ed.readingValue = Ed.readingValue .. ' '
    return
  end

  if key == 'return' then
    if #Ed.readingValue == 0 then
      return
    end

    Ed.reading = false
    local toNumber = item ~= 'enemy_type' and true or false
    local value = toNumber and tonumber(Ed.readingValue) or Ed.readingValue

    if item == 'waves' then
      Lvl.waves = value
      Ed.currentWave = 1
      Utils.updateSpawnpointWaves(Lvl.spawnPoints, Lvl.waves)
    elseif item == 'enemy_type' then
      if Ed.selectedEntity.waves[Ed.currentWave] == 0 then
        Ed.selectedEntity.waves[Ed.currentWave] = {}
      end
      Ed.selectedEntity.waves[Ed.currentWave][value] = { number = 0, cooldown = 0}
      Ed.currentEnemyType = value
      Ed.readingEnemyType = y
      Ed.reading, Ed.readingEnemyNumbers = true, true
    elseif item == 'enemy_numbers' then
      Ed.selectedEntity.waves[Ed.currentWave][Ed.currentEnemyType].number = value or 0
      Ed.readingEnemyNumbers = false
      Ed.reading, Ed.readingEnemyCooldown = true, true
    elseif item == 'enemy_cooldown' then
      Ed.selectedEntity.waves[Ed.currentWave][Ed.currentEnemyType].cooldown = value or 0
      Ed.readingEnemyCooldown = false
    end
    Ed.readingValue = ''
    return
  end

  if #key ~= 1 then return end

  Ed.readingValue = Ed.readingValue .. key
end

--------------------------------------------------------------------------------

local function handleSpawnOptions(key)

  if key == 'n' or key == 'N' then
    Ed.currentWave = Utils.nextIndex(Ed.currentWave, Lvl.waves, 1)
  end

  if key == 'a' or key == 'A' then
    Ed.readingEnemyType = true
    Ed.reading = true
  end

  if key == 'e' or key == 'E' then
    if Ed.selectedEntity.waves[Ed.currentWave] ~= 0 then
      Utils.clearTableIPairs(Ed.waveEnemyKeys)
      for k, _ in pairs(Ed.selectedEntity.waves[Ed.currentWave]) do
        table.insert(Ed.waveEnemyKeys, k)
      end
      if #Ed.waveEnemyKeys > 0 then
        Ed.editingSpawnWave = true
        Ed.currentEnemyIndex = 1
      end
    end
  end
end

--------------------------------------------------------------------------------

local function handleSpawnEdit(key)
  if key == 'escape' then
    Ed.editingSpawnWave = false
    Ed.currentEnemyIndex = 0
  end

  if key == 'return' then
    -- If current selected enemy exists
    if Ed.selectedEntity.waves[Ed.currentWave][Ed.waveEnemyKeys[Ed.currentEnemyIndex]] then
      Ed.currentEnemyType = Ed.waveEnemyKeys[Ed.currentEnemyIndex]
      Ed.reading = true
      Ed.readingEnemyNumbers = true
      Ed.editingSpawnWave = false
      Ed.currentEnemyIndex = 0
    end
  end

  if key == 'n' or key == 'N' then
    Ed.currentEnemyIndex = Utils.nextIndex(Ed.currentEnemyIndex, #Ed.waveEnemyKeys, 1)
  end

  if key == 'delete' then
    Ed.selectedEntity.waves[Ed.currentWave][Ed.waveEnemyKeys[Ed.currentEnemyIndex]] = nil
    Ed.editingSpawnWave = false
    Ed.currentEnemyIndex = 0
  end

  return
end
-- Private Functions END

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Public Functions
function InputHandler.init(editor, level, toolset)
  Ed, Lvl, Tools = editor, level, toolset
end

--------------------------------------------------------------------------------

function InputHandler.update(key, tool, hasSelected, isEditing, reading)
  if reading then
    handleReading(key, reading)
  end

  if not hasSelected then
    if (key == 'w' or key == 'W') and not Ed.selectedEntity then
      Ed.readingWaves = true
      Ed.reading = true
      return
    end

    if (key == 'z' or key == 'z') and love.keyboard.isDown('lctrl') and Ed.lastRemoved.valid then
      table.insert(Ed.lastRemoved.collection, Ed.lastRemoved.entity)
      Ed.lastRemoved.valid = false
      return
    end

    if (key == 's' or key == 'S') and love.keyboard.isDown('lctrl') then
      File = io.open('res/result.lua', 'w')
      if File then
        File:write('return {' .. charE)
        Utils.saveToFile(File, Lvl, 0)
        File:write('}')
        File:close()
      end
      return
    end
  end

  if tool ~= 'SPAWN_POINT' or (tool == 'SPAWN_POINT' and not hasSelected) then
    if key == 'space' and not Ed.editingSpawnWave then
      Ed.currentTool = Utils.nextIndex(Ed.currentTool, #Tools, 1)
      Ed.selectedEntity = nil
      if Ed.editingSpawnWave then
        Ed.editingSpawnWave = false
        Ed.currentEnemyIndex = 0
      end
      return
    end
    return
  end

  if hasSelected then
    if key == 'escape' then
      Ed.selectedEntity = nil
      Ed.currentEnemyIndex = 0
      return
    end
  end

  if tool == 'SPAWN_POINT' then
    if hasSelected and isEditing then
      handleSpawnEdit(key)
      return
    end
    if hasSelected then
      handleSpawnOptions(key)
      return
    end
    return
  end

  if key == 'h' or key == 'H' then
    Ed.help = not Ed.help
  end
end
-- Public Functions END

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return InputHandler
