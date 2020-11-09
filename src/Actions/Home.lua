local Spawner = require("/src/Models/Spawner")
local MobSoul = require("/src/Models/MobSoul")
local utils = require("/apis/Utils")
local log = utils.saveLog

local View = {
  app = nil,
  
  menu = {
    scanner = nil,
    settings = nil,
    reboot = nil
  },
  msList = nil,
  spawners = Spawner.all(),
  mobSouls = MobSoul.all()
}

local function getMsByName(msName)
  for _, v in pairs(View.mobSouls) do
    if v.name == msName then
      return v
    end
  end

  return nil
end

local function updateSpawnersState(state)
  for _, spawner in pairs(View.spawners) do
    spawner.gui.state = state
  end
end

function View.InitMenu()
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

function View.InitMsList()
  View.msList = View.app:GetObject("msList")
  
  local list = {}

  for k, v in pairs(View.mobSouls) do
    table.insert(list, v.name)
  end

  View.msList.Items = list

  View.msList.OnSelect = function(_self, msName)
    local ms = getMsByName(msName)
    updateSpawnersState('select')

    log("test", View.spawners)
  end
end

function View.InitSpawners()
  for _, spawner in pairs(View.spawners) do
    spawner.button = View.app:GetObject("Spawner_" .. spawner.id .. "_Label")
    spawner.label = View.app:GetObject("Spawner_" .. spawner.id .. "_Button")
  end

  log("test", View.spawners)
end

function View.Initialise(application)
  View.app = application

  View.InitMenu()
  View.InitSpawners()
  View.InitMsList()
end

return View