function love.load(arg)
  w,h = love.graphics.getDimensions()
  hole = {
    d_1 = 50,
    d_2 = 15,
    segs = 100,
    angle = 0}
  disk = {
    d = w*1.5,
    segs = 100,
    side_y = 0}
  wind_dependency ={
    velocity = .2,
    brake_down = 0.2,
    speed_up = 0.2,
    angle = 0 ,
    direction = 0}
  game = {
    timer = 0,
    timeInterval = 2,
    main_size = 40,
    font_size = 10,
    dt = love.timer.getDelta(),
    space_pressed = false,
    off_x = w-50,
    off_y = h-200  }
  turbine = {
    rotate = true,
    velocity = wind_dependency.velocity,
    rotation = 0,
    blade_pitch = 0,
    yaw = 0,
    yawing = false,
    yaw_angle = 0,
    yaw_diff = 0 }
  colors = {
    grey = {150,150,150,255},
    black = {0,0,0,255},
    white = {255,255,255,255},
    blue = {0,0,255,255},
    green = {0,255,0,255},
    red = {255,0,0,255}}
  mainFont = love.graphics.newFont(game.main_size)
  debugFont = love.graphics.newFont(game.font_size)
  make_canvas()
end

function love.update(dt)
  turbine.yaw_angle = turbine.yaw_angle + dt*turbine.yaw * math.pi/2
  turbine.yaw_angle = turbine.yaw_angle % (2*math.pi)
  turbine.yaw_diff = (math.deg(wind_dependency.angle - turbine.yaw_angle) +180) % 360 - 180
  wind_dependency.direction = math.random(-1,1)
  wind_dependency.angle = wind_dependency.angle + dt * wind_dependency.direction/10 * math.pi/2
  wind_dependency.angle = wind_dependency.angle % (2*math.pi)
  game.timer = game.timer + dt
    if game.timer >= game.timeInterval then
      get_rotation(dt)
      game.timer = game.timer - game.timeInterval
    end
  -- turbine.velocity = 1/(((100*turbine.yaw_diff)/180)/100)
  if turbine.rotate then
    disk.side_y = disk.side_y +((dt*turbine.velocity* math.pi/2))*disk.d/2
    hole.angle = hole.angle + dt*turbine.velocity * math.pi/2
    hole.angle = hole.angle % (2*math.pi)
    if game.space_pressed then  --brake & speed
      -- if turbine.velocity >= 0 then
      if tostring(turbine.velocity):sub(1,5) ~= '-0.00' then
        turbine.velocity = turbine.velocity - (dt*wind_dependency.brake_down)
      else
        turbine.velocity = 0
      end
      if turbine.velocity < 0 then
        turbine.rotate = false
      end
    else
      if tostring(turbine.velocity):sub(1,3) <= tostring(wind_dependency.velocity) then
        turbine.velocity = turbine.velocity + (dt*wind_dependency.speed_up)
      end
    end
  end
end

function print_debug()
  love.graphics.reset()
  start_y = h/20 + w/2.5
  love.graphics.setFont(debugFont)
  game.dt = game.dt +love.timer.getDelta()
  love.graphics.setColor(unpack(colors.green))
  love.graphics.print(string.format('%2.1f',turbine.rotation)..' U/Min',     10,start_y)
  start_y = start_y + game.font_size
  love.graphics.print('turbine.yaw_diff:'..string.format('%2.1f',turbine.yaw_diff),     10,start_y)
  start_y = start_y + game.font_size
  love.graphics.print('turbine.yaw_diff:'..string.format('%2.1f',(math.abs((turbine.yaw_diff*100)/90))%90),     10,start_y)
  start_y = start_y + game.font_size
  love.graphics.print('turbine.velocity:'..string.format('%2.1f',turbine.velocity),     10,start_y)
  start_y = start_y + game.font_size
  love.graphics.print(w..'  '..h,     10,start_y)
  start_y = start_y + game.font_size
  if game.dt > 1 then
    s = turbine.speed
    game.dt = 0
  else
    turbine.speed = s
  end
  check_for_success()
end

