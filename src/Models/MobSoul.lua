local tables = require("/apis/Tables")
local json = require("/apis/Json")

local _mobSouls = tables.get("mob_soul")

local MobSoul = {} -- [hash]

function MobSoul:new(data)
  local ms = data
  
	setmetatable(ms, self)
	self.__index = self
	return ms
end

function MobSoul:refresh()
  local rawMobSouls = MobSoul.all(true)
  local raw = rawMobSouls[self.hash]
  self.name = raw.name
  
  return self
end

function MobSoul:save()
  local rawMobSouls = MobSoul.all(true)

  -- serialize
  rawMobSouls[self.hash].name = self.name

  _mobSouls["data"] = json.encode(rawMobSouls)
  _mobSouls:save()

  return self
end

function MobSoul.all(raw)
  raw = raw or false
  
  local rawMobSouls = json.decode(_mobSouls:getData())
  local results = {}

  if raw == false then
    for hash, data in pairs(rawMobSouls) do
      data.hash = hash
      table.insert(results, MobSoul:new(data))
    end
  else
    results = rawMobSouls
  end

  return results
end

return MobSoul