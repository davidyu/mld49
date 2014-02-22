
-- vendor libs
require 'vendor/AnAL'

-- modules
local utils = require 'utils'
local bot = require 'bot'
local cmd = require 'cmd'

-- static game data
local map

function love.load()
  love.window.setMode( 640, 640 ) -- temporary
  map = utils.buildMap( "art/levels/intro" )
  cmd.init()
  bot.init()
end

function love.keypressed( key )
  local command = cmd.toCommand( key )
  cmd.process( command )
end

function love.update( dt )
  cmd.execute( bot )
  bot.anim:update( dt )
end

function love.draw()
  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end

  -- draw bot
  bot.anim:draw( ( bot.x - 1 ) * map.tilewidth, ( bot.y - 1 ) * map.tileheight )
end
