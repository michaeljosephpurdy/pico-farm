Log={
  msg=function(msg)
    printh(msg, 'picofarm')
  end,
  table=function(t)
    Log.msg('{')
    for k,v in t do
      Log.msg(' ' .. k .. ': ' .. v)
    end
    Log.msg('}')
  end,
}