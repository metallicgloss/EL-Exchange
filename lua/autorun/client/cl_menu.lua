surface.CreateFont( "GM55", {
	font = "Roboto Medium",
	size = 55,
	shadow = false,
} )
 
surface.CreateFont( "GM32", {
	font = "Roboto Medium",
	size = 32,
	shadow = false,
} )

surface.CreateFont( "GM20", {
	font = "Roboto Medium",
	size = 20,
	shadow = false,
} )

surface.CreateFont( "GM10", {
	font = "Roboto Medium",
	size = 16,
	shadow = false,
} )

net.Receive( "el_exchange_contents", function( len )
	el_exchange_contents_tbl = net.ReadTable()
	el_exchange_creds = net.ReadInt(32)
	el_exchange_sales = net.ReadInt(32)
	el_exchange_totalearned = net.ReadInt(32)
	el_exchange_totalspent = net.ReadInt(32)
end )


function el_exchange_menu()
	local mainFrame = vgui.Create( "DFrame" )
	mainFrame:SetPos( ScrW()/2-ScrW()/1.8/2,ScrH()/2-ScrW()/1.8 )
	mainFrame:SetSize( ScrW()/1.8,ScrW()/1.7)
	mainFrame:SetTitle( "elExchange" )
	mainFrame:SetVisible( true )
	mainFrame:SetDraggable( true )
	mainFrame:ShowCloseButton( true )
	mainFrame:SetBackgroundBlur( true )
	mainFrame:MakePopup()
	local mPanel = vgui.Create( "DPanel",mainFrame )
	mPanel:SetPos( 0,0 )
	mPanel:SetSize( mainFrame:GetSize() )
	mPanel:SetVisible( true )
	function mPanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(236, 240, 241) )
	end

	local statswindow = vgui.Create( "DPanel",mainFrame )
	statswindow:SetPos( ScrW()/1.8-ScrW()/4+ScrW()/50, ScrW()/1.8/8+80 )
	statswindow:SetSize( ScrW()/4.68, ScrH()/1.35 ) 
	function statswindow:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(52, 73, 94) )
	end

	local imgtbl = {"icon16/coins.png","icon16/coins_add.png","icon16/coins_delete.png","icon16/cart_go.png"}
	for k,v in pairs(imgtbl) do
		local img = vgui.Create("DImage",statswindow)
		img:SetPos(12,60+k*19)
		img:SetSize(16,16)
		img:SetImage(imgtbl[k])
	end

	local stats = vgui.Create( "DLabel",statswindow )
	stats:SetPos( 35,0 )
	stats:SetSize( ScrW()/4.68, ScrH()/1.35/4 )
	stats:SetVisible( true )
	stats:SetText("\n\n\nCurrent balance: $"..el_exchange_creds.."\nTotal earned: $"..el_exchange_totalearned.."\nTotal spent: $"..el_exchange_totalspent.."\nTotal sales: "..el_exchange_sales)
	stats:SetTextColor(Color(255, 255, 255))
	stats:SetFont("GM20")

	local titlestats = vgui.Create( "DLabel",statswindow )
	titlestats:SetPos( 10,15 )
	titlestats:SetSize( ScrW()/4.68, 60 )
	titlestats:SetVisible( true )
	titlestats:SetText("elExchange Stats")
	titlestats:SetTextColor(Color(255, 255, 255))
	titlestats:SetFont("GM32")

	local items_owned = vgui.Create( "DListView",statswindow )
	items_owned:SetMultiSelect( false )
	items_owned:SetPos(0,ScrW()/10)
	if ScrW()<1600 then 
		items_owned:SetSize(ScrW()/4.68,ScrH()/7)
	else
		items_owned:SetSize(ScrW()/4.68,ScrH()/5+25)
	end
	items_owned:AddColumn( "Item" )
	items_owned:AddColumn( "Price" )
	items_owned:AddColumn( "ID" )
	for k,v in pairs(el_exchange_contents_tbl) do
		if el_exchange_contents_tbl[k].steamid == LocalPlayer():SteamID64() then 
			items_owned:AddLine( el_exchange_contents_tbl[k].name,el_exchange_contents_tbl[k].price,el_exchange_contents_tbl[k].id )
		end
	end

	local col = vgui.Create( "DButton",statswindow )
	col:SetPos( 0, ScrW()/10+235 )
	col:SetSize( ScrW()/4.68,20 )
	col:SetVisible( true )
	col:SetText("Collect credits")
	col:SetTextColor(Color(255,255,255))
	col.Fill = false
	col:SetImage("icon16/money_add.png")
	col:SetFont("GM10")
	col.OnCursorEntered = function () col.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	col.OnCursorExited = function () col.Fill = false end 
	col.Paint = function()
		if !col.Fill then 
			surface.SetDrawColor(41, 128, 185)
		else
			surface.SetDrawColor(52, 152, 219)
		end
		col:DrawFilledRect()
	end
	col.DoClick = function() 
		mainFrame:Close()
		net.Start( "el_collect" )
		net.SendToServer()
	end

	local rem = vgui.Create( "DButton",statswindow )
	rem:SetPos( 0, ScrW()/10+210 )
	rem:SetSize( ScrW()/4.68,20 )
	rem:SetVisible( true )
	rem:SetText("Remove selected item")
	rem:SetTextColor(Color(255,255,255))
	rem.Fill = false
	rem:SetImage("icon16/delete.png")
	rem:SetFont("GM10")
	rem.OnCursorEntered = function () rem.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	rem.OnCursorExited = function () rem.Fill = false end 
	rem.Paint = function()
		if !rem.Fill then 
			surface.SetDrawColor(192, 57, 43,255)
		else
			surface.SetDrawColor(231, 76, 60,255)
		end
		rem:DrawFilledRect()
	end
	rem.DoClick = function() 
		local key = items_owned:GetSelectedLine( );
		local line = items_owned.Lines[ key ];
		local id_data = line:GetColumnText( 3 );
		mainFrame:Close()
		net.Start( "el_request_removal" )
			net.WriteString("ITEM")
			net.WriteInt(id_data,32)
		net.SendToServer()
	end

	local statswindow_l = vgui.Create( "DPanel",mainFrame )
	statswindow_l:SetPos( ScrW()/1.8-ScrW()/4+ScrW()/50, ScrH()/1.35+ScrW()/1.8/8+80 )
	statswindow_l:SetSize( ScrW()/4.68, 12 ) 
	function statswindow_l:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(44, 62, 80) )
	end

	local statswindow_s = vgui.Create( "DPanel",mainFrame )
	statswindow_s:SetPos( ScrW()/1.8-ScrW()/4+ScrW()/50-12, ScrW()/1.8/8+80 )
	statswindow_s:SetSize( 12, ScrH()/1.35+12 ) 
	function statswindow_s:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(44, 62, 80) )
	end

	local scrollpanel = vgui.Create( "DScrollPanel",mainFrame )
	scrollpanel:SetPos( 12, ScrW()/1.8/8+80 )
	scrollpanel:SetSize( ScrW()/1.8-ScrW()/4+5, ScrH()/1.35+12 ) 
	function scrollpanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(236, 240, 241) )
	end


	for k,v in pairs(el_exchange_contents_tbl) do
		local itemrow = vgui.Create( "DPanel",scrollpanel )
		itemrow:SetPos( 0, k*80-80 )
		itemrow:SetSize( ScrW()/1.8-ScrW()/4, 65 ) 
		function itemrow:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(52, 73, 94) )
		end

		local lowerrow = vgui.Create( "DPanel",scrollpanel )
		lowerrow:SetPos( 0, k*80-80+65 )
		lowerrow:SetSize( ScrW()/1.8-ScrW()/4, 10 ) 
		function lowerrow:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(44, 62, 80) )
		end

		local pnlmdl = vgui.Create( "DPanel",itemrow )
		pnlmdl:SetPos( 0, 0 )
		pnlmdl:SetSize( 65,65 ) 
		function pnlmdl:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(44, 62, 80) )
		end

		local itemthumbnail = vgui.Create( "SpawnIcon",itemrow )
		itemthumbnail:SetPos( 0, 0 )
		itemthumbnail:SetModel(el_exchange_contents_tbl[k].model)
		itemthumbnail:SetToolTip("Item ID: "..el_exchange_contents_tbl[k].id..", Class: "..el_exchange_contents_tbl[k].classname)

		local name = vgui.Create( "DLabel",itemrow )
		name:SetPos( 75, -10 )
		name:SetSize( ScrW()/4, ScrW()/25 )
		name:SetVisible( true )
		name:SetText(el_exchange_contents_tbl[k].name)
		name:SetTextColor(Color(255, 255, 255))
		name:SetFont("GM20")

		local name = vgui.Create( "DLabel",itemrow )
		name:SetPos( 75, 15 )
		name:SetSize( ScrW()/4, ScrW()/25 )
		name:SetVisible( true )
		name:SetText("Added by "..el_exchange_contents_tbl[k].username)
		name:SetTextColor(Color(255, 255, 255))
		name:SetFont("GM10")

		local cmp = vgui.Create( "DButton",itemrow )
		cmp:SetPos( ScrW()/1.8-ScrW()/4-85, 35 )
		cmp:SetSize( 25, 25 )
		cmp:SetVisible( true )
		cmp:SetText("")
		cmp:SetToolTip("Compare with other sellers")
		cmp:SetTextColor(Color(255,255,255))
		cmp.Fill = false
		cmp:SetImage("icon16/chart_bar.png")
		cmp.DoClick = function() 
			mainFrame:Close()
			net.Start( "el_query" )
				net.WriteString( "search" )
				net.WriteString( el_exchange_contents_tbl[k].name )
			net.SendToServer()
		end
		cmp:SetFont("GM10")
		cmp.OnCursorEntered = function () cmp.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
		cmp.OnCursorExited = function () cmp.Fill = false end 
		cmp.Paint = function()
			if !cmp.Fill then 
				surface.SetDrawColor(192, 57, 43,0)
			else
				surface.SetDrawColor(231, 76, 60,0)
			end
			cmp:DrawFilledRect()
		end

		local mtext = vgui.Create( "DLabel",itemrow )
		mtext:SetPos( ScrW()/1.8-ScrW()/4-85,-10 )
		mtext:SetSize( ScrW()/4, ScrW()/25 )
		mtext:SetVisible( true )
		mtext:SetText("$"..el_exchange_contents_tbl[k].price)
		if LocalPlayer():getDarkRPVar("money") < tonumber(el_exchange_contents_tbl[k].price) then
			mtext:SetTextColor(Color(192, 57, 43))
		else
			mtext:SetTextColor(Color(46, 204, 113))
		end
		mtext:SetFont("GM20")

		local buy = vgui.Create( "DButton",itemrow )
		buy:SetPos( ScrW()/1.8-ScrW()/4-60, 35 )
		buy:SetSize( 25, 25 )
		buy:SetToolTip("Buy this item")
		buy:SetImage("icon16/cart_put.png")
		buy:SetVisible( true )
		buy:SetText("")
		buy:SetTextColor(Color(255,255,255))
		buy.Fill = false
		buy.DoClick = function() 
			mainFrame:Close()
			net.Start( "el_buy_item" )
				net.WriteInt( el_exchange_contents_tbl[k].id,32 )
			net.SendToServer()
		end
		buy:SetFont("GM10")
		buy.OnCursorEntered = function () buy.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
		buy.OnCursorExited = function () buy.Fill = false end 
		buy.Paint = function()
			if LocalPlayer():getDarkRPVar("money") < tonumber(el_exchange_contents_tbl[k].price) then
				surface.SetDrawColor(149, 165, 166,0)
			else
				if !buy.Fill then 
					surface.SetDrawColor(39, 174, 96,0)
				else
					surface.SetDrawColor(46, 204, 113,0)
				end
			end
			buy:DrawFilledRect()
		end

		local steamprofile = vgui.Create( "DButton",itemrow )
		steamprofile:SetPos( ScrW()/1.8-ScrW()/4-35, 35 )
		steamprofile:SetSize( 25, 25 )
		steamprofile:SetToolTip("Open steam profile")
		steamprofile:SetImage("icon16/user_gray.png")
		steamprofile:SetVisible( true )
		--steamprofile:SetText("$"..el_exchange_contents_tbl[k].price)
		steamprofile:SetText("")
		steamprofile:SetTextColor(Color(255,255,255))
		steamprofile.Fill = false
		steamprofile.DoClick = function() 
			mainFrame:Close()
			gui.OpenURL( "http://steamcommunity.com/profiles/"..el_exchange_contents_tbl[k].steamid )
		end
		steamprofile:SetFont("GM10")
		steamprofile.OnCursorEntered = function () steamprofile.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
		steamprofile.OnCursorExited = function () steamprofile.Fill = false end 
		steamprofile.Paint = function()
			if !steamprofile.Fill then 
				surface.SetDrawColor(243, 156, 18,0)
			else
				surface.SetDrawColor(241, 196, 15,0)
			end
			steamprofile:DrawFilledRect()
		end
	end
	
	local sortbyprice = vgui.Create( "DButton",mainFrame )
	sortbyprice:SetPos( 12, ScrW()/12 )
	sortbyprice:SetSize( ScrW()/7, 20 )
	sortbyprice:SetVisible( true )
	sortbyprice:SetText("Sort by price")
	sortbyprice:SetTextColor(Color(255,255,255))
	sortbyprice.Fill = false
	sortbyprice:SetImage("icon16/coins.png")
	sortbyprice.DoClick = function() 
		mainFrame:Close()
		net.Start( "el_query" )
			net.WriteString( "price" )
		net.SendToServer()
	end
	sortbyprice:SetFont("GM10")
	sortbyprice.OnCursorEntered = function () sortbyprice.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	sortbyprice.OnCursorExited = function () sortbyprice.Fill = false end 
	sortbyprice.Paint = function()
		if !sortbyprice.Fill then 
			surface.SetDrawColor(44, 62, 80)
		else
			surface.SetDrawColor(52, 73, 94)
		end
		sortbyprice:DrawFilledRect()
	end

	local sell = vgui.Create( "DButton",mainFrame )
	sell:SetPos( 12, ScrW()/12+25 )
	sell:SetSize( ScrW()/7*3+ScrW()/10.5-2+13, 20 )
	sell:SetVisible( true )
	sell:SetText("To sell an item, look at it and type /el_sell.")
	sell:SetTextColor(Color(255,255,255))
	sell.Fill = false
	sell:SetImage("icon16/cart_remove.png")
	sell:SetFont("GM10")
	sell.OnCursorEntered = function () sell.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	sell.OnCursorExited = function () sell.Fill = false end 
	sell.Paint = function()
		if !sell.Fill then 
			surface.SetDrawColor(41, 128, 185)
		else
			surface.SetDrawColor(52, 152, 219)
		end
		sell:DrawFilledRect()
	end

	local sortbydate = vgui.Create( "DButton",mainFrame )
	sortbydate:SetPos( ScrW()/7+25-13, ScrW()/12 )
	sortbydate:SetSize( ScrW()/7+13, 20 )
	sortbydate:SetVisible( true )
	sortbydate:SetText("Sort by date")
	sortbydate:SetTextColor(Color(255,255,255))
	sortbydate.Fill = false
	sortbydate:SetImage("icon16/calendar.png")
	sortbydate.DoClick = function() 
		mainFrame:Close()
		net.Start( "el_query" )
			net.WriteString( "date" )
		net.SendToServer()
	end
	sortbydate:SetFont("GM10")
	sortbydate.OnCursorEntered = function () sortbydate.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	sortbydate.OnCursorExited = function () sortbydate.Fill = false end 
	sortbydate.Paint = function()
		if !sortbydate.Fill then 
			surface.SetDrawColor(52, 73, 94)
		else
			surface.SetDrawColor(44, 62, 80)
		end
		sortbydate:DrawFilledRect()
	end

	local TextEntry = vgui.Create( "DTextEntry", mainFrame )
	TextEntry:SetPos( ScrW()/7*3+23, ScrW()/12 )
	TextEntry:SetSize( ScrW()/10.5, 20 )
	TextEntry:SetText( "" )

	local serachitem = vgui.Create( "DButton",mainFrame )
	serachitem:SetPos( ScrW()/7*2+23, ScrW()/12 )
	serachitem:SetSize( ScrW()/7, 20 )
	serachitem:SetVisible( true )
	serachitem:SetText("Search an item:")
	serachitem:SetTextColor(Color(255,255,255))
	serachitem:SetImage("icon16/magnifier.png")
	serachitem.Fill = false
	serachitem.DoClick = function() 
		mainFrame:Close()
		net.Start( "el_query" )
			net.WriteString( "search" )
			net.WriteString( TextEntry:GetText() )
		net.SendToServer()
	end
	serachitem:SetFont("GM10")
	serachitem.OnCursorEntered = function () serachitem.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	serachitem.OnCursorExited = function () serachitem.Fill = false end 
	serachitem.Paint = function()
		if !serachitem.Fill then 
			surface.SetDrawColor(44, 62, 80)
		else
			surface.SetDrawColor(52, 73, 94)
		end
		serachitem:DrawFilledRect()
	end

	local Abort = vgui.Create( "DButton",mainFrame )
	Abort:SetPos( ScrW()/1.8-65, 0 )
	Abort:SetSize( 65, 40 )
	Abort:SetVisible( true )
	Abort:SetText("X")
	Abort:SetTextColor(Color(255,255,255))
	Abort.Fill = false
	Abort.DoClick = function() 
		mainFrame:Close()
	end
	Abort:SetFont("GM10")
	Abort.OnCursorEntered = function () Abort.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	Abort.OnCursorExited = function () Abort.Fill = false end 
	Abort.Paint = function()
		if !Abort.Fill then 
			surface.SetDrawColor(192, 57, 43,255)
		else
			surface.SetDrawColor(231, 76, 60,255)
		end
		Abort:DrawFilledRect()
	end

	local title = vgui.Create( "DLabel",mainFrame )
	title:SetPos( 25, ScrW()/1.8/36 )
	title:SetSize( (ScrW()/7)*1.2, ScrW()/25 )
	title:SetVisible( true )
	title:SetText("elExchange")
	title:SetTextColor(Color(52, 73, 94))
	title:SetFont("GM55")

	local stitle = vgui.Create( "DLabel",mainFrame )
	stitle:SetPos( 25, ScrW()/1.8/36+45 )
	stitle:SetSize( ScrW()/4, ScrW()/25 )
	stitle:SetVisible( true )
	stitle:SetText("Your reliable marketplace.")
	stitle:SetTextColor(Color(52, 73, 94))
	stitle:SetFont("GM32")

	if ScrW()<1600 then 
		title:SetFont("GM32")
		stitle:SetFont("GM20")
		stitle:SetPos( 25, ScrW()/1.8/36+25 )
	end
