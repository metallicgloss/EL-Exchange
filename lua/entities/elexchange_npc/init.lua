AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

function ENT:Initialize()
	math.randomseed(os.time())
	self:SetModel("models/humans/group02/male_0"..math.random(1,9)..".mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE, CAP_TURN_HEAD)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
	self:SetMaxYawSpeed( 90 )
end

local function el_balance(ply)
	if sql.Query( "SELECT balance FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].balance == nil then return end
	return tonumber(sql.Query( "SELECT balance FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].balance)
end

function ENT:AcceptInput(name, activator, ply, data)
	if name == "Use" && IsValid(ply) && ply:IsPlayer() then
		local credits = el_balance(ply)
		local local_items = sql.Query( "SELECT * FROM el_exchange_items" )
		if local_items then local_items = table.Reverse(local_items) else local_items = {} end
		net.Start( "el_exchange_contents" )
			net.WriteTable( local_items )
			net.WriteInt( credits,32 )
			net.WriteInt( sql.Query( "SELECT sales FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].sales,32 )
			net.WriteInt( sql.Query( "SELECT total_earned FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].total_earned,32 )
			net.WriteInt( sql.Query( "SELECT total_spent FROM el_exchange_stats WHERE steamid ='"..ply:SteamID64().."'" )[1].total_spent,32 )
		net.Send(ply)	
	    umsg.Start( "el_exchange_menu", ply )
	    umsg.End()
	end
end