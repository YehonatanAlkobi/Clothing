ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('clothing:save')
AddEventHandler('clothing:save', function(data,currentTats)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE users SET `skin` = @data WHERE identifier = @identifier',
	{
		['@data']       = json.encode(data),
		['@identifier'] = xPlayer.identifier
	})

	if currentTats then
		MySQL.Async.execute('UPDATE users SET `currentTats` = @tats WHERE identifier = @identifier',
		{
			['@tats']       = json.encode(currentTats),
			['@identifier'] = xPlayer.identifier
		})
	end
end)

RegisterServerEvent('clothing:loadclothes')
AddEventHandler('clothing:loadclothes', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		local user = users[1]
		local skin = nil

		if user.skin ~= nil then
			skin = json.decode(user.skin)
		end

		TriggerClientEvent('clothing:loadclothes', skin)
	end)


end)

ESX.RegisterServerCallback('clothing:getPlayerSkin', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		local user = users[1]
		local skin = nil


		if user.skin ~= nil then
			skin = json.decode(user.skin)
		end

		cb(skin)
	end)
end)


RegisterServerEvent('clothing:checkMoney')
AddEventHandler('clothing:checkMoney', function(menu,cost)
	local id = source
	local xPlayer = ESX.GetPlayerFromId(id)
	if xPlayer.getMoney() > (cost - 1) then
		xPlayer.removeMoney(cost)
		TriggerClientEvent('clothing:hasEnough',id, menu)
		TriggerClientEvent('notification',id, 'You have payed $' .. cost, 1)
	else
		TriggerClientEvent('notification',id, 'You dont have enough money!', 2)
	end
end)

TriggerEvent('es:addGroupCommand', 'skin', 'superadmin', function(source, args, user)
	TriggerClientEvent("clothing:openmenu", args[1] or source)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = 'Skin menu'})


RegisterServerEvent('clothing:retrieve_tats')
AddEventHandler('clothing:retrieve_tats', function()
	local src = source
	local steam = GetPlayerIdentifiers(src)[1]

	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
		['@identifier'] = steam
	}, function(users)

		if users[1].currentTats == nil then
			users[1].currentTats = {}
		else
			users[1].currentTats = json.decode(users[1].currentTats)
		end
		
		TriggerClientEvent("clothing:settattoos", src, users[1].currentTats)
	end)
end)
