local Tables = {}

local appData = require("/apis/AppData")
local json = require("/apis/Json")

function Tables.get(tableName, onlyData)
  onlyData = onlyData or false
  
  local data = appData.get("tables")
  local file = data:createFile(tableName .. ".json")
  
  if file == nil then
    error("Table " .. tableName .. " doesn't exist!\n")
  end

  file:getData()
  if onlyData then
    return json.decode(file:getData())
  end

  return file
end

return Tables