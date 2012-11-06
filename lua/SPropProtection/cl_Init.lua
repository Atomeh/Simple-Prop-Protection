------------------------------------
--	Simple Prop Protection
--	By Spacetech
-- 	http://code.google.com/p/simplepropprotection
--  Modified for Garry's Mod 13
------------------------------------

SPropProtection.AdminCPanel = nil
SPropProtection.ClientCPanel = nil

CreateClientConVar("spp_check", 1, false, true)
CreateClientConVar("spp_admin", 1, false, true)
CreateClientConVar("spp_use", 1, false, true)
CreateClientConVar("spp_edmg", 1, false, true)
CreateClientConVar("spp_pgr", 1, false, true)
CreateClientConVar("spp_awp", 1, false, true)
CreateClientConVar("spp_dpd", 1, false, true)
CreateClientConVar("spp_dae", 0, false, true)
CreateClientConVar("spp_delay", 120, false, true)
CreateClientConVar("spp_drive", 1, false, true)
CreateClientConVar("spp_property", 1, false, true)

surface.CreateFont( "SPropProtectionHUD", {
	font 		= "DermaDefault",
	size 		= 13,
	weight 		= 500,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false

} )


function SPropProtection.HUDPaint()
	if(!LocalPlayer() or !LocalPlayer():IsValid()) then
		return
	end
	local tr = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
	if(tr.HitNonWorld) then
		if(tr.Entity:IsValid() and !tr.Entity:IsPlayer() and !LocalPlayer():InVehicle()) then
			local PropOwner = "Owner: "
			local OwnerObj = tr.Entity:GetNetworkedEntity("OwnerObj", false)
			if(OwnerObj and OwnerObj:IsValid() and OwnerObj:IsPlayer()) then
				PropOwner = PropOwner..OwnerObj:Name()
			else
				OwnerObj = tr.Entity:GetNetworkedString("Owner", "N/A")
				if(type(OwnerObj) == "string") then
					PropOwner = PropOwner..OwnerObj
				elseif(OwnerObj:IsValid() and OwnerObj:IsPlayer()) then
					PropOwner = PropOwner..OwnerObj:Name()
				else
					PropOwner = PropOwner.."N/A"
				end
			end
			surface.SetFont("SPropProtectionHUD")
			local Width, Height = surface.GetTextSize(PropOwner)
			Width = Width + 25
			draw.RoundedBox(4, ScrW() - (Width), (ScrH()/2 - 200) - (8), Width, Height + 4, Color(0, 0, 0, 150))
			draw.SimpleText(PropOwner, "SPropProtectionHUD", ScrW() - (Width / 2), ScrH()/2 - 200.5, Color(255, 255, 255, 255), 1, 1)
		end
	end
end
hook.Add("HUDPaint", "SPropProtection.HUDPaint", SPropProtection.HUDPaint)

function SPropProtection.AdminPanel(Panel)
	Panel:ClearControls()
	
	if(!LocalPlayer():IsAdmin()) then
		Panel:AddControl("Label", {Text = "You are not an admin"})
		return
	end
	
	if(!SPropProtection.AdminCPanel) then
		SPropProtection.AdminCPanel = Panel
	end
	
	Panel:AddControl("Label", {Text = "SPP - Admin Panel - Spacetech"})
	
	Panel:AddControl("CheckBox", {Label = "Prop Protection", Command = "spp_check"})
	Panel:AddControl("CheckBox", {Label = "Admins Can Do Everything", Command = "spp_admin"})
	Panel:AddControl("CheckBox", {Label = "Use Protection", Command = "spp_use"})
	Panel:AddControl("CheckBox", {Label = "Entity Damage Protection", Command = "spp_edmg"})	
	Panel:AddControl("CheckBox", {Label = "Entity Drive Protection", Command = "spp_drive"})	
	Panel:AddControl("CheckBox", {Label = "Property Menu Protection", Command = "spp_property"})	
	Panel:AddControl("CheckBox", {Label = "Physgun Reload Protection", Command = "spp_pgr"})
	Panel:AddControl("CheckBox", {Label = "Admins Can Touch World Prop", Command = "spp_awp"})	
	Panel:AddControl("CheckBox", {Label = "Disconnect Prop Deletion", Command = "spp_dpd"})
	Panel:AddControl("CheckBox", {Label = "Delete Admin Entities", Command = "spp_dae"})
	Panel:AddControl("Slider", {Label = "Deletion Delay (Seconds)", Command = "spp_delay", Type = "Integer", Min = "10", Max = "500"})
	Panel:AddControl("Button", {Text = "Apply Settings", Command = "spp_apply"})
	
	Panel:AddControl("Label", {Text = "Cleanup Panel"})
	
	for k, ply in pairs(player.GetAll()) do
		if(ply and ply:IsValid()) then
			Panel:AddControl("Button", {Text = ply:Nick(), Command = "spp_cleanupprops "..ply:EntIndex()})
		end
	end
	
	Panel:AddControl("Label", {Text = "Other Cleanup Options"})
	Panel:AddControl("Button", {Text = "Cleanup Disconnected Players Props", Command = "spp_cdp"})
end

function SPropProtection.ClientPanel(Panel)
	Panel:ClearControls()
	
	if(!SPropProtection.ClientCPanel) then
		SPropProtection.ClientCPanel = Panel
	end
	
	Panel:AddControl("Label", {Text = "SPP - Client Panel - Spacetech"})
	
	Panel:AddControl("Button", {Text = "Cleanup Props", Command = "spp_cleanupprops"})
	Panel:AddControl("Label", {Text = "Friends Panel"})
	
	local Players = player.GetAll()
	if(table.Count(Players) == 1) then
		Panel:AddControl("Label", {Text = "No Other Players Are Online"})
	else
		for k, ply in pairs(Players) do
			if(ply and ply:IsValid() and ply != LocalPlayer()) then
				local FriendCommand = "spp_friend_"..ply:GetNWString("SPPSteamID")
				if(!LocalPlayer():GetInfo(FriendCommand)) then
					CreateClientConVar(FriendCommand, 0, false, true)
				end
				Panel:AddControl("CheckBox", {Label = ply:Nick(), Command = FriendCommand})
			end
		end
		Panel:AddControl("Button", {Text  = "Apply Settings", Command = "spp_applyfriends"})
	end
	Panel:AddControl("Button", {Text  = "Clear Friends", Command = "spp_clearfriends"})
end

function SPropProtection.SpawnMenuOpen()
	if(SPropProtection.AdminCPanel) then
		SPropProtection.AdminPanel(SPropProtection.AdminCPanel)
	end
	if(SPropProtection.ClientCPanel) then
		SPropProtection.ClientPanel(SPropProtection.ClientCPanel)
	end
end
hook.Add("SpawnMenuOpen", "SPropProtection.SpawnMenuOpen", SPropProtection.SpawnMenuOpen)

function SPropProtection.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Simple Prop Protection", "Admin", "Admin", "", "", SPropProtection.AdminPanel)
	spawnmenu.AddToolMenuOption("Utilities", "Simple Prop Protection", "Client", "Client", "", "", SPropProtection.ClientPanel)
end
hook.Add("PopulateToolMenu", "SPropProtection.PopulateToolMenu", SPropProtection.PopulateToolMenu)
