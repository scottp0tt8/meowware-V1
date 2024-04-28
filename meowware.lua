-- very bad
-- sorry for you having to read this


print ("Meowware loaded: starting up for:")

local load_module = false

if jit.arch == "x86" then
    print("32-bit game")
    load_module = true
    pcall(require, "big")
elseif jit.arch == "x64" then
    print("64-bit game")
    load_module = false
end

RunConsoleCommand("sv_airaccelerate", 10000000)RunConsoleCommand("cl_updaterate", 1000)
RunConsoleCommand("cl_cmdrate", 0)
RunConsoleCommand("cl_interp", 0)
RunConsoleCommand("rate", 51200)

local meowware = {}
local ply = LocalPlayer()

meowware.debugwhite = Material("models/debug/debugwhite")
meowware.wireframe = Material("models/wireframe")

surface.CreateFont("PlayerNameFont", {
    font = "Arial Rounded MT Bold",
    size = 20,
    weight = 500,
    outline = true,
    outline_color = Color(0, 0, 0),
    antialias = true,
})

surface.CreateFont("WaterMarkFont", {
    font = "Default",
    size = 18,
    weight = 500,
    --outline = true,
    --outline_color = Color(0, 0, 0),
    antialias = true,
})

local function OnScreen(v)
	if math.abs(v:LocalToWorld(v:OBBCenter()):ToScreen().x) < ScrW() * 5 and math.abs(v:LocalToWorld(v:OBBCenter()):ToScreen().y) < ScrH() * 5 then
		return true
	else
		return false
	end
end

local menu = {
	["Visuals"] = {
		["Other Players:"] = {
			{"Name", "Checkbox", "meowware_visuals_name", 0, 0, true, true},
			
			{"2D Box", "Checkbox", "meowware_visuals_2d_box", 0, 0, true, true},
			{"Gradient 2D Box", "Checkbox", "meowware_visuals_gradient_2d_box", 0, 0, true, true},
			{"Gradient Box", "Checkbox", "meowware_visuals_gradient_box", 0, 0, true, true},
			
			{"Health Bar", "Checkbox", "meowware_visuals_healthbar", 0, 0, true, false},
			{"Health Bar Outline", "Checkbox", "meowware_visuals_healthbar_outline", 0, 0, true, true},
			
			{"Chams", "Checkbox", "meowware_visuals_chams", 0, 0, true},
			
			{"chams Overlay", "Checkbox", "meowware_visuals_chams_overlay", 0, 0, true, false},
			
			{"Tracers", "Checkbox", "meowware_visuals_tracers", 0, 0, true},
			
			{"Show friend status", "Checkbox", "meowware_visuals_friend_status", 0, 0, false},
		},
		["Props:"] = {
			{"Prop Chams", "Checkbox", "meowware_visuals_prop_chams", 0, 0, true, false},
			{"Prop Chams Overlay", "Checkbox", "meowware_visuals_prop_chams_overlay", 0, 0, true, false},
			
			{"Holding Prop Text", "Checkbox", "meowware_visuals_holding_prop_text", 0, 0, true, true},
		},
		["LocalPlayer:"] = {
			{"Custom FOV", "Checkbox", "meowware_visuals_fov", 0, 0, false, false},
			{"Custom FOV", "Slider", "meowware_visuals_fov_value", 0, 360, false, false},
			
			{"Move Camera", "Checkbox", "meowware_visuals_camera", 0, 0, false, false},
			{"Move Camera", "Slider", "meowware_visuals_camera_value", 0, 360, false, false},
			
			{"Landing Pos Master", "Checkbox", "meowware_visuals_landing_pos_master", 0, 0, false, false},
			{"Landing Pos 2D Box", "Checkbox", "meowware_visuals_landing_pos_2d_box", 0, 0, true, false},
			{"Landing Pos 2D Box", "Slider", "meowware_visuals_landing_pos_2d_box_size", 0, 10, false, false},
			{"Landing 3D Cricle Mat", "Checkbox", "meowware_visuals_landing_pos_3d_circle", 0, 0, true, false},
			{"Landing 3D Cricle Wire", "Checkbox", "meowware_visuals_landing_pos_3d_circle_wire", 0, 0, true, false},
		},
		["World:"] = {
			{"Custom Skybox", "Checkbox", "meowware_visuals_skybox_stencil", 0, 0, false, false},
			{"Dont Draw Ragdolls", "Checkbox", "meowware_visuals_no_draw_ragdol", 0, 0, false, false},
			{"Draw Skybox", "Checkbox", "meowware_visuals_draw_skybox", 0, 0, true, true},
			{"Draw Skybox Texture", "Checkbox", "meowware_visuals_draw_skybox_orginal", 0, 0, false, false},
			{"Draw Skybox Altutude", "Slider", "meowware_visuals_draw_skybox_altitude", 0, 15000, false, false},
		},
		["Menu:"] = {
			{"WaterMark", "Checkbox", "meowware_visuals_watermark", 0, 0, false, false},
			{"Menu Fade", "Checkbox", "meowware_visuals_menu_fade", 0, 0, false, false},
			{"Menu Fade Alpha", "Slider", "meowware_visuals_menu_fade_a", 0, 255, false, false},
			
			{"Background Effect", "Checkbox", "meowware_visuals_menu_bg_effect", 0, 0, false, false},
		},
	},
	["Other"] = {
		-- {"name", "type", "con_var", min, max, colorPicker, colorPicker2}
		["Movement:"] = {
			{"Auto Bhop", "Checkbox", "meowware_other_bhop", 0, 0},
			{"AirStuck", "Checkbox", "meowware_other_air_stuck", 0, 0},
		}
		--{"CheckBox2", "Checkbox", "meowware_Movement_checkbox2"},
	},
	["Aimbot"] = {
		["Aimbot:"] = {
			{"Enabled", "Checkbox", "meowware_aimbot_enabled", 0, 0},
		},
		["Target:"] = {
			{"Only Target Shitlist", "Checkbox", "meowware_aimbot_only_target_shitlist", 0, 0},
		},
	},
}

local function CreateMeowwareConVars()
	for _, tabs in pairs(menu) do
		for _, subtabs in pairs(tabs) do
			for _, feature in ipairs(subtabs) do
				local name, typ, conVar, mi, ma, colorpick, colorpick2 = unpack(feature)
				if (conVar && string.len(conVar) > 1) then
					CreateClientConVar(conVar, "0", { FCVAR_ARCHIVE })
					if (colorpick) then
						CreateClientConVar(conVar .. "_r", "255", { FCVAR_ARCHIVE })
						CreateClientConVar(conVar .. "_g", "255", { FCVAR_ARCHIVE })
						CreateClientConVar(conVar .. "_b", "255", { FCVAR_ARCHIVE })
						CreateClientConVar(conVar .. "_a", "255", { FCVAR_ARCHIVE })
							
						if (colorpick2) then
							CreateClientConVar(conVar .. "2_r", "255", { FCVAR_ARCHIVE })
							CreateClientConVar(conVar .. "2_g", "255", { FCVAR_ARCHIVE })
							CreateClientConVar(conVar .. "2_b", "255", { FCVAR_ARCHIVE })
							CreateClientConVar(conVar .. "2_a", "255", { FCVAR_ARCHIVE })
						end
					end
				end
			end
		end
	end
