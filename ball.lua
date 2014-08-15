require 'class'

Ball = class {}

function Ball:create(world, x, y, dir)
    local obj = self:new {
        graphics = love.graphics.newImage('blinky.png'),
    }
    obj.r = obj.graphics:getWidth()/2
    obj.body = love.physics.newBody(world, x, y - obj.r*dir, 'dynamic')
    obj.body:setGravityScale(dir)
    obj.shape = love.physics.newCircleShape(obj.r)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 0.2)
    obj.fixture:setFriction(0.1)
    obj.fixture:setRestitution(0.8)
    obj.collideOn = { obj.fixture }
    return obj
end

function Ball:getX()
    return self.body:getX() - self.r
end

function Ball:getY()
    return self.body:getY() - self.r
end

function Ball:collide(fixture, contact)
    -- Change gravity direction when we hit a player
    if fixture:getCategory() == 2 then
        self.body:setGravityScale(fixture:getUserData().dir)
    end
end

function Ball:update(dt)
end
