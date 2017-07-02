util.AddNetworkString( "el_exchange_contents" )
util.AddNetworkString( "el_query" )
util.AddNetworkString( "el_buy_item" )
util.AddNetworkString( "el_collect" )
util.AddNetworkString( "el_request_removal" )
util.AddNetworkString( "el_sell_item" )
util.AddNetworkString( "el_sell_notify" )

local DB_Blacklist = {}
DB_Blacklist["cbus_station"] = true 
DB_Blacklist["prop_physics"] = true 
DB_Blacklist["prop_dynamic"] = true 
DB_Blacklist["prop_door_rotating"] = true 
DB_Blacklist["func_door_rotating"] = true 
DB_Blacklist["func_door"] = true
DB_Blacklist["gasnpc"] = true 

local function getDarkRPWep(model)
	for k,v in pairs(CustomShipments) do
		if(string.lower(model) == string.lower(v.model)) then
			return v.name
		end
	end
	return "Weapon"
end

local function el_dtvars(ent)
	if not ent.GetNetworkVars then 
		return
	else
		local name, v = debug.getupvalue(ent.GetNetworkVars, 1)
		local dbgr = {}
		for k,i in pairs(v) do dbgr[k] = i.GetFunc(ent, i.index) end
		return util.TableToJSON(dbgr)
	end
end

