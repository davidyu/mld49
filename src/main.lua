-- vendor libs
require 'vendor/AnAL'

-- modules
local utils = require 'utils'
local bot = require 'bot'
local cmd = require 'cmd'
local doodad = require 'doodad'

-- static game data
local map

function love.load()
  love.window.setMode( 640, 640 ) -- temporary
  map = utils.buildMap( "art/levels/intro" )
  cmd.init()
  bot.init()
  doodad.init()
end

function love.keypressed( key )
  local command = cmd.toCommand( key )
  cmd.process( command )
end

function love.update( dt )
  cmd.execute( bot )

  -- sanitize position
  if bot.x < 1         then bot.x = 1 end
  if bot.x > map.width then bot.x = map.width end

  if bot.y < 1          then bot.y = 1 end
  if bot.y > map.height then bot.y = map.height end

  bot.anim:update( dt )
  table.foreach( doodad.anims, function( _, anim ) anim:update( dt ) end )
end

function love.draw()
  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end

  -- draw doodads
  doodad.destanim:draw( ( map.dest.x - 1 ) * map.tilewidth, ( map.dest.y - 1 ) * map.tileheight )

  -- draw bot
  bot.anim:draw( ( bot.x - 1 ) * map.tilewidth, ( bot.y - 1 ) * map.tileheight )

end
