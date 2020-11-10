local tables = require("/apis/Tables")
local json = require("/apis/Json")

local _mobkillers = tables.get("mob_killer")
local _caches = {
  all = nil
}

local view = nil

local MobKiller = {}

function MobKiller:new(data)
  local mk = data
  
	setmetatable(mk, self)
	self.__index = self
	return mk
end

function MobKiller:initGui(parentView)
  view = parentView
end

function MobKiller:refresh()
  local raws = MobKiller.raws()
  local raw = raws[self.name]
  self.active = raw.active
end

function MobKiller:save()
  local raws = MobKiller.raws()

  -- serialize
  raws[self.name].active = self.active

  _mobkillers["data"] = json.encode(raws)
  _mobkillers:save()
end

-- GLOBAL

function MobKiller.all()
  if _caches.all == nil then
    local raws = MobKiller.raws()
    _caches.all = {}

    for k, data in pairs(raws) do
      data.name = k
      _caches.all[k] = MobKiller:new(data)
    end
  end

  return _caches.all
end

function MobKiller.raws()
  return json.decode(_mobkillers:getData())
end

function MobKiller.getOneByHash(msHash)
  return MobKiller.all()[msHash]
end

function MobKiller.getOneByName(mkName)
  local all = MobKiller.all()
  
  for _, mk in pairs(all) do
      if mk.name == mkName then
        return mk
      end
  end

  return nil
end

return MobKiller