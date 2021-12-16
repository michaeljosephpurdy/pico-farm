Repel = {
  ent = function(e1, e2)
    if e1 == e2 then return end

    local overlaps,dist=Collision.ent(e1,e2)
    if not overlaps then return end

    e1.overlaps=overlaps
    e2.overlaps=overlaps
    
    local ang=atan2(e1.y-e2.y,e1.x-e2.x)
    local force=0.001
    local repelpower=(e1.r+e2.r-dist)/(e1.r+e2.r)
    
    e1.dx -= cos(ang) * repelpower * force
    e1.dy -= sin(ang) * repelpower * force

    e2.dx += cos(ang) * repelpower * force
    e2.dy += sin(ang) * repelpower * force
  end
}