local tables = require("/apis/Tables")
local json = require("/apis/Json")

local _spawners = tables.get("spawner")

local Spawner = {}

function Spawner:new(data)
  local s = data
  -- virtual for GUI
  s.gui = {
    button = nil,
    label = nil,
    state = 'default'
  }

	setmetatable(s, self)
	self.__index = self
	return s
end

function Spawner:refresh()
  local rawSpawners = Spawner.all(true)
  local raw = rawSpawners[self.id]
  
  self.soulHash = raw.soulHash
  self.active = raw.active
  
  return self
end

function Spawner:save()
  local rawSpawners = Spawner.all(true)

  -- serialize
  rawSpawners[self.id].soulHash = self.soulHash
  rawSpawners[self.id].active = self.active

  _spawners["data"] = json.encode(rawSpawners)
  _spawners:save()

  return self
end

function Spawner.all(raw)
  raw = raw or false

  local rawSpawners = json.decode(_spawners:getData())
  local results = {}

  if raw == false then
    for k, data in pairs(rawSpawners) do
      data.id = k
      table.insert(results, Spawner:new(data))
    end
  else
    results = rawSpawners
  end

  return results
end

return Spawner