end
CreateMeowwareConVars()

local darkThemeColor = Color(15, 15, 15)

local MeowwareMenuOpen = false

local function MeowwareMenu()
	MeowwareMenuOpen = not MeowwareMenuOpen
end

local function MouseDownPos(x, y, xx, yy)
	local mouseX, mouseY = gui.MousePos()
	xx = x+xx
	yy = y+yy
	
	if (mouseX > x && mouseX < xx && mouseY > y && mouseY < yy) then
		if input.IsMouseDown(MOUSE_LEFT) then
			return 1, mouseX, mouseY
		elseif input.IsMouseDown(MOUSE_RIGHT) then
			return 2, mouseX, mouseY
		end
	end
	return 0, mouseX, mouseY
end

local function AntiMouseDownPos(x, y, xx, yy)
	local mouseX, mouseY = gui.MousePos()
	xx = x+xx
	yy = y+yy
	
	if not (mouseX > x && mouseX < xx && mouseY > y && mouseY < yy) then
		if input.IsMouseDown(MOUSE_LEFT) then
			return 1, mouseX, mouseY
		elseif input.IsMouseDown(MOUSE_RIGHT) then
			return 2, mouseX, mouseY
		end
	end
	return 0, mouseX, mouseY
end

local click = 0
local click_count = 0

local function IsClick(x, y, xx, yy)
	if click == 0 then
		click = MouseDownPos(x, y, xx, yy)
		return click
	else
		return 0 
	end
	return 0
end

local ColorPickerOpen = false
local ColorPickerConVar = ""
local ColorPickerX, ColorPickerY

local function OpenColorPicker(conVar)
	ColorPickerOpen = true
	ColorPickerConVar = conVar
	
	ColorPickerX, ColorPickerY = gui.MousePos()
end

local allowInteract = true

local function DrawSlider(menX, menY, itemSize, xOffset, mi, ma, conVar, DownOffset, name, ignoreInteract)
	local sliderValue = GetConVarNumber(conVar)
	local sliderPos = ((math.min(sliderValue, ma))/ma)*160
	
	surface.SetDrawColor(Color(150,150,150))
	surface.DrawRect(menX+xOffset+15, menY+72+DownOffset+itemSize, 160,2)
	
	--left
	surface.DrawRect(menX+xOffset+15, menY+70+DownOffset+itemSize, 1,6)
	
	--middle
	surface.DrawRect(menX+xOffset+15+80, menY+70+DownOffset+itemSize, 1,6)
	
	--right
	surface.DrawRect(menX+xOffset+15+160, menY+70+DownOffset+itemSize, 1,6)
	
	--slider bar
	surface.SetDrawColor(Color(255,255,255))
	surface.DrawRect(menX+xOffset+15+sliderPos, menY+69+DownOffset+itemSize, 3,8)


	surface.SetTextPos(menX+xOffset+15, menY+54+DownOffset+itemSize)
	surface.DrawText(name .. ": " .. sliderValue)
	
	if (ignoreInteract or allowInteract) then
		local MouseDownPo, mouseX = MouseDownPos(menX+xOffset+15, menY+66+DownOffset+itemSize, 160,12)
		if (MouseDownPo == 1) then
			sliderValue = math.Round(math.min(((mouseX-(menX+xOffset+15))/160)*ma, ma), 0) -- i fucking hate math.min it should be called math.max, giving the smallest of two inputs is retarded
			
			-- set the convar
			RunConsoleCommand(conVar, sliderValue)
		elseif (MouseDownPo == 2) then
			sliderValue = math.ceil(math.Round(math.min(((mouseX-(menX+xOffset+15))/160)*ma, ma), 0) / 5) * 5
			
			-- set the convar
			RunConsoleCommand(conVar, sliderValue)
		end
	end
	
	return 28
end

local function DrawColorPicker()
	if (ColorPickerOpen && MeowwareMenuOpen) then
		allowInteract = false
		if (AntiMouseDownPos(ColorPickerX, ColorPickerY, 200, 145) == 1) then
			ColorPickerOpen = false
		end
		local currentColor = Color(GetConVarNumber(ColorPickerConVar .. "_r"), GetConVarNumber(ColorPickerConVar .. "_g"), GetConVarNumber(ColorPickerConVar .. "_b"), GetConVarNumber(ColorPickerConVar .. "_a"))
		
		surface.SetDrawColor(Color(20,20,20))
		surface.DrawRect(ColorPickerX, ColorPickerY, 200, 145)
		
		surface.SetDrawColor(currentColor)
		surface.DrawRect(ColorPickerX, ColorPickerY, 200, 4)
		
		--i am lazy as fuck, enjoy your 4 sliders for color motherfucker
		
		DrawSlider(ColorPickerX, ColorPickerY, -40, 5, 0, 255, ColorPickerConVar .. "_r", 0, "Red", true)
		DrawSlider(ColorPickerX, ColorPickerY, -10, 5, 0, 255, ColorPickerConVar .. "_g", 0, "Green", true)
		DrawSlider(ColorPickerX, ColorPickerY, 20, 5, 0, 255, ColorPickerConVar .. "_b", 0, "Blue", true)
		DrawSlider(ColorPickerX, ColorPickerY, 50, 5, 0, 255, ColorPickerConVar .. "_a", 0, "Alpha", true)
		--DrawSlider(menX, menY, itemSize, xOffset, mi, ma, conVar, DownOffset, name)
	else
		allowInteract = true
	end
end

local menuH = 600
local menuW = 400
local menuXpos = (ScrW()/2)-(menuW/2)
local menuYpos = (ScrH()/2)-(menuH/2)
local diffX, diffY

local menuWasOpen = false
local selectedTab = "Visuals"
local isTyping = false

