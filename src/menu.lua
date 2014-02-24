-- libs
local gui = require 'vendor/Quickie'
local gamestate = require 'vendor/hump/gamestate'

local flow = require 'flow'

-- other states
local menu = {}
menu.needname = false
menu.changename = {}
menu.changename.inputstr = { text = "" }
menu.credits = {}
local fonts = {}

function menu:init()
  flow.init()
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
      flow.reset()
      print( flow.map.name )
      gamestate.switch( game )
      gamestate.push( game.help )
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

function menu.credits:enter()
  menu.credits.overlayimg = love.graphics.newImage( "art/overlays/over.png" )
end

-- Attempts to open a given URL in the system default browser, regardless of Operating System.
-- pretty awesome snippet from Textmode at http://stackoverflow.com/a/18864453
local open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
function open_url(url)
  print( string.match( io.popen( "uname -s"):read '*a', "Darwin" ) == "Darwin" )
  if not open_cmd then
    if package.config:sub(1,1) == '\\' then -- windows
      open_cmd = function(url)
        os.execute(string.format('start "%s"', url))
      end
    -- the only systems left should understand uname...
    elseif string.find( io.popen( "uname -s"):read '*a', "Darwin" ) ~= nil then
      open_cmd = function(url)
        os.execute(string.format('open "%s"', url))
      end
    else -- that ought to only leave Linux
      open_cmd = function(url)
        -- should work on X-based distros.
        os.execute(string.format('xdg-open "%s"', url))
      end
    end
  end

  open_cmd(url)
end

function menu.credits:update( dt )
  gui.group.push{ grow = "right", pos = { 210, 350 } }
  love.graphics.setFont( fonts["button"] )
  if gui.Button{ text = "PLAY AGAIN" } then
    gamestate.switch( menu )
  end
  if gui.Button{ text = "SOURCE" } then
    open_url( "http://github.com/desktop/mld49" )
  end
  gui.group.pop{}
end

function menu.credits:draw()
  love.graphics.draw( menu.credits.overlayimg )
  gui.core.draw()
end

function menu.credits:keypressed( key, code )
  if key == ' ' or key == 'kpenter' or key == 'return' then
    gamestate.switch( menu )
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
      flow.reset()
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
