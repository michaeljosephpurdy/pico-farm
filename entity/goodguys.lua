Goodguy = {
  update = function(e)
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
    for e2 in all(goodguys) do
      Repel.ent(e, e2)
    end
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
  end,
}