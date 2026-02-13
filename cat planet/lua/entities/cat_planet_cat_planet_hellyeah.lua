AddCSLuaFile()

ENT.Type        = "anim"
ENT.Base        = "base_anim"
ENT.PrintName   = "Cat Planet"
ENT.Category    = "Fun + Games"
ENT.Author      = "IntellectualPotato"
ENT.Spawnable   = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Editable = true

local SPRITE_SIZE, SPHERE_RADIUS, SCALE = 32, 16, 1
local FADE_START, FADE_END = 400, 250
local CV_SUPER = CreateConVar("catplanet_super", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Use super cat planet", 0, 1)
local CV_TEXT  = CreateConVar("catplanet_super_text", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Use outline text (may be more expensive)", 0, 1)

local function NewAnim(path, frames, w, h, contentW, inv)
    return {
        material = Material(path, "alphatest"), frames = frames,
        texW = w, texH = h, contentW = contentW or w, contentH = h, invertflip = inv
    }
end

local ANIMS = {
    idle_super = NewAnim("catplanet/super_cat_planet_hellyeah.png", 4, 64, 16),
    idle_normal = NewAnim("catplanet/cat_planet_hellyeah.png", 4, 64, 16),
    idle_strange = NewAnim("catplanet/cat_planet_strange_lookin_cat.png", 4, 64, 16, 64, true),
    dance = NewAnim("catplanet/dance_dance_party_planet.png", 12, 192, 16),
    dance_strange = NewAnim("catplanet/Dance_The_Strange_Away.png", 12, 256, 16, 216)
}

local CAT_TEXTS = {
    "hit a switch! cool!", "aaah!", "yahoo!", "hot! hot!", "oh yeah!", "welcome to cat planet!",
    "warning: dangerous machines ahead!", "warning: switch room ahead!", "scary!", "up there is a thing!",
    "lavalavalava!", "me too!", "oh! what a factory!", "hey hey!", "floating!", "what does this factory make?#nobody knows!",
    "wow, hot lava cave!", "cat planet!", "explore cat planet!", "factory!!", "factory!", "factory!!!",
    "factory!!!!", "factory!!!!!", "watch your step!", "cat planet?", "!!!!", "this is my house!",
    "cat planet#cat planet#cat planet!!!", "so cool!", "so many paths!", "lava caves down below!",
    "be careful!", "way radical!", "you're in cat village!", "cat village is great!", "jungles can be dangerous!",
    "hey there!", "planet", "cat", "dude. dude!", "lots to do on cat planet!", "have fun!",
    "here is underground jungle!", "good job!", "see ya later!", "this way to more cat planet!",
    "j-j-jungle!", "what a crazy jungle!", "this is our jungle clubhouse!", "groove out!",
    "such an exciting jungle!", "solve the mystery of the gate!", "go! go!", "never give up!",
    "thorns hurt!", "keep it up!", "i'm hiding!", "do you have 61 cats?#getting back will be tough!",
    "beware of crows!", "everybody cat planet!", "it's a jungle out there!", "whoa!", "funkatronic!",
    "jungle here, jungle there, jungle everywhere!",
    "cat planet#cat planet cat planet#cat planet cat planet cat planet#cat planet cat planet cat planet cat planet#cat planet cat planet cat planet cat planet cat planet#cat planet cat planet cat planet cat planet cat planet cat planet#cat planet cat planet cat planet cat planet cat planet cat planet cat planet",

    --Custom:
    "colonize new cat planet!",
    "climb! climb!",
    "hell yeah!",
    "i feel so stellarific!!",
    "is this the meaning of life?!!",
    "find my cats!",
    "i am my own favorite instrument!",
    "better than dog planet!",
    "hashtag relatable!",
    "woah! woah! woah! woah! ",
    "i'm with cat planet!#---->",
    "join the clubhouse!!#<----",
    "beware of the scary basement!",
    ":3!",
    "how did i get here?!!",
    "thats not very cat planet of you!",
    "press 'unbound' to bake a yummy cake!",
    "I'm not what i appear to be.",
    "do cats come from eggs?",

    --Super cat planet:
    "checkpoint!","checkpointed!","check this point out!","alright, checkpoint!","sweet checkpoint!",
    "thanks for#the checkpoint!","i'm a checkpoint now!","checkpoint flaaaag!","checkpoint reached!",
    "everybody checkpoint!","checkpointinator!","flag! flag!#checkpoint flag!","bye now!","hello there!",
    "welcome back to cat planet!","lots of new stuff!","alright!","secret!","welcome to my house!","i'm here too!",
    "you're in new cat village!","rad!","cat to the planet!","multiple paths!#to the left is the jungle!#i forget what's to the right!",
    "we dug deeper since last time!","whee!","super cool hangout!","yeah yeah!","g!","Jungles can be confusing!","whoa!",
    "Jungels can bee canfuzling!","thorns hurt!","funkatronic!","cat planet!","this is my hidey hole!",
    "i forget the rest of the lyrics!","careful!","these plants taste good!","secret clubhouse!","cozy!","so cool!",
    "i'm lost!","yeah, jungles!","watch your step!","welcome to the jungle!","so many thorns!","jeez!","lava caves down below!",
    "juuuungle!","wow!","still a jungle!","don't get lost in this maze!","you made it!","dude. dude!","echo!","this canyon is huge!",
    "hold \"up\" to jump really high!","canyon!","i'm staying cool in here!","i'm staying hot out here!","way up!","look out!",
    "danger to the right!","that was close!","orange button!","press it!","aaaaaaaah!","hold \"down\" to jump really low!",
    "i've just added an extra turnip#to the eigth dimension's cell turbines!","sky sand!","wooo!","pat clanet!",
    "where there's danger, there's treasure!","great view!","ppthpththphhpth!","floating!","party!","island!","meow!",
    "everything smells so good!","super chill!","super cozy-like!","cool tree!","petals petals petals petals#petals petals!!",
    "shooty plants!","eek!","good job!","this next screen's tough!","mmmm!","stomp that button!","wooooo!","relaxing!",
    "yup!","we're up here!","we're like guards except not!","welcome to flowers!","crazy red blocks!",
    "it's really windy in here!","whoosh!","ice caaaaves!","swirling!","             it's too cold to fish here!",
    "such a cool breeze!","boing!",";w;!","great!","I don't even have hands!","you don't need to swim in waterfalls!",
    "i'm a cat!","way deep!","whirling!","brrr!","wind isn't always friendly!","believe in yourself!","well this is weird!",
    "shouldn't be too hard!","whiiiiite button!","you did it!","flippity#floppy!","some kinda#double jump!",
    "f!","a!","c!","t!","o!","r!","y!","welcome backtory to the factory!","don't forget about highjumps and lowjumps!",
    "factories are dangerous!","so complex!","still floating!","switches aren't dangerous!","out of order!","things everywhere!",
    "new blue switch!!","!!!!!!!","red! blue! red! blue!","crossroads!","oh boy, here we go!","pistons are safe when they aren't moving!",
    "this isn't even a factory anymore!#we just put these pistons everywhere!",
    "01100011 01100001 01110100#00100000 01110000 01101100#01100001 01101110 01100101#01110100 00100001",
    "factories#are cool!","they're okay#i guess!","So many ribbons!","Demo!!!","you're getting warmer!",
    "tricky timing!","yow!","alright, leftwards yellow button!","push it push it push it push it!","all the lava!",
    "convection schmonvection!","i'm pretty sure#these are lava bubbles!","no lava here!","spinning!",
    "solve the mystery of the...#...wait there's no gate here! nevermind!","welcome to tiny lava hotel!",
    "fdsafdf!!!","this is a terrible clock!","oh man!","right-side yellow button!","such wonders!",
    "cat#planet#cat#planet#cat#planet#cat#planet#cat#planet#cat#planet#cat#planet#cat#planet#cat#planet#cat#planet#cat#planet#cat#planet",
    "It's scary down here!","watch out for crows!","pretty tricky!","never give up!","just cheese it!","man!","you're almost there!",
    "i believe in you!","you did it!#great job!","you're#doing#great!","crazy dark!","pretty spooky!","last one!",
    "i know you can do it!","good luck, buddy!","p!","l!","n!","e!"
}

local CAT_TEXTS_STRANGE = {
    "oh...hello. what are you doing all the way out here?#Don't mind me, I'm fine.",
    "you seem to be lost. same here.#but i do enjoy the solitude sometimes.",
        "Clever one, aren't you?","what's over here?","hey there.",
        "They'll want to know.","Oh, hi.#Just enjoying the view.",
        "Tell the moth about this.","Oh, hey.#This lake is so flooded with petals it looks pink.",
        "Hey there.#These plants aren't too bad once you get used to them.","Hello.",
        "You shouldn't be here.","it's all gone.","Don't leave us...",
        "Hello.#I just need some privacy, sorry.",
        "Oh, hello.#Strange cats like me aren't very sociable.#I appreciate you visiting, though.",
        "You're persistent, aren't you?#Well, here's something useful.#There's clothes hidden in#Jungle, Flowers, Factory, Mushrooms, here, and...#...another place I don't want to mention.",
        "Don't lose hope.##There's a way.","Hey, uh...#why did they add those red/blue switches?#it just complicates things.",
        "Time passes.","Free-flowing hair, nice and simple. Love it.","Cute little cat ears you got.","Those ears are really fluffy. Adorable.",
        "Nice halo. Fitting for you,#being an angel and all.","Infinite ammo, huh?",
        "Ooh, pretty necklace.#Gotta have that bling blang.","Too cool, dude. too cool.","You're a squid now?",
        "That sleeping cap's my favorite.","That mask makes you look like some kind of lab experiment.",
        "Nice scarf. Dunno why you're wearing it here, though.","That hat looks familiar...",
        "Man, that bow is huge.#So bouncy, too.","Wow, good job finding that.#If you complete that outfit then you'd look just like a certain idiot...",
        "Now that's creepy.","I'll admit, you don't really pull off the ''Creepy'' look very well.",
        "Whoa, one eye? Haven't seen that before.","It's not over yet.",
        "Wow, hi.#Didn't expect anyone to find me here.#Well...good job.#There aren't any more hiding spots#in this area, by the way.#Saving you the trouble.",
        "Not much longer now.",

        --Custom:
        "How many places do you think you've explored in this engine?#I don't know how many i've been to myself.",
        "Some seem to imagine dark silthouette's#I don't believe in fairy tales.",
        "Shouldn't you be grateful?#For your gift, that is.",
        "Can you do something about your friend...?#Yes, your friend... The one behind you, with the creepy smile.", -- Yes i yoinked this, sue me!!
        "How does it feel to be able to change your skin at any time?#Is it painful?",
        "There are so many varieties of places, Do you have a favorite?",
        "Oh, me?#I'm just, you know...#Existing, as we all do.",
        "Share your secret."
}

function ENT:UpdateAnims(useSuper)
    local strange = self:GetIsStrange()
    if strange then
        self.idleAnim, self.danceAnim, self.sfx = ANIMS.idle_strange, ANIMS.dance_strange, "catplanet/fxStrangeMeow.wav"
    else
        self.idleAnim = useSuper and ANIMS.idle_super or ANIMS.idle_normal
        self.danceAnim, self.sfx = ANIMS.dance, "catplanet/fxMeow.wav"
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "CatText", { KeyName = "Cat text", Edit = { type = "Generic", order = 1}})
    self:NetworkVar("Bool", 0, "IsSpinning", { KeyName = "Active (Spinning)", Edit = { type = "Boolean", order = 2}})
    self:NetworkVar("Bool", 1, "IsStrange")
    self:NetworkVar("Float", 0, "DanceStartTime")
    if SERVER then
        self:SetIsStrange(math.random(1,100) == 1)
        self:SetDanceStartTime(-1)
        self:UpdateAnims(CV_SUPER:GetBool())
    end
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/hunter/misc/sphere025x025.mdl")
        self:SetUseType(SIMPLE_USE)
        self:PhysicsInitSphere(SPHERE_RADIUS, "metal_bouncy")

        timer.Simple(0, function() self:SetPos(self:GetPos() + Vector(0, 0, SPHERE_RADIUS / 2 )) end )

        self:PhysWake()

        self:UpdateAnims(CV_SUPER:GetBool())
    end

    function ENT:SetCatTextOnce()
        if self:GetCatText() ~= "" then return end

        local txt
        local isStrange = self:GetIsStrange()

        if not isStrange and CAT_CONTEXTUAL_TEXT then
            txt = CAT_CONTEXTUAL_TEXT.GetContextualText(self:GetPos())
        end

        if not txt or txt == "" then
            local targetTable = isStrange and CAT_TEXTS_STRANGE or CAT_TEXTS
            if targetTable and #targetTable > 0 then
                txt = table.Random(targetTable)
            else
                txt = "cat planet!"
            end
        end

        self:SetCatText(txt)
    end

    function ENT:TriggerDance()
        if self:GetIsSpinning() then return end
        self:SetIsSpinning(true)
        self:SetDanceStartTime(CurTime())
        self:SetCatTextOnce()
    end

    function ENT:PhysicsCollide(data, phys)
        local speed = data.OurOldVelocity:Length()

        if speed > 100 and self.sfx then
            self:EmitSound(self.sfx)
        end

        if speed > 200 then
            self:TriggerDance()
        end

        local vel = phys:GetVelocity()
        vel.x = math.abs(vel.x) >= 30 and vel.x / 1.5 or vel.x
        vel.y = math.abs(vel.y) >= 30 and vel.y / 1.5 or vel.y
        vel.z = math.abs(vel.z) <= 300 and vel.z / 1.2 or vel.z
        phys:SetVelocity(vel)
    end

    function ENT:Use(activator, caller)
        if self.sfx then self:EmitSound(self.sfx) end
        self:TriggerDance()
    end
end

if CLIENT then
    surface.CreateFont("CatPlanetFont", { font = "MS PGothic", size = 14, weight = 400, antialias = false }) --Same font used in cat planet!

    local function DrawCatText(text, alpha, outline)
        surface.SetFont("CatPlanetFont")
        local shadowCol = Color(0, 0, 0, alpha)
        local mainCol = Color(255, 255, 255, alpha)
        local lines = string.Explode("#", text)

        for i, line in ipairs(lines) do
            local w = surface.GetTextSize(line)
            local x, y = -w / 2, -SPRITE_SIZE / 2 - 25 - (16 * (#lines - i))

            if outline then
                for dx = -1, 1 do for dy = -1, 1 do
                    if dx ~= 0 or dy ~= 0 then draw.SimpleText(line, "CatPlanetFont", x + dx, y + dy, shadowCol) end
                end end
            else
                draw.SimpleText(line, "CatPlanetFont", x + 1, y + 1, shadowCol)
            end
            draw.SimpleText(line, "CatPlanetFont", x, y, mainCol)
        end
    end

    function ENT:Draw()
        local pos, camPos = self:GetPos(), EyePos()
        if not self.idleAnim or not self.danceAnim then self:UpdateAnims(CV_SUPER:GetBool()) end

        local isSpinning = self:GetIsSpinning()
        local anim = isSpinning and self.danceAnim or self.idleAnim

        local frame = 0
        if isSpinning then
            local startTime = self:GetDanceStartTime()
            frame = (startTime and startTime > 0) and math.floor((CurTime() - startTime) / 0.1) % anim.frames or 0
        else
            frame = math.floor((CurTime() - (self:EntIndex() * 1.7)) / 0.1) % anim.frames
        end

        local flipUV = (pos - camPos):GetNormalized():Dot(EyeAngles():Right()) < 0
        if anim.invertflip then flipUV = not flipUV end

        local u_ratio = anim.contentW / anim.texW
        local u0, u1 = (frame / anim.frames) * u_ratio, ((frame + 1) / anim.frames) * u_ratio
        if flipUV and not isSpinning then u0, u1 = u1, u0 end

        local du, dv = 0.5 / anim.texW, 0.5 / anim.texH
        u0, u1 = (u0 - du) / (1 - 2 * du), (u1 - du) / (1 - 2 * du)
        local v0, v1 = (0 - dv) / (1 - 2 * dv), ((anim.contentH / anim.texH) - dv) / (1 - 2 * dv)

        local ang = (camPos - pos):Angle()
        ang:RotateAroundAxis(ang:Right(), -90); ang:RotateAroundAxis(ang:Up(), 90)
        local drawAng = Angle(0, math.NormalizeAngle(ang.y), 90)

        local dist, text = camPos:Distance(pos), self:GetCatText()
        local hasText = text ~= "" and isSpinning

        if hasText and dist < FADE_START then
            local alpha = dist > FADE_END and 255 * (1 - (dist - FADE_END) / (FADE_START - FADE_END)) or 255

            if alpha > 0 then
                cam.IgnoreZ(true)
                cam.Start3D2D(pos, drawAng, SCALE)
                    render.PushFilterMag(TEXFILTER.POINT); render.PushFilterMin(TEXFILTER.POINT)
                        DrawCatText(text, alpha, CV_TEXT:GetBool())
                    render.PopFilterMin(); render.PopFilterMag()
                cam.End3D2D()
                cam.IgnoreZ(false)
            end
        end

        cam.Start3D2D(pos, drawAng, SCALE)
            render.PushFilterMag(TEXFILTER.POINT); render.PushFilterMin(TEXFILTER.POINT)
                surface.SetMaterial(anim.material); surface.SetDrawColor(255, 255, 255)
                surface.DrawTexturedRectUV(-SPRITE_SIZE / 2, -SPRITE_SIZE / 2, SPRITE_SIZE, SPRITE_SIZE, u0, v0, u1, v1)
                if hasText then
                    DrawCatText(text, 255, CV_TEXT:GetBool())
                end

            render.PopFilterMin(); render.PopFilterMag()
        cam.End3D2D()
    end
end