if not SERVER then return end

CreateConVar("catplanet_max_cats", "100", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("catplanet_spawn_delay", "40", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("catplanet_random_spawn", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

local function GetMaxCats() return GetConVar("catplanet_max_cats"):GetInt() end
local function GetSpawnDelay() return GetConVar("catplanet_spawn_delay"):GetFloat() end
local function ShouldRandomSpawn() return GetConVar("catplanet_random_spawn"):GetBool() end

CAT_CONTEXTUAL_TEXT = {
    NICKNAMES = { -- Should probably add more but this is lazy time consuming thingy
        func_door = "door", func_door_rotating = "spinny door", prop_door_rotating = "door",
        func_button = "button", npc_citizen = "person", item_healthkit = "life juice",
        item_battery = "blue juice", npc_turret_floor = "shooty thing", npc_zombie = "stinky man",
        npc_pigeon = "birb", npc_crow = "crow", npc_vortigaunt = "radical zappy alien"
    },
    PHRASES = {
        "wow, a %s!", "this %s is radical!", "i found a %s!", "what does this %s do?",
        "cat planet %s!", "look at this %s!", "%s %s %s!!", "i like this %s!",
        "this %s is mine!", "is this %s edible?", "me and my %s!", "nice %s you got here!",
        "want to buy this %s?!", "unbelievable %s!!", "sweet, sweet %s!"
    },
    GetContextualText = function(pos)
        local target, minDist = nil, 100 * 100
        for _, ent in ipairs(ents.FindInSphere(pos, 100)) do
            if not IsValid(ent) then continue end
            local class = ent:GetClass()
            if CAT_CONTEXTUAL_TEXT.NICKNAMES[class] or class:find("prop_physics") then
                local dist = pos:DistToSqr(ent:GetPos())
                if dist < minDist then
                    minDist, target = dist, ent
                end
            end
        end

        if IsValid(target) then
            local name = CAT_CONTEXTUAL_TEXT.NICKNAMES[target:GetClass()]
            if not name then
                local model = target:GetModel()
                if model and model ~= "" then
                    name = string.gsub(string.StripExtension(string.GetFileFromFilename(model)), "[%d_]", " ")
                    name = string.Trim(name)
                else
                    name = "thing"
                end
            end

            local str = CAT_CONTEXTUAL_TEXT.PHRASES[math.random(#CAT_CONTEXTUAL_TEXT.PHRASES)]
            if str:find("%%s") then
                local _, count = string.gsub(str, "%%s", "")
                local args = {}
                for i = 1, count do table.insert(args, name) end
                return string.format(str, unpack(args))
            end
            return str
        end

        if bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER then
            return table.Random({"glub glub!", "i'm a catfish!", "wet feet!", "so refreshing!"})
        end
    end
}

local CAT_CLASS = "cat_planet_cat_planet_hellyeah"

local function GetWeightedRandomNavPos() -- i have no idea if this works better or not tbh
    if not navmesh.IsLoaded() then return end
    local areas = navmesh.GetAllNavAreas()
    local totalArea = 0
    for _, a in ipairs(areas) do totalArea = totalArea + a:GetSizeX() * a:GetSizeY() end

    local weight = math.random() * totalArea
    for _, a in ipairs(areas) do
        weight = weight - (a:GetSizeX() * a:GetSizeY())
        if weight <= 0 then return a:GetRandomPoint() end
    end
end

local function GetCatTextForPosition(pos, isStrange)
    if isStrange then return nil end
    return CAT_CONTEXTUAL_TEXT.GetContextualText(pos)
end

local function SpawnCatPlanet(count)
    for i = 1, (count or 1) do
        if #ents.FindByClass(CAT_CLASS) >= GetMaxCats() then break end
        local pos = GetWeightedRandomNavPos()
        if not pos then continue end

        local cat = ents.Create(CAT_CLASS)
        if IsValid(cat) then
            cat:SetPos(pos + Vector(0, 0, 15))
            cat:Spawn()
            if cat:GetIsStrange() then continue end
            local txt = GetCatTextForPosition(pos, cat:GetIsStrange())
            if txt then cat:SetCatText(txt) end
        end
    end
end

local function UpdateSpawnTimer()
    if ShouldRandomSpawn() then
        timer.Create("CatPlanetSpawnerTimer", GetSpawnDelay(), 0, function() SpawnCatPlanet(math.random(2, 5)) end)
    else
        timer.Remove("CatPlanetSpawnerTimer")
    end
end

cvars.AddChangeCallback("catplanet_random_spawn", UpdateSpawnTimer, "catplanet")
cvars.AddChangeCallback("catplanet_spawn_delay", function() if ShouldRandomSpawn() then timer.Adjust("CatPlanetSpawnerTimer", GetSpawnDelay(), 0, nil) end end, "catplanet")

UpdateSpawnTimer()
hook.Add("PostCleanupMap", "SpawnCatPlanetsHellYeah", function() if ShouldRandomSpawn() then SpawnCatPlanet(5) end end)
