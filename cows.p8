pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
tilesize=8
--debug=true
rescued=0
abducted=0
function _init()
 player=ent_new(20,20,'cow')
-- ent_new(20,20,'ufo')
 ent_new(40,40,'cow')
 ent_new(60,60,'chicken')
 ent_new(20,20,'ufo')
 ent_new(10,80,'cow')
 ent_new(60,60,'chicken')
end

function _update60()
 if btnp(❎) then
  ent_select(1)
 end
 if btnp(🅾️) then
  ent_select(-1)
 end
 ent_update()
end

local function pprint(msg,x,y)
 print(msg,x,y+1,13)
 print(msg,x,y,14)
end
function _draw()
 cls()
 map()
 ent_draw()
 pprint('abducted '..abducted,8,0)
 pprint(rescued.. ' rescued',80,0)
end

-->8
entities={}
badguys={}
goodguys={}
local data={
 cow={
  s=1,speed=.05,r=3,
 },
 chicken={
  s=2,speed=.1,r=2,
 },
 ufo={
  s=3,speed=.15,r=4,
  badguy=true,
 },
}
local selected_ent_i=1

local function map_collision(mx,my,flying)
 local flags=fget(mget(mx,my))
 if flying then
  return flags==1
 end
 return flags==1 or flags==3
end

local function ent_collision(e1,e2)
 if e1==e2 then return false end
 if abs(e1.mx-e2.mx)>=2 and
    abs(e1.my-e2.my)>=2 then
  return false,0
 end
 local max_dist=e1.r+e2.r
 local dist_sqr=(e1.x-e2.x)*
                (e1.x-e2.x)+
                (e1.y-e2.y)*
                (e1.y-e2.y)
 return dist_sqr<=max_dist*max_dist,dist_sqr
end

ent_new=function(x,y,t)
 local e={}
 for k,v in pairs(data[t]) do
  e[k]=v
 end
 e.x,e.y=x,y
 e.dx,e.dy=0,0
 e.mx=flr(x/tilesize)
 e.my=flr(y/tilesize)
 e.xr,e.yr=.5,.5
 e.t=t
 e.selected=false
 if e.badguy then
  add(badguys,e)
 else
  add(goodguys,e)
 end
 add(entities,e)
 return e
end

ent_select=function(next_i)
 if #goodguys==0 then return end
 goodguys[selected_ent_i].selected=false
 local i=selected_ent_i+next_i
 if i>#goodguys then
  i=1
 elseif i<1 then
  i=#goodguys
 end
 goodguys[i].selected=true
 player=goodguys[i]
 selected_ent_i=i
 if player.badguy then
  ent_select(next_i)
 end
end

local function control_ai(e)
 if not e.state then
  e.ignores_collisions=true
  e.bounce=true
  e.state='idle'
  e.state_t=40
 end
 if e.state=='idle' then
  e.ignore_friction=false
  e.state_t-=1
  if e.state_t<0 then
   e.state='moving'
   e.dx=rnd(e.speed*2)-e.speed
   e.dy=rnd(e.speed*2)-e.speed
   e.state_t=70
  end
 end
 if e.state=='moving' then
  e.ignore_friction=true
  e.state_t-=1
  if e.state_t<0 then
   e.state='idle'
   e.state_t=80
  end
 end
end

local function control_selected(e)
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

local function apply_friction(e)
 if e.ignore_friction then return end
 e.dx*=0.85
 e.dy*=0.85
end

local function find_collisions(e)
 local flying=e.ignores_collisions
 if e.xr>.75 and
    map_collision(e.mx+1,e.my,flying) then
  e.xr=.75
  if e.bounce then
   e.dx=-e.dx
  end
 elseif e.xr<.25 and
    map_collision(e.mx-1,e.my,flying) then
  e.xr=.25
  if e.bounce then
   e.dx=-e.dx
  end
 end if e.yr>.75 and
    map_collision(e.mx,e.my+1,flying) then
  e.yr=.75
  if e.bounce then
   e.dy=-e.dy
  end
 elseif e.yr<.25 and
    map_collision(e.mx,e.my-1,flying) then
  e.yr=.25
  if e.bounce then
   e.dy=-e.dy
  end
 end
end

local function push_other_goodguys(e1)
 for e2 in all(goodguys) do
  if e1!=e2 then
   local overlaps,dist=ent_collision(e1,e2)
   e1.overlaps=overlaps
   e2.overlaps=overlaps
   if not overlaps then break end
   local ang=atan2(e1.y-e2.y,e1.x-e2.x)
   local force=0.001
   local repelpower=(e1.r+e2.r-dist)/(e1.r+e2.r)
   e1.dx-=cos(ang)*repelpower*force
   e1.dy-=sin(ang)*repelpower*force
   e2.dx+=cos(ang)*repelpower*force
   e2.dy+=sin(ang)*repelpower*force
  end
 end