function love.keypressed(key)
    if key == "escape" then
      love.event.quit()
    elseif key == "space" then
      game.space_pressed = true
      if turbine.velocity < 0 then
        turbine.rotate = false
      end
    end
    if key == 'left' then
      turbine.yawing = true
      turbine.yaw = .5
    elseif key == 'right' then
      turbine.yawing = true
      turbine.yaw = -.5
    end
end

function love.keyreleased(key)
  if key == "space" then
    turbine.rotate = true
    game.space_pressed = false
  end
  if key == 'left' then
    turbine.yawing = false
    turbine.yaw = 0
  end
  if key == 'right' then
    turbine.yawing = false
    turbine.yaw = 0
  end
end

function get_rotation (dt)
  _a = (dt*turbine.velocity * math.pi/2)
  turbine.rotation = math.abs((math.deg(_a)*love.timer.getFPS()*60)/360)
end

function format_number (number,offset)
  return (tostring(number):sub(1,offset))
end

function check_for_success (args)
  -- if game.space_pressed then
  --   if tostring(hole.angle):sub(1,4) == tostring(math.rad(50)):sub(1,4) or
  --      tostring(hole.angle):sub(1,4) == tostring(math.rad(170)):sub(1,4) or
  --      tostring(hole.angle):sub(1,4) == tostring(math.rad(290)):sub(1,4) then
  --     love.graphics.print('Treffer '..tostring(hole.angle):sub(1,4),10,110)
  --   else
  --     love.graphics.print('Niete '..tostring(hole.angle):sub(1,4),10,110)
  --   end
  -- end
end

