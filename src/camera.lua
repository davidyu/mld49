local camera = {}

camera.x = 0
camera.y = 0
camera.screenw = nil
camera.screenh = nil
camera.bounds = nil

function math.clamp(x, min, max)
  if x < min then
    return min
  elseif x > max then
    return max
  else
    return x
  end
end

function camera:init()
  self.screenw, self.screenh = love.window.getDimensions()
end

function camera:set()
  love.graphics.push()
  love.graphics.translate( -self.x, -self.y )
end

function camera.unset()
  love.graphics.pop()
end

function camera:setbounds( x1, y1, x2, y2 )
  self.bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function camera:pan( dir )
  local newx, newy = self.x, self.y

  local dp = 3
  if dir == 'left' then
    newx = self.x - dp
  elseif dir == 'right' then
    newx = self.x + dp
  elseif dir == 'up' then
    newy = self.y - dp
  elseif dir == 'down' then
    newy = self.y + dp
  end

  if self.bounds then
    self.x = math.clamp( newx, self.bounds.x1, self.bounds.x2 )
    self.y = math.clamp( newy, self.bounds.y1, self.bounds.y2 )
  else
    self.x = newx
    self.y = newy
  end
end

function camera:centerbot( bot, map )
  local newx = ( bot.x * map.tilewidth - self.screenw / 2 )
  local newy = ( bot.y * map.tileheight - self.screenh / 2 )
  if self.bounds then
    self.x = math.clamp( newx, self.bounds.x1, self.bounds.x2 )
    self.y = math.clamp( newy, self.bounds.y1, self.bounds.y2 )
  else
    self.x = newx
    self.y = newy
  end
end

return camera