local function DrawItem(subtabs, xOffset, DownOffset)
	local itemSize = 0
	for _, feature in ipairs(subtabs) do
		local name, pType, conVar, mi, ma, colorpick, colorpick2 = unpack(feature)
		
		if pType == "Checkbox" then
			surface.SetDrawColor(Color(200,200,200))
			surface.DrawRect(menuXpos+xOffset+15, menuYpos+55+DownOffset+itemSize, 10,10)
			surface.SetTextPos(menuXpos+xOffset+30, menuYpos+54+DownOffset+itemSize)
			surface.DrawText(name)
			
			--color box if applicable
			if (colorpick) then
				
				surface.SetDrawColor(Color(GetConVarNumber(conVar .. "_r"),GetConVarNumber(conVar .. "_g"),GetConVarNumber(conVar .. "_b"), GetConVarNumber(conVar .. "_a")))
				surface.DrawRect(menuXpos+xOffset+160, menuYpos+58+DownOffset+itemSize, 16,8)
				
				if (IsClick(menuXpos+xOffset+160, menuYpos+58+DownOffset+itemSize, 16,8) == 2 && allowInteract) then
					OpenColorPicker(conVar)
				end
				
				if (colorpick2) then
					surface.SetDrawColor(Color(GetConVarNumber(conVar .. "2_r"),GetConVarNumber(conVar .. "2_g"),GetConVarNumber(conVar .. "2_b"), GetConVarNumber(conVar .. "2_a")))
					surface.DrawRect(menuXpos+xOffset+140, menuYpos+58+DownOffset+itemSize, 16,8)
					
					if (IsClick(menuXpos+xOffset+140, menuYpos+58+DownOffset+itemSize, 16,8) == 2 && allowInteract) then
						OpenColorPicker(conVar .. "2")
					end
				end
				
				surface.SetDrawColor(Color(200,200,200))
			end
			
			
			local curValue = GetConVarNumber(conVar)
			
			if (curValue == 1) then
				surface.SetDrawColor(Color(0,0,0))
				surface.DrawRect(menuXpos+xOffset+16, menuYpos+56+DownOffset+itemSize, 8,8)
			end
			
			if (IsClick(menuXpos+xOffset+15, menuYpos+55+DownOffset+itemSize, 10, 10) == 1 && allowInteract) then
				if (curValue == 1) then
					RunConsoleCommand(conVar, 0)
				else
					RunConsoleCommand(conVar, 1)
				end
			end
			
			itemSize = itemSize + 15
			
		elseif pType == "Slider" then
			itemSize = itemSize + DrawSlider(menuXpos, menuYpos, itemSize, xOffset, mi, ma, conVar, DownOffset, name, false)
		end
	end
	return itemSize
end

local function subTab(subtabs, subTabName, DownOffset, subTabNum, xOffset)
	--top lines
	surface.DrawLine(menuXpos+10+xOffset, menuYpos+50+DownOffset, menuXpos+88+xOffset-(surface.GetTextSize(subTabName)/2), menuYpos+50+DownOffset)
	surface.SetTextPos((menuXpos+90+xOffset)-(surface.GetTextSize(subTabName)/2),menuYpos+44+DownOffset)
	surface.DrawText(subTabName)
	
	surface.DrawLine(menuXpos+xOffset+92+(surface.GetTextSize(subTabName)/2), menuYpos+50+DownOffset, menuXpos+180+xOffset, menuYpos+50+DownOffset)
	
	--items
	local itemSize = DrawItem(subtabs, xOffset, DownOffset)
	
	surface.SetDrawColor(Color(200,200,200))
	surface.SetTextColor(Color(200,200,200))
	
	--left line
	surface.DrawLine(menuXpos+10+xOffset, menuYpos+50+DownOffset, menuXpos+10+xOffset, menuYpos+55+itemSize+DownOffset)
	
	--right line
	surface.DrawLine(menuXpos+180+xOffset, menuYpos+50+DownOffset, menuXpos+180+xOffset, menuYpos+55+itemSize+DownOffset)
	
	--bottom line
	surface.DrawLine(menuXpos+10+xOffset, menuYpos+55+itemSize+DownOffset, menuXpos+180+xOffset, menuYpos+55+itemSize+DownOffset)
	
	return itemSize
end

local function DrawPage(pageName, x, y, w, h, tabs)
	surface.SetDrawColor(Color(24,24,24))
	surface.DrawRect(menuXpos+x, menuYpos+y, w, h)
	
	local firstDownOffset = 0
	local secondDownOffset = 0
	local subTabNum = 0
	
	surface.SetDrawColor(Color(200,200,200))
	surface.SetTextColor(Color(200,200,200))
	surface.SetFont("Default")
	
	for subTabName, subtabs in pairs(tabs) do
		if (subTabNum % 2 == 0) then
			local itemSize = subTab(subtabs, subTabName, firstDownOffset, subTabNum, 0)
			
			--add to offset
			firstDownOffset = itemSize+firstDownOffset + 20
		else
			local itemSize = subTab(subtabs, subTabName, secondDownOffset, subTabNum, 208)
			
			--add to offset
			secondDownOffset = itemSize+secondDownOffset + 20
		end
		
		subTabNum = subTabNum+1
		
		--surface.DrawLine(x, y, xx, yy)
	end
end

local function DrawTab(x, y, w, h, text, textcolor, selected, tabs)
	if (selected) then
		DrawPage(text, 5, 45, menuW-10, menuH-49, tabs)
		surface.SetDrawColor(Color(24,24,24))
	else
		surface.SetDrawColor(Color(15,15,15))
	end
	surface.SetTextColor(textcolor)
	
    surface.DrawRect(menuXpos+x, menuYpos+y, w, h)
    surface.SetTextPos((menuXpos+x+(w/2)) - (surface.GetTextSize(text))/2, menuYpos+y + (h/2) -7)
    surface.SetFont("Default")
    surface.DrawText(text)
    
    if (MouseDownPos(menuXpos+x, menuYpos+y, w, h) == 1) then
    	selectedTab = text
    end
end

local function DrawTabs()
	local tabXPos = 5
	local tabXsize = 50
	for tabName, tabs in pairs(menu) do
		if tabName == selectedTab then
			DrawTab(tabXPos, 25, tabXsize, 20, tabName, Color(250,250,250), true, tabs)
		else
			DrawTab(tabXPos, 25, tabXsize, 20, tabName, Color(250,250,250), false, tabs)
		end
		tabXPos = tabXPos+tabXsize+1
	end
end

-- add attribute to all players
for _, v  in ipairs(player:GetAll()) do
	if (v == LocalPlayer()) then
		v["PlayerList"] = 3
	else
		v["PlayerList"] = 0
	end
end

