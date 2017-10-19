local DrawHandler = {}

local Ed, Lvl, Tools

function DrawHandler.init(editor, lvl, toolset)
  Ed, Lvl, Tools = editor, lvl, toolset
end

--------------------------------------------------------------------------------

function DrawHandler.drawEntity(entity, color)
  if entity ~= Ed.draggingEntity then
    if entity == Ed.selectedEntity then
      love.graphics.setColor(255, 0, 255, 255)
      love.graphics.setLineWidth(3)
      love.graphics.circle('line', entity.x, entity.y, 26)
      love.graphics.setLineWidth(1)
      love.graphics.setColor(color.r, color.g, color.b, 255)
    end
    love.graphics.circle('fill', entity.x, entity.y, 25 )
  end
end

--------------------------------------------------------------------------------

function DrawHandler.drawSettings()
  love.graphics.setColor(130, 130, 130, 130)
  love.graphics.rectangle('fill', 10, 10, 170, 55)
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.print('SlectedTool = ' .. Tools[Ed.currentTool], 20, 20)
  love.graphics.print('#Waves = ' .. Lvl.waves, 20, 40)
end

--------------------------------------------------------------------------------

function DrawHandler.drawSpawnOptions()
  if Tools[Ed.currentTool] == 'SPAWN' and Ed.selectedEntity then
    local x = Ed.selectedEntity.x < love.graphics.getWidth() / 2 and love.graphics.getWidth() - 320 or 20
    local y = Ed.selectedEntity.y < love.graphics.getHeight() / 2 and love.graphics.getHeight() - 220 or 20
    love.graphics.setColor(200, 130, 130, 255)
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

--------------------------------------------------------------------------------

return DrawHandler