end
usermessage.Hook("el_exchange_menu",el_exchange_menu)

function elSell_m(  )
	local mFrame = vgui.Create( "DFrame" )
	mFrame:SetSize( 300, 110 )
	mFrame:SetPos( ScrW()/2-149,ScrH()/2-55 )
	mFrame:SetTitle( " " )
	mFrame:SetVisible( true )
	mFrame:SetDraggable( false )
	mFrame:SetBackgroundBlur( true )
	mFrame:ShowCloseButton( false )
	mFrame.Paint = function()
		surface.SetDrawColor(0,0,0,150)
		mFrame:DrawFilledRect()
		surface.SetDrawColor(0,0,0)
		mFrame:DrawOutlinedRect()
	end
	mFrame:MakePopup()

	local mPanel = vgui.Create( "DPanel",mFrame )
	mPanel:SetPos( 0,0 )
	mPanel:SetSize( mFrame:GetSize() )
	mPanel:SetVisible( true )
	function mPanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(52, 73, 94) )
	end

	local title = vgui.Create( "DLabel", mPanel )	
	title:SetPos( 85, 35)
	title:SetTextColor(Color(255,255,255))
	title:SetSize( 200, 25 ) 
	title:SetText( "Selling item: "..(LocalPlayer():GetEyeTrace().Entity.PrintName or "Item") )
	
	local price = vgui.Create( "DTextEntry", mPanel )	
	price:SetPos( 85, 65)
	price:SetSize( 135, 25 )
	price:SetText( "Price" )
	price.OnGetFocus = function( )
		price:SetText("")
	end

	local xs = vgui.Create( "DLabel", mPanel )	
	xs:SetPos( 15, 0)
	xs:SetSize( 200, 30 )
	xs:SetTextColor( Color(255,255,255) )
	xs:SetText( "Weapon Selling Menu" )
	
	local tnail = vgui.Create( "SpawnIcon", mPanel )	
	tnail:SetPos( 10, 35)
	tnail:SetModel(LocalPlayer():GetEyeTrace().Entity:GetModel())
	
	slb = vgui.Create( "DButton", mPanel )
	slb:SetSize( 60, 20 ) 
	slb:SetPos( 225, 68 )
	slb:SetText( "Sell" )
	slb:SetTextColor( Color(255,255,255) )
	slb.OnCursorEntered = function () slb.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	slb.OnCursorExited = function () slb.Fill = false end 
	slb.Paint = function()
		if !slb.Fill then 
			surface.SetDrawColor(192, 57, 43,255)
		else
			surface.SetDrawColor(231, 76, 60,255)
		end
		slb:DrawFilledRect()
	end
	slb.DoClick = function() 
		mFrame:Close()
		if tonumber(price:GetText())~=nil then 
			net.Start( "el_sell_item" )
				net.WriteEntity( LocalPlayer():GetEyeTrace().Entity )
				net.WriteInt(price:GetText(),32)
			net.SendToServer()
		else
			LocalPlayer():ChatPrint("Enter a numeric value as a price.")
		end
	end
	local Abort = vgui.Create( "DButton",mFrame )
	Abort:SetPos( 275, 5 )
	Abort:SetSize( 20, 20 ) 
	Abort:SetVisible( true )
	Abort:SetText("X")
	Abort:SetTextColor(Color(255,255,255))
	Abort.Fill = false
	Abort.DoClick = function() 
		mFrame:Close()
	end
	Abort:SetFont("GM10")
	Abort.OnCursorEntered = function () Abort.Fill = true surface.PlaySound("UI/buttonrollover.wav") end 
	Abort.OnCursorExited = function () Abort.Fill = false end 
	Abort.Paint = function()
		if !Abort.Fill then 
			surface.SetDrawColor(192, 57, 43,255)
		else
			surface.SetDrawColor(231, 76, 60,255)
		end
		Abort:DrawFilledRect()
	end
