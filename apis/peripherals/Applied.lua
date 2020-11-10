local const = require("/src/Constants")

local Applied = {
  ae2 = nil
}

function Applied.init(sideOrName)
  Applied.ae2 = peripheral.wrap(sideOrName)
  if Applied.ae2 == nil then
    error("Cannot initiliase applied module")
  end
end

function Applied.itemFormat (id, nbtHash, damage)
  return {id=id, dmg=damage or 0, nbt_hash=nbtHash or ''}
end

function Applied.getQuantity(item)
  local detail = Applied.ae2.getItemDetail(item)

  return detail.basic().qty
end

function Applied.exportItem(item, sideOrName, quantity)
  quantity = quantity or 1
  sideOrName = sideOrName or const.sides.TOP
  Applied.ae2.exportItem(item, sideOrName, quantity)
end

