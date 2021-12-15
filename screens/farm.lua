Farm={
  rescued = 0,
  abducted = 0,
  init = function()
    --ent_new(100,100,'ufo')
    ent_new(100,100,'ufo')
    ent_new(20,20,'cow')
    ent_new(40,40,'cow')
    ent_new(60,60,'chicken')
    ent_new(10,80,'cow')
    ent_new(80,10,'pig')
    ent_new(60,68,'chicken')
    for y=1,16 do
      for x=1,16 do
        local tile=mget(x,y)
        if fget(tile,3) then
          Coverage:new(x, y, tile)
        end
      end
    end
    EntitySelection:new()
  end,
  update=function(self)
    EntitySelection:update()
    for e in all(goodguys) do
      e:update()
    end
    for e in all(badguys) do
      e:update()
    end
  end,
  draw=function(self)
    cls()
    map()
    for e in all(goodguys) do
      e:draw()
    end
    Coverage:draw()
    for e in all(badguys) do
      e:draw_bg()
    end
    for e in all(badguys) do
      e:draw()
    end
    pprint('abducted ' .. self.abducted, 8, 0)
    pprint(self.rescued .. ' rescued', 80, 0)
  end,
}
