-- Hacked together quick hide thing because i personally couldnt find something like it
-- on the workshop LOL
-- Sorry if it SUCKS!! -IntellectualPotato

local QH_Hidden = QH_Hidden or setmetatable({}, { __mode = "k" }) -- i honestly have no meta table knowledge but apparantly this is good?

local Hide = function(ent, ply)
	if not IsValid(ent) or QH_Hidden[ent] then return end

	local frozen = {} -- Table, because ragdolls and such have multiple physics objects technically
	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local phys = ent:GetPhysicsObjectNum(i)
		if IsValid(phys) then
			frozen[i] = phys:IsMotionEnabled()
			phys:EnableMotion(false) -- These things have their collisions disabled, dont want them to FALL through the world!
		end
	end

	QH_Hidden[ent] = {motion = frozen, hider = ply}

	-- used to use setnodraw here but it caused a lot of issues for syncing
	ent:ForcePlayerDrop()
	ent:SetNotSolid(true)
	ent:SetNW2Bool("QH", true)
end

local Unhide = function(ent)
	if not IsValid(ent) or not QH_Hidden[ent] then return end

	local data = QH_Hidden[ent]
	QH_Hidden[ent] = nil

	ent:SetNotSolid(false)
	ent:SetNW2Bool("QH", false) --kinda hoping these dont save (dupe/save) im lazy to check

	for i, motion in pairs(data.motion) do
		local phys = ent:GetPhysicsObjectNum(i)
		if motion and IsValid(phys) then phys:EnableMotion(true) end
	end
end

local QH_PropAction = function(self, ent)
	self:MsgStart()
	net.WriteEntity(ent)
	self:MsgEnd()
end

-- Context menu buttons!! wowie!!
properties.Add("quickhide_hide", {
	MenuLabel = "Hide",
	Order = 1600,
	MenuIcon = "icon16/eye.png",

	Filter = function(self, ent)
		return IsValid(ent) and not ent:IsPlayer() and not ent:IsWorld() and not ent:GetNW2Bool("QH")
	end,

	Action = QH_PropAction,

	Receive = function(self, length, ply)
		local ent = net.ReadEntity()
		if self:Filter(ent) then Hide(ent, ply) end
	end
})

properties.Add("quickhide_unhide", {
	MenuLabel = "Unhide",
	Order = 1600,
	MenuIcon = "icon16/eye.png",

	Filter = function(self, ent)
		return IsValid(ent) and ent:GetNW2Bool("QH")
	end,

	Action = QH_PropAction,

	Receive = function(self)
		local ent = net.ReadEntity()
		if self:Filter(ent) then Unhide(ent) end
	end
})

local DoHide = function(ply)
	local ent = IsValid(ply) and ply:GetEyeTrace().Entity or NULL
	if not (IsValid(ent) and not ent:IsPlayer() and not ent:IsWorld() and not ent:GetNW2Bool("QH")) then return end
	Hide(ent, ply)
end

local DoUnhide = function(ply)
	for ent, data in pairs(QH_Hidden) do
		if not IsValid(ply) or data.hider == ply then Unhide(ent) end
	end
end

local DoUnhideGlobal = function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end
	for ent in pairs(QH_Hidden) do Unhide(ent) end
end

local QH_Actions = { DoHide, DoUnhide, DoUnhideGlobal }

if SERVER then
	util.AddNetworkString("QH_Request")
	net.Receive("QH_Request", function(_, ply)
		local fn = QH_Actions[net.ReadUInt(2) + 1]
		if fn then fn(ply) end
	end)
	hook.Add("CanPlayerUnfreeze", "QuickHide", function(ply, ent) if QH_Hidden[ent] then return false end end)
end

local AddQHCommand = function(name, action)
	concommand.Add(name, function(ply)
		if CLIENT then
			net.Start("QH_Request")
			net.WriteUInt(action, 2)
			net.SendToServer()
			return
		end
		QH_Actions[action + 1](ply)
	end)
end

AddQHCommand("qh_hide", 0)
AddQHCommand("qh_unhide", 1)
AddQHCommand("qh_unhide_global", 2)