function make_canvas (args)
  disk_canvas_blade = love.graphics.newCanvas(disk.d,disk.d)
    love.graphics.setCanvas(disk_canvas_blade)
    love.graphics.setLineWidth(hole.d_1*2)
    for i = 0,359,15 do
      if i%120 == 0 then
        love.graphics.line( disk.d/2+((disk.d/4+hole.d_1)*math.cos(i*math.pi/180)),
                            disk.d/2+((disk.d/4+hole.d_1)*math.sin(i*math.pi/180)),
                            disk.d/2+((disk.d/2-100)*math.cos(i*math.pi/180)),
                            disk.d/2+((disk.d/2-100)*math.sin(i*math.pi/180)))
      end
    end
  love.graphics.setCanvas()
  love.graphics.setFont(mainFont)
  disk_canvas_blade_text = love.graphics.newCanvas(disk.d,disk.d)
    love.graphics.setCanvas(disk_canvas_blade_text)
    love.graphics.setLineWidth(1)
    --for i = 0,120,15 do
    --for i = 0,359,120 do
      -- if i%120 == 0 then
     --   print(i)
    love.graphics.print("A",disk.d/2+(disk.d/2.6*math.cos(0  *math.pi/180)),disk.d/2+(disk.d/2.6*math.sin(0  *math.pi/180)),0)
    love.graphics.print("B",disk.d/2+(disk.d/2.6*math.cos(120*math.pi/180)),disk.d/2+(disk.d/2.6*math.sin(120*math.pi/180)),(2*math.pi/3))
    love.graphics.print("C",disk.d/2+(disk.d/2.6*math.cos(240*math.pi/180)),disk.d/2+(disk.d/2.6*math.sin(240*math.pi/180)),(4*math.pi/3))
    --love.graphics.line(0,0,disk.d/2+(disk.d/2.4*math.cos(0*math.pi/180)),disk.d/2+(disk.d/2.6*math.sin(0*math.pi/180)))
    love.graphics.line(disk.d/2,disk.d/2,disk.d/2+(disk.d/2.5*math.cos(0  *math.pi/180)),disk.d/2+(disk.d/2.5*math.sin(0  *math.pi/180)))
    love.graphics.line(disk.d/2,disk.d/2,disk.d/2+(disk.d/2.5*math.cos(120*math.pi/180)),disk.d/2+(disk.d/2.5*math.sin(120*math.pi/180)))
    love.graphics.line(disk.d/2,disk.d/2,disk.d/2+(disk.d/2.5*math.cos(240*math.pi/180)),disk.d/2+(disk.d/2.5*math.sin(240*math.pi/180))) 
    -- end
    --end
  love.graphics.setCanvas()
  love.graphics.reset()
  love.graphics.setLineWidth(1)
  disk_canvas_big_hole = love.graphics.newCanvas(disk.d,disk.d)
    love.graphics.setCanvas(disk_canvas_big_hole)
    for i = 0,359,15 do
      if i%120 == 0 then
        new_hole = love.graphics.circle('fill', disk.d/2+(disk.d/4*math.cos(i*math.pi/180)),
                                                disk.d/2+(disk.d/4*math.sin(i*math.pi/180)),
                                                hole.d_1,hole.segs)
      end
    end
  love.graphics.setCanvas()
  disk_canvas_small_hole = love.graphics.newCanvas(disk.d,disk.d)
    love.graphics.setCanvas(disk_canvas_small_hole)
    for i = 0,359,15 do
      if i%120 ~= 0 then
        love.graphics.circle('fill', disk.d/2+(disk.d/4*math.cos(i*math.pi/180)),disk.d/2+(disk.d/4*math.sin(i*math.pi/180)),hole.d_2,hole.segs)
      end
    end
  love.graphics.setCanvas()
  disk_outer_outer = love.graphics.newCanvas(disk.d,disk.d)
    love.graphics.setCanvas(disk_outer_outer)
    love.graphics.circle('fill', disk.d/2,disk.d/2,disk.d/4+hole.d_1+5,hole.segs)
  love.graphics.setCanvas()
  disk_outer_inner = love.graphics.newCanvas(disk.d,disk.d)
    love.graphics.setCanvas(disk_outer_inner)
    love.graphics.circle('fill', disk.d/2,disk.d/2,disk.d/4-hole.d_1-5,hole.segs)
  love.graphics.setCanvas()
  disk_inner_inner = love.graphics.newCanvas(disk.d,disk.d)
    love.graphics.setCanvas(disk_inner_inner)
    love.graphics.circle('fill', disk.d/2,disk.d/2,disk.d/12,hole.segs)
  love.graphics.setCanvas()
  dest_rect_canvas = love.graphics.newCanvas((hole.d_1*2)+10,(hole.d_1*2)+10)
    love.graphics.setCanvas(dest_rect_canvas)
    love.graphics.setLineWidth(5)
    --love.graphics.rectangle('line',0,0,hole.d_1*2,hole.d_1*2)
    love.graphics.rectangle('line',5,0,(hole.d_1*2)+5,(hole.d_1*2)+5)

    love.graphics.setCanvas()
  vane_canvas_1 = love.graphics.newCanvas(w/8,w/8,nil,100)
    love.graphics.setCanvas(vane_canvas_1)
    love.graphics.circle('line', w/16 ,w/16, w/16+1, 100)
    love.graphics.polygon('fill',w/16               ,w/16-w/16+game.font_size/4, w/16+5,w/16-5,w/16-5,w/16-5)
    love.graphics.polygon('fill',w/16               ,w/8-game.font_size/4      , w/16+5,w/16-5,w/16-5,w/16-5)
    love.graphics.polygon('fill',w/8-w/8+game.font_size/4,w/16                 , w/16+5,w/16-5,w/16+5,w/16+5)
    love.graphics.polygon('fill',w/8-game.font_size/4    ,w/16                 , w/16+5,w/16-5,w/16+5,w/16+5)
    love.graphics.print('N',w/16-game.font_size/4   ,w/16-w/16)
    love.graphics.print('S',w/16-game.font_size/4   ,w/8-game.font_size/1.5)
    love.graphics.print('O',w/8-w/8,w/16-game.font_size/4)
    love.graphics.print('W',w/8-mainFont:getWidth('W')/2   ,w/16-game.font_size/4)
  love.graphics.setCanvas()
  yaw_canvas_1 = love.graphics.newCanvas(w/8,w/8,nil,100)
    love.graphics.setCanvas(yaw_canvas_1)
    love.graphics.circle('line', w/16 ,w/16, w/16-1, 100)
    love.graphics.rectangle('fill',40,40,20,40)
    love.graphics.arc( "fill", 50, 45, 20, math.pi,math.pi*2 ,100)
    love.graphics.line(10,35,90,35)
  love.graphics.setCanvas()
  pitch_canvas_1 = love.graphics.newCanvas(w/8,w/8,nil,100)
    love.graphics.setCanvas(pitch_canvas_1)
    love.graphics.circle('line', w/16 ,w/16, w/16-1, 100)
    love.graphics.arc( "line", 35, 50, 20, math.pi+math.pi/2 ,math.pi/2,100)
    love.graphics.line(35,30,90,50)
    love.graphics.line(35,70,90,50)
  love.graphics.setCanvas()
  disk_side_canvas_1 = love.graphics.newCanvas(20,(math.pi*(disk.d/2)/3),nil,100)
    love.graphics.setCanvas(disk_side_canvas_1)
    
    love.graphics.rectangle('line',0,0,20,(math.pi*(disk.d/2)/3))
  love.graphics.setCanvas()
  canvas_color_table = {
    {disk_outer_outer,colors.white},
    {disk_outer_inner,colors.black},
    {disk_inner_inner,colors.white},
    {disk_canvas_big_hole,colors.black},
    {disk_canvas_small_hole,colors.green},
    {disk_canvas_blade,colors.white},
    {disk_canvas_blade_text,colors.red}}