end	
usermessage.Hook( "elSell_m", elSell_m )


local function sellNotif(strinel_info)
	surface.PlaySound("update_notif.mp3")

	local c_whitec = Color(236, 240, 241)
	local width = ScrW() * 0.25

	local mainFrame = vgui.Create( "DFrame" )
	mainFrame:SetSize(width*0.75, ScrH()/6)
	mainFrame:SetPos(-width*2, ScrH()*4/5)
	mainFrame:MoveTo(ScrW() - (width*0.75)*1.2, ScrH()-(ScrH()/5)*1.2, 0.25, 0, 0.15)
	mainFrame:SetVisible( true )
	mainFrame:SetDraggable( false )
	mainFrame:ShowCloseButton( false )
	mainFrame:SetKeyboardInputEnabled(false)
	mainFrame:SetMouseInputEnabled(true)
	mainFrame:SetVisible(true)

	mainFrame.Paint = function()
		surface.SetDrawColor(c_whitec)
		mainFrame:DrawFilledRect()
		surface.SetDrawColor( 189, 195, 199 )
		surface.DrawRect( 0, mainFrame:GetTall()-10, mainFrame:GetWide(), mainFrame:GetTall() )
	end

	local button = vgui.Create("DButton",mainFrame)
	button:SetPos((width*0.75)-55, 15)
	button:SetSize(40,25)
	button:SetText("X")
	button:SetFont("Trebuchet18")
	button.DoClick = function (btn) 
		timer.Simple(1,function() mainFrame:Close() end)
		mainFrame:MoveTo(ScrW(), ScrH(), 0.25, 0, 0.15)
		surface.PlaySound("buttons/button24.wav")
	end
	button:SetTextColor(Color(255,255,255))
	button.Paint = function (btn) 
		surface.SetDrawColor( 231, 76, 60 )
		surface.DrawRect( 0, 0, button:GetWide(), button:GetTall() )
		surface.SetDrawColor( 192, 57, 43 )
		surface.DrawRect( 0, 20, button:GetWide(), button:GetTall() )
	end

	local titl = vgui.Create( "DLabel", mainFrame )
	titl:SetPos( 15, 20 )
	titl:SetSize( 200,25 )
	titl:SetFont("GM20")
	titl:SetText( "gExchage Notification" )
	titl:SetColor( Color(52, 73, 94) )

	local titl2 = vgui.Create( "DLabel", mainFrame )
	titl2:SetPos( 15, -5 )
	titl2:SetSize( 300,165 )
	titl2:SetFont("GM10")
	titl2:SetText( strinel_info )
	titl2:SetColor( Color(52, 73, 94) )
end

net.Receive( "el_sell_notify", function( len )
	local arg = net.ReadString()
	print(arg)
	if arg=="JoinNotif" then 
		local balance = net.ReadString()
		sellNotif("\nYou have money in your elExchange account. \nCollect it from the elExchange NPC.\n\nBalance: $"..balance.."")
	elseif arg=="SoldNotif" then
		local buyer = net.ReadString()
		local price = net.ReadInt(32)
		local itemname = net.ReadString()
		sellNotif("You sold "..itemname.." for $"..price.." to "..buyer..".\nThe money is in your elExchange account.\nCollect it by going to the NPC.")
	end
end )