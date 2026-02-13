AddCSLuaFile()

ENT.Type, ENT.Base = "anim", "cat_planet_cat_planet_hellyeah"
ENT.PrintName, ENT.Category = "Cat Planet (EVIL!)", "Fun + Games"
ENT.Author, ENT.Spawnable = "IntellectualPotato", true

-- max range that these CREATURES will absolutely ASSAULT us! (i choose to believe they mean well)
local CV_MAX_RANGE = CreateConVar("catplanet_aggressive_max_range", "2000", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Maximum range for aggressive cat planet to detect and attack targets", 500, 5000)

if SERVER then
    function ENT:Initialize()
        self.BaseClass.Initialize(self)
        timer.Create("cat_jump_" .. self:EntIndex(), 1.5, 0, function()
            if IsValid(self) and not GetConVar("ai_disabled"):GetBool() then self:JumpAtTarget() end
        end)
    end

    function ENT:GetNearestTarget()
        local nearest, nearestDist = nil, math.huge
        local targets = ents.GetAll()
        local maxRange = CV_MAX_RANGE:GetFloat()
        local maxRangeSqr = maxRange * maxRange

        for _, ent in ipairs(targets) do
            local isPlayer = ent:IsPlayer() and ent:Alive() and not GetConVar("ai_ignoreplayers"):GetBool()
            local isNPC = ent:IsNPC() and ent:Health() > 0

            if isPlayer or isNPC then
                local dist = self:GetPos():DistToSqr(ent:GetPos())
                if dist < nearestDist and dist <= maxRangeSqr then
                    nearestDist, nearest = dist, ent
                end
            end
        end
        return nearest
    end

    function ENT:JumpAtTarget()
        local target = self:GetNearestTarget()
        local phys = self:GetPhysicsObject()
        if not IsValid(target) or not IsValid(phys) then return end

        local dist = self:GetPos():Distance(target:GetPos())
        local travelTime = math.Clamp(dist / 500, 0.1, 1.2)
        local predictedPos = target:GetPos() + (target:GetVelocity() * travelTime)

        local jumpVel = (predictedPos - self:GetPos()):GetNormalized() * math.Clamp(dist * 1.5, 200, 800)
        if self:GetPos().z <= target:GetPos().z + 50 then
            jumpVel.z = 250
        end

        --randomize aim so they dont like, stack on eachother, janky solution but eh LOL
        local randAng = Angle(0, math.random(-20, 20), 0)
        jumpVel:Rotate(randAng)

        phys:SetVelocity(jumpVel)
        if self.sfx then self:EmitSound(self.sfx) end
        self:TriggerDance()
    end

    function ENT:Think()
        if GetConVar("ai_disabled"):GetBool() then return end
        local target = self:GetNearestTarget()
        local phys = self:GetPhysicsObject()

        if IsValid(target) and IsValid(phys) then
            local dir = (target:GetPos() - self:GetPos()):GetNormalized()
            phys:AddVelocity(dir * 100)
        end
    end

    function ENT:Touch(ent)
        if not IsValid(ent) or GetConVar("ai_disabled"):GetBool() then return end
        local isTarg = (ent:IsPlayer() and ent:Alive()) or (ent:IsNPC() and ent:Health() > 0)

        if isTarg then
            local dmg = DamageInfo()
            dmg:SetDamage(5)
            dmg:SetAttacker(self)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_CLUB)
            ent:TakeDamageInfo(dmg)

            local phys = self:GetPhysicsObject()
            if IsValid(phys) then
                phys:AddVelocity((self:GetPos() - ent:GetPos()):GetNormalized() * 300 + Vector(0,0,100))
            end

            self:EmitSound("catplanet/fxAttack.wav")
            if ent:Health() <= 0 then ent:EmitSound("catplanet/fxDie.wav") end
            self:TriggerDance()
        end
    end

    function ENT:OnRemove()
        timer.Remove("cat_jump_" .. self:EntIndex())
    end
end