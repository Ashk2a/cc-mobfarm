local View = {}
local app = nil

function View.Initialise(application)
  app = application
  local back = app:GetObject("Back_Button")

  back.OnClick = function(_self)
    app:LoadView("Home")
  end
end

return View