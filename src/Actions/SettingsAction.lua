local const = require("/src/Constants")

local MobKiller = require("/src/Models/MobKiller")
local Member = require("/src/Models/Member")

local utils = require("/apis/Utils")
local log = utils.saveLog

local View = {
  app = nil,
  back = nil
}

local function initKillers()
  local mobKillers = MobKiller.all()
  for k, mb in pairs(mobKillers) do
      mb:initGui()
  end
end

local function initMembers()

end

function View.Initialise(application)
  View.app = application

  View.back = View.app:GetObject("Back_Button")

  View.back.OnClick = function()
    View.app:LoadView("Home")
  end

  initKillers()
  initMembers()
end

return View