require 'ball'
require 'class'
require 'player'

local DEBUG_VIEW = false
local tileW, tileH = 32, 32

local function imageTile(name)
    return function(world, x, y)
        local obj = {}
        obj.graphics = love.graphics.newImage(name)
        obj.body = love.physics.newBody(world, x, y)
        obj.shape = love.physics.newRectangleShape(tileW, tileH)
        obj.fixture = love.physics.newFixture(obj.body, obj.shape)
        return obj
    end
end

local function objTile(cls, dir)
    return function(world, x, y)
        return cls:create(world, x, y + tileH/2*dir, dir)
    end
end

local legend = {
    B = imageTile('brick.png'),
    G = imageTile('grass.png'),
    R = imageTile('grass2.png'),
    P = objTile(Player, 1),
    Q = objTile(Player, -1),
    O = objTile(Ball, 1),
    ['.'] = function() return {} end,
}

Level = class {}

function Level:fromString(str)
    love.physics.setMeter(tileH)
    local world = love.physics.newWorld(0, 9.8*tileH, true)
    local row, objects, collisions = {}, {}, {}
    local grid = { row }
    for i = 1, #str do
        local c = str:sub(i, i)
        if c == '\n' then
            row = {}
            grid[#grid + 1] = row
        else
            local x, y = (#row+0.5) * tileW, (#grid-0.5) * tileH
            local obj = legend[c](world, x, y)
            if obj.update then
                objects[#objects + 1] = obj
                if obj.collideOn then
                    for _, fixt in pairs(obj.collideOn) do
                        collisions[fixt] = obj
                    end
                end
                obj = {}
            end
            row[#row + 1] = obj
        end
    end
    local function onContact(fixt1, fixt2, contact)
        if collisions[fixt1] then
            collisions[fixt1]:collide(fixt2, contact)
        end
        if collisions[fixt2] then
            collisions[fixt2]:collide(fixt1, contact)
        end
    end
    world:setCallbacks(onContact, onContact)

    love.window.setMode(#grid[1] * tileW, #grid * tileH)
    return self:new {
        world = world,
        grid = grid,
        objects = objects,
    }
end

function Level:update(dt)
    for _, obj in pairs(self.objects) do
        obj:update(dt)
    end
    self.world:update(dt)
end

function Level:draw()
    for y, row in ipairs(self.grid) do
        for x, t in ipairs(row) do
            if t.graphics then
                love.graphics.draw(t.graphics, (x-1) * tileW, (y-1) * tileH)
            end
        end
    end
    for i, obj in pairs(self.objects) do
        love.graphics.draw(obj.graphics, obj:getX(), obj:getY())
    end 
end

if DEBUG_VIEW then
    local function drawShapes(obj)
        for _, val in pairs(obj) do
            if type(val) == 'userdata' and val.typeOf and val:typeOf('Fixture') then
                local body, shape = val:getBody(), val:getShape()
                if shape:typeOf('PolygonShape') then
                    love.graphics.polygon('line', body:getWorldPoints(shape:getPoints()))
                elseif shape:typeOf('CircleShape') then
                    love.graphics.circle('line', body:getX(), body:getY(), shape:getRadius())
                end
            end
        end
    end

    function Level:draw()
        love.graphics.setColor(250, 250, 250)
        for y, row in ipairs(self.grid) do
            for x, t in ipairs(row) do
                drawShapes(t)
            end
        end
        love.graphics.setColor(250, 0, 0)
        for i, obj in pairs(self.objects) do
            drawShapes(obj)
        end 
    end
end
