local _timer = {}
Timer = {
  add = function(_table, field_name, new_value, time)
    Log.msg(_table)
    Log.msg(field_name)
    Log.msg(new_value)
    Log.msg(time)
    add(_timer,{ _table=_table, field_name=field_name, time=time, new_value=new_value})
  end,
  update = function()
      Log.msg(#_timer)
    for t in all(_timer) do
      t.time -= 1
      if t.time < 0 then
        t._table[t.field_name]=t.new_value
        del(_timer, t)
      end
    end
  end,
}