require 'ruby2d'

set background: 'red'

class Score

  def initialize()
    @player1 = 0
    @ai = 0
  end

  def off_bounds(ball)
    if ball.shape.x <= 0 
      @ai +=1
    elsif ball.shape.x2 >= Window.width
      @player1 += 1
    end
  end
  
  def draw
    Text.new(
      "Player #{@player1} :: Ai #{@ai}",
      x: 150, y: 50,
      font: 'meera.ttf',
      style: 'bold',
      size: 20,
      color: 'blue',
    )
  end

end

class Paddle

  HEIGHT = 125
  
  attr_accessor :direction
  def initialize(side,movement_speed)
    @direction = nil
    @movement_speed = movement_speed
    @y = 200
    if side == :left
      @x = 10
    else
      @x = 610
    end
  end

  def movement
    if @direction == :up
      @y = [@y - @movement_speed,0].max
    elsif @direction == :down
      @y = [@y + @movement_speed,win_max].min
    end
  end

  def track_ball(ball)
    if ball.y_middle > y_middle
      @y = [@y + @movement_speed,win_max].min
    else ball.y_middle < y_middle
      @y = [@y - @movement_speed,0].max
    end
  end

  def hit_ball(ball)
    ball.shape && [[ball.shape.x1,ball.shape.y1],[ball.shape.x2,ball.shape.y2],
    [ball.shape.x3,ball.shape.y3],[ball.shape.x4,ball.shape.y4]].any? do |coordinates|
          @shape.contains?(coordinates[0], coordinates[1])
    end
  end

  def win_max
    Window.height - HEIGHT
  end

  def y_middle
    @y + (HEIGHT/2)
  end

  def draw
    @shape = Rectangle.new(x: @x, y: @y,width: 20, height: HEIGHT,color: 'white')
  end
end

class Ball

  HEIGHT = 20
  attr_reader :shape
  def initialize(speed)
    @x = 400
    @y = 220
    @x_velocity = -speed
    @y_velocity = speed
  end

  def draw
    @shape = Square.new(x: @x, y: @y, size: HEIGHT,color: "white")  
  end

  def movement
    if hit_bottom || hit_top
      @y_velocity = -@y_velocity
    end
    @x = @x + @x_velocity
    @y = @y + @y_velocity
  end

  def hit_bottom
    @y+HEIGHT > Window.height
  end

  def hit_top
    @y <= 0
  end

  def off_bounds
    @x <= 0 || @shape.x2 >= Window.width
  end

  def bounce
    @x_velocity = -@x_velocity
  end

  def y_middle
    @y + (HEIGHT/2)
  end

end

player = Paddle.new(:left,5)
opponent = Paddle.new(:right,4)
ball = Ball.new(4)
score = Score.new
boom = Music.new('boom.mp3')

on :key_down do |event|
  if event.key == 'w'
    player.direction = :up
  elsif event.key == 's'
    player.direction = :down
  end
end

on :key_up do |event|
  player.direction = nil
end


update do
  clear

  score.draw
  if player.hit_ball(ball) || opponent.hit_ball(ball)
    puts "HIT"
    boom.play
    ball.bounce
    boom.pause
  end
  player.movement
  player.draw

  opponent.draw
  opponent.track_ball(ball)

  ball.movement
  ball.draw
  score.off_bounds(ball)
  if ball.off_bounds
    ball = Ball.new(6)
  end
end

show