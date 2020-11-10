local tables = require("/apis/Tables")
local json = require("/apis/Json")

local _mobSouls = tables.get("mob_soul")
local _caches = {
  all = nil
}

local MobSoul = {}

function MobSoul:new(data)
  local ms = data
  
	setmetatable(ms, self)
	self.__index = self
	return ms
end

function MobSoul:refresh()
  local raws = MobSoul.raws()
  local raw = raws[self.hash]
  self.name = raw.name
end

function MobSoul:save()
  local raws = MobSoul.raws()

  -- serialize
  raws[self.hash].name = self.name

  _mobSouls["data"] = json.encode(raws)
  _mobSouls:save()
end

-- GLOBAL

function MobSoul.all()
  if _caches.all == nil then
    local raws = MobSoul.raws()
    _caches.all = {}

    for k, data in pairs(raws) do
      data.hash = k
      _caches.all[k] = MobSoul:new(data)
    end
  end

  return _caches.all
end

function MobSoul.raws()
  return json.decode(_mobSouls:getData())
end

function MobSoul.getOneByHash(msHash)
  return MobSoul.all()[msHash]
end

function MobSoul.getOneByName(msName)
  local all = MobSoul.all()
  
  for _, ms in pairs(all) do
      if ms.name == msName then
        return ms
      end
  end

  return nil
end

return MobSoul