if CLIENT then
	local open = false
	local mat = Material("effects/freeze_unfreeze") -- This one renders through walls and stuff which works for this

	local qh_dotsize = CreateClientConVar("qh_dotsize", "0.025", true, false, "Size of the QuickHide targeting dots (also scales click radius)", 0.01, 1)
	local SIZE = qh_dotsize:GetFloat() -- Size is constant on-screen size, rather than changing at distances

	local SELECTION_RADIUS = SIZE * 960
	-- Number taken from:
	-- https://github.com/Facepunch/garrysmod/blob/52ad10f3bca95a9230384da29516faae5cd85433/garrysmod/lua/includes/modules/properties.lua#L158
	local RANGE = 1024 -- max distance prop dot can be targeted or drawn from

	cvars.AddChangeCallback("qh_dotsize", function()
		SIZE = qh_dotsize:GetFloat()
		SELECTION_RADIUS = SIZE * 960
	end, "QuickHide_DotSize")

	local qh_transparency = CreateClientConVar("qh_transparency", "0.3", true, false, "Transparency of hidden props (0 = invisible, 1 = solid)", 0, 1)
	local TRANSPARENCY = qh_transparency:GetFloat()

	cvars.AddChangeCallback("qh_transparency", function()
		TRANSPARENCY = qh_transparency:GetFloat()
	end, "QuickHide_Transparency")

	local qh_alwaysvisible = CreateClientConVar("qh_alwaysvisible", "0", true, false, "Always draw hidden props instead of only when context-menu is open")
	local ALWAYS_VISIBLE = qh_alwaysvisible:GetBool()

	cvars.AddChangeCallback("qh_alwaysvisible", function()
		ALWAYS_VISIBLE = qh_alwaysvisible:GetBool()
	end, "QuickHide_AlwaysVisible")

	-- Grab any that might already exist during initialization
	for _, ent in ents.Iterator() do
		if ent:GetNW2Bool("QH") then
			QH_Hidden[ent] = true
		end
	end

	-- do the nodraw setting on the CLIENT now!
	hook.Add("EntityNetworkedVarChanged", "QuickHide", function(ent, name, _, new)
		if name == "QH" and IsValid(ent) then
			ent:SetNoDraw(new)
			QH_Hidden[ent] = new or nil
		end
	end)

	-- Catch entities re-entering PVS
	-- I only just now found out this hook exists after previously making it do it every frame 🥺
	hook.Add("NotifyShouldTransmit", "QuickHide", function(ent, shouldTransmit)
		if shouldTransmit and ent:GetNW2Bool("QH") then
			ent:SetNoDraw(true)
			QH_Hidden[ent] = true
		end
	end)

	-- Had this on workshop page before i just did this to fix it:
	-- May behave weirdly with welded objects or such if they arent frozen themself, 
	-- havent figured out why, objects just become fully opaque instead of not drawing basically, 
	-- exiting and re-entering PVS usually makes it re-set to proper state

	-- This is now fixed just by forcing it every frame basically LOL
	-- Not too expensive i hope, because its only doing it on hidden objects
	hook.Add("PreRender", "QuickHide_EnforceNoDraw", function() 
		for ent in pairs(QH_Hidden) do
			if IsValid(ent) and not ent:GetNoDraw() then
				ent:SetNoDraw(true)
			end
		end
	end)

	hook.Add("OnContextMenuOpen", "QuickHide", function()
		open = true
	end)

	hook.Add("OnContextMenuClose", "QuickHide", function()
		open = false
	end)

	-- Finds the closest hidden prop near the mouse cursor
	local function GetMarker(pos)
		local mx, my = gui.MousePos()
		local best, bestDist, bestPos

		for ent in pairs(QH_Hidden) do
			if not IsValid(ent) then continue end

			local center = ent:WorldSpaceCenter()
			local dist = pos:Distance(center)

			if dist < RANGE then
				local scr = center:ToScreen()

				-- Check if within selection radius of mouse + is the closest prop
				if math.Distance(scr.x, scr.y, mx, my) < SELECTION_RADIUS and (not bestDist or dist < bestDist) then
					best, bestDist, bestPos = ent, dist, center
				end
			end
		end

		return best, bestPos
	end

	local color_not_hovered = Color(255, 170, 60)
	hook.Add("PostDrawTranslucentRenderables", "QuickHide", function(depth, sky)
		if depth or sky then return end
		-- props are only drawn here when the context menu is open, unless always-visible is on
		if not open and not ALWAYS_VISIBLE then return end

		local eye, hovered
		if open then
			eye = EyePos()
			hovered = GetMarker(eye)
		end

		for ent in pairs(QH_Hidden) do
			if IsValid(ent) then

				ent:SetNoDraw(true)

				-- Makes the transparency of the QH_Hidden objects render prettier
				-- Taken from example on: https://wiki.facepunch.com/gmod/render.SetBlend <3
				render.OverrideColorWriteEnable(true, false)
				ent:DrawModel()
				render.OverrideColorWriteEnable(false, false)

				render.SetBlend(TRANSPARENCY)
				ent:DrawModel()
				render.SetBlend(1)

				-- clickable dot for unhiding
				if open then
					local c = ent:WorldSpaceCenter()
					local dist = eye:Distance(c)

					if dist < RANGE then
						local size = dist * SIZE * (ent == hovered and 1.5 or 1)

						render.SetMaterial(mat)
						render.DrawSprite(c, size, size, ent == hovered and color_white or color_not_hovered)
					end
				end
			end
		end
	end)

	-- Only the dots are targetable, the ghost itself is ignored so you can click through it, helps with posing etc
	-- Hopefully doesnt break something else hijacking it this way LOL
	local GetHovered = properties.GetHovered -- Original function before hijacking

	function properties.GetHovered(pos, dir) -- Overide function to call itself + our own logic
		if open then
			local ent, hit = GetMarker(pos)

			if ent then
				return ent, {
					Entity = ent,
					HitPos = hit,
					Hit = true,
					HitNonWorld = true
				}
			end
		end

		return GetHovered(pos, dir) -- If dot wasnt hovered over, just be normal
	end
end