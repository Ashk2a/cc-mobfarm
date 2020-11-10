local const = require("/src/Constants")

local MobSoul = require("/src/Models/MobSoul")

local tables = require("/apis/Tables")
local json = require("/apis/Json")
local utils = require("/apis/Utils")
local log = utils.saveLog

local _spawners = tables.get("spawner")
local _caches = {
  all = nil
}

local view = nil

local Spawner = {}

function Spawner:new(data)
  local s = data
  -- virtual for GUI
  s.mobSoul = nil
  s.gui = {
    state = const.states.default,

    -- callback register
    cb = {
      [const.states.default] = {
        onClick = Spawner.updateActiveStatus,
        onUpdate = Spawner.setDefaultState
      },
      [const.states.selection] = {
        onClick = Spawner.updateLinkedSoul,
        onUpdate = Spawner.setSelectionState,
      }
    }
  }

	setmetatable(s, self)
	self.__index = self
	return s
end

function Spawner:initGui(parentView)
    view = parentView
    self.mobSoul = MobSoul.getOneByHash(self.mobSoulHash)

    self.gui.button = view.app:GetObject(string.format(const.formats.spawner_button, self.id))
    self.gui.label = view.app:GetObject(string.format(const.formats.spawner_label, self.id))
    
    self:updateState(const.states.default)

    self.gui.button.OnClick = function()
      local cb = self.gui.cb[self.gui.state].onClick
      cb(self)
    end
end

--#################
-- Start callbacks
--#################
function Spawner:updateActiveStatus()
  self.active = not self.active
  self:save()
end

function Spawner:updateLinkedSoul()
  local selectedMsName = view.msList.Selected.Text
  local ms = MobSoul.getOneByName(selectedMsName)
  
  if ms.hash ~= self.mobSoul.hash then
    self.mobSoul = ms
    self:save()
  end

  Spawner.updateAllStates(const.states.default)
  view.msList.NeedsItemUpdate = true
end

function Spawner:setDefaultState()
  self.gui.button.BackgroundColour = 'red'
  self.gui.button.ActiveBackgroundColour = 'green'
  self.gui.button.Toggle = self.active
  self.gui.label.Text = self.mobSoul == nil and const.empty or self.mobSoul.name
end

function Spawner:setSelectionState()
  self.gui.button.BackgroundColour = 'gray'
  self.gui.button.ActiveBackgroundColour = 'gray'
end
--#################
-- End callbacks
--#################

function Spawner:updateState(newState)
  self.gui.state = newState

  local cb = self.gui.cb[self.gui.state].onUpdate
  cb(self)
end

function Spawner:refresh()
  local raws = Spawner.raws()
  local raw = raws[self.id]
  
  self.mobSoulHash = raw.mobSoulHash
  self.active = raw.active

  -- virtual
  self.mobSoul = MobSoul.getOneByHash(self.mobSoulHash)
end

function Spawner:save()
  local raws = Spawner.raws()

  -- serialize
  raws[self.id].mobSoulHash = self.mobSoul == nil and '' or self.mobSoul.hash
  raws[self.id].active = self.active

  _spawners["data"] = json.encode(raws)
  _spawners:save()
end

--#################
-- Start globals
--#################

function Spawner.updateAllStates(newState)
  local all = Spawner.all()

  for _, spawner in pairs(all) do
      spawner:updateState(newState)
  end
end

function Spawner.all()
  if _caches.all == nil then
    local raws = Spawner.raws()
    _caches.all = {}

    for k, data in pairs(raws) do
      data.id = k
      table.insert(_caches.all, Spawner:new(data))
    end
  end

  return _caches.all
end

function Spawner.raws()
  return json.decode(_spawners:getData())
end

--#################
-- End globals
--#################

return Spawner