meowware.playerlist = false
local function DrawPlayerList(x,y)
	local rainbowColor = HSVToColor((CurTime()*50)%360, 1, 1)

	x = x+menuW+5
	if (meowware.playerlist) then
		surface.SetDrawColor(Color(20,20,20))
			
		--close button
		surface.SetDrawColor(Color(20,20,20))
		surface.DrawRect(x+310,y+10,20,20)
		surface.SetTextColor(Color(250,250,250,255))
		surface.SetTextPos(x+317,y+13)
		surface.DrawText("<")
		if (MouseDownPos(x+310,y+10,20,20) == 1) then
			meowware.playerlist = false
		end
		
		--menu
		surface.DrawRect(x,y,300,menuH)
		
		--playerlist
		surface.SetDrawColor(Color(200,200,200))
		
		surface.SetTextPos(x+10,y+5)
		surface.DrawText("Player Name")
		surface.DrawLine(x+98,y+5,x+98,y+menuH)
		
		surface.SetTextPos(x+100,y+5)
		surface.DrawText("Role")
		surface.DrawLine(x+168,y+5,x+168,y+menuH)
		
		surface.SetTextPos(x+170,y+5)
		surface.DrawText("Uid")
		surface.DrawLine(x+198,y+5,x+198,y+menuH)
		
		surface.SetTextPos(x+200,y+5)
		surface.DrawText("Ping")
		surface.DrawLine(x+225,y+5,x+225,y+menuH)
		
		surface.SetTextPos(x+230,y+5)
		surface.DrawText("Status")
		
		for _, v  in ipairs(player:GetAll()) do
			if (v:IsValid()) then
				surface.SetDrawColor(Color(20,20,20))
				surface.SetTextColor(200,200,200)
				
				surface.SetTextPos(x+10,y+20)
				surface.DrawText(v:Nick())
				
				surface.DrawRect(x+100,y+22,60,10)
				surface.SetTextPos(x+100,y+20)
				surface.DrawText(v:GetUserGroup())
				
				surface.DrawRect(x+170,y+22,16,10)
				surface.SetTextPos(x+170,y+20)
				surface.DrawText(v:UserID())
				
				surface.DrawRect(x+200,y+22,19,10)
				surface.SetTextPos(x+200,y+20)
				surface.DrawText(v:Ping())
				
				surface.DrawRect(x+230,y+22,35,10)
				surface.SetTextPos(x+230,y+20)
				
				local click = IsClick(x, y+22, 300, 10)
				
				if (v["PlayerList"] == 0) then
					surface.SetTextColor(Color(200,200,200))
					surface.DrawText("non")
					if (click == 1) then
						print ("Setting " .. v:Nick() .. " to Friend")
						v["PlayerList"] = 1
					end
				elseif (v["PlayerList"] == 1) then
					surface.SetTextColor(Color(5,250,5))
					surface.DrawText("Friend")
					if (click == 1) then
						print ("Setting " .. v:Nick() .. " to Shit")
						v["PlayerList"] = 2
					end
			elseif (v["PlayerList"] == 2) then
					surface.SetTextColor(Color(250,5,5))
					surface.DrawText("Shit")
					if (click == 1) then
						print ("Setting " .. v:Nick() .. " to non")
						v["PlayerList"] = 0
					end
					
				elseif (v["PlayerList"] == 3) then
					surface.SetTextColor(rainbowColor)
					surface.DrawText("You")
					if (click == 1) then
						print ("This is you retard")
					end
				else
					v["PlayerList"] = 0
				end
				
				surface.SetDrawColor(Color(200,200,200))
				surface.DrawRect(x+0,y+20,300,1)
				
				y = y+13
			end
		end
		
	else
		--open button
		surface.SetDrawColor(Color(20,20,20))
		surface.DrawRect(x,y+10,20,20)
		surface.SetTextColor(Color(250,250,250,255))
		surface.SetTextPos(x+7,y+13)
		surface.DrawText(">")
		
		--onclick
		if (MouseDownPos(x,y+10,20,20) == 1) then
			meowware.playerlist = true
		end
	end
end

local function DrawMeowwareMenu()
	if MeowwareMenuOpen then
		local rainbowColor = HSVToColor((CurTime()*50)%360, 1, 1)
	
		local MouseDownPo, mouseX, mouseY = MouseDownPos(menuXpos, menuYpos, menuW, 20)
		
		if (MouseDownPo == 1) then
			menuXpos = menuXpos - (diffX-(mouseX - menuXpos))
			menuYpos = menuYpos - (diffY-(mouseY - menuYpos))
			
			menuXpos = math.min(math.max(menuXpos, 0), ScrW()-menuW)
			menuYpos = math.min(math.max(menuYpos, 0), ScrH()-menuH)
		end
		diffX = (mouseX - menuXpos)
		diffY = (mouseY - menuYpos)
		
		--menu background
		surface.SetDrawColor(Color(20, 20, 20))
		surface.DrawRect(menuXpos, menuYpos, menuW, menuH)
		
		-- top dragable
		surface.SetDrawColor(Color(30, 30, 30))
		surface.DrawRect(menuXpos, menuYpos, menuW, 20)
		
		--name
		surface.SetTextColor(Color(250,250,250))
		surface.SetTextPos(menuXpos + 5,menuYpos + 4)
		surface.SetFont("Default")
		surface.DrawText("Meowware")

		if (load_module == true) then
			print ("what????")
			surface.SetTextColor(Color(0,255,0))
			surface.SetTextPos(menuXpos + 350,menuYpos + 4)
			surface.SetFont("Default")
			surface.DrawText("Modules")
		else
			surface.SetTextColor(Color(250,0,0))
			surface.SetTextPos(menuXpos + 350,menuYpos + 4)
			surface.SetFont("Default")
			surface.DrawText("Modules")
		end
		
		--swagbar
		surface.SetDrawColor(rainbowColor)
		surface.DrawRect(menuXpos, menuYpos, menuW, 2)
		
		--tab select
		DrawTabs()
		
		--draw playerlist
		DrawPlayerList(menuXpos,menuYpos)
		
		gui.EnableScreenClicker(true)
		menuWasOpen = true
	elseif (menuWasOpen) then
		menuWasOpen = false
		gui.EnableScreenClicker(false)
	end
end

concommand.Add("meowware_menu", MeowwareMenu)


function EstimateSkyboxHeight()
	local referencePositions = {
		LocalPlayer():GetPos() + Vector(0,0,5),
		Vector(0,0,0),
		Vector(100,10,-20),
		Vector(400,50,20),
		Vector(800,100,10),
		Vector(1000,500,-5),
	}
	
	local LargestHeight = -9999999999
	for k,v in ipairs(referencePositions) do
		local traceData = {}
		
		traceData.start = v
		traceData.endpos = v + Vector(0, 0, 200000)
		traceData.mask = MASK_SOLID_BRUSHONLY
		
		local traceResult = util.TraceLine(traceData)
		if traceResult.Hit then
			LargestHeight = math.max(LargestHeight, traceResult.HitPos.z)
		end
	end

	if LargestHeight > -9999999999 then
		print("Estimated skybox height:", LargestHeight)
		return LargestHeight
	else
		print("No hit detected. Skybox height estimation failed.")
		return -9999999
	end
end

local skyboxHeight = EstimateSkyboxHeight()

local function reCalculate()
	skyboxHeight = EstimateSkyboxHeight()
end

concommand.Add("meowware_recalculate", reCalculate)

local gravity = GetConVarNumber("sv_gravity") -- The current gravity on the server
local function getLandingPos()
	local localplayer = LocalPlayer()
	local onground = localplayer:IsOnGround()

	if onground then return nil end

	gravity = gravity and gravity > 0 and gravity or GetConVarNumber("sv_gravity")

	local pos = localplayer:GetPos()
	local speed = localplayer:GetVelocity()
	local horizontalSpeed = Vector(speed.x, speed.y, 0)


	local time = speed.z / gravity -- Time since hitting the top of the parabola
	local vertDist = 0.5*gravity*time*time -- Vertical distance from top of parabola
	local startPos = pos + Vector(0, 0, vertDist) + horizontalSpeed * time -- The location of the top of the flying parabola

	speed.z = math.Min(-300, -math.abs(speed.z)) -- make sure the tracer always looks down (otherwise it will go up before hitting the top of parabola)

	-- Estimating the height of the landing zone, because calculating it in the while loop is too resource intensive
	local trace = {
			start = pos,
			endpos = pos + speed * 100000000,
			//endpos = pos -Vector(0, 0, 100000000),
			filter = localplayer
		}

	local tr = util.TraceLine(trace)

	local landingPos = startPos
	local t = -time -- Starting time for finding the destination
	while landingPos.z > tr.HitPos.z and t < 10 do
		local vert = 0.5*gravity*t*t -- The vertical distance travelled at time t
		landingPos = startPos + horizontalSpeed * t - Vector(0, 0, vert) -- location of player at time t
		t = t + 0.01
	end

	local endTrace = util.QuickTrace(pos, (landingPos - pos) * 2, localplayer)

	return endTrace.HitPos, endTrace, startPos
