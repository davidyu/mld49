local utils = {}

function utils.buildMap( path )
  assert( love.filesystem.exists( path .. ".lua" ),
          "the level " .. path .. "does not exist!" )
  local mapdata = love.filesystem.load( path .. ".lua" )() -- executable output from tmx2lua
  local map = {}
  map.name = path
  map.width = mapdata.width
  map.height = mapdata.height
  map.tilewidth = mapdata.tilewidth
  map.tileheight = mapdata.tileheight
  map.tileset = love.graphics.newImage( mapdata.tilesets[1].image.source )
  for i, tilelayer in ipairs( mapdata.tilelayers ) do
    if tilelayer.name == 'base' then
      map.tiles = {}
      local tilesetwidth = mapdata.tilesets[1].image.width / mapdata.tilesets[1].tilewidth
      for j, tile in ipairs( tilelayer.tiles ) do
        local tx = ( tilelayer.tiles[j].id % tilesetwidth ) * map.tilewidth
        local ty = math.floor( tilelayer.tiles[j].id / tilesetwidth ) * map.tileheight
        map.tiles[j] = love.graphics.newQuad( tx, ty, mapdata.tilewidth, mapdata.tileheight, mapdata.tilesets[1].image.width, mapdata.tilesets[1].image.height )
      end
    elseif tilelayer.name == 'doodads' then
      map.start = {}
      map.dest = {}
      for j, tile in ipairs( tilelayer.tiles ) do
        if tile then
          local x = ( j - 1 ) % mapdata.width + 1
          local y = math.floor( ( j -  1 ) / mapdata.width ) + 1
          if tile.id == 0 then -- start
            map.start.x = x
            map.start.y = y
          elseif tile.id == 1 then -- dest
            map.dest.x = x
            map.dest.y = y
          end
        end
      end
    end
  end
  return map
end

return utils
