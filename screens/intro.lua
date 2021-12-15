Intro={
  init = function(self)
  end,
  update = function(self)
    if btnp(❎) then
      gamestate='farm'
    end
  end,
  draw = function(self)
    cls()
    print('help the animals',35,20)
    print('get to the barn', 36,40)
    print('press ❎ to begin',30,100)
  end,
}
