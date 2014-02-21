
-- modules
local utils = require 'utils'

-- static game data
local map

function love.load()
  love.window.setMode( 640, 640 ) -- temporary
  map = utils.buildMap( "art/levels/intro" )
end

function love.update( dt )

end

function love.draw()
  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end
end
