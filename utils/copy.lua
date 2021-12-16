Copy = function(to, from)
  for k, v in all(from) do
    to[k] = v
  end
  return to
end