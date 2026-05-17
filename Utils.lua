_G.SBT_Utils = _G.SBT_Utils or {}

local function HasResetPassed(lastUpdate)
  if not lastUpdate then return true end

  local nowUTC = time({
    year  = tonumber(date("!%Y")),
    month = tonumber(date("!%m")),
    day   = tonumber(date("!%d")),
    hour  = tonumber(date("!%H")),
    min   = tonumber(date("!%M")),
    sec   = tonumber(date("!%S")),
  })

  local resetTodayUTC = time({
    year  = tonumber(date("!%Y")),
    month = tonumber(date("!%m")),
    day   = tonumber(date("!%d")),
    hour  = 15,
  })

  if nowUTC < resetTodayUTC then
    resetTodayUTC = resetTodayUTC - 86400
  end

  return lastUpdate < resetTodayUTC
end

local function UpdateCharacterData(dbName, quests)
  local charName = UnitName("player").." - "..GetRealmName()
  local hasSkinning = false
  local profs = {GetProfessions()}
  for _,p in ipairs(profs) do
    if p then
      local profName = select(1,GetProfessionInfo(p))
      if profName and profName:find("Skinning") then
        hasSkinning = true
      end
    end
  end

  if hasSkinning then
    _G[dbName] = _G[dbName] or {}
    if not _G[dbName][charName] then
      _G[dbName][charName] = {quests={}, lastUpdate=0}
    end

    if HasResetPassed(_G[dbName][charName].lastUpdate) then
      _G[dbName][charName].quests = {}
    end

    for _,q in ipairs(quests) do
      _G[dbName][charName].quests[q.id] = C_QuestLog.IsQuestFlaggedCompleted(q.id)
    end

    _G[dbName][charName].lastUpdate = time({
      year  = tonumber(date("!%Y")),
      month = tonumber(date("!%m")),
      day   = tonumber(date("!%d")),
      hour  = tonumber(date("!%H")),
      min   = tonumber(date("!%M")),
      sec   = tonumber(date("!%S")),
    })
  end
end

_G.SBT_Utils.HasResetPassed = HasResetPassed
_G.SBT_Utils.UpdateCharacterData = UpdateCharacterData