end

hook.Add("CalcView", "meowware_CalcView", function(me, pos, ang, fov)
	local view = {}
	if (GetConVarNumber("meowware_visuals_fov") == 1) then
		view.origin = pos
		view.angles = ang
		view.fov = GetConVarNumber("meowware_visuals_fov_value")
	end
	if (GetConVarNumber("meowware_visuals_camera") == 1) then
		-- Get the player's yaw angle
		local yaw = ang.yaw
		
		-- Calculate the forward direction vector based on the player's yaw angle
		local forward = Angle(0, yaw, 0):Forward()
		
		-- Scale the forward vector by the desired distance (in this example, we'll use 100 units)
		local distance = GetConVarNumber("meowware_visuals_camera_value")
		local new_pos = pos + forward * distance
		
		view.origin = new_pos
		view.angles = ang
	end
	return view
end)

hook.Add("HUDShouldDraw", "HideCrosshair", function(name)
    if name == "CHudCrosshair" && MeowwareMenuOpen then
        return false
    end
end)

local LocalPlayerLandingPos = getLandingPos()

hook.Add("Think", "BHOP", function()
	--awful way to do this but gg
	if (not input.IsMouseDown(MOUSE_LEFT) && not input.IsMouseDown(MOUSE_RIGHT)) then
		click = 0
	end
end)

meowware.gradient_down = Material( "gui/gradient_down" )
meowware.gradient_up = Material( "gui/gradient_up" )

hook.Add("HUDPaint", "Huddrawmeowware", function()
	if (LocalPlayerLandingPos && GetConVarNumber("meowware_visuals_landing_pos_master") == 1 && LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP) then
		local LocalPlayerLandingPosToScreen = LocalPlayerLandingPos:ToScreen()
		
		if (GetConVarNumber("meowware_visuals_landing_pos_2d_box") == 1) then
			local scale = GetConVarNumber("meowware_visuals_landing_pos_2d_box_size")
			
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_landing_pos_2d_box_r"),GetConVarNumber("meowware_visuals_landing_pos_2d_box_g"),GetConVarNumber("meowware_visuals_landing_pos_2d_box_b"),GetConVarNumber("meowware_visuals_landing_pos_2d_box_a")))
			surface.DrawOutlinedRect(LocalPlayerLandingPosToScreen.x-scale, LocalPlayerLandingPosToScreen.y-scale, scale+scale, scale+scale)
		end
		--if (different type of draw)
	end
	
	for _, v in pairs(player.GetAll()) do
		if v == LocalPlayer() then continue end
		
		if (GetConVarNumber("meowware_visuals_tracers") == 1 && v:Alive()) then
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_tracers_r"), GetConVarNumber("meowware_visuals_tracers_g"), GetConVarNumber("meowware_visuals_tracers_b"), GetConVarNumber("meowware_visuals_tracers_a")))
			local vPos = v:GetPos():ToScreen()
			local localPos = LocalPlayer():GetPos():ToScreen()
			
			surface.DrawLine(localPos.x, localPos.y, vPos.x, vPos.y)
			--render.DrawLine(LocalPlayer():GetPos() + Vector(0, 0, 10), v:GetPos() + Vector(0, 0, 10), Color(GetConVarNumber("meowware_visuals_tracers_r"), GetConVarNumber("meowware_visuals_tracers_g"), GetConVarNumber("meowware_visuals_tracers_b"), GetConVarNumber("meowware_visuals_tracers_a")))
		end
		
		if not OnScreen(v) then continue end
		
		local x1, y1, x2, y2 = ScrW() * 2, ScrH() * 2, - ScrW(), - ScrH()
		local min, max = v.GetCollisionBounds(v)
		local corners = {v:LocalToWorld(Vector(min.x, min.y, min.z)):ToScreen(), v:LocalToWorld(Vector(min.x, max.y, min.z)):ToScreen(), v:LocalToWorld(Vector(max.x, max.y, min.z)):ToScreen(), v:LocalToWorld(Vector(max.x, min.y, min.z)):ToScreen(), v:LocalToWorld(Vector(min.x, min.y, max.z)):ToScreen(), v:LocalToWorld(Vector(min.x, max.y, max.z)):ToScreen(), v:LocalToWorld(Vector(max.x, max.y, max.z)):ToScreen(), v:LocalToWorld(Vector(max.x, min.y, max.z)):ToScreen()}
			
		for k, v in next, corners do
			x1, y1 = math.min(x1, v.x), math.min(y1, v.y)
			x2, y2 = math.max(x2, v.x), math.max(y2, v.y)
		end
		
		local diff, diff2 = math.abs(x2 - x1), math.abs(y2 - y1)
		
		local health = v:Health()
		local maxHealth = v:GetMaxHealth()
		
		if (GetConVarNumber("meowware_visuals_name") == 1) then
			local pos = v:GetPos()
			local ang = LocalPlayer():EyeAngles()
			local pos2D = (pos + Vector(0, 0, 80)):ToScreen()
				
			-- Check if the player is within the screen bounds
			if pos2D.visible then
				local nick = v:Nick()
				local text = nick
				local font = "Default"
				
				surface.SetFont(font)
				local textWidth, textHeight = surface.GetTextSize(text)
				
				if (v:Alive()) then
					draw.SimpleTextOutlined(text, font, pos2D.x - textWidth / 2, pos2D.y - textHeight - 2, Color(GetConVarNumber("meowware_visuals_name_r"),GetConVarNumber("meowware_visuals_name_g"),GetConVarNumber("meowware_visuals_name_b"),GetConVarNumber("meowware_visuals_name_a")), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(GetConVarNumber("meowware_visuals_name2_r"),GetConVarNumber("meowware_visuals_name2_g"),GetConVarNumber("meowware_visuals_name2_b"),GetConVarNumber("meowware_visuals_name2_a")))
				else
					text = "*DEAD*"
					draw.SimpleTextOutlined(text, font, pos2D.x - textWidth / 2, pos2D.y - textHeight - 2, Color(255,10,10, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(20,20,20,100))
				end
			end
		end
		if (not v:Alive()) then continue end
		
		if (GetConVarNumber("meowware_visuals_2d_box") == 1) then
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_2d_box_r") ,GetConVarNumber("meowware_visuals_2d_box_g"),GetConVarNumber("meowware_visuals_2d_box_b"),GetConVarNumber("meowware_visuals_2d_box_a")))
			surface.DrawOutlinedRect(x1, y1, diff, diff2)
			
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_2d_box2_r") ,GetConVarNumber("meowware_visuals_2d_box2_g"),GetConVarNumber("meowware_visuals_2d_box2_b"),GetConVarNumber("meowware_visuals_2d_box2_a")))
			surface.DrawOutlinedRect(x1-1, y1-1, diff+2, diff2+2)
		end
		
		if (GetConVarNumber("meowware_visuals_gradient_box") == 1) then
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_gradient_box_r") ,GetConVarNumber("meowware_visuals_gradient_box_g"),GetConVarNumber("meowware_visuals_gradient_box_b"),GetConVarNumber("meowware_visuals_gradient_box_a")))
			surface.SetMaterial(meowware.gradient_down)
			surface.DrawTexturedRect(x1, y1, diff, diff2)
			
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_gradient_box2_r"), GetConVarNumber("meowware_visuals_gradient_box2_g"), GetConVarNumber("meowware_visuals_gradient_box2_b"), GetConVarNumber("meowware_visuals_gradient_box2_a")))
			surface.SetMaterial(meowware.gradient_up)
			surface.DrawTexturedRect(x1, y1, diff, diff2)
		end
		
		if (GetConVarNumber("meowware_visuals_gradient_2d_box") == 1) then
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_gradient_2d_box_r") ,GetConVarNumber("meowware_visuals_gradient_2d_box_g"),GetConVarNumber("meowware_visuals_gradient_2d_box_b"),GetConVarNumber("meowware_visuals_gradient_2d_box_a")))
			surface.SetMaterial(meowware.gradient_down)
			surface.DrawTexturedRect(x1, y1, 1, diff2)
			surface.DrawTexturedRect(x1+diff-1, y1, 1, diff2)
			surface.DrawRect(x1, y1, diff, 1)
			
			surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_gradient_2d_box2_r") ,GetConVarNumber("meowware_visuals_gradient_2d_box2_g"),GetConVarNumber("meowware_visuals_gradient_2d_box2_b"),GetConVarNumber("meowware_visuals_gradient_2d_box2_a")))
			surface.SetMaterial(meowware.gradient_up)
			surface.DrawTexturedRect(x1, y1, 1, diff2)
			surface.DrawTexturedRect(x1+diff-1, y1, 1, diff2)
			surface.DrawRect(x1, y1+diff2, diff, 1)
		end
		
		if (GetConVarNumber("meowware_visuals_healthbar") == 1) then
			if not ((diff*0.05) > 120) then 
				local scale = math.min((health/maxHealth), 1)
				
				surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_healthbar_r"),GetConVarNumber("meowware_visuals_healthbar_g"),GetConVarNumber("meowware_visuals_healthbar_b"), GetConVarNumber("meowware_visuals_healthbar_a")))
				surface.SetMaterial(meowware.gradient_up)
				surface.DrawTexturedRect(x1-(diff*0.05)-2, y1+(diff2-(diff2*scale)), (diff*0.05), diff2-(diff2-(diff2*scale)))
				
				if (GetConVarNumber("meowware_visuals_healthbar_outline") == 1) then
					surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_healthbar_outline_r") ,GetConVarNumber("meowware_visuals_healthbar_outline_g"),GetConVarNumber("meowware_visuals_healthbar_outline_b"),GetConVarNumber("meowware_visuals_healthbar_outline_a")))
					surface.DrawOutlinedRect(x1-(diff*0.05)-2, y1, (diff*0.05), diff2)
					
					surface.SetDrawColor(Color(GetConVarNumber("meowware_visuals_healthbar_outline2_r") ,GetConVarNumber("meowware_visuals_healthbar_outline2_g"),GetConVarNumber("meowware_visuals_healthbar_outline2_b"),GetConVarNumber("meowware_visuals_healthbar_outline2_a")))
					surface.DrawOutlinedRect(x1-(diff*0.05)-2-1, y1-1, (diff*0.05)+2, diff2+2)
				end
			end
		end
	
		if (GetConVarNumber("meowware_visuals_friend_status") == 1) then
			surface.SetTextPos(x1+diff+5, y1)
			if (v["PlayerList"] == 1) then
				surface.SetTextColor(Color(0,255,0,240))
				surface.DrawText("Friend")
			elseif (v["PlayerList"] == 2) then
				surface.SetTextColor(Color(255,0,0,240))
				surface.DrawText("Shit")
			end
		end
	end
	
	if (GetConVarNumber("meowware_visuals_holding_prop_text") == 1) then
		if (meowware.holdingProp && IsValid(meowware.Prop)) then
			local propPos = meowware.Prop:GetPos():ToScreen()
			local text = "*Holding Prop*"
			local textWidth, textHeight = surface.GetTextSize(text)
			
			draw.SimpleTextOutlined(text, "Default", propPos.x - textWidth / 2, propPos.y - textHeight - 2, Color(GetConVarNumber("meowware_visuals_holding_prop_text_r"),GetConVarNumber("meowware_visuals_holding_prop_text_g"),GetConVarNumber("meowware_visuals_holding_prop_text_b"),GetConVarNumber("meowware_visuals_holding_prop_text_a")), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(GetConVarNumber("meowware_visuals_holding_prop_text2_r"),GetConVarNumber("meowware_visuals_holding_prop_text2_g"),GetConVarNumber("meowware_visuals_holding_prop_text2_b"),GetConVarNumber("meowware_visuals_holding_prop_text2_a")))
		end
	end
	
	if (MeowwareMenuOpen) then
		if (GetConVarNumber("meowware_visuals_menu_fade") == 1) then
			surface.SetDrawColor(Color(0, 0, 0, GetConVarNumber("meowware_visuals_menu_fade_a")))
			surface.DrawRect(-1,-1, ScrW()+1, ScrH()+1)
		end
		
		if (GetConVarNumber("meowware_visuals_menu_bg_effect") == 1) then
			
		end
	end
	if (GetConVarNumber("meowware_visuals_watermark") == 1) then
		surface.SetFont( "WaterMarkFont" )
		local rainbowColor = HSVToColor((CurTime()*50)%360, 1, 1)
		
		local cheatname = "Meowware"
		local velocity = math.Round(LocalPlayer():GetVelocity():Length(), 0)
		local ping = LocalPlayer():Ping() .. "ms"
		local name = LocalPlayer():Nick()
		
		local gap = " "
		local text = cheatname .. gap .. velocity .. gap .. ping .. gap .. name
		local panelwidth = surface.GetTextSize(text) + 20
		
		surface.SetTextColor(250,250,250)
		
		surface.SetDrawColor(Color(20, 20, 20, 250))
		surface.DrawRect(5,5, panelwidth, 30)
		
		surface.SetDrawColor(rainbowColor)
		surface.DrawRect(5,5, panelwidth, 2)
		
		surface.SetTextPos(10,11)
		surface.DrawText(cheatname .. gap)
		
		surface.SetDrawColor(Color(70,70,70))
		local firstpos = 15 + surface.GetTextSize(cheatname)
		surface.DrawLine(firstpos,7, firstpos, 35)
		
		surface.SetTextPos(firstpos,11)
		surface.DrawText(gap .. velocity)
		
		firstpos = firstpos + surface.GetTextSize(velocity .. gap) + 4
		surface.DrawLine(firstpos,7, firstpos, 35)
		
		surface.SetTextPos(firstpos,11)
		surface.DrawText(gap .. ping)
		
		firstpos = firstpos + surface.GetTextSize(ping .. gap) + 4
		surface.DrawLine(firstpos,7, firstpos, 35)
		
		surface.SetTextPos(firstpos + 4,11)
		surface.DrawText(name)
		
	end
end)

hook.Add("DrawOverlay", "gfh4332542dfg2", function()
	DrawMeowwareMenu()
	DrawColorPicker()
end)

local stencleTexture = Material("skybox.png")
hook.Add("PostDraw2DSkyBox", "dfgd4334fff5d2", function()
	if (GetConVarNumber("meowware_visuals_skybox_stencil") == 1) then
	
	    render.SetStencilWriteMask(0xFF)
	    render.SetStencilTestMask(0xFF)
	    render.SetStencilReferenceValue(1)
	
	    render.SetStencilCompareFunction(STENCIL_ALWAYS)
	    render.SetStencilPassOperation(STENCIL_REPLACE)
	
	    render.SetStencilEnable(true)
	    render.ClearStencil()
	
	    render.SetMaterial(stencleTexture)
	    render.DrawScreenQuad()
	
	    render.SetStencilEnable(false)
    end
end)

local function CreateClientProp(modelPath)
    local prop = ClientsideModel(modelPath)
    
    if not IsValid(prop) then return end
    
    return prop
end

local a3DcricleProp = CreateClientProp("models/hunter/misc/sphere075x075.mdl")
a3DcricleProp:SetNoDraw(true)

local SkyboxPropModel = CreateClientProp("models/hunter/plates/plate32x32.mdl")
SkyboxPropModel:SetNoDraw(true)
SkyboxPropModel:SetPos(Vector(0,0,skyboxHeight))

hook.Add("PostDrawSkyBox", "asdsreg333333354354", function()
	--{"Draw skybox", "Checkbox", "meowware_visuals_draw_skybox", 0, 0, true, true},
	if (GetConVarNumber("meowware_visuals_draw_skybox") == 1 && (skyboxHeight - LocalPlayer():GetPos().z) < GetConVarNumber("meowware_visuals_draw_skybox_altitude")) then
		local localPlayerPos = LocalPlayer():GetPos()
		SkyboxPropModel:SetPos(Vector(localPlayerPos.x,localPlayerPos.y,skyboxHeight))
		
		render.MaterialOverride(meowware.debugwhite)
		SkyboxPropModel:SetRenderMode( RENDERMODE_TRANSALPHA )
		render.SetColorModulation(GetConVarNumber("meowware_visuals_draw_skybox_r")/255, GetConVarNumber("meowware_visuals_draw_skybox_g")/255, GetConVarNumber("meowware_visuals_draw_skybox_b")/255)
		render.SetBlend(GetConVarNumber("meowware_visuals_draw_skybox_a")/255)
		SkyboxPropModel:DrawModel()
		
		render.MaterialOverride(meowware.wireframe)
		SkyboxPropModel:SetRenderMode( RENDERMODE_TRANSALPHA )
		render.SetColorModulation(GetConVarNumber("meowware_visuals_draw_skybox2_r")/255, GetConVarNumber("meowware_visuals_draw_skybox2_g")/255, GetConVarNumber("meowware_visuals_draw_skybox2_b")/255)
		render.SetBlend(GetConVarNumber("meowware_visuals_draw_skybox2_a")/255)
		SkyboxPropModel:DrawModel()
		render.MaterialOverride(nil)
		
		if (GetConVarNumber("meowware_visuals_draw_skybox_orginal") == 1) then
			SkyboxPropModel:SetNoDraw(false)
		end
	else
		SkyboxPropModel:SetNoDraw(true)
	end		
end)

local function CHAMS()
	
	if (GetConVarNumber("meowware_visuals_landing_pos_3d_circle") == 1 && LocalPlayerLandingPos) then
		render.MaterialOverride(meowware.debugwhite)
		a3DcricleProp:SetPos(LocalPlayerLandingPos)
		a3DcricleProp:SetRenderMode( RENDERMODE_TRANSALPHA )
		render.SetColorModulation(GetConVarNumber("meowware_visuals_landing_pos_3d_circle_r")/255, GetConVarNumber("meowware_visuals_landing_pos_3d_circle_g")/255, GetConVarNumber("meowware_visuals_landing_pos_3d_circle_b")/255)
		render.SetBlend(GetConVarNumber("meowware_visuals_landing_pos_3d_circle_a")/255)
		a3DcricleProp:DrawModel()
		render.MaterialOverride(nil)
	end
	
	if (GetConVarNumber("meowware_visuals_landing_pos_3d_circle_wire") == 1 && LocalPlayerLandingPos) then
		render.MaterialOverride(meowware.wireframe)
		a3DcricleProp:SetPos(LocalPlayerLandingPos)
		a3DcricleProp:SetRenderMode( RENDERMODE_TRANSALPHA )
		render.SetColorModulation(GetConVarNumber("meowware_visuals_landing_pos_3d_circle_wire_r")/255, GetConVarNumber("meowware_visuals_landing_pos_3d_circle_wire_g")/255, GetConVarNumber("meowware_visuals_landing_pos_3d_circle_wire_b")/255)
		render.SetBlend(GetConVarNumber("meowware_visuals_landing_pos_3d_circle_wire_a")/255)
		a3DcricleProp:DrawModel()
		render.MaterialOverride(nil)
	end
	
	if (GetConVarNumber("meowware_visuals_chams") == 1) then
		for k,v in pairs(player.GetAll()) do
			cam.IgnoreZ (true)
				render.MaterialOverride(meowware.debugwhite)
				v:SetRenderMode( RENDERMODE_TRANSALPHA )
				render.SetColorModulation( GetConVarNumber("meowware_visuals_chams_r")/255, GetConVarNumber("meowware_visuals_chams_g")/255, GetConVarNumber("meowware_visuals_chams_b")/255)
				render.SetBlend(GetConVarNumber("meowware_visuals_chams_a")/255)
				v:DrawModel()
				render.MaterialOverride(nil)
			cam.IgnoreZ (false)
		end
	end
	
	if (GetConVarNumber("meowware_visuals_chams_overlay") == 1) then
		for k,v in pairs(player.GetAll()) do
			cam.IgnoreZ (true)
				render.MaterialOverride(meowware.wireframe)
				v:SetRenderMode( RENDERMODE_TRANSALPHA )
				render.SetColorModulation( GetConVarNumber("meowware_visuals_chams_overlay_r")/255, GetConVarNumber("meowware_visuals_chams_overlay_g")/255, GetConVarNumber("meowware_visuals_chams_overlay_b")/255)
				render.SetBlend(GetConVarNumber("meowware_visuals_chams_overlay_a")/255)
				v:DrawModel()
				render.MaterialOverride(nil)
			cam.IgnoreZ (false)
		end
	end
	
	if (GetConVarNumber("meowware_visuals_prop_chams") == 1) then
		for _, v in pairs(ents.FindByClass("prop_physics")) do
			cam.IgnoreZ (true)
				render.MaterialOverride(meowware.debugwhite)
				v:SetRenderMode( RENDERMODE_TRANSALPHA )
				render.SetColorModulation( GetConVarNumber("meowware_visuals_prop_chams_r")/255, GetConVarNumber("meowware_visuals_prop_chams_g")/255, GetConVarNumber("meowware_visuals_prop_chams_b")/255)
				render.SetBlend(GetConVarNumber("meowware_visuals_prop_chams_a")/255)
				v:DrawModel()
				render.MaterialOverride(nil)
			cam.IgnoreZ (false)
		end
	end
	if (GetConVarNumber("meowware_visuals_prop_chams_overlay") == 1) then
		for _, v in pairs(ents.FindByClass("prop_physics")) do
			cam.IgnoreZ (true)
				render.MaterialOverride(meowware.wireframe)
				v:SetRenderMode( RENDERMODE_TRANSALPHA )
				render.SetColorModulation( GetConVarNumber("meowware_visuals_prop_chams_overlay_r")/255, GetConVarNumber("meowware_visuals_prop_chams_overlay_g")/255, GetConVarNumber("meowware_visuals_prop_chams_overlay_b")/255)
				render.SetBlend(GetConVarNumber("meowware_visuals_prop_chams_overlay_a")/255)
				v:DrawModel()
				render.MaterialOverride(nil)
			cam.IgnoreZ (false)
		end
	end
end
hook.Add ("PreDrawEffects", "CHAMS", CHAMS)

meowware.holdingProp = false

hook.Add("PhysgunPickup", "fdggd3e3222425ff", function(v, ent)
    if IsValid(v) and IsValid(ent) and ent:IsValid() and ent:GetClass() == "prop_physics" then
    	meowware.holdingProp = true
    	meowware.Prop = ent
    end
end)

hook.Add("PhysgunDrop", "hjgg4r43444d", function(v, ent)
    if IsValid(v) and IsValid(ent) and ent:IsValid() and ent:GetClass() == "prop_physics" then
        meowware.holdingProp = false
    end
end)

hook.Add("CreateMove","fged32232ss22343453453dfd",function(cmd)
	if (GetConVarNumber("meowware_other_air_stuck") == 1) then
	    if (input.IsKeyDown(KEY_E) && load_module == true) then
	        big.SetOutSequenceNumber(big.GetOutSequenceNumber()+100)
	    end
    end
end)

local function IsEntityVisible(entity)

    if not IsValid(entity) && not LocalPlayer():Alive() then
        return false
    end

    -- Get the start position of the trace from the player's eye position.
    local startPos = LocalPlayer():EyePos()

    -- Get the end position of the trace from the center of the entity.
    local endPos = entity:LocalToWorld(entity:OBBCenter())

    -- Perform the trace.
    local trace = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = {LocalPlayer()} -- Ignore the player and the entity in the trace.
    })

    -- Check if the trace hit the entity or not.
    if trace.Entity == entity then
        -- The entity is visible, as there was no obstruction between the player and the entity.
        return true
    else
        -- The entity is not visible, as the trace hit something else or didn't hit anything.
        return false
    end
