local openedMenus, resList, orderedMenus, menuSettings = {}, {}, {}, {}
local selectedElm, selectedVal = 0
local closing, moveToCurrentSetting = false, false

doRound = function(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

MenuText = function(text, x, y, scale, rgba)
  SetTextFont(menuSettings.font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(math.floor(rgba.x), math.floor(rgba.y), math.floor(rgba.z), math.floor(rgba.w))
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(2, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextEntry('STRING')
  AddTextComponentString(text)
  DrawText(x, y)
end

MenuRect = function(text, scale)
  BeginTextCommandGetWidth('STRING')
  AddTextComponentString(text)
  SetTextFont(menuSettings.font)
  SetTextScale(scale, scale)
  return EndTextCommandGetWidth(true)
end

IsMenuOpen = function(name)
  while closing do Wait(0) end
  for i = 1,#openedMenus do
    if openedMenus[i].name == name then
      return true, i
    end
  end
  return false, #openedMenus+1
end

CheckMenuOpen = function(mType, res, name, cb)
  cb(IsMenuOpen(res..':'..name))
end

CloseMenu = function(name)
  closing = true
  for i = 1,#openedMenus do
    if openedMenus[i] and openedMenus[i].name then
      if openedMenus[i].name == name then
        if openedMenus[i].mType == 'dialog' then ForceCloseTextInputBox() end
        openedMenus[i] = nil
        resList[name] = nil
        break
      end
    end
  end
  closing = false
end

CloseAll = function()
  for i = #openedMenus,1,-1 do
    while closing do Wait(0) end
    CloseMenu(openedMenus[i].name)
  end
end

GetCurrentSettingElm = function(elms)
  for k,v in pairs(elms) do
    if v.value == menuSettings[moveToCurrentSetting] then
      return k
    end
  end
  return 1
end

RunMenu = function(mType, res, name, opts, cb, onClose, onNew)
  local name = res..':'..name
  resList[name] = res
  if mType == 'default' then
    if #opts.elements <= 0 then opts.elements = {{label = 'NO ELEMENTS PROVIDED TO TABLE', value = 'RETURN'}} end
    if not Config.screenLocations[opts.align] then opts.align = 'custom' end
    local title, location, elements = opts.title, opts.align, opts.elements
    local menu = {}
    local isOpen, listPos = IsMenuOpen(name)
    if not isOpen then
      menu.mType = mType
      menu.title = title
      menu.name = name
      menu.elements = elements
      menu.selElm = 1
      menu.location = location
      menu.cb = cb
      menu.onClose = onClose
      menu.onNew = onNew
      menu.pos = listPos
      menu.prev = (listPos-1 > 0 and openedMenus[listPos-1]) or nil
      menu.lastPress = 0
      menu.close = function()
        CloseMenu(menu.name)
      end
      menu.update = function(options, newElements)
        for i = 1,#menu.elements do
          for k,v in pairs(options) do
            if menu.elements[i][k] == v then
              for g,f in pairs(newElements) do
                menu.elements[i][g] = f
              end
            end
          end
        end
      end
      menu.refresh = function()
        -- print('Does it not auto refresh?')
      end
      if moveToCurrentSetting ~= false then menu.selElm = GetCurrentSettingElm(menu.elements); moveToCurrentSetting = false; end
      table.insert(openedMenus, menu)
    end
    while true do
      local isOpen, listPos = IsMenuOpen(menu.name)
      if not isOpen then break end
      Citizen.Wait(0)
      if menu.pos == #openedMenus then
        local x,y = Config.screenLocations[menu.location].x, Config.screenLocations[menu.location].y
        if menu.location == 'custom' and menuSettings.custom then x = menuSettings.x; y = menuSettings.y; end
        local textScale = GetRenderedCharacterHeight(menuSettings.scale, menuSettings.font)
        local limitCenter = math.ceil(menuSettings.limit/2)
        local titleY = y-(textScale*limitCenter)
        MenuText(menu.title,x,titleY,menuSettings.scale,vector4(255,255,255,200))
        local subt = 1
        for i = 1,menuSettings.limit do
          if i < limitCenter then
            local diff = limitCenter - i
            local prev = menu.selElm - diff
            while prev < 1 do
              prev = #menu.elements+prev
            end
            MenuText(menu.elements[prev].label,x,y-(textScale*(limitCenter-subt)),menuSettings.scale,vector4(255,0,0,200))
            subt = subt + 1
          elseif i == limitCenter then
            if not menu.elements[menu.selElm].sp1 then
              menu.elements[menu.selElm].sp1 = MenuRect(menu.elements[menu.selElm].label,menuSettings.scale)
            end
            if menu.elements[menu.selElm].type == 'slider' then
              if not menu.elements[menu.selElm].isSlider then
                menu.elements[menu.selElm].isSlider = '  >  '..menu.elements[menu.selElm].value
                menu.elements[menu.selElm].sp1 = MenuRect(menu.elements[menu.selElm].label..menu.elements[menu.selElm].isSlider,menuSettings.scale)
              end
              DrawRect(x+menu.elements[menu.selElm].sp1/2.0,y+textScale/1.5,menu.elements[menu.selElm].sp1,textScale,0,0,0,200)
              MenuText(menu.elements[menu.selElm].label..menu.elements[menu.selElm].isSlider,x,y,menuSettings.scale,vector4(0,255,0,200))
            else
              DrawRect(x+menu.elements[menu.selElm].sp1/2.0,y+textScale/1.5,menu.elements[menu.selElm].sp1,textScale,0,0,0,200)
              MenuText(menu.elements[menu.selElm].label,x,y,menuSettings.scale,vector4(0,255,0,200))
            end
            subt = subt + 1
          elseif i > limitCenter then
            local diff = i - limitCenter
            local following = menu.selElm + diff
            while following > #menu.elements do
              following = 0+(following-#menu.elements)
            end
            MenuText(menu.elements[following].label,x,y+(textScale*(subt-limitCenter)),menuSettings.scale,vector4(255,0,0,200))
            subt = subt + 1
          end
        end
        if Config.keyBinds.DisableKeybinds then
          DisableControlAction(0,Config.keyBinds['Previous Option'],true)
          DisableControlAction(0,Config.keyBinds['Next Option'],true)
          DisableControlAction(0,Config.keyBinds['Decrease Value'],true)
          DisableControlAction(0,Config.keyBinds['Increase Value'],true)
          DisableControlAction(0,Config.keyBinds['Select Option'],true)
          DisableControlAction(0,Config.keyBinds['Close Menu'],true)
        else
          EnableControlAction(0,Config.keyBinds['Previous Option'],true)
          EnableControlAction(0,Config.keyBinds['Next Option'],true)
          EnableControlAction(0,Config.keyBinds['Decrease Value'],true)
          EnableControlAction(0,Config.keyBinds['Increase Value'],true)
          EnableControlAction(0,Config.keyBinds['Select Option'],true)
          EnableControlAction(0,Config.keyBinds['Close Menu'],true)
        end
        local gTime = GetGameTimer()
        if ((Config.keyBinds.DisableKeybinds and IsDisabledControlPressed(0,Config.keyBinds['Previous Option'])) or IsControlPressed(0,Config.keyBinds['Previous Option'])) and gTime-menu.lastPress > Config.scrollSpeed then
          menu.selElm = menu.selElm - 1
          if menu.selElm == 0 then menu.selElm = #menu.elements end
          if menu.onNew ~= nil then menu.onNew({current = menu.elements[menu.selElm]}, menu) end
          menu.lastPress = gTime
        elseif ((Config.keyBinds.DisableKeybinds and IsDisabledControlPressed(0,Config.keyBinds['Next Option'])) or IsControlPressed(0,Config.keyBinds['Next Option'])) and gTime-menu.lastPress > Config.scrollSpeed then
          menu.selElm = menu.selElm + 1
          if menu.selElm > #menu.elements then menu.selElm = 1 end
          if menu.onNew ~= nil then menu.onNew({current = menu.elements[menu.selElm]}, menu) end
          menu.lastPress = gTime
        elseif ((Config.keyBinds.DisableKeybinds and IsDisabledControlPressed(0,Config.keyBinds['Decrease Value'])) or IsControlPressed(0,Config.keyBinds['Decrease Value'])) and gTime-menu.lastPress > Config.scrollSpeed then
          if menu.elements[menu.selElm].isSlider ~= nil then
            menu.elements[menu.selElm].value = menu.elements[menu.selElm].value - 1
            if menu.elements[menu.selElm].value < menu.elements[menu.selElm].min then menu.elements[menu.selElm].value = menu.elements[menu.selElm].max end
            menu.elements[menu.selElm].isSlider = '  >  '..menu.elements[menu.selElm].value
            menu.elements[menu.selElm].sp1 = MenuRect(menu.elements[menu.selElm].label..menu.elements[menu.selElm].isSlider,menuSettings.scale)
            if menu.onNew ~= nil then menu.onNew({current = menu.elements[menu.selElm]}, menu) end
            menu.lastPress = gTime
          end
        elseif ((Config.keyBinds.DisableKeybinds and IsDisabledControlPressed(0,Config.keyBinds['Increase Value'])) or IsControlPressed(0,Config.keyBinds['Increase Value'])) and gTime-menu.lastPress > Config.scrollSpeed then
          if menu.elements[menu.selElm].isSlider ~= nil then
            menu.elements[menu.selElm].value = menu.elements[menu.selElm].value + 1
            if menu.elements[menu.selElm].value > menu.elements[menu.selElm].max then menu.elements[menu.selElm].value = menu.elements[menu.selElm].min end
            menu.elements[menu.selElm].isSlider = '  >  '..menu.elements[menu.selElm].value
            menu.elements[menu.selElm].sp1 = MenuRect(menu.elements[menu.selElm].label..menu.elements[menu.selElm].isSlider,menuSettings.scale)
            if menu.onNew ~= nil then menu.onNew({current = menu.elements[menu.selElm]}, menu) end
            menu.lastPress = gTime
          end
        elseif (Config.keyBinds.DisableKeybinds and IsDisabledControlJustPressed(0,Config.keyBinds['Select Option'])) or IsControlJustPressed(0,Config.keyBinds['Select Option']) then
          menu.cb({current = menu.elements[menu.selElm]}, menu)
        elseif (Config.keyBinds.DisableKeybinds and IsDisabledControlJustPressed(0,Config.keyBinds['Close Menu'])) or IsControlJustPressed(0,Config.keyBinds['Close Menu']) then
          if menu.onClose ~= nil then menu.onClose({current = menu.elements[menu.selElm]}, menu) end
          CloseMenu(menu.name)
        end
      end
    end
  elseif mType == 'dialog' then
    local title = opts.title
    local menu = {}
    local isOpen, listPos = IsMenuOpen(name)
    if not isOpen then
      menu.mType = mType
      menu.title = title
      menu.name = name
      menu.selElm = ''
      menu.cb = cb
      menu.pos = listPos
      menu.prev = (listPos-1 > 0 and openedMenus[listPos-1]) or nil
      menu.close = function()
        CloseMenu(menu.name)
      end
      table.insert(openedMenus, menu)
    end
    DisplayOnscreenKeyboard(1, '', '', '', '', menu.title..'\n', '', 255+#menu.title)
    while true do
      local isOpen, listPos = IsMenuOpen(menu.name)
      if not isOpen then break end
      Citizen.Wait(0)
      if menu.pos == #openedMenus then
        local keyboardStatus = UpdateOnscreenKeyboard()
        if keyboardStatus == -1 then
          DisplayOnscreenKeyboard(1, '', '', '', '', menu.title..'\n', '', 255+#menu.title)
        elseif keyboardStatus == 1 then
          local inputText = GetOnscreenKeyboardResult():sub(#menu.title+1)
          DisplayOnscreenKeyboard(1, '', '', '', '', menu.title, inputText, 255+#menu.title)
          menu.cb({value = inputText:sub(2)}, menu)
        elseif keyboardStatus == 2 then
          CloseMenu(menu.name)
        end
      end
    end
  end
end

SetMenuSettings = function(settings)
  for k,v in pairs(settings) do menuSettings[k] = v end
end

StartAdjustOptions = function()
  TriggerEvent('menuAlone:closeAll')
  TriggerEvent('menuAlone:open', 'default', GetCurrentResourceName(), 'select_option',
  {title = 'Select Option To Adjust', align = 'custom', elements = {{label = 'X Position', value = 'x'}, {label = 'Y Position', value = 'y'}, {label = 'Scale', value = 'scale'}, {label = 'Font', value = 'font'}, {label = 'Limit', value = 'limit'}}},
  function(data, menu)
    local list = {}
    if data.current.value ~= 'font' and data.current.value ~= 'limit' then
      table.insert(list, {label = '0', value = 0})
      for i = 0.01,1,0.01 do
        table.insert(list, {label = doRound(i, 2), value = doRound(i, 2)})
      end
      table.insert(list, {label = 1, value = 1})
    elseif data.current.value == 'font' then
      for i = 0,8 do
        if Config.usableFonts[i] then
          table.insert(list, {label = tostring(i), value = i})
        end
      end
    elseif data.current.value == 'limit' then
      for i = 1,Config.menuOptions.displayedOptionsLimit do
        if i%2 ~= 0 then
          table.insert(list, {label = tostring(i), value = i})
        end
      end
    end
    moveToCurrentSetting = data.current.value
    TriggerEvent('menuAlone:open', 'default', GetCurrentResourceName(), 'adjust_option',
    {title = 'Select New '..data.current.label..' Value', align = 'custom', elements = list},
    function(data2, menu2)
      menu2.close()
      menuSettings[data.current.value] = data2.current.value
      TriggerServerEvent('menuAlone:setPlayerSettings', menuSettings)
    end, function(data2, menu2)
      menu2.close()
    end, function(data2, menu2)
      menuSettings[data.current.value] = data2.current.value
    end)
  end)
end

RegisterNetEvent('menuAlone:setSettings')

AddEventHandler('menuAlone:close', CloseMenu)
AddEventHandler('menuAlone:closeAll', CloseAll)
AddEventHandler('menuAlone:open', RunMenu)
AddEventHandler('menuAlone:isOpen', CheckMenuOpen)
AddEventHandler('menuAlone:setSettings', SetMenuSettings)
AddEventHandler('onResourceStop', function(res)
  if res == GetCurrentResourceName() then
    CloseAll()
  else
    for k,v in pairs(resList) do
      if res == v then
        CloseMenu(k)
      end
    end
  end
end)
TriggerServerEvent('menuAlone:getPlayerSettings')

if Config.menuOptions.allowCustom then
  RegisterCommand('adjustMAOpts', StartAdjustOptions, false)
end