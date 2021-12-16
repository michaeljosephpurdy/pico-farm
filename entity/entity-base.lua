BaseEntity = {
  new = function(x, y, t)
    local ent = {}
    setmetatable(ent, BaseEntity)
    ent.x, ent.y = x, y
    ent.dx, ent.dy = 0,0
    ent.mx = flr(x / TILESIZE)
    ent.my = flr(y / TILESIZE)
    ent.xr, ent.yr = 0.5, 0.5
    ent.t = t
    ent.selected=false
    return ent
  end,
  update = function(self)
    -- reset states
    self.overlaps = false

    --pre-update
    if self.pre_update then
      self:pre_update()
    end

    --apply friction
    if not self.ignore_friction then
     self.dx *= 0.85
     self.dy *= 0.85
     self.xr += self.dx
     self.yr += self.dy
    end
 
    --map collisions
    local flying = self.ignores_collisions
    if self.xr > 0.75 and
       Collision.map(self.mx + 1, self.my, flying) then
     self.xr=.75
     if self.bounce then
      self.dx=-self.dx
     end
    elseif self.xr<.25 and
       Collision.map(self.mx-1, self.my,flying) then
     self.xr=.25
     if self.bounce then
      self.dx=-self.dx
     end
    end if self.yr>.75 and
       Collision.map(self.mx,self.my+1,flying) then
     self.yr=.75
     if self.bounce then
      self.dy=-self.dy
     end
    elseif self.yr<.25 and
       Collision.map(self.mx,self.my-1,flying) then
     self.yr=.25
     if self.bounce then
      self.dy=-self.dy
     end
    end

    --grid translations
    while(self.xr>1) do
     self.xr -= 1
     self.mx += 1
    end while(self.xr<0) do
     self.xr += 1
     self.mx -= 1
    end while(self.yr>1) do
     self.yr -= 1
     self.my += 1
    end while(self.yr<=0) do
     self.yr += 1
     self.my -= 1
    end
 
    -- post update
    if (self.post_update) then
      self:post_update()
    end

    -- final
    self.x = (self.mx + self.xr) * TILESIZE
    self.y = (self.my + self.yr) * TILESIZE

    -- final update
    if (self.final_update) then
       self:final_update()
    end
  end,
  draw = function(self)
    if self.hidden then return end
    local x = self.x - TILESIZE / 2
    local y = self.y - TILESIZE / 2
    color(9)
    spr(self.s, x, y, 1, 1, self.dx > 0)
    if self.selected then
      line(self.x - 4, self.y + 5, self.x + 3, self.y + 5)
    end
  end,
}
BaseEntity.__index = BaseEntity