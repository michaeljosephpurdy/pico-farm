local function spotlight_update(e)
  e.found_ent=false
  for gg in all(goodguys) do
    if Collision.ent(e,gg) then
      e.found_ent=true
    end
  end
end

local function ufo_pre_update(e)
e.beam_anim+=.1
  if e.beam_anim>=e.beam_anim_end+1 then
    e.beam_anim=e.beam_anim_start
  end
  --statemachine
  if e.state=='idle' then
    e.ignore_friction=false
    e.state_t-=1
    if e.state_t<0 then
      e.state='searching'
      e.dx=rnd(e.speed*2)-e.speed
      e.dy=rnd(e.speed*2)-e.speed
      e.state_t=70
  end
  elseif e.state=='searching' then
    e.ignore_friction=true
    e.show_spotlight=true
    e.state_t-=1
    if e.spotlight.found_ent then
      e.state='chasing'
    end
    --if e.state_t<0 then
    -- e.state='idle'
    -- e.state_t=80
    --end
  elseif e.state=='chasing' then
    e.show_beam=true
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
  e.show_spotlight=true
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

function spotlight_pre_update(e)
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
end

function spotlight_post_update(e)
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
  Log.msg(e.state)
  Log.msg(e.next_state)
  Log.msg(e.state_time)
  e.hidden = not e.ufo.show_spotlight
end

Badguy = {
  spotlight_post_update=spotlight_post_update,
  spotlight_pre_update=spotlight_pre_update,
  ufo_pre_update=ufo_pre_update,
  ufo_draw_bg=ufo_draw_bg,
  ufo_draw=ufo_draw,
}