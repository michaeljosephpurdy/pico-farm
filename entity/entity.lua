entities={}
badguys={}
goodguys={}

local selected_ent_i=1
local selected_ent=nil
local selected_ent_x=0
local selected_ent_y=0


local function push_other_goodguys(e1)
 for e2 in all(goodguys) do
  if e1!=e2 then
   local overlaps,dist=Collision.ent(e1,e2)
   e1.overlaps=overlaps
   e2.overlaps=overlaps
   if overlaps then
    local ang=atan2(e1.y-e2.y,e1.x-e2.x)
    local force=0.001
    local repelpower=(e1.r+e2.r-dist)/(e1.r+e2.r)
    e1.dx -= cos(ang) * repelpower * force
    e1.dy -= sin(ang) * repelpower * force
    e2.dx += cos(ang) * repelpower * force
    e2.dy += sin(ang) * repelpower * force
   end
  end
 end
end

function abduct_goodguy(e)
 if not e.is_covered then
  del(entities,e)
  del(goodguys,e)
  if selected_ent==e then
   selected_ent=nil
  end
  Farm.abducted+=1
 end
end

function goodguy_update(e)
 if e.selected then
   if btn(➡️) then
     e.dx=e.speed
   elseif btn(⬅️) then
     e.dx=-e.speed
   end
   if btn(⬆️) then
     e.dy=-e.speed
   elseif btn(⬇️) then
     e.dy=e.speed
   end
 end
 push_other_goodguys(e)
 e.is_covered=false
 if fget(mget(e.mx,e.my),7) then
  del(entities,e)
  del(goodguys,e)
  if selected_ent==e then
   selected_ent=nil
  end
  Farm.rescued+=1
 end
 if fget(mget(e.mx,e.my),3) then
  e.is_covered=true
 end
end

function ufo_update(e)
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
    abduct_goodguy(gg)
   end
  end
 end
end

local function ent_draw(e)
 local x=e.x-TILESIZE/2
 local y=e.y-TILESIZE/2
 color(9)
 spr(e.s,
     e.x-TILESIZE/2,
     e.y-TILESIZE/2,
     1,1,e.dx>0)
 if e.selected then
  line(e.x-4,e.y+5,e.x+3,e.y+5)
 end
end

local data={
 cow={
  s=1,speed=.04,r=3,
  pre_update=goodguy_update,
 },
 chicken={
  s=2,speed=.1,r=2,
  pre_update=goodguy_update,
 },
 pig={
  s=4,speed=.05,r=2,
  pre_update=goodguy_update,
 },
 ufo={
  s=3,speed=.1,r=4,
  badguy=true,
  beam_anim=16,
  beam_anim_start=16,
  beam_anim_end=19,
  pre_update=ufo_update,
  draw_bg=function(self)
   local x=self.x-TILESIZE/2
   local y=self.y-TILESIZE/2
   --shadow
   spr(22,x,self.y)
   --tractor beam
   if self.show_beam then
    spr(flr(self.beam_anim),x,y)
   end
  end,
  draw=function(self)
   local yoffset=-8
   local x=self.x-TILESIZE/2
   local y=self.y-TILESIZE/2
   --leftside
   spr(5,self.x-TILESIZE,y+yoffset)
   --rightside
   spr(6,self.x,y+yoffset)
   print(self.state,0,8)
  end,
  ignores_collisions=true,
  show_beam=false,
  show_spotlight=true,
  bounce=true,
  state='idle',
  state_t=40,
 },
 spotlight={
  s=20,speed=.2,r=2,
  badguy=true,
  pre_update=function(self)
   self.found_ent=false
   for gg in all(goodguys) do
    if Collision.ent(self,gg) then
     self.found_ent=true
    end
   end
  end,
  draw_bg=function(self)
  end,
  draw=function(self)
   if self.ufo.show_spotlight then
    ent_draw(self)
   end
  end,
 }
}

ent_new=function(x,y,t)
  local e=BaseEntity.new(x, y, t)
  for k,v in pairs(data[t]) do
    e[k]=v
  end
  if t=='ufo' then
    e.spotlight=ent_new(x,y,'spotlight')
    e.spotlight.ufo=e
  end
  if e.badguy then
    add(badguys,e)
  else
    add(goodguys,e)
  end
  add(entities,e)
  return e
end