end

local function findTarget()
	local bestTargetDistance = math.huge
	local bestEnt
	local crosshairPos = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
	
	for k, v in ipairs(player.GetAll()) do
		if (v == LocalPlayer()) then continue end
		if (GetConVarNumber("meowware_aimbot_only_target_shitlist") == 1 && not v["PlayerList"] == 2) then continue end
		if (v["PlayerList"] == 1) then continue end
		if (not IsEntityVisible(v)) then continue end
		
		local vPos = v:EyePos():ToScreen()
		local distance = math.sqrt((crosshairPos.x - vPos.x) ^ 2 + (crosshairPos.y - vPos.y) ^ 2)
		
		if (distance < bestTargetDistance) then 
			bestTargetDistance = distance
			bestEnt = v
		end
	end
	return bestEnt
end

local nonShootableWeapons = {
	    "weapon_physgun",
	    "gmod_tool",
	    "weapon_physcannon",
	    "gmod_camera",
    }

local function isWeapon()
	local weapon = LocalPlayer():GetActiveWeapon()
	
	if not IsValid(weapon) or not weapon:IsWeapon() then
        return false
    end

    local weaponClass = weapon:GetClass()

    for _, nonShootableClass in ipairs(nonShootableWeapons) do
        if weaponClass == nonShootableClass then
            return false
        end
    end
    
    return true