local function el_balance(ply)
	if sql.Query( "SELECT balance FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].balance == nil then return end
	return tonumber(sql.Query( "SELECT balance FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].balance)
end

net.Receive( "el_sell_item", function( len, ply )
	local ent = net.ReadEntity()
	local price = net.ReadInt(32)
	local dt_vars = el_dtvars(ent)
	if !DB_Blacklist[ent:GetClass()] and IsValid(ent) and tonumber(price) then
		math.randomseed(os.time())
		if ent:GetClass()=="spawned_weapon" then
			local temp = ents.Create(ent:GetWeaponClass())
			sql.Query( "INSERT INTO el_exchange_items VALUES ('"..ply:SteamID64().."','"..ent:GetClass().."',"..sql.SQLStr(ply:Nick())..",'"..tostring(price).."','"..ent:GetModel().."','"..(temp.PrintName or getDarkRPWep(ent:GetModel())).." (Amount: "..ent:Getamount()..")','"..dt_vars.."',"..math.random(1,999999)..")")
			ent:Remove()
			temp:Remove()
		return end
		local ent_info = " "
		if !ent.PrintName then ent.PrintName = "Item: "..ent:GetClass() end
		sql.Query( "INSERT INTO el_exchange_items VALUES ('"..ply:SteamID64().."','"..ent:GetClass().."',"..sql.SQLStr(ply:Nick())..",'"..tostring(price).."','"..ent:GetModel().."','"..ent.PrintName.."','"..ent_info.."',"..math.random(1,999999)..")")
		ent:Remove()
	else
		ply:ChatPrint("You can't sell this item on the market.")
	end
end )


net.Receive( "el_collect", function( len, ply )
	if el_balance(ply)<1 then 
		ply:ChatPrint("Your balance is empty.")
	else
		ply:ChatPrint("$"..el_balance(ply).." withdrawn.")
		ply:addMoney(el_balance(ply))
		sql.Query("UPDATE el_exchange_stats SET balance = 0 WHERE steamid = '"..ply:SteamID64().."'")
	end
end )

net.Receive( "el_request_removal", function( len, ply )
	local arg = net.ReadString()
	if arg=="ITEM" then
		local id = net.ReadInt(32)
		local classname = sql.Query("SELECT classname FROM el_exchange_items WHERE id ="..id.." AND steamid ='"..ply:SteamID64().."'")[1].classname
		local dtinfo = sql.Query("SELECT ent_info FROM el_exchange_items WHERE id ="..id.." AND steamid ='"..ply:SteamID64().."'")[1].ent_info
		local wmodel = sql.Query("SELECT model FROM el_exchange_items WHERE id ="..id.." AND steamid ='"..ply:SteamID64().."'")[1].model
		local c_ent = ents.Create(classname)
		c_ent:SetPos(ply:GetPos())
		if IsValid(c_ent) then
			if classname=="spawned_weapon" then 
				local dtvars = util.JSONToTable(dtinfo)
				c_ent:SetModel(wmodel)
				c_ent:SetWeaponClass(dtvars.WeaponClass)
				c_ent:Setamount(dtvars.amount)
			end 
			ply:addPocketItem(c_ent)
		end
		sql.Query("DELETE FROM el_exchange_items WHERE id ="..id.." AND steamid ='"..ply:SteamID64().."'")
		ply:ChatPrint("Removed item with ID "..id.." and the item is in your pocket.")
	end
end )


net.Receive( "el_query", function( len, ply )
	local credits = el_balance(ply)
	local sortby = net.ReadString()
	local sqlqry = "SELECT * FROM el_exchange_items"
	if sortby == "price" then
		sqlqry = "SELECT * FROM el_exchange_items ORDER BY price ASC"
	end
	if sortby == "search" then
		local keyword = sql.SQLStr("%"..net.ReadString().."%")
		sqlqry = "SELECT * FROM el_exchange_items WHERE name LIKE "..keyword.." ORDER BY price ASC"
	end

	local sqltbl = sql.Query( sqlqry )
	if sortby=="date" then sqltbl = table.Reverse(sqltbl) end
	if sqltbl == nil then
		ply:ChatPrint("No results were found.")
	else
		net.Start( "el_exchange_contents" )
			net.WriteTable( sqltbl )
			net.WriteInt( credits,32 )
			net.WriteInt( sql.Query( "SELECT sales FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].sales,32 )
			net.WriteInt( sql.Query( "SELECT total_earned FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].total_earned,32 )
			net.WriteInt( sql.Query( "SELECT total_spent FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].total_spent,32 )
		net.Send(ply)	
	    umsg.Start( "el_exchange_menu", ply )
	    umsg.End()
	end
end )

net.Receive( "el_buy_item", function( len, ply )
	local n = net.ReadInt(32)
	local data = sql.Query( "SELECT * FROM el_exchange_items" )
	for k,v in pairs(data) do
		if tonumber(data[k].id)==tonumber(n) then
			if data[k].steamid == ply:SteamID64() then
				ply:ChatPrint("You can't buy your own item. To remove an item, use the control panel in the left.")
				return
			end
			if ply:canAfford(data[k].price) then 
				ply:addMoney(-data[k].price)
				local c_ent = ents.Create(data[k].classname)
				c_ent:SetPos(ply:GetPos())
				if IsValid(c_ent) then 
					if data[k].classname=="spawned_weapon" then
						local dtvars = util.JSONToTable(data[k].ent_info)
						c_ent:SetWeaponClass(dtvars.WeaponClass)
						c_ent:Setamount(dtvars.amount)
						c_ent:SetModel(data[k].model)
					end
					ply:addPocketItem(c_ent)
					for i,plyr in pairs(player.GetAll()) do
						if plyr:SteamID64() == data[k].steamid then
							net.Start( "el_sell_notify" )
								net.WriteString("SoldNotif")
								net.WriteString( ply:Nick() )
								net.WriteInt( data[k].price,32 )
								net.WriteString( data[k].name )
							net.Send(plyr)
						end
					end
					local sqlstr = "SELECT * FROM el_exchange_stats WHERE steamid='"..data[k].steamid.."'"
					local row = sql.QueryRow( sqlstr )
					local curr_balance = row.balance
					local sales = row.sales
					local earned = row.total_earned

					sqlstr = "SELECT * FROM el_exchange_stats WHERE steamid='"..ply:SteamID64().."'"
					row = sql.QueryRow( sqlstr )
					local total_spent = row.total_spent
					sql.Query("DELETE FROM el_exchange_items WHERE id ="..data[k].id)
					sql.Query("UPDATE el_exchange_stats SET balance = "..curr_balance+data[k].price.." WHERE steamid = '"..data[k].steamid.."'")
					sql.Query("UPDATE el_exchange_stats SET sales = "..(sales+1).." WHERE steamid = '"..data[k].steamid.."'")
					sql.Query("UPDATE el_exchange_stats SET total_earned = "..earned+data[k].price.." WHERE steamid = '"..data[k].steamid.."'")
					sql.Query("UPDATE el_exchange_stats SET total_spent = "..total_spent+data[k].price.." WHERE steamid = '"..ply:SteamID64().."'")
					ply:ChatPrint("Your item had been delivered to you ("..data[k].name..").")
					ply:ChatPrint("$"..data[k].price.." deducted.")
					file.Append( "elexchange_purchases.txt", ply:Nick().." has bought "..data[k].name.." for $"..data[k].price.."from "..data[k].name..".\r\n" )
				end
			else
				ply:ChatPrint("You cannot afford this.")
			end
		end
	end
end )

function elSellItem( ply, text, public )
    if (string.sub(text, 1, 7) == "/el_sell") then
    	local ent = ply:GetEyeTrace().Entity
		if ( IsValid( ply ) and IsValid( ent ) ) then
			umsg.Start( "elSell_m", ply )
			umsg.End()	
			ply:ChatPrint("Successfully sold an item.")
			return ""
		else
			DarkRP.notify( ply, 1, 3, "This item is unsellable!" )
			return ""
		end
	end
end
hook.Add( "PlayerSay", "elSellItem", elSellItem )

local function el_ply_spawn( ply )
	timer.Simple(5, function() 
		local b = sql.Query( "SELECT * FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )
		if b==nil then 
			sql.Query( "INSERT INTO el_exchange_stats ( 'steamid', 'balance', 'sales', 'total_earned', 'total_spent') VALUES ('"..ply:SteamID64().."', '0', '0', '0', '0')" )
		end
	end)
end
hook.Add( "PlayerInitialSpawn", "el_ply_spawn", el_ply_spawn )

local function el_ply_spawnnotif( ply )
	timer.Simple(10, function() 
		if tonumber(sql.Query( "SELECT balance FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].balance)>0 then
			net.Start( "el_sell_notify" )
				net.WriteString("JoinNotif")
				net.WriteString(sql.Query( "SELECT balance FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].balance)
			net.Send(ply)
		end
	end)
end
hook.Add( "PlayerInitialSpawn", "el_ply_spawnnotif", el_ply_spawnnotif )

function initDB()
	if not sql.TableExists( 'el_exchange_items' ) then
		sql.Query( 'CREATE TABLE el_exchange_items ( steamid TEXT, classname TEXT, username TEXT, price TEXT, model TEXT, name TEXT, ent_info TEXT, id NUMERIC ) ')
	end
	if not sql.TableExists( 'el_exchange_stats' ) then
		sql.Query( 'CREATE TABLE el_exchange_stats ( steamid TEXT, balance INT, sales INT, total_earned INT, total_spent INT) ')
	end
end
hook.Add("Initialize", "initDB", initDB)
