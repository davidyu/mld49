local cmd = {}

function cmd.init()
  cmd.commandq = {}
  cmd.records = {}
  cmd.repeatrate = 0
  cmd.state = 'regular'
end

function cmd.toCommand( key )
  if key == 'left' then
    return 'ml'
  elseif key == 'right' then
    return 'mr'
  elseif key == 'up' then
    return 'mu'
  elseif key == 'down' then
    return 'md'
  elseif key == 'q' then
    if cmd.state ~= 'playback-getkey' and cmd.state ~= 'record-getkey' then
      return 'rec'
    else
      return key
    end
  elseif key == '2' and ( love.keyboard.isDown( 'lshift' ) or love.keyboard.isDown( 'rshift' ) ) then
    if cmd.state ~= 'playback-getkey' and cmd.state ~= 'record-getkey' then
      return 'play'
    else
      return key
    end
  elseif key == 'h' then
    if cmd.state ~= 'playback-getkey' and cmd.state ~= 'record-getkey' then
      return 'ml'
    else
      return key
    end
  elseif key == 'l' then
    if cmd.state ~= 'playback-getkey' and cmd.state ~= 'record-getkey' then
      return 'mr'
    else
      return key
    end
  elseif key == 'k' then
    if cmd.state ~= 'playback-getkey' and cmd.state ~= 'record-getkey' then
      return 'mu'
    else
      return key
    end
  elseif key == 'j' then
    if cmd.state ~= 'playback-getkey' and cmd.state ~='record-getkey' then
      return 'md'
    else
      return key
    end
  elseif key >= '0' and key <= '9' then
    return key
  else
    return 'unknown'
  end
end

-- helper/aux functions for cmd.process (all have side effects!)
local function playback( id )
  local record = cmd.records[ id ]
  if record ~= nil then
    for _, entry in ipairs( record ) do
      table.insert( cmd.commandq, entry )
    end
  end
end

function cmd.process( command )
  if command == 'ml' or command == 'mr' or command == 'mu' or command == 'md' then
    -- also take into account record state <- save to record instead
    if cmd.repeatrate > 0 then
      for i = 1,cmd.repeatrate do
        if cmd.state == 'record' then
          table.insert( cmd.records[ cmd.rpid ], command )
        end
        table.insert( cmd.commandq, command )
      end
      cmd.repeatrate = 0
    else
      if cmd.state == 'record' then
        table.insert( cmd.records[ cmd.rpid ], command )
      end
      table.insert( cmd.commandq, command )
    end
  elseif command == 'rec' then -- starts and ends record phase
    if cmd.state == 'regular' then
      cmd.state = 'record-getkey'
    elseif cmd.state == 'record' then
      cmd.state = 'regular'
      cmd.rpid = nil
    end
  elseif command == 'play' then -- only starts playback phase
    if cmd.state == 'regular' then
      cmd.state = 'playback-getkey'
    end
  elseif command >= '0' and command <= '9' then
    if cmd.state ~= 'record-getkey' and cmd.state ~= 'playback-getkey' then
      cmd.repeatrate = cmd.repeatrate * 10 + tonumber( command )
    else
      -- gah, code duplication sucks
      cmd.rpid = command
      if cmd.state == 'record-getkey' then -- set up record buffer
        cmd.records[ cmd.rpid ] = {}
        cmd.state = 'record'
        cmd.repeatrate = 0
      elseif cmd.state == 'playback-getkey' then -- parse record buffer
        if cmd.repeatrate > 0 then
          for i = 1,cmd.repeatrate do
            playback( command )
          end
          cmd.repeatrate = 0
        else
          playback( command )
        end
        cmd.state = 'regular'
      end
    end
  else
    if cmd.state == 'record-getkey' then
      cmd.state = 'record'
      cmd.repeatrate = 0
      cmd.rpid = command
      cmd.records[ cmd.rpid ] = {}
    elseif cmd.state == 'playback-getkey' then
      -- grab results from records db and put all into commandq
      if cmd.repeatrate > 0 then
        for i = 1,cmd.repeatrate do
          playback( command )
        end
        cmd.repeatrate = 0
      else
        playback( command )
      end
      cmd.state = 'regular'
    end
  end
end

function cmd.execute( bot )
  if table.maxn( cmd.commandq ) > 0 and bot.state == 'idle' then
    local command = table.remove( cmd.commandq, 1 )
    if command == 'ml' then
      bot.x = bot.x - 1
    elseif command == 'mr' then
      bot.x = bot.x + 1
    elseif command == 'mu' then
      bot.y = bot.y - 1
    elseif command == 'md' then
      bot.y = bot.y + 1
    end
    -- debug
    print( cmd.state .. " " .. command )
  end
end

return cmd
