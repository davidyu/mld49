-- libs
local gui = require 'vendor/Quickie'
local gamestate = require 'vendor/hump/gamestate'

-- other states
local game = require 'game'

local menu = {}
menu.changename = {}
menu.controls = {}
local fonts = {}

function menu:init()
  fonts = {
    ["title"] = love.graphics.newFont( "art/fonts/typeone.ttf", 60 );
    ["button"] = love.graphics.newFont( "art/fonts/BebasNeue.otf", 15 )
  }
end

function menu:update( dt )
  gui.group.push{ grow = "down", pos = { 250, 350 } }
  love.graphics.setFont( fonts["button"] )
  if gui.Button{ text = "PLAY" } then
    gamestate.switch( game )
  end
  gui.Button{ text = " CHANGE NAME " }
  gui.group.pop{}
end

function menu:enter()
end

function menu:draw()
  -- title
  love.graphics.setFont( fonts["title"] )
  love.graphics.print( "AUTOMATON", 150, 250 )
  gui.core.draw()
end

return menu
