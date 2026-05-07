local context = _G.SBT_Shared_Context
if not context then return end

local dbName = context.dbName
local quests = context.quests
local HasResetPassed = context.HasResetPassed
local UpdateCharacterData = context.UpdateCharacterData

-- UI
SkinningBeastTracker = CreateFrame("Frame", "SkinningBeastTrackerFrame", UIParent, "UIPanelDialogTemplate")
SkinningBeastTracker:SetSize(1200, 550)
SkinningBeastTracker:SetPoint("CENTER")
SkinningBeastTracker:SetClampedToScreen(true)
SkinningBeastTracker:SetMovable(true)
SkinningBeastTracker:EnableMouse(true)
SkinningBeastTracker:RegisterForDrag("LeftButton")
SkinningBeastTracker:SetScript("OnDragStart", SkinningBeastTracker.StartMoving)
SkinningBeastTracker:SetScript("OnDragStop", SkinningBeastTracker.StopMovingOrSizing)
if SkinningBeastTracker.TitleText then
  SkinningBeastTracker.TitleText:SetText("Skinning Beast Tracker")
end
if SkinningBeastTracker.Bg then
  SkinningBeastTracker.Bg:SetTexCoord(0, 1, 0, 0.85)
end

local CONTENT_PADDING_LEFT = 20
local CONTENT_PADDING_TOP = 46
local ROW_HEIGHT = 22

SkinningBeastTracker:Hide()

-- Cho phép đóng bằng phím Esc
table.insert(UISpecialFrames, "SkinningBeastTracker")

-- Clear DB button
local clearBtn = CreateFrame("Button",nil,SkinningBeastTracker,"UIPanelButtonTemplate")
clearBtn:SetSize(100,25)
clearBtn:SetPoint("BOTTOMRIGHT",-22,18)
clearBtn:SetText("Clear DB")
clearBtn:SetScript("OnClick",function()
  StaticPopupDialogs["SBT_CLEARDB_CONFIRM"] = {
    text = "Are you sure you want to clear all Skinning Beast Tracker data?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
      wipe(_G[dbName])
      SkinningBeastTracker:Update()
      print("Skinning Beast Tracker DB cleared.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }
  StaticPopup_Show("SBT_CLEARDB_CONFIRM")
end)

local function GetLocalOffset()
  local utcEpoch = time(date("!*t"))
  local localEpoch = time()
  return localEpoch - utcEpoch
end

-- Headers
local function CreateHeaders()
  local headerNames = {}
  local charCount = 0
  if _G[dbName] then
    for _ in pairs(_G[dbName]) do
      charCount = charCount + 1
    end
  end

  table.insert(headerNames,"Character ("..charCount..")")
  for _,q in ipairs(quests) do table.insert(headerNames,q.name) end
  table.insert(headerNames,"Last Updated")
  table.insert(headerNames,"Action")

  SkinningBeastTracker.headers = SkinningBeastTracker.headers or {}
  local colWidths = {}
  colWidths[1] = 250
  for i=2,#quests+1 do colWidths[i] = 100 end
  colWidths[#quests+2] = 250
  colWidths[#quests+3] = 100

  local x = CONTENT_PADDING_LEFT
  for i,h in ipairs(headerNames) do
    if not SkinningBeastTracker.headers[i] then
        SkinningBeastTracker.headers[i] = SkinningBeastTracker:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    end
    SkinningBeastTracker.headers[i]:SetPoint("TOPLEFT",x,-CONTENT_PADDING_TOP)
    SkinningBeastTracker.headers[i]:SetText(h)
    x = x + colWidths[i]
  end

  return colWidths
end

SkinningBeastTracker.rows = {}

function SkinningBeastTracker:Update()
  UpdateCharacterData()

  for _,row in ipairs(SkinningBeastTracker.rows) do
    for _,fs in ipairs(row) do fs:Hide() end
  end
  SkinningBeastTracker.rows = {}

  local colWidths = CreateHeaders()

  local charList = {}
  if _G[dbName] then
      for char,data in pairs(_G[dbName]) do
        if char ~= "minimap" then -- Loại bỏ table minimap khỏi danh sách nhân vật
            if HasResetPassed(data.lastUpdate) then
              data.quests = {}
            end
            table.insert(charList,{name=char,data=data})
        end
      end
  end
  table.sort(charList,function(a,b)
    return (a.data.lastUpdate or 0) > (b.data.lastUpdate or 0)
  end)

  local rowIndex = 0
  for _,entry in ipairs(charList) do
    local char = entry.name
    local data = entry.data
    rowIndex = rowIndex + 1
    local row = {}
    local y = -(CONTENT_PADDING_TOP + 22) - (rowIndex-1)*ROW_HEIGHT
    local x = CONTENT_PADDING_LEFT

    local nameFS = SkinningBeastTracker:CreateFontString(nil,"OVERLAY","GameFontNormal")
    nameFS:SetPoint("TOPLEFT",x,y)
    nameFS:SetText(char)
    table.insert(row,nameFS)
    x = x + colWidths[1]

    for i,q in ipairs(quests) do
      local fs = SkinningBeastTracker:CreateFontString(nil,"OVERLAY","GameFontNormal")
      fs:SetPoint("TOPLEFT",x,y)
      if data.quests[q.id] then
        fs:SetText("|cff00ff00O|r")
      else
        fs:SetText("|cffff0000X|r")
      end
      table.insert(row,fs)
      x = x + colWidths[i+1]
    end

    local fs = SkinningBeastTracker:CreateFontString(nil,"OVERLAY","GameFontNormal")
    fs:SetPoint("TOPLEFT",x,y)
    if HasResetPassed(data.lastUpdate) then
      fs:SetText("|cffff0000"..date("%Y-%m-%d %H:%M", (data.lastUpdate or 0) + GetLocalOffset()).."|r")
    else
      fs:SetText(date("%Y-%m-%d %H:%M", (data.lastUpdate or 0) + GetLocalOffset()))
    end
    table.insert(row,fs)

    x = x + colWidths[#quests+2]

    local clearCharBtn = CreateFrame("Button",nil,SkinningBeastTracker,"UIPanelButtonTemplate")
    clearCharBtn:SetSize(80,18)
    clearCharBtn:SetPoint("TOPLEFT",x,y+2)
    clearCharBtn:SetText("Clear")
    clearCharBtn:SetScript("OnClick",function()
      StaticPopupDialogs["SBT_CLEAR_CHARACTER_CONFIRM"] = {
        text = "Are you sure you want to clear data for "..char.."?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
          if _G[dbName] then
            _G[dbName][char] = nil
          end
          SkinningBeastTracker:Update()
          print("Skinning Beast Tracker data cleared for "..char..".")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("SBT_CLEAR_CHARACTER_CONFIRM")
    end)
    table.insert(row,clearCharBtn)

    table.insert(SkinningBeastTracker.rows,row)
  end
end

function SkinningBeastTracker:ToggleUI()
  if SkinningBeastTracker:IsShown() then
    SkinningBeastTracker:Hide()
  else
    SkinningBeastTracker:Show()
    SkinningBeastTracker:Update()
  end
end

_G.SBT_MinimapIcon_Context = _G.SBT_MinimapIcon_Context or {}
_G.SBT_MinimapIcon_Context.mainFrame = SkinningBeastTracker
