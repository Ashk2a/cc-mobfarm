local tables = require("/apis/Tables")
local json = require("/apis/Json")

local _members = tables.get("mob_killer")
local _caches = {
  all = nil
}

local view = nil

local Member = {}

function Member:new(data)
  local m = data
  
	setmetatable(m, self)
	self.__index = self
	return m
end

function Member:initGui(parentView)
  view = parentView
end

function Member:save()
  local raws = Member.raws()

  -- serialize
  raws[self.id].name = self.name

  _members["data"] = json.encode(raws)
  _members:save()
end

-- GLOBAL

function Member.all()
  if _caches.all == nil then
    local raws = Member.raws()
    _caches.all = {}

    for k, data in pairs(raws) do
      data.id = k
      _caches.all[k] = Member:new(data)
    end
  end

  return _caches.all
end

function Member.raws()
  return json.decode(_members:getData())
end

function Member.getOneByName(memberName)
  local all = Member.all()
  
  for _, member in pairs(all) do
      if member.name == memberName then
        return member
      end
  end

  return nil
end

return Member