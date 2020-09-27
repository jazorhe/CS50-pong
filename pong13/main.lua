WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
TO_WIN = 3
Class = require 'Class'
push = require 'push'

require 'Ball'
require 'Paddle'
require 'Score'

function love.load()

    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')
    smallFont   = love.graphics.newFont('font.ttf', 8)
    scoreFont   = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    love.graphics.setFont(smallFont)

    sounds = {
        ['serving']      = love.audio.newSource('serving.wav', 'static'),
        ['victory']      = love.audio.newSource('winning.wav', 'static'),
        ['wall_hit']     = love.audio.newSource('wall_hit.wav', 'static'),
        ['paddle_hit']   = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })


    paddle1 = Paddle(5, 30, 5, 20, nil)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20, nil)

    player1Score = Score(VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3, 0)
    player2Score = Score(VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3, 0)

    servingPlayer = math.random(2) == 1 and paddle1.name or paddle2.name
    winningPlayer = 0
    mode = 1


    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameStart()

end

function love.resize(w, h)

    push:resize(w, h)

end

function love.update(dt)

    if gameState == 'play' then

        if ball.x <= 0 then
            -- player 2 has won
           player2Score.score =  player2Score.score + 1
           servingPlayer = paddle1.name
           ball:reset()
           paddle1:reset()
           paddle2:reset()
           ball.dx = 100

            if player2Score.score >= TO_WIN then
                winningPlayer = paddle2.name
                sounds['victory']:play()
                gameState = 'victory'
            else
                sounds['point_scored']:play()
                gameState = 'serve'
            end

        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            -- player 1 has won
            player1Score.score =  player1Score.score + 1
            servingPlayer = paddle2.name
            ball:reset()
            paddle1:reset()
            paddle2:reset()
            ball.dx = -100

            if player1Score.score >= TO_WIN then
                winningPlayer = paddle1.name
                sounds['victory']:play()
                gameState = 'victory'
            else
                sounds['point_scored']:play()
                gameState = 'serve'
            end

        end

    end

    if ball:collides(paddle1) then
        ball.dx = -ball.dx * 1.05
        ball.x  = paddle1.x + 5
        sounds['paddle_hit']:play()
    end

    if ball:collides(paddle2) then
        ball.dx = -ball.dx * 1.05
        ball.x  = paddle2.x - 4
        sounds['paddle_hit']:play()
    end

    if ball.y <= 0 then
        sounds['wall_hit']:play()
        ball.dy = - ball.dy
        ball.y = 0
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
        sounds['wall_hit']:play()
        ball.dy = - ball.dy
        ball.y = VIRTUAL_HEIGHT - 4
    end

    if gameState == 'start' then
        if love.keyboard.isDown('up') then
            mode = 1
        elseif love.keyboard.isDown('down') then
            mode = 2
        end
    end

    if gameState == 'serve' or gameState == 'play' then

        if love.keyboard.isDown('w') then
            paddle1.dy = - PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end

        if mode == 2 then
            if love.keyboard.isDown('up') then
                paddle2.dy = - PADDLE_SPEED
            elseif love.keyboard.isDown('down') then
                paddle2.dy = PADDLE_SPEED
            else
                paddle2.dy = 0
            end
        end

    end

    if gameState == 'play' and mode == 1 then

        -- AI takes control of the  right paddle:

        -- if paddle2 height - ball height < 0 (above ball)
        if paddle2.y + paddle2.height / 2 - ball.y < paddle2.height / 2 and not startMoving
        and (love.timer.getTime() - tstop >= 0.005) then
            -- move down
            paddle2.dy = math.pow(paddle2.y + paddle2.height / 2 - ball.y, 2)
            startMoving = true
            tstart = love.timer.getTime()

        -- elseif >= 0 (below the ball)
        elseif paddle2.y + paddle2.height / 2 - ball.y >= paddle2.height and not startMoving
        and (love.timer.getTime() - tstop >= 0.005) then
            -- move up
            paddle2.dy = - math.pow(paddle2.y + paddle2.height / 2 - ball.y, 2)
            startMoving = true
            tstart = love.timer.getTime()

        elseif startMoving and (love.timer.getTime() - tstart >= 0.01) then
            paddle2.dy = 0
            startMoving = false
            tstop = love.timer.getTime()

        end
    end

    paddle1:update(dt)
    paddle2:update(dt)

    if gameState == 'play' then
        ball:update(dt)
    end

end


function love.keypressed(key)

    if key == 'escape' then

        love.event.quit()

    elseif key == 'r' then

      gameStart()
      gameState = 'start'

    elseif key == 'enter' or key == 'return' then

        if gameState == 'start' then

            if mode == 2 then
                paddle1.name = 'Player 1'
                paddle2.name = 'Player 2'
                servingPlayer = math.random(2) == 1 and paddle1.name or paddle2.name
            elseif mode == 1 then
                paddle1.name = 'You'
                paddle2.name = 'Computer'
                servingPlayer = math.random(2) == 1 and paddle1.name or paddle2.name
            end
            gameState = 'serve'

        elseif gameState == 'serve' then
            sounds['serving']:play()
            gameState = 'play'

        elseif gameState == 'victory' then
            player1Score.score = 0
            player2Score.score = 0
            gameState = 'start'

        end

    end

end

function love.draw()

    push:apply('start')

        love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

        if gameState == 'start' then
            love.graphics.setFont(smallFont)
            love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Select Mode!", 0, 20, VIRTUAL_WIDTH, 'center')

            if mode == 1 then
                love.graphics.printf(">", VIRTUAL_WIDTH / 2 - 35, 50, VIRTUAL_WIDTH, 'left')
            elseif mode == 2 then
                love.graphics.printf(">", VIRTUAL_WIDTH / 2 - 35, 60, VIRTUAL_WIDTH, 'left')
            end

            love.graphics.printf("1 Player", 0, 50, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("2 Player", 0, 60, VIRTUAL_WIDTH, 'center')

        elseif gameState == 'serve' then
            love.graphics.setFont(smallFont)
            love.graphics.printf(tostring(servingPlayer .. " serving!"), 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Press Enter to Serve!", 0, 20, VIRTUAL_WIDTH, 'center')

        elseif gameState == 'play' then
            -- no message will be shown for the play state

        elseif gameState == 'victory' then
            love.graphics.setFont(victoryFont)
            love.graphics.printf(tostring(winningPlayer .. " won the game!"), 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf("Press Enter to Restart!", 0, 42, VIRTUAL_WIDTH, 'center')

        end

        paddle1:render()
        paddle2:render()
        ball:render()
        player1Score:render()
        player2Score:render()

        displayFPS()

    push:apply('end')

end

function gameStart()

    gameState = 'start'
    ball:reset()
    paddle1:reset()
    paddle2:reset()
    tstop = love.timer.getTime()

end

function displayFPS()

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)

end
