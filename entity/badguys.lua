local function spotlight_update(e)
  e.found_ent=false
  for gg in all(goodguys) do
    if Collision.ent(e,gg) then
      e.found_ent=true
    end
  end
end

local function ufo_update(e)
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

Badguy = {
  spotlight_update=spotlight_update,
  ufo_update=ufo_update,
  ufo_draw_bg=ufo_draw_bg,
  ufo_draw=ufo_draw,
}