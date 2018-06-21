local Help = {
  currentState = 1,
  hasSelected = false,
  reading = false
}

local HelpStates = {
  TOOL_GATE = 1,
  TOOL_BUILDING_POINT = 2,
  TOOL_SPAWN_POINT = 3,
  SPAWN_POINT_SELECTED = 4,
  EDITING_SPAWN_POINT = 5,
  READING = 6
}

--[[
  --- Private functions ---
]]--

local function drawControls()
  love.graphics.print('Press \'W\' to change NUMBER OF WAVES for this level', 20, 578)
  love.graphics.print('Press \'CTRL + S\' to SAVE to file', 870, 518)
  love.graphics.print('Press \'CTRL + Z\' to RESTORE LAST REMOVED entity (only one)', 685, 538)
end

local function drawTool(tool, hasSelected)
  if hasSelected then
    love.graphics.print('\'LEFT CLICK\' to drag entity ' .. tool, 20, 518)
    love.graphics.print('\'RIGHT CLICK\' to disselect entity', 20, 538)
  else
    love.graphics.print('\'LEFT CLICK\' to create or select a ' .. tool, 20, 518)
    love.graphics.print('\'RIGHT CLICK\' to remove a ' .. tool, 20, 538)
  end
  love.graphics.print('Press \'SPACE\' to change CURRENT TOOL', 20, 558)
end

local function drawSpawnSelected()
  love.graphics.print('Press \'A\' to ADD ENEMY TO WAVE', 20, 518)
  love.graphics.print('Press \'E\' to EDIT ENEMY TO WAVE', 20, 538)
  love.graphics.print('Press \'N\' to change CURRENT WAVE', 20, 558)
end

local function drawEditingSpawn()
  love.graphics.print('Press \'ESC\' to CANCEL', 20, 518)
  love.graphics.print('Press \'RETURN\' to begin EDIT ENEMY params', 20, 538)
  love.graphics.print('Press \'DELETE\' to REMOVE CURRENT selected enemy', 20, 558)
  love.graphics.print('Press \'N\' to CHANGE CURRENT selected enemy', 20, 578)
end

local function drawReading(item)
  if item == 'waves' then
    love.graphics.print('Type in number of waves for this level (integer)...', 20, 518)
  elseif item == 'enemy_type' then
    love.graphics.print('Type a custom enemy type (string)...', 20, 518)
  elseif item == 'enemy_numbers' then
    love.graphics.print('Type in number of enemies for this wave (integer)...', 20, 518)
  elseif item == 'enemy_cooldown' then
    love.graphics.print('Type in interval of time between spawns (in seconds, float)...', 20, 518)
  end
end

--[[
  --- Public functions ---
]]--

function Help:update(tool, hasSelected, isEditing, reading)
  self.hasSelected = hasSelected
  self.reading = reading

  if reading then
    self.currentState = HelpStates.READING
    return
  end

  if tool == 'GATE' then
    self.currentState = HelpStates.TOOL_GATE
  elseif tool == 'BUILDING_POINT' then
    self.currentState = HelpStates.TOOL_BUILDING_POINT
  else -- tool == 'SPAWN_POINT'
    if hasSelected and not isEditing then
      self.currentState = HelpStates.SPAWN_POINT_SELECTED
    elseif hasSelected and isEditing then
      self.currentState = HelpStates.EDITING_SPAWN_POINT
    else
      self.currentState = HelpStates.TOOL_SPAWN_POINT
    end
  end
end

function Help:draw()
  love.graphics.setColor(130, 130, 130, 130)
  love.graphics.rectangle('fill', 0, 508, 1080, 100)

  love.graphics.setColor(0, 0, 0, 255)
  if self.currentState == HelpStates.TOOL_GATE then
    drawTool('GATE', self.hasSelected)
    if not self.hasSelected then
      drawControls()
    end
    return
  end

  if self.currentState == HelpStates.TOOL_BUILDING_POINT then
    drawTool('BUILDING_POINT', self.hasSelected)
    if not self.hasSelected then
      drawControls()
    end
    return
  end

  if self.currentState == HelpStates.TOOL_SPAWN_POINT then
    drawTool('SPAWN_POINT')
    drawControls()
    return
  end

  if self.currentState == HelpStates.SPAWN_POINT_SELECTED then
    drawSpawnSelected()
    return
  end

  if self.currentState == HelpStates.EDITING_SPAWN_POINT then
    drawEditingSpawn()
    return
  end

  if self.currentState == HelpStates.READING then
    drawReading(self.reading)
    return
  end
  love.graphics.setColor(255, 255, 255, 255)
end

return Help
