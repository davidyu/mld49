-- vendor libs
require 'vendor/AnAL'

-- modules
local bot = require 'bot'
local cmd = require 'cmd'
local doodad = require 'doodad'
local flow = require 'flow'
local camera = require 'camera'

-- static game data
local map

local function resetlevel()
  map = flow.map

  bot.x = map.start.x
  bot.y = map.start.y

  camera:setbounds( 0, 0, map.tilewidth * map.width, map.tileheight * map.height )

  cmd.init()
end

function love.load()
  love.window.setMode( 640, 640 ) -- temporary

  -- init all modules
  flow.init()
  cmd.init()
  bot.init()
  doodad.init()

  resetlevel()
end

function love.keypressed( key )
  local command = cmd.toCommand( key )
  cmd.process( command )
end

-- true if won, false otherwise
local function won( bot, map )
  if bot.x == map.dest.x and bot.y == map.dest.y then
    return true
  else
    return false
  end
end

function love.update( dt )

  -- update anims
  bot.anim:update( dt )
  table.foreach( doodad.anims, function( _, anim ) anim:update( dt ) end )

  -- execute commands
  cmd.execute( bot )

  -- sanitize position
  if bot.x < 1         then bot.x = 1 end
  if bot.x > map.width then bot.x = map.width end

  if bot.y < 1          then bot.y = 1 end
  if bot.y > map.height then bot.y = map.height end

  -- update camera
  camera:update( bot, map )

  -- check for win condition
  if won( bot, map ) then
    -- play brief celebratory overlay
    flow.advance()
    resetlevel()
  end
end

function love.draw()
  camera:set()

  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end

  -- draw doodads
  if ( map.dest.x and map.dest.y ) then
    doodad.destanim:draw( ( map.dest.x - 1 ) * map.tilewidth, ( map.dest.y - 1 ) * map.tileheight )
  end

  -- draw bot
  bot.anim:draw( ( bot.x - 1 ) * map.tilewidth, ( bot.y - 1 ) * map.tileheight )

  camera:unset()
end
