local addon = LibStub("AceAddon-3.0"):NewAddon("SkinningBeastTracker")

local quests = {
  {id=88545, name="Gloomclaw"},
  {id=88526, name="Silverscale"},
  {id=88531, name="Lumenfin"},
  {id=88532, name="Umbrafang"},
  {id=88524, name="Netherscythe"},
}

-- Configurable DB name
local dbName = "SBT_Storage"

local utils = _G.SBT_Utils or {}
local HasResetPassed = utils.HasResetPassed
local function UpdateCharacterData()
  return utils.UpdateCharacterData(dbName, quests)
end

_G.SBT_Shared_Context = {
  dbName = dbName,
  quests = quests,
  HasResetPassed = HasResetPassed,
  UpdateCharacterData = UpdateCharacterData,
}

_G.SBT_MinimapIcon_Context = {
  dbName = dbName,
  quests = quests,
}

SLASH_SKINNINGBEASTTRACKER1 = "/sbt"
SlashCmdList["SKINNINGBEASTTRACKER"] = function()
  local frame = _G.SBT_MinimapIcon_Context and _G.SBT_MinimapIcon_Context.mainFrame
  if frame and frame.ToggleUI then
    frame:ToggleUI()
  end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SkinningBeastTracker" then
        _G[dbName] = _G[dbName] or {}
        _G[dbName].minimap = _G[dbName].minimap or { hide = false, minimapPos = 180 }

        UpdateCharacterData()
    end
end)