end

function love.draw()
  print_debug()
  draw_disk()
  draw_vane()
  draw_pitch()
  draw_dest_rect()
  draw_yaw()
  draw_vane_diff()
  --draw_side_disk()
end

function draw_side_disk (args)
  love.graphics.reset()
  -- love.graphics.draw(disk_side_canvas_1,2*w/3,disk.side_y-(math.pi*(disk.d/2)/3),0,1,1)
  love.graphics.draw(disk_side_canvas_1,2*w/3,disk.side_y,0,1,1)
  if disk.side_y >= (math.pi*(disk.d/2)/3) then
    disk.side_y = 0
  end
end

function draw_disk (args)
  love.graphics.reset()
  love.graphics.translate(game.off_x,game.off_y)
  love.graphics.rotate(-hole.angle)
  love.graphics.translate(-game.off_x,-game.off_y)
  for i,v in ipairs(canvas_color_table) do
    t,c = unpack(v)
    love.graphics.setColor(unpack(c))
    love.graphics.draw(t,game.off_x,game.off_y,0,1,1,disk.d/2,disk.d/2)
  end
end

function draw_yaw (args)
  love.graphics.reset()
  love.graphics.translate((w/4+w/16),(h/20+w/16))
  love.graphics.rotate(-turbine.yaw_angle)
  love.graphics.translate(-(w/4+w/16),-(h/20+w/16))
  love.graphics.setColor(unpack(colors.white))
  love.graphics.draw(yaw_canvas_1,w/4,h/20,0,1,1)
end

function draw_vane_diff (args)
  love.graphics.reset()
  if math.abs(turbine.yaw_diff) < 40 then
    love.graphics.setColor(unpack(colors.green))
  else
    love.graphics.setColor(unpack(colors.red))
  end
  love.graphics.setLineWidth(3)
  love.graphics.line((w/4+w/16),h/20-10,(w/4+w/16)-(turbine.yaw_diff)/1.5,h/20-10)
end

function draw_pitch (args)
  love.graphics.reset()
  -- love.graphics.translate((w/4+w/16),(h/20+w/16))
  -- love.graphics.rotate(-turbine.yaw_angle)
  -- love.graphics.translate(-(w/4+w/16),-(h/20+w/16))
  love.graphics.setColor(unpack(colors.white))
  love.graphics.draw(pitch_canvas_1,w/20,h/20+w/5,0,1,1)
end

function draw_vane (args)
  love.graphics.reset()
  love.graphics.translate((w/20+w/16),(h/20+w/16))
  love.graphics.rotate(-wind_dependency.angle)
  love.graphics.translate(-(w/20+w/16),-(h/20+w/16))
  love.graphics.setColor(unpack(colors.white))
  love.graphics.draw(vane_canvas_1,w/20,h/20,0,1,1)
end

function draw_dest_rect (args)
  love.graphics.reset()
  love.graphics.setColor(unpack(colors.red))
  
  love.graphics.draw(dest_rect_canvas, (w/2)-5,(h/2)-5)
  love.graphics.setBackgroundColor(1,0,0)
end
