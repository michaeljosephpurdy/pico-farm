entities={}
badguys={}
goodguys={}

local data={
  cow={
    s=1, speed=0.04, r=3,
    pre_update=Goodguy.update,
  },
  chicken={
    s=2,speed=0.1,r=2,
    pre_update=Goodguy.update,
  },
  pig={
    s=4,speed=0.05,r=2,
    pre_update=Goodguy.update,
  },
  ufo={
    s=3,speed=0.1,r=4,
    badguy=true,
    beam_anim=16,
    beam_anim_start=16,
    beam_anim_end=19,
    pre_update=Badguy.ufo_update,
    draw_bg=Badguy.ufo_draw_bg,
    draw=Badguy.ufo_draw,
    ignores_collisions=true,
    show_beam=false,
    show_spotlight=true,
    bounce=true,
    state='idle',
    state_t=40,
 },
 spotlight={
  s=20, speed=0.2, r=2,
  badguy=true,
  pre_update=Badguy.spotlight_update,
  draw_bg=function(self)
  end,
  post_update=function(self)
    self.hidden = false
  end,
 }
}

ent_new=function(x,y,t)
  local e = BaseEntity.new(x, y, t)
  assert(data[t], t..' not found in data')
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