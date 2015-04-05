function inTable(t, v)
  for _,v2 in pairs(t) do
    if v == v2 then
      return true
    end
  end
  return false
end

function iSlice(t, start, stop)
  res = {}

  for i,v in ipairs(t) do
      if i >= start and i < stop then
        table.insert(res, v)
      end
  end

  return res
end

function reverse(t)
  res = {}

  for i,v in ipairs(t) do
    res[#t-i+1] = v
  end

  return res
end

function isEmpty(t)
  return next(t) == nil
end

function concatTable(t1, t2)
  res = {}

  for _,v in ipairs(t1) do
    table.insert(res, v)
  end
  for _,v in ipairs(t2) do
    table.insert(res, v)
  end

  return res
end

function tableEqual(t1, t2)
  if type(t1) ~= "table" or type(t2) ~= "table" then
    return t1 == t2
  end

  if #t1 ~= #t2 then
    return false
  end

  for i=1,#t1 do
    if not tableEqual(t1[i], t2[i]) then return false end
  end

  return true
end
