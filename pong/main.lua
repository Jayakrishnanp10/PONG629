require 'class'
push=require 'push'
require 'ball'
require 'paddle'

window_width=1280
window_height=720

virtual_width=432
virtual_height=243

x1=5
x2=virtual_width-10

paddle_speed=300



function love.load()
    love.window.setTitle("pong629")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setBackgroundColor(0,.5,0)
    font1=love.graphics.newFont("SnesItalic-1G9Be.ttf",20)
    local imagedata = love.image.newImageData("image.png")
    love.window.setIcon(imagedata)
    sounds={
    ["start"]=love.audio.newSource("sounds/start.wav","stream"),
    ["victory"]=love.audio.newSource("sounds/victory.wav","stream"),
    ["score"]=love.audio.newSource("sounds/score.wav","static"),
    ["paddlehit"]=love.audio.newSource("sounds/paddlehit.wav","static"),
    ["wallhit"]=love.audio.newSource("sounds/wallhit.wav","static"),
    }
    push:setupScreen(virtual_width,virtual_height,window_width,window_height,{
        fullscreen=false,
        resizable=false,
        vsync=true
    })
    ball=ball(virtual_width/2,virtual_height/2,4)
    player1=paddle(x1,virtual_height/2,5,20)
    player2=paddle(x2,virtual_height/2,5,20)
    gamestate="start"
    
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 's' then
        if gamestate=="start" then
            gamestate="play"
            gamemode="single"
        end
    end
    if key == 'm' then
        if gamestate=="start" then
            gamestate="play"
            gamemode="multi"
        end
    end
end

function love.update(dt)
    if gamestate=="start" then
        sounds["start"]:play(true)
    end
    if gamestate=="play" then
        if gamemode=="single" then
            if love.keyboard.isDown('up') then
                player1:up(dt)
            end
            if love.keyboard.isDown('down') then
                player1:down(dt)
            end
            player2.dy=(ball.y-player2.y)*15
            player2.y=player2.y+player2.dy*dt
        end
        if gamemode=="multi" then
            if love.keyboard.isDown('w') then
                player1:up(dt)
            end
            if love.keyboard.isDown('s') then
                player1:down(dt)
            end
            if love.keyboard.isDown('up') then
                player2:up(dt)
            end
            if love.keyboard.isDown('down') then
                player2:down(dt)
            end
        end
        if ball:collision(player1) then
            ball.dx=-ball.dx*1.04
            ball.x=player1.x+5
            sounds["paddlehit"]:play()
        end
        if ball:collision(player2) then
            ball.dx=-ball.dx*1.04
            ball.x=player2.x-5
            sounds["paddlehit"]:play()
        end
        if ball.y<0 then
            ball.dy=-ball.dy
            ball.y=5
            sounds["wallhit"]:play()
        end
        if ball.y+ball.r>virtual_height then
            ball.dy=-ball.dy
            ball.y=virtual_height-5
            sounds["wallhit"]:play()
        end
        if ball.x<0 then
            player2.score=player2.score+1
            sounds["score"]:play()
            ball:reset()
            player1:reset()
            player2:reset()
        end
        if ball.x+ball.r>virtual_width then
            player1.score=player1.score+1
            sounds["score"]:play()
            ball:reset()
            player1:reset()
            player2:reset()
        end
        ball:update(dt)
        if player2.score==5 then
            gamestate="victory2"
            sounds["victory"]:play(true)
        end
        if player1.score==5 then
            gamestate="victory1"
            sounds["victory"]:play(true)
        end
    end
    if gamestate=="victory1" or gamestate=="victory2" then
        if love.keyboard.isDown('d') then
            gamestate="play"
            player1.score=0
            player2.score=0
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(0.15, 0.27, 0.47)
    love.graphics.setBackgroundColor( 0.15, 0.27, 0.47,0.5 )
    love.graphics.setFont(font1)
    --love.graphics.print("fps:"..tostring(love.timer.getFPS()),10,10)
    if gamestate=="start" then
        love.graphics.setColor(1,1,1,0.5)
    elseif gamestate=="play" then
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.setColor(1,2,1)
    if gamestate=="start" then

        love.graphics.printf("pong_",0,virtual_height/2-30,virtual_width,'center')
        love.graphics.printf("TO START PRESS\nm-multiplayer\ns-singleplayer",0,virtual_height/2+30,virtual_width,'center')
    elseif gamestate=="play" then
        love.graphics.printf("pong_",0,10,virtual_width,'center')
        love.graphics.setColor(0,0,1)
        love.graphics.printf(tostring(player1.score),-100,10,virtual_width,'center')
        love.graphics.setColor(1,0,0)
        love.graphics.printf(tostring(player2.score),100,10,virtual_width,'center')
        love.graphics.setColor(0,0,1)
        player1:render()
        love.graphics.setColor(1,0,0)
        player2:render()
        love.graphics.setColor(1,2,1)
        ball:render()
    elseif gamestate=="victory1" then
        love.graphics.setColor(0,0,1)
        love.graphics.printf("player1 has won the game\npress d to play\nesc to quit",virtual_height/2,virtual_height/2,virtual_width/2,'center')
    elseif gamestate=="victory2" then
        love.graphics.setColor(1,0,0)
        love.graphics.printf("player2 has won the game\npress d to play\n esc to quit",virtual_height/2,virtual_height/2,virtual_width/2,'center')
    end
    push:finish()
end