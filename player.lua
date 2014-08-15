require 'class'

local imageMap = {
    [1]  = 'char1.png',
    [-1] = 'char2.png',
}

local keyMap = {
    [1]  = {
        left  = 'kp4',
        right = 'kp6',
        up    = 'kp8',
    },
    [-1] = {
        left  = 'a',
        right = 'd',
        up    = 'w',
    },
}

Player = class {}

function Player:create(world, x, y, dir)
    local obj = self:new {
        dir = dir,
        graphics = love.graphics.newImage(imageMap[dir]),
        keys = keyMap[dir],
        touching = 0,
        touchingFixt = {},
    }
    local function makeCircle(x, y, r)
        local body = love.physics.newBody(world, x, y, 'dynamic')
        body:setFixedRotation(true)
        body:setGravityScale(dir)
        local shape = love.physics.newCircleShape(r)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setFriction(0)
        fixture:setRestitution(0)
        fixture:setCategory(2)
        fixture:setUserData(obj)
        return body, shape, fixture
    end
    local w, h = obj.graphics:getWidth(), obj.graphics:getHeight()
    obj.r = w/2
    obj.body1, obj.shape1, obj.fixture1 = makeCircle(x, y - w/2*dir, w/2)
    obj.body2, obj.shape2, obj.fixture2 = makeCircle(x, y - (h - w/2)*dir, w/2)
    obj.body = dir > 0 and obj.body2 or obj.body1
    obj.joint1 = love.physics.newPrismaticJoint(obj.body1, obj.body2, x, y, 0, 1)
    obj.joint2 = love.physics.newPrismaticJoint(obj.body1, obj.body2, x, y, 1, 0)
    obj.collideOn = { obj.fixture1 }
    return obj
end

function Player:getX()
    return self.body:getX() - self.r
end

function Player:getY()
    return self.body:getY() - self.r
end

function Player:collide(fixture, contact)
    local x, y = contact:getNormal()
    local ok = contact:isTouching() and math.abs(x) < 0.1 or nil
    if ok ~= self.touchingFixt[fixture] then
        self.touching = self.touching + (ok and 1 or -1)
    end
    self.touchingFixt[fixture] = ok
end

function Player:update(dt)
    local vx, _ = self.body:getLinearVelocity()
    local mu = self.touching > 0 and 5 or 3
    local fx = -mu*vx
    if love.keyboard.isDown(self.keys.left) then
        fx = fx - (self.touching > 0 and 1800 or 800)
    end
    if love.keyboard.isDown(self.keys.right) then
        fx = fx + (self.touching > 0 and 1800 or 800)
    end
    self.body:applyForce(fx, 0)
    if love.keyboard.isDown(self.keys.up) and self.touching > 0 then
        self.body:applyForce(0, -8000*self.dir)
    end
end
