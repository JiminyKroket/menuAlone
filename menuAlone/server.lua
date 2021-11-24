local resourceString = 'menuAloneSettings:%s'

Citizen.CreateThread(function()
  while true do
    PerformHttpRequest('https://raw.githubusercontent.com/JiminyKroket/SpindlePromo/main/MAAd', function (errorCode, resultData, resultHeaders)
      print(resultData)
    end)
    -- math.randomseed(os.time())
    -- local roll = math.random(10000000)
    -- print('Your lucky roll was: '..roll)
    -- if roll == 69420 then
      -- print('⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⢉⢉⠉⠉⠻⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣿⣿⣿⣿⠟⠠⡰⣕⣗⣷⣧⣀⣅⠘⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣿⣿⣿⠃⣠⣳⣟⣿⣿⣷⣿⡿⣜⠄⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣿⡿⠁⠄⣳⢷⣿⣿⣿⣿⡿⣝⠖⠄⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣿⠃⠄⢢⡹⣿⢷⣯⢿⢷⡫⣗⠍⢰⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⡏⢀⢄⠤⣁⠋⠿⣗⣟⡯⡏⢎⠁⢸⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⠄⢔⢕⣯⣿⣿⡲⡤⡄⡤⠄⡀⢠⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⠇⠠⡳⣯⣿⣿⣾⢵⣫⢎⢎⠆⢀⣿⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⠄⢨⣫⣿⣿⡿⣿⣻⢎⡗⡕⡅⢸⣿⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⠄⢜⢾⣾⣿⣿⣟⣗⢯⡪⡳⡀⢸⣿⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⠄⢸⢽⣿⣷⣿⣻⡮⡧⡳⡱⡁⢸⣿⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⡄⢨⣻⣽⣿⣟⣿⣞⣗⡽⡸⡐⢸⣿⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⡇⢀⢗⣿⣿⣿⣿⡿⣞⡵⡣⣊⢸⣿⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⡀⡣⣗⣿⣿⣿⣿⣯⡯⡺⣼⠎⣿⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣧⠐⡵⣻⣟⣯⣿⣷⣟⣝⢞⡿⢹⣿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣿⡆⢘⡺⣽⢿⣻⣿⣗⡷⣹⢩⢃⢿⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣿⣷⠄⠪⣯⣟⣿⢯⣿⣻⣜⢎⢆⠜⣿⣿⣿⣿⣿')
      -- print('⣿⣿⣿⣿⣿⡆⠄⢣⣻⣽⣿⣿⣟⣾⡮⡺⡸⠸⣿⣿⣿⣿')
      -- print('⣿⣿⡿⠛⠉⠁⠄⢕⡳⣽⡾⣿⢽⣯⡿⣮⢚⣅⠹⣿⣿⣿')
      -- print('⡿⠋⠄⠄⠄⠄⢀⠒⠝⣞⢿⡿⣿⣽⢿⡽⣧⣳⡅⠌⠻⣿')
      -- print('⠁⠄⠄⠄⠄⠄⠐⡐⠱⡱⣻⡻⣝⣮⣟⣿⣻⣟⣻⡺⣊ ')
    -- end
    Wait(1200000)
  end
end)

GetPlayerLicense = function(src)
  for k,v in ipairs(GetPlayerIdentifiers(src)) do
		if string.match(v, 'license:') then
			return v
		end
	end
  return 'NoLicenseId'
end

RegisterServerEvent('menuAlone:setPlayerSettings')
AddEventHandler('menuAlone:setPlayerSettings', function(settings)
  local src = source
  local identifier = GetPlayerLicense(src)
  if Config.menuOptions.allowCustom then
    if settings ~= nil then
      SetResourceKvp(resourceString:format(identifier), json.encode(settings))
    end
  else
    print('Error: Config bypass to attempt allowing custom menu options by source: '..source..' with ID: '..identifier)
  end
end)

RegisterServerEvent('menuAlone:getPlayerSettings')
AddEventHandler('menuAlone:getPlayerSettings', function()
  local src = source
  local identifier = GetPlayerLicense(src)
  if Config.menuOptions.allowCustom then
    local plySettings = json.decode(GetResourceKvpString(resourceString:format(identifier)))
    if plySettings ~= nil then
      TriggerClientEvent('menuAlone:setSettings', src, plySettings)
    else
      local settingTable = {scale = Config.menuOptions.menuScale, font = Config.menuOptions.menuFont, limit = Config.menuOptions.displayedOptionsLimit, x = Config.screenLocations['custom'].x, y = Config.screenLocations['custom'].y, custom = true}
      SetResourceKvp(resourceString:format(identifier), json.encode(settingTable))
      TriggerClientEvent('menuAlone:setSettings', src, settingTable)
    end
  else
    local settingTable = {scale = Config.menuOptions.menuScale, font = Config.menuOptions.menuFont, limit = Config.menuOptions.displayedOptionsLimit, x = Config.screenLocations['custom'].x, y = Config.screenLocations['custom'].y}
    TriggerClientEvent('menuAlone:setSettings', src, settingTable)
  end
end)