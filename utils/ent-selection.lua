local function cycle_ents(self, i)
 self.last_selected_ent=self.selected_ent
 local mx=self.selected_ent_mx
 local found=false
 while not found do
  local ents_at_mx=self.sorted_ents[mx]
  for e in all(ents_at_mx) do
   if e!=self.selected_ent then
    found=true
    self.selected_ent=e
    self.selected_ent_mx=e.mx
    self.selected_ent_my=e.my
    e.selected=true
    if self.last_selected_ent then
     self.last_selected_ent.selected=false
    end
    break
   end
  end
  mx+=i--todo fix this
  if mx>16 then
   mx=0
  elseif mx<0 then
   mx=16
  end
  if mx==self.selected_ent_mx then
   found=true
  end
 end
end

EntitySelection={
 selected_ent=nil,
 last_selected_ent=nil,
 selected_ent_mx=1,
 selected_ent_my=1,
 selected_ent_x=1,
 selected_ent_y=1,
 sorted_ents={},
 new=function(self)
  self:next()
 end,
 update=function(self)
  if btnp(❎) then
    self:next()
  end
  if btnp(🅾️) then
    self:prev()
  end
  sorted={}
  for gg in all(goodguys) do
    if not sorted.gg then
      sorted[gg.mx]={}
    end
    add(sorted[gg.mx], gg)
  end
  self.sorted_ents=sorted
 end,
 next=function(self)
  cycle_ents(self, 1)
 end,
 prev=function(self)
  cycle_ents(self, -1)
 end,
}