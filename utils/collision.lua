local function ent_collision(e1,e2)
  if e1 == e2 then return false end
  if abs(e1.mx - e2.mx) >= 2 and abs(e1.my - e2.my) >= 2 then
    return false, 0
  end
  local max_dist = e1.r + e2.r
  local dist_sqr = (e1.x - e2.x) * (e1.x - e2.x) +
                   (e1.y - e2.y) * (e1.y - e2.y)
  return dist_sqr <= max_dist * max_dist, dist_sqr
end

local function map_collision(mx,my,flying)
 local flags=fget(mget(mx,my))
 if flying then
  return flags==1
 end
 return flags==1 or flags==3
end

Collision = {
  __index=Collision,
  ent=ent_collision,
  map=map_collision
}