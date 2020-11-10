local json = require("/apis/Json")

local AppData = {}

AppData.numChars = "/.appData"

if fs.exists(AppData.numChars) == false then
  fs.makeDir(AppData.numChars)
elseif fs.isDir(AppData.numChars) == false then
  fs.delete(AppData.numChars)
  fs.makeDir(AppData.numChars)
end

AppData.File = {}
function AppData.File:__tostring()
  return self.type ..": ".. self.path 
end

function AppData.File:new (o)
  local p = o or {}   -- create object if user does not provide one
  setmetatable(p, self)
  self.__index = self
  if o then
    p["path"]= o["path"] or ""
    p["name"] = o["name"] or ""
  else
    p["name"] = ""
    p["path"]= ""
  end
  p["type"]= "file"
  return p
end

function AppData.File:getData()
  local handle = fs.open(self.path, "r")
  self["data"] = handle.readAll()
  handle.close()
  return self["data"]
end

function AppData.File:save()
  local data = self["data"] or ""
  
  local handle = fs.open(self.path, "w")
  handle.write(data)
  handle.close()
end

function AppData.File:append(data)
  local handle = fs.open(self.path, "a")
  handle.write(data)
  handle.close()
end

function AppData.File:delete()
  fs.delete(self.path)
end

AppData.Directory = {}
function AppData.Directory:__tostring()
  return self.type ..": ".. self.path 
end

function AppData.Directory:new (o)
  p = o or {}   -- create object if user does not provide one
  setmetatable(p, self)
  self.__index = self
  if o then
    p["path"]= o["path"] or ""
    p["name"] = o["name"] or ""
  else
    p["name"] = ""
    p["path"]= ""
  end
  p["type"]= "dir"
  p["items"]= {}
  return p
end

function AppData.Directory:parseFiles()
  local items = fs.list(self.path)
  for k, v in pairs(items) do
    local path = fs.combine(self.path, v)
    
    if fs.isDir(path) then
      self.items[v] = AppData.Directory:new({name=v, path=path})
      self.items[v]:parseFiles()
    else
      self.items[v] = AppData.File:new({name=v, path=path})
    end
  end
end

function AppData.Directory:getFiles()
  local files = {}
  for k, v in pairs(self.items) do
    if v.type == 'file' then
      table.insert(files, v)
    end
  end
  return files
end

function AppData.Directory:getFileByName(name)
  for k, v in pairs(self.items) do
    if v.type == 'file' and v.name == name then
      return v
    end
  end
  return nil
end

function AppData.Directory:getDirs()
  local files = {}
  for k, v in pairs(self.items) do
    if v.type == 'dir' then
      table.insert(files, v)
    end
  end
  return files
end

function AppData.Directory:getDirByName(name)
  for k, v in pairs(self.items) do
    if v.type == 'dir' and v.name == name then
      return v
    end
  end
  return nil
end

function AppData.Directory:createFile(name)
  if self:getFileByName(name) ~= nil or self:getDirByName(name)then
    return self:getFileByName(name)
  end
  local handle = fs.open(fs.combine(self.path, name), "a")
  self.items[name] = AppData.File:new({name=name, path=fs.combine(self.path, name)})
  handle.close()
  return self.items[name]
end

function AppData.isDataPresent(appName)
  if fs.isDir(fs.combine(AppData.numChars, appName)) then
    return true
  end
  return false
end

function AppData.get(appName)
  local data = AppData.Directory:new({path=fs.combine(AppData.numChars, appName), name=appName})
  if AppData.isDataPresent(appName) == false then
    fs.makeDir(fs.combine(AppData.numChars, appName))
    return data
  end
  data:parseFiles()
  return data
end

function AppData.getFile(appName, filePath, jsonData)
  jsonData = jsonData or false
  local data = AppData.get(appName)
  local file = data:createFile(filePath)
  
  if file == nil then
    error(appName .. " doesn't exist!\n")
  end
  file:getData()
  if jsonData then
    return json.decode(file:getData())
  end
  return file
end

function AppData.saveData(dataObject)
end


return AppData