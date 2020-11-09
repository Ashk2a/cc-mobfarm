local Utils = {}

function Utils.inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return true end
    end

    return false
end

function Utils.tprint(tbl, indent)
  if tbl == nil then 
    print() 
    return 0
  end
  
  if type(tbl) ~= "table" then 
    print(tbl)
    return 0
  end 
  
  if not indent then
    indent = 0
  end

  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      Utils.tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end

function Utils.tprint2(tbl, indent)
  local str = ""

  if not indent then
    indent = 0
  end

  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      str = str .. formatting .. "\n"
      str = str .. Utils.tprint2(v, indent+1)
    elseif type(v) == 'boolean' then
      str = str .. formatting .. tostring(v) .. "\n"    
    else
      str = str .. formatting .. v .. "\n"
    end
  end
  
  return str
end

function Utils.saveLog(fileName, obj)
  local file = fs.open(fileName .. ".log", "w")

  if type(obj) == "table" then
    file.write(Utils.tprint2(obj))
  else
    file.write(obj)
  end

  --print ("Log has been written to " .. fileName .. ".log\n")

  file.close()
end

return Utils