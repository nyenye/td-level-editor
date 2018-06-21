charS, charE = '  ', '\n'

local function nextIndex(current, max, min)
  return current + 1 > max and min or current + 1
end

--------------------------------------------------------------------------------

local function updateSpawnpointWaves(spawnpoints, waveNumber)
  -- Update waves of every spawnpoint to adjust to new number of waves
  for _, spawn in ipairs(spawnpoints) do
    local waves = {}
    for i = 1, waveNumber do
      if spawn.waves[i] == nil then
        spawn.waves[i] = 0
      end
      table.insert(waves, spawn.waves[i])
    end
    spawn.waves = waves
  end
end

--------------------------------------------------------------------------------

local function clearTableIPairs(t)
  for i, v in ipairs(t) do
    tab[i] = nil
  end
end

--------------------------------------------------------------------------------

local function clearTablePairs(t)
  for i, v in pairs(t) do
    tab[i] = nil
  end
end

--------------------------------------------------------------------------------

local function getReadingItem(reading, waves, e_type, e_numbers, e_cooldown)
  if reading then
    if waves then return 'waves' end

    if e_type then return 'enemy_type'
    elseif e_numbers then return 'enemy_numbers'
    elseif e_cooldown then return 'enemy_cooldown' end
  end
  return false
end

--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------

local function isInside(x, y, entity)
  if entity.w and entity.h then
    local inWidth = x >= entity.x and x <= entity.x + entity.w
    local inHeight = y >= entity.y and y <= entity.y + entity.h
    return inWidth and inHeight
  end
  return (x - entity.x)^2 + (y - entity.y)^2 < 25^2
end

--------------------------------------------------------------------------------

local function isOverlaping(x, y, entity)
  if entity.w and entity.h then
    local inWidth = math.abs(x - entity.x) < entity.w
    local inHeight = math.abs(y - entity.y) < entity.h
    return inWidth and inHeight
  end
  return math.abs(x - entity.x) < 25 and math.abs(y - entity.y) < 25
end

--------------------------------------------------------------------------------

return {
  nextIndex = nextIndex,
  updateSpawnpointWaves = updateSpawnpointWaves,
  getReadingItem = getReadingItem,
  clearTableIPairs = clearTableIPairs,
  clearTablePairs = clearTablePairs,
  saveToFile = saveToFile,
  isInside = isInside,
  isOverlaping = isOverlaping
}