end

ent_update=function()
 for e in all(entities) do
  if e.selected then
   control_selected(e)
  end
  if e.badguy then
   control_ai(e)
   for gg in all(goodguys) do
    if ent_collision(e,gg) then
     del(entities,gg)
     del(goodguys,gg)
     abducted+=1
    end
   end
  else
   push_other_goodguys(e)
   if fget(mget(e.mx,e.my),7) then
    del(entities,e)
    del(goodguys,gg)
    rescued+=1
   end
  end
  apply_friction(e)
  e.xr+=e.dx
  e.yr+=e.dy
  --map collisions
  find_collisions(e)
  
  --grid translations
  while(e.xr>1) do
   e.xr-=1
   e.mx+=1
  end while(e.xr<0) do
   e.xr+=1
   e.mx-=1
  end while(e.yr>1) do
   e.yr-=1
   e.my+=1
  end while(e.yr<=0) do
   e.yr+=1
   e.my-=1
  end
  --final
  e.x=(e.mx+e.xr)*tilesize
  e.y=(e.my+e.yr)*tilesize
 end
end

ent_draw=function()
 for e in all(entities) do
  color(2)
  spr(e.s,
      e.x-tilesize/2,
      e.y-tilesize/2,
      1,1,e.dx>0)
  if e.selected then
   line(e.x-4,e.y+3,e.x+3,e.y+3)
  end
  if e.overlaps then
   pset(e.mx*tilesize+1,
        e.my*tilesize+1,
        9)
  end
  if e.badguy and debug then
   print(e.state)
   print('x:'..e.x..' y:'..e.y)
   print('dx:'..(e.dx or 0))
   print('dy:'..(e.dy or 0))
   oval(e.x,e.y+10,e.x+8,e.y+14)
  end
 
  if debug then
   rect(e.mx*tilesize,
        e.my*tilesize,
        (e.mx+1)*tilesize,
        (e.my+1)*tilesize)
   circ(e.x,e.y,e.r)
  end
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700ff7777550000000000cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ff757775004000000cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ff7557770944000065556556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777550044440065556556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007000500004400006565560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007000700000a00000565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333333333333330000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbb3b3bbbbb333bbbbb330000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbbbbbbbbbb3bbbbbbb30000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbbbbbbbbbbbbbbbbbbb0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbbbbbbbbbbbbbbbbbbb0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003bbbbbbbbbbbbbbbbbbbbbbb0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033bb33bbbbbbbbbbbbbbbbbb0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333bbbbbbbbbbbbbbbb0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333333355555555555555553333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333333555555555555555555333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333335555555555555555555533
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333335555555555555555555533
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333355555555555555555555553
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333354444444444444444444453
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333344888884848848488888443
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033344333348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333344333348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333344333348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333344333348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333344333348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333344433348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333344433348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333444433348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333334444443348888888488884888888843
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333333333333384888848333443333333333333344333
00000000000000000000000000000000000000000000000000000000000000000000000000000000333333333333333384888848333443333333333333344333
000000000000000000000000000000000000000000000000000000000000000000bbbb000bbbbbb0333333333333333385555558333443333333333333344333
00000000000000000000000000000000000000000000000000000000000000000bbbbbb0bbbbbbb0333333333333333354444445333443334444444444444444
0000000000000000000000000000000000000000000000000000000000000000bbbbb3bbbbbbbbbb333333333333333344444444333443334444444444444444
0000000000000000000000000000000000000000000000000000000000000000bbb3b3b333bbbbb0333333333333333344444444333443333333333333344333
00000000000000000000000000000000000000000000000000000000000000000b3bbb3000b3bbb0333333333333333344444444333443333333333333344333
00000000000000000000000000000000000000000000000000000000000000000000400000440000333333333333333344444444333443333333333333344333
__label__
22244223eee3eee3ee33e2e33ee3eee3eee3ee333333ee3333333333333333333333333333333333eee33333eee3eee33ee33ee3e3e3eee3ee33333333344333
22242323ede3ede3ede3e3e3edd3ded3edd3ede33333de3333333333333333333333333333333333ede33333ede3edd3edd3edd3e3e3edd3ede3333333344333
23242323eee3eed3e3e3e3e3e3333e33ee33e3e333333e3333333333333333333333333333333333e3e33333eed3ee33eee3e333e3e3ee33e3e3333333344333
24242424ede4ede4e4e4e4e4e4444e44ed44e4e444444e4444444444444444444444444444444444e4e44444ede4ed44dde4e444e4e4ed44e4e4444444444444
24242244e2e4eee4eee4dee4dee44e44eee4eee44444eee444444444444444444444444444444444eee44444e4e4eee4eed4dee4dee4eee4eee4444444444444
33344333d3d3ddd3ddd33dd33dd33d33ddd3ddd33333ddd333333333333333333333333333333333ddd33333d3d3ddd3dd333dd33dd3ddd3ddd3333333344333
23244333222322233333222323232223232333332323333322232223333322232233222323333333333333333333333333333333333333333333333333344333
23244233233333233333232323232323232333332323323323233323333323333233232323333333333333333333333333333333333333333333333333344333
32344333222333233333222322232223222333332223333322233223333322233233222322233333333333333333333333333333333333333333333333344333
23244233332333233333232333233323332333333323323323233323333333233233232323233333333333333333333333333333333333333333333333344333
23244333222333233233222333233323332333332223333322232223323322232223222322233333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
22342323333322233333222323232233222333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
23242323323323233333232323233233232333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
23244233333323233333232322233233222333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
23242323323323233333232333233233332333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
22242323333322233233222333232223332333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
22342323333333332223333322332223222322233333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
23242323323333332323333332332323332323233333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
23242223333322232323333332332323332322233333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
23244323323333332323333332332323332333233333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
22242223333333332223323322232223332333233333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
333443333333333333333333333333333bbbbb333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333bbbbbbb33333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333bbbbbbbb3333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333bbbbbbbb3333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333bbbbbbbb3333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333bbbbbbbb3333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333bbbbbbbb3333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443332222222223333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443332332223323333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443332f27772523333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333443332275777223333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333444332275577223333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333444332277775223333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333334444332323332323333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333344444432372227323333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333332222222222222333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333222222222333333333333333333355555555555555555555555533333333333333344333
33344333333333333333333333333333333333333333333333333333233333332333333333333333333555555555555555555555555553333333333333344333
33344333333333333333333333333333333333333333333333333333233222332333333333333333335555555555555555555555555555333333333333344333
33344333333333333333333333333333333333333333333333333333232333232333333333333333335555555555555555555555555555333333333333344333
33344333333333333333333333333333333333333333333333333333292433232333333333333333355555555555555555555555555555533333333333344333
33344333333333333333333333333333333333333333333333333333232444232333333333333333354444444444444444444444444444533333333333344333
33344333333333333333333333333333333333333333333333333333233222332333333333333333344888884848848448488484888884433333333333344333
333443333333333333333333333333333333333333333333333333332333a3332333333333333333348888888488884884888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333222222222222233333333333348888888488884884888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333348888888488884884888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333348888888555555884888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333348888885444444584888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333348888884444444484888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333348888884444444484888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333348888884444444484888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333348888884444444484888848888888433333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333222333333333333333333333333333333333333333333333333333333333333333344333
33344333222222222333333333333333333333333333333333333322222222222333333333333333333333333333333333333333333333333333333333344333
3334433323322233233333333333333333333333333333333333332c2cc323332333333333333333333333333333333333333333333333333333333333344333
333443332f27772523333333333333333333333333333333333332cc2ccc32332333333333333333333333333333333333333333333333333333333333344333
33344333227577722333333333333333333333333333333333333255255562332333333333333333333333333333333333333333333333333333333333344333
33344333227557722333333333333333333333333333333333333255255562332333333333333333333333333333333333333333333333333333333333344333
33344333227777522333333333333333333333333333333333333325265623332333333333333333333333333333333333333333333333333333333333344333
33344333232333232333333333333333333333333333333333333322265223332333333333333333333333333333333333333333333333333333333333344333
33344333237222732333333333333333333333333333333333333222222222222233333333333333333333333333333333333333333333333333333333344333
33344333222222222222233333333333333333333333333333333333222222222333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333222223333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333332333332333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333323333333233333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333332333332333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333222223333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333
33344333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333344333

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303030000000000000000000000000000010303030000000000000000000000000103030300000000000000000808000081010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7f7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b4c7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b5c7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b6c7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b5d5e5e5f7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b6d7c6e6f7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7b7b7b7b7b7b7b7b7b7b7b7b7b7b7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7f7e7e7e7e7e7e7e7e7e7e7e7e7e7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
