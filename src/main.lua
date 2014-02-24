local gamestate = require 'vendor/hump/gamestate'

-- public gamestates
menu = require 'menu'
game = require 'game'

function love.load()
  if love.window ~= nil then
    love.window.setMode( 640, 640 )
    love.window.setTitle( "automaton" )
  else
    love.graphics.setMode( 640, 640 )
    love.graphics.setCaption( "automaton" )
  end

  gamestate.push( menu )
end

function love.keypressed( key, code )
  gamestate.keypressed( key, code )
end

function love.update( dt )
  gamestate.update( dt )
end

function love.draw()
  gamestate.draw()
end
