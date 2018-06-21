
local MouseHandler = {
}

local Ed, Lvl, Tools

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- Private Functions
local function handleLeftButton(mouse, entities, tool)
  if not entities then return end

  if mouse.pressed then
    if Ed.selectedEntity and not Utils.isInside(mouse.x, mouse.y, Ed.selectedEntity) then
      Ed.selectedEntity = nil
      return
    end

    Ed.selectedEntity = nil

    for i, e in ipairs(entities) do
      if Utils.isInside(mouse.x, mouse.y, e) then
        Ed.draggingEntity = e
        return
      end
    end
    -- If empty spot then create new entity
    local entity = {x = mouse.x, y = mouse.y}
    if tool == 'SPAWN_POINT' then
      entity.waves = {}
      for i = 1, Lvl.waves do
        entity.waves[i] = 0
      end
    end
    table.insert(entities, entity)
  else -- released
    if Ed.draggingEntity then
      local x, y = love.mouse.getPosition()
      if not Utils.isOverlaping(x, y, Ed.draggingEntity) then
        Ed.draggingEntity.x, Ed.draggingEntity.y = x, y
      end
      Ed.selectedEntity = Ed.draggingEntity
      Ed.draggingEntity = nil
    end
  end
end

local function handleRightButton(mouse, entities)
  if not mouse.pressed and entities then -- released
    if Ed.selectedEntity and Utils.isInside(mouse.x, mouse.y, Ed.selectedEntity) then
      Ed.selectedEntity = false
      return
    end
    for i, e in ipairs(entities) do
      if Utils.isInside(mouse.x, mouse.y, e) then
        local lr = Ed.lastRemoved
        lr.entity, lr.collection, lr.valid = e, entities, true
        table.remove(entities, i)
      end
    end
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Public Functions
function MouseHandler.init(editor, level, toolset)
  Ed, Lvl, Tools = editor, level, toolset
end

--------------------------------------------------------------------------------

function MouseHandler.update(mouse, button, tool)
  local entities = tool == 'GATE' and Lvl.gates or
  tool == 'BUILDING_POINT' and Lvl.buildingPoints or
  tool == 'SPAWN_POINT' and Lvl.spawnPoints or nil

  if button == 1 then
    handleLeftButton(mouse, entities, tool)
  else -- 2
    handleRightButton(mouse, entities)
  end
end
-- Public Functions END

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return MouseHandler