end

local function aimbot()
	if (GetConVarNumber("meowware_aimbot_enabled") && isWeapon()) then
		--finish this pls thanks
	end
end

local jumped = 0

hook.Add("Tick", "100notAimbotIswear3335676", function()
	--LocalPlayerLandingPos = getLandingPos()

	if GetConVarNumber("meowware_other_bhop") == 1 then
		if (input.IsKeyDown(KEY_SPACE) && LocalPlayer():GetMoveType() != MOVETYPE_NOCLIP && not LocalPlayer():IsTyping()) then
			if LocalPlayer():IsOnGround() then
					RunConsoleCommand("+jump")
					jumped = 1
			else
					RunConsoleCommand("-jump")
					jumped = 0
			end
		end
	end
end)

local function RunOncePerSecond()
	if (GetConVarNumber("meowware_visuals_no_draw_ragdol") == 1) then
		for _, ent in ipairs(ents.GetAll()) do
			if ent:IsRagdoll() then
				local mats = ent:GetMaterials()
				for  _, mat in ipairs(mats) do
					ent:SetSubMaterial(_, "engine/occlusionproxy")
				end
			end
		end
	end
end
timer.Create("RunOncePerSecond_meowware", 1, 0, RunOncePerSecond)

local function unload()
	hook.Remove("CreateMove","fged32232ss22343453453dfd")
	hook.Remove("PhysgunDrop", "hjgg4r43444d")
	hook.Remove("PhysgunPickup", "fdggd3e3222425ff")
	hook.Remove("PreDrawEffects", "CHAMS")
	hook.Remove("PostDraw2DSkyBox", "dfgd4334fff5d2")
	hook.Remove("DrawOverlay", "gfh4332542dfg2")
	hook.Remove("HUDPaint", "Huddrawmeowware")
	hook.Remove("Think", "BHOP")
	hook.Remove("HUDShouldDraw", "HideCrosshair")
	hook.Remove("CalcView", "meowware_CalcView")
	hook.Remove("Tick", "100notAimbotIswear3335676")
	hook.Remove("PreDrawSkyBox", "asdsreg333333354354")
	timer.Destroy("RunOncePerSecond_meowware")
end

concommand.Add("meowware_unload", unload)