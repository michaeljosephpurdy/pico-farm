local coverage = {}
Coverage = {
  coverage = {},
  new = function(self, mx, my, s)
    add(self.coverage, {
      x = mx * TILESIZE,
      y = my * TILESIZE,
      s = s + 16,
    })
  end,
  draw = function(self)
    for c in all(self.coverage) do
      spr(c.s, c.x, c.y)
    end
  end,
}
