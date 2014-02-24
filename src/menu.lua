-- libs
local gui = require 'vendor/Quickie'
local gamestate = require 'vendor/hump/gamestate'

-- other states
local game = require 'game'

local menu = {}
menu.needname = false
menu.changename = {}
menu.changename.inputstr = { text = "" }
menu.controls = {}
local fonts = {}

function menu:init()

  -- grab saved name, if possible
  bot = game.getbot()
  local namefile = "automaton-mld49"
  if love.filesystem.exists( namefile ) then
    bot.name, size = love.filesystem.read( namefile )
    if size < 1 then
      menu.needname = true
    else
      menu.changename.inputstr = { text = bot.name }
      --debug
      print( "got name " .. bot.name )
    end

  else
    menu.needname = true
  end

  fonts = {
    ["title"] = love.graphics.newFont( "art/fonts/typeone.ttf", 60 );
    ["button"] = love.graphics.newFont( "art/fonts/BebasNeue.otf", 15 )
  }
end

local function savename( name )
  local namefile = "automaton-mld49"
  love.filesystem.write( namefile, name )
  bot.name = name
end

function menu.changename:enter()
  bot.init() -- we want to use bot anims
end

function menu.changename:update( dt )
  bot.anim:update( dt )
  gui.group.push{ grow = "right", pos = { 150, 300 } }
  gui.Label{ text = "please name your automaton:", size = { 150 } }
  gui.Input{ info = menu.changename.inputstr, size = { 100 } }
  if gui.Button{ text = "save" } then
    savename( menu.changename.inputstr.text )
    if menu.needname then
      gamestate.switch( game )
    else
      gamestate.switch( menu )
    end
  end
  gui.group.pop{}
end

function menu.changename:draw()
  gui.core.draw()
  bot.anim:draw( 310, 230 )
end

function menu.changename:keypressed( key, code )
  gui.keyboard.pressed( key )

  if pcall( string.char, code ) and code > 0 then
      gui.keyboard.textinput(string.char(code))
  end
end

function love.textinput(str)
    gui.keyboard.textinput(str)
end

function menu:update( dt )
  gui.group.push{ grow = "down", pos = { 250, 350 } }
  love.graphics.setFont( fonts["button"] )
  if gui.Button{ text = "PLAY" } then
    if menu.needname then
      gamestate.push( menu.changename )
    else
      gamestate.switch( game )
    end
  end
  if not menu.needname then
    if gui.Button{ text = " CHANGE NAME " } then
      gamestate.push( menu.changename )
    end
  end
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
