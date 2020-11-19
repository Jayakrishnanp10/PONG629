require "class"
ball=class()

function ball:init(x,y,r)
    math.randomseed(os.time())
    self.x=x
    self.y=y
    self.dx=math.random(2)==1 and 200 or -200
    self.dy=math.random(-100,100)
    self.r=r
end

function ball:update(dt)
    self.x=self.x+self.dx*dt
    self.y=self.y+self.dy*dt
end

function ball:collision(paddle)
    if self.x>paddle.x+paddle.width or self.x+self.r<paddle.x then
        return false
    end
    if self.y>paddle.y+paddle.height or self.y+self.r<paddle.y then
        return false
    end
    return true
end

function ball:reset()
    self.x=virtual_width/2
    self.y=virtual_height/2
    self.dx=math.random(2)==1 and 200 or -200
    self.dy=math.random(-100,100)
end

function ball:render()
    love.graphics.circle('fill',self.x,self.y,self.r)
end
