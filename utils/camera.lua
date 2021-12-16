local shakes = {}
Camera = {
  add_shake=function(time)
    add(shakes, {
      t = time or 5,
    })
  end,
  update=function()
    local shake = shakes[1]
    if not shake then return end
    shake.t -= 1
    if shake.t <= 0 then
      del(shakes, shake)
    end
  end,
  draw=function()
    if not shakes[1] then return end
    camera(rnd(1)+.5, rnd(1)+.5)
  end,
}