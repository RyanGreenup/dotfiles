function Reverse(tbl)
  local reversed_tbl = {}
  for i = #tbl, 1, -1 do
    table.insert(reversed_tbl, tbl[i])
  end
  return reversed_tbl
end
