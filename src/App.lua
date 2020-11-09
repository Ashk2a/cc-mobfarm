local bedrockPath='/apis/'
os.loadAPI("/apis/Bedrock.lua")

Bedrock.BasePath = bedrockPath 
Bedrock.ProgramPath = shell.getRunningProgram()

local app = Bedrock:Initialise()

app.DefaultView = "Home"

app.OnViewLoad = function(name)
  local view = require("/src/Actions/" .. name)
  view.Initialise(app)
end

app.OnKeyChar = function(self, event, keychar)
  if keychar == '\\' then
    self:Quit()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
  end
end

app:Run(function()
  term.setTextColor(colours.white)
end)