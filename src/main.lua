local gamestate = require 'vendor/hump/gamestate'

-- gamestates
local menu = require 'menu'
local game = require 'game'
local credits = {}

function love.load()
  if love.window ~= nil then
    love.window.setMode( 640, 640 )
  else
    love.graphics.setMode( 640, 640 )
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
