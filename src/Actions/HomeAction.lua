local const = require("/src/Constants")

local Spawner = require("/src/Models/Spawner")
local MobSoul = require("/src/Models/MobSoul")

local utils = require("/apis/Utils")
local log = utils.saveLog

local View = {
  app = nil,
  menu = {},
  msList = nil,
  lastSelection = nil,
}

local function InitMenu()
  View.menu.scanner = View.app:GetObject("Scanner")
  View.menu.settings = View.app:GetObject("Settings")
  View.menu.reboot = View.app:GetObject("Reboot")

  View.menu.scanner.OnClick = function(_self)
    View.app:LoadView("Scanner")
  end

  View.menu.settings.OnClick = function(_self)
    View.app:LoadView("Settings")
  end

  View.menu.reboot.OnClick = function(_self)
    View.app:Quit()
    shell.run("Kernel.lua")
  end
end

local function InitMsList()
  View.msList = View.app:GetObject("msList")

  local list = {}

  for _, ms in pairs(MobSoul.all()) do
    table.insert(list, ms.name)
  end

  table.sort(list)
  View.msList.Items = list

  View.msList.OnSelect = function(_self)
    if View.lastSelection == _self.Selected and View.lastSelection ~= nil then
      Spawner.updateAllStates(const.states.default)
      _self.NeedsItemUpdate = true
    else
      Spawner.updateAllStates(const.states.selection)
      View.lastSelection = _self.Selected
    end
  end
end

local function InitSpawners()
  for _, spawner in pairs(Spawner.all()) do
    spawner:initGui(View)
  end
end

function View.Initialise(application)
  View.app = application

  InitMenu()
  InitSpawners()
  InitMsList()
end

return View