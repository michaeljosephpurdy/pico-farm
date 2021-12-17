local function ufo_pre_update(e)
  e.beam_anim+=.1
  if e.beam_anim>=e.beam_anim_end+1 then
    e.beam_anim=e.beam_anim_start
  end
  if e.state=='idle' then
    e.show_beam = false
    e.show_spotlight=true
    e.state_t-=1
    if e.state_t<0 then
      e.state='searching'
      e.target = { x= rnd(100) + 10, y= rnd(100) + 10 }
      e.state_t = 70
  end
  elseif e.state=='searching' then
    e.show_beam = false
    e.show_spotlight=true
    local x_dist = e.target.x - e.x
    local y_dist = e.target.y - e.y
    if abs(x_dist) <= 1 then
      x_dist=0
    end
    if abs(y_dist) <= 1 then
      y_dist=0
    end
    e.dx = mid(-e.speed, (x_dist), e.speed)
    e.dy = mid(-e.speed, (y_dist), e.speed)

    e.state_t-=1
    if e.state_t <= 0 then
      e.state = 'idle'
      e.state_t=20
    end
    if e.spotlight.found_ent then
      e.state='chasing'
      e.state_t = 20
      e.target = e.spotlight.found_ent
    end
  elseif e.state=='chasing' then
    e.state_t -= 1
    e.show_beam = true
    e.show_spotlight = false
    if e.state_t <= 0 then
      e.state='idle'
      e.state_t=50
    end
  end
  if e.show_beam then
    for gg in all(goodguys) do
      if Collision.ent(e,gg) then
        if not e.is_covered then
          del(entities,gg)
          del(goodguys,gg)
          if selected_ent==e then
            selected_ent=nil
          end
          Farm.abducted+=1
        end
      end
    end
  end
end
local function ufo_draw_bg(e)
  local x=e.x-TILESIZE/2
  local y=e.y-TILESIZE/2
  --shadow
  spr(22,x,e.y)
  --tractor beam
  if e.show_beam then
    spr(flr(e.beam_anim),x,y)
  end
  --e.show_spotlight=false
  --line(e.x, y, e.spotlight.x - 4, e.spotlight.y, 7)
  --line(e.x, y, e.spotlight.x + 4, e.spotlight.y, 7)
  --line(e.x, y, e.spotlight.x - 2, e.spotlight.y + 2, 7)
  --line(e.x, y, e.spotlight.x + 2, e.spotlight.y + 2, 7)
end
local function ufo_draw(e)
  local yoffset=-8
  local x=e.x-TILESIZE/2
  local y=e.y-TILESIZE/2
  --leftside
  spr(5,e.x-TILESIZE,y+yoffset)
  --rightside
  spr(6,e.x,y+yoffset)
end

local function spotlight_pre_update(e)
  -- clamp spotlight to ufo position
  e.dx = e.ufo.dx
  e.dy = e.ufo.dy
  e.yr = e.ufo.yr
  e.my = e.ufo.my

  e.found_ent = nil
  if e.state == 'wait' then
    e.state_time -= 1
    if e.state_time < 0 then
      e.state = e.next_state
      e.next_state = nil
    end
  elseif e.state == 'go-left' then
    e.dx = -e.speed
  elseif e.state == 'go-right' then
    e.dx = e.speed
  end

  -- search for entities
  for gg in all(goodguys) do
    if Collision.ent(e, gg) then
      e.found_ent = e
    end
  end
end

local function spotlight_post_update(e)
  if e.state == 'go-left' and e.mx < e.ufo.mx - 1 then
    e.state = 'wait'
    e.state_time = 40
    e.next_state = 'go-right'
  end
  if e.state == 'go-right' and e.mx > e.ufo.mx + 1 then
    e.state = 'wait'
    e.state_time = 40
    e.next_state = 'go-left'
  end
  e.hidden = not e.ufo.show_spotlight
end

Badguy = {
  spotlight_post_update=spotlight_post_update,
  spotlight_pre_update=spotlight_pre_update,
  ufo_pre_update=ufo_pre_update,
  ufo_draw_bg=ufo_draw_bg,
  ufo_draw=ufo_draw,
}