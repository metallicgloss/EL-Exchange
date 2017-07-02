hook.Add( "PlayerSay", "elSaveCMDFuel", function( ply, text, team )
	if ( string.sub( text, 1, 16 ) == "/el_savenpc" ) then
		if !ply:IsAdmin() then return end
		local ent = ply:GetEyeTrace().Entity
		if ent:GetClass()=="elexchange_npc" then 
			ply:ChatPrint("[---- EL-EXCHANGE -----]")
			ply:ChatPrint("NPC found, attempting to save.")
			local pos = ent:GetPos()
			local ang = ent:GetAngles()
			math.randomseed(os.time())
			local idnpc = math.random(1,100000)
			file.Append( "npc_elexchange.txt", "["..idnpc.."]\r\n" )
			file.Append( "npc_elexchange.txt", tostring(pos).."\r\n" )
			file.Append( "npc_elexchange.txt", tostring(ang).."\r\n" )
			ply:ChatPrint("Successfuly saved this NPC.") 
			ent.fuel_npc_id = idnpc
			return ""
		else
			ply:ChatPrint("Saving failed, NPC not found.")
			return ""
		end
	end
end )

local function CreateGNPCs()
	if SERVER then
		local datablock = file.Read( "npc_elexchange.txt", "DATA" )
		if !datablock then print("EL-EXCHANGE: No NPC's were found. Maybe create some?") return end
		local lst = string.Explode( "\r\n", datablock )
		local id,pos,ang
		local k = 0
		for i=0,table.Count(lst),3 do
			id = lst[i+1]
			pos = lst[i+2]
			ang = lst[i+3]
			if(lst[i+4]==nil) then break end
			local listPos = string.Explode( " ", pos )
			pos = Vector(listPos[1],listPos[2],listPos[3])
			local listAng = string.Explode( " ", ang )
			ang = Angle(tonumber(listAng[1]),tonumber(listAng[2]),tonumber(listAng[3]))
			local ent = ents.Create("elexchange_npc")
			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:Spawn()
			ent:Activate()
			ent.fuel_npc_id = string.gsub(id,'%W','')
		end
	end
end
hook.Add( "InitPostEntity", "CreateGNPCs", CreateGNPCs)
