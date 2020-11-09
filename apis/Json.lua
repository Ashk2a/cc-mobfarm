------------------------------------------------------------------ utils
local Json = {}

Json.controls = {["\n"]="\\n", ["\r"]="\\r", ["\t"]="\\t", ["\b"]="\\b", ["\f"]="\\f", ["\""]="\\\"", ["\\"]="\\\\"}

function Json.isArray(t)
  local max = 0
  for k,v in pairs(t) do
    if type(k) ~= "number" then
      return false
    elseif k > max then
      max = k
    end
  end
  return max == #t
end

Json.whites = {['\n']=true; ['\r']=true; ['\t']=true; [' ']=true; [',']=true; [':']=true}
function Json.removeWhite(str)
  while Json.whites[str:sub(1, 1)] do
    str = str:sub(2)
  end
  return str
end

------------------------------------------------------------------ encoding

function Json.encodeCommon(val, pretty, tabLevel, tTracking)
  local str = ""

  -- Tabbing util
  local function tab(s)
    str = str .. ("\t"):rep(tabLevel) .. s
  end

  local function arrEncoding(val, bracket, closeBracket, iterator, loopFunc)
    str = str .. bracket
    if pretty then
      str = str .. "\n"
      tabLevel = tabLevel + 1
    end
    for k,v in iterator(val) do
      tab("")
      loopFunc(k,v)
      str = str .. ","
      if pretty then str = str .. "\n" end
    end
    if pretty then
      tabLevel = tabLevel - 1
    end
    if str:sub(-2) == ",\n" then
      str = str:sub(1, -3) .. "\n"
    elseif str:sub(-1) == "," then
      str = str:sub(1, -2)
    end
    tab(closeBracket)
  end

  -- Table encoding
  if type(val) == "table" then
    assert(not tTracking[val], "Cannot encode a table holding itself recursively")
    tTracking[val] = true
    if Json.isArray(val) then
      arrEncoding(val, "[", "]", ipairs, function(k,v)
        str = str .. Json.encodeCommon(v, pretty, tabLevel, tTracking)
      end)
    else
      arrEncoding(val, "{", "}", pairs, function(k,v)
        assert(type(k) == "string", "JSON object keys must be strings", 2)
        str = str .. Json.encodeCommon(k, pretty, tabLevel, tTracking)
        str = str .. (pretty and ": " or ":") .. Json.encodeCommon(v, pretty, tabLevel, tTracking)
      end)
    end
  -- String encoding
  elseif type(val) == "string" then
    str = '"' .. val:gsub("[%c\"\\]", Json.controls) .. '"'
  -- Number encoding
  elseif type(val) == "number" or type(val) == "boolean" then
    str = tostring(val)
  else
    error("JSON only supports arrays, objects, numbers, booleans, and strings", 2)
  end
  return str
end

function Json.encode(val)
  return Json.encodeCommon(val, false, 0, {})
end

function Json.encodePretty(val)
  return Json.encodeCommon(val, true, 0, {})
end

------------------------------------------------------------------ decoding

Json.decodeControls = {}
for k,v in pairs(Json.controls) do
  Json.decodeControls[v] = k
end

function Json.parseBoolean(str)
  if str:sub(1, 4) == "true" then
    return true, Json.removeWhite(str:sub(5))
  else
    return false, Json.removeWhite(str:sub(6))
  end
end

function Json.parseNull(str)
  return nil, Json.removeWhite(str:sub(5))
end

Json.numChars = {['e']=true; ['E']=true; ['+']=true; ['-']=true; ['.']=true}
function Json.parseNumber(str)
  local i = 1
  while Json.numChars[str:sub(i, i)] or tonumber(str:sub(i, i)) do
    i = i + 1
  end
  local val = tonumber(str:sub(1, i - 1))
  str = Json.removeWhite(str:sub(i))
  return val, str
end

function Json.parseString(str)
  str = str:sub(2)
  local s = ""
  while str:sub(1,1) ~= "\"" do
    local next = str:sub(1,1)
    str = str:sub(2)
    assert(next ~= "\n", "Unclosed string")

    if next == "\\" then
      local escape = str:sub(1,1)
      str = str:sub(2)

      next = assert(Json.decodeControls[next..escape], "Invalid escape character")
    end

    s = s .. next
  end
  return s, Json.removeWhite(str:sub(2))
end

function Json.parseArray(str)
  str = Json.removeWhite(str:sub(2))

  local val = {}
  local i = 1
  while str:sub(1, 1) ~= "]" do
    local v = nil
    v, str = Json.parseValue(str)
    val[i] = v
    i = i + 1
    str = Json.removeWhite(str)
  end
  str = Json.removeWhite(str:sub(2))
  return val, str
end

function Json.parseObject(str)
  str = Json.removeWhite(str:sub(2))

  local val = {}
  while str:sub(1, 1) ~= "}" do
    local k, v = nil, nil
    k, v, str = Json.parseMember(str)
    val[k] = v
    str = Json.removeWhite(str)
  end
  str = Json.removeWhite(str:sub(2))
  return val, str
end

function Json.parseMember(str)
  local k = nil
  k, str = Json.parseValue(str)
  local val = nil
  val, str = Json.parseValue(str)
  return k, val, str
end

function Json.parseValue(str)
  local fchar = str:sub(1, 1)
  if fchar == "{" then
    return Json.parseObject(str)
  elseif fchar == "[" then
    return Json.parseArray(str)
  elseif tonumber(fchar) ~= nil or Json.numChars[fchar] then
    return Json.parseNumber(str)
  elseif str:sub(1, 4) == "true" or str:sub(1, 5) == "false" then
    return Json.parseBoolean(str)
  elseif fchar == "\"" then
    return Json.parseString(str)
  elseif str:sub(1, 4) == "null" then
    return Json.parseNull(str)
  end
  return nil
end

function Json.decode(str)
  str = Json.removeWhite(str)
  t = Json.parseValue(str)
  return t
end

function Json.decodeFromFile(path)
  local file = assert(fs.open(path, "r"))
  local decoded = Json.decode(file.readAll())
  file.close()
  return decoded
end

return Json