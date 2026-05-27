local sharedContext = _G.SBT_Shared_Context
local minimapContext = _G.SBT_MinimapIcon_Context
if not sharedContext or not minimapContext then return end

local dbName = sharedContext.dbName
local quests = sharedContext.quests
local UpdateCharacterData = sharedContext.UpdateCharacterData

-- TomTom waypoints
local beastWaypoints = {
  [88545] = {mapID=2395, x=0.4195, y=0.8005, title="Gloomclaw"},
  [88526] = {mapID=2437, x=0.4769, y=0.5325, title="Silverscale"},
  [88531] = {mapID=2413, x=0.6628, y=0.4791, title="Lumenfin"},
  [88532] = {mapID=2405, x=0.5460, y=0.6580, title="Umbrafang"},
  [88524] = {mapID=2405, x=0.4325, y=0.8275, title="Netherscythe"},
}

-- Frame danh sách boss chưa kill
local UnkilledBossFrame = CreateFrame("Frame","UnkilledBossFrame",UIParent,"BackdropTemplate")
UnkilledBossFrame:SetSize(300,200)
UnkilledBossFrame:SetPoint("CENTER")
UnkilledBossFrame:Hide()
UnkilledBossFrame:SetMovable(true)
UnkilledBossFrame:EnableMouse(true)
UnkilledBossFrame:RegisterForDrag("LeftButton")
UnkilledBossFrame:SetScript("OnDragStart", UnkilledBossFrame.StartMoving)
UnkilledBossFrame:SetScript("OnDragStop", UnkilledBossFrame.StopMovingOrSizing)
UnkilledBossFrame:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
UnkilledBossFrame.title = UnkilledBossFrame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
UnkilledBossFrame.title:SetPoint("TOP",0,-10)
UnkilledBossFrame.title:SetText("Skinning Beast")

function UnkilledBossFrame:Update()
  UpdateCharacterData()
  if UnkilledBossFrame.rows then
    for _,row in ipairs(UnkilledBossFrame.rows) do
      for _,fs in ipairs(row) do fs:Hide() end
    end
  end
  UnkilledBossFrame.rows = {}

  local charName = UnitName("player").." - "..GetRealmName()
  UnkilledBossFrame.title:SetText(charName)
  if not _G[dbName] or not _G[dbName][charName] then return end
  local data = _G[dbName][charName]

  local y = -40
  for _,q in ipairs(quests) do
    local wp = beastWaypoints[q.id]
    local row = {}
    local mapInfo = wp and C_Map.GetMapInfo(wp.mapID)
    local zoneName = mapInfo and mapInfo.name or "Unknown Zone"
    local bossName = (wp and wp.title) or q.title or q.name or ("Quest " .. q.id)
    local isKilled = data.quests and data.quests[q.id]

    local fsName = UnkilledBossFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
    fsName:SetPoint("TOPLEFT",20,y)
    fsName:SetText(bossName .. " - " .. zoneName)
    if isKilled then
      fsName:SetTextColor(1,0.2,0.2)
    end
    table.insert(row,fsName)

    if isKilled then
      local strike = UnkilledBossFrame:CreateTexture(nil, "ARTWORK")
      strike:SetColorTexture(1, 0.2, 0.2, 0.9)
      strike:SetHeight(1.5)
      strike:SetPoint("LEFT", fsName, "LEFT", 0, 0)
      strike:SetPoint("RIGHT", fsName, "RIGHT", 0, 0)
      table.insert(row, strike)
    end

    local btn = CreateFrame("Button", nil, UnkilledBossFrame, "BackdropTemplate")
    btn:SetPoint("TOPLEFT",20,y)
    btn:SetSize(250,18)
    btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    btn:SetBackdropColor(0,0,0,0)
    if isKilled then
      btn:EnableMouse(false)
    else
      btn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.2,0.6,1,0.3) end)
      btn:SetScript("OnLeave", function(self) self:SetBackdropColor(0,0,0,0) end)
      btn:SetScript("OnClick", function()
          if wp then
            if C_Map and C_Map.ClearUserWaypoint and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
              C_Map.ClearUserWaypoint()
              C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(wp.mapID, wp.x, wp.y))
              if C_Map.SetSuperTrackedUserWaypoint then
                C_Map.SetSuperTrackedUserWaypoint(true)
              end
            end

            if TomTom and TomTom.AddWaypoint then
              -- Keep TomTom as fallback/complement
              TomTom:AddWaypoint(wp.mapID, wp.x, wp.y, { title = bossName, persistent = false })
            end
          end
      end)
    end
    table.insert(row,btn)
    table.insert(UnkilledBossFrame.rows,row)
    y = y - 20
  end
end

function UnkilledBossFrame:ToggleUI()
  if UnkilledBossFrame:IsShown() then
    UnkilledBossFrame:Hide()
  else
    UnkilledBossFrame:Show()
    UnkilledBossFrame:Update()
  end
end

local questEventFrame = CreateFrame("Frame")
questEventFrame:RegisterEvent("QUEST_LOG_UPDATE")
questEventFrame:SetScript("OnEvent", function()
  if not UnkilledBossFrame:IsShown() then return end

  local charName = UnitName("player").." - "..GetRealmName()
  local db = _G[dbName]
  local charData = db and db[charName]
  local cachedQuests = charData and charData.quests
  if not cachedQuests then return end

  local changed = false
  for _, q in ipairs(quests) do
    local liveStatus = C_QuestLog.IsQuestFlaggedCompleted(q.id) or false
    local cachedStatus = cachedQuests[q.id] or false
    if liveStatus ~= cachedStatus then
      changed = true
      break
    end
  end

  if changed then
    UpdateCharacterData()
    UnkilledBossFrame:Update()
  end
end)

minimapContext.listFrame = UnkilledBossFrame
