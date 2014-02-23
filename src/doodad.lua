require 'vendor/AnAL'

local doodad = {}

function doodad.init()
  -- source spritesheets and create anims
  doodad.destsheet = love.graphics.newImage( "art/doodads/dest.png" )
  doodad.destanim = newAnimation( doodad.destsheet, 64, 64, 0.5, 4 )

  -- gather all anims into one table
  doodad.anims = {}
  table.insert( doodad.anims, destanim )
end

return doodad
