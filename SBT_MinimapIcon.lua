local context = _G.SBT_MinimapIcon_Context
if not context then return end

local ldb = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)
local BrokerObject

if ldb then
  BrokerObject = ldb:NewDataObject("SkinningBeastTracker", {
    type = "launcher",
    text = "SBT",
    icon = "Interface\\Icons\\Spell_magic_polymorphchicken",
    OnClick = function(_, button)
      if button == "LeftButton" then
        context.listFrame:ToggleUI()
      elseif button == "RightButton" then
        context.mainFrame:ToggleUI()
      end
    end,
    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then return end
      local total, killed = 0, 0
      local charName = UnitName("player").." - "..GetRealmName()
      if _G[context.dbName] and _G[context.dbName][charName] then
        for _, q in ipairs(context.quests) do
          total = total + 1
          if _G[context.dbName][charName].quests[q.id] then killed = killed + 1 end
        end
      end
      tooltip:AddLine("Skinning Beast Tracker")
      tooltip:AddLine("Bosses killed: "..killed.."/"..total)
      tooltip:AddLine("|cff00ff00Left-Click:|r Toggle Unkilled List")
      tooltip:AddLine("|cff00ff00Right-Click:|r Toggle Main UI")
    end,
  })
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
  if addonName == "SkinningBeastTracker" then
    _G[context.dbName] = _G[context.dbName] or {}
    _G[context.dbName].minimap = _G[context.dbName].minimap or { hide = false, minimapPos = 180 }

    if LDBIcon and BrokerObject then
      LDBIcon:Register("SkinningBeastTracker", BrokerObject, _G[context.dbName].minimap)
      LDBIcon:Show("SkinningBeastTracker")
    end
  end
end)
