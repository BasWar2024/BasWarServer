
local TechEffect = class("TechEffect")
function TechEffect:ctor(target, effectValue)
    self.target = target
    self.effectValue = effectValue
end

function TechEffect:resetEffect(args)

end

function TechEffect:apply(args)

end


local ResLimitEffect = class("ResLimitEffect", TechEffect)
function ResLimitEffect:ctor(target, effectValue)
    ResLimitEffect.super.ctor(self, target, effectValue)
end

function ResLimitEffect:resetEffect(union)
    assert(type(self.target) == "table")
    local resCfgId = self.target[1]
    if resCfgId == constant.RES_STARCOIN then
        union.starCoinLimitAdd = 0
    elseif resCfgId == constant.RES_ICE then
        union.iceLimitAdd = 0
    elseif resCfgId == constant.RES_GAS then
        union.gasLimitAdd = 0
    elseif resCfgId == constant.RES_TITANIUM then
        union.titaniumLimitAdd = 0
    elseif resCfgId == constant.RES_CARBOXYL then
        union.carboxylLimitAdd = 0
    end
end

function ResLimitEffect:apply(union)
    assert(type(self.target) == "table")
    local resCfgId = self.target[1]
    if resCfgId == constant.RES_STARCOIN then
        union.starCoinLimitAdd = union.starCoinLimitAdd or 0
        union.starCoinLimitAdd = union.starCoinLimitAdd + self.effectValue
    elseif resCfgId == constant.RES_ICE then
        union.iceLimitAdd = union.iceLimitAdd or 0
        union.iceLimitAdd = union.iceLimitAdd + self.effectValue
    elseif resCfgId == constant.RES_GAS then
        union.gasLimitAdd = union.gasLimitAdd or 0
        union.gasLimitAdd = union.gasLimitAdd + self.effectValue
    elseif resCfgId == constant.RES_TITANIUM then
        union.titaniumLimitAdd = union.titaniumLimitAdd or 0
        union.titaniumLimitAdd = union.titaniumLimitAdd + self.effectValue
    elseif resCfgId == constant.RES_CARBOXYL then
        union.carboxylLimitAdd = union.carboxylLimitAdd or 0
        union.carboxylLimitAdd = union.carboxylLimitAdd + self.effectValue
    end
    return union
end

--""x""
local DefenseLevelUpEffect = class("DefenseLevelUpEffect", TechEffect)
function DefenseLevelUpEffect:ctor(target, effectValue)
    DefenseLevelUpEffect.super.ctor(self, target, effectValue)
end

function DefenseLevelUpEffect:resetEffect(union)
    
end

function DefenseLevelUpEffect:apply(union)
    assert(type(self.target) == "table")
    local buildCfgId = self.target[1]
    local attrType = self.target[2]

    if not union.builds[buildCfgId] then --""
        union:unlockBuild(buildCfgId, self.effectValue)
    else
        for k, v in pairs(union.builds) do
            if buildCfgId == 0 then
                v.level = self.effectValue
            else
                if v.cfgId == buildCfgId then
                    v.level = self.effectValue
                end
            end
        end
    end
    return union
end

--""
local DefenseAttrAddEffect = class("DefenseAttrAddEffect", TechEffect)
function DefenseAttrAddEffect:ctor(target, effectValue)
    DefenseAttrAddEffect.super.ctor(self, target, effectValue)
end

function DefenseAttrAddEffect:resetEffect(union)
    local buildCfgId = self.target[1]
    local attrType = self.target[2]
    local attrName = constant.UNION_TECH_ATTRS[attrType]
    for k, v in pairs(union.builds) do
        if buildCfgId == 0 then
            v[attrName] = 0
        else
            if v.cfgId == buildCfgId then
                v[attrName] = 0
            end
        end
    end
end

function DefenseAttrAddEffect:apply(union)
    assert(type(self.target) == "table")
    local buildCfgId = self.target[1]
    local attrType = self.target[2]
    local attrName = constant.UNION_TECH_ATTRS[attrType]
    if attrName then
        for k, v in pairs(union.builds) do
            if buildCfgId == 0 then
                v[attrName] = v[attrName] + self.effectValue
            else
                if v.cfgId == buildCfgId then
                    v[attrName] = v[attrName] + self.effectValue
                end
            end
        end
    end
    return union
end

--""x""
local SoliderLevelUpEffect = class("SoliderLevelUpEffect", TechEffect)
function SoliderLevelUpEffect:ctor(target, effectValue)
    SoliderLevelUpEffect.super.ctor(self, target, effectValue)
end

function SoliderLevelUpEffect:apply(union)
    assert(type(self.target) == "table")
    local soliderCfgId = self.target[1]
    local attrType = self.target[2]
    if not union.soliders[soliderCfgId] then --""
        union:unlockSolider(soliderCfgId, self.effectValue)
    else
        for k, v in pairs(union.soliders) do
            if soliderCfgId == 0 then
                v.level = self.effectValue
            else
                if v.cfgId == soliderCfgId then
                    v.level = self.effectValue
                end
            end
        end
    end
    return union
end

--""
local SoliderAttrAddEffect = class("SoliderAttrAddEffect", TechEffect)
function SoliderAttrAddEffect:ctor(target, effectValue)
    SoliderAttrAddEffect.super.ctor(self, target, effectValue)
end

function DefenseAttrAddEffect:resetEffect(union)
    assert(type(self.target) == "table")
    local soliderCfgId = self.target[1]
    local attrType = self.target[2]
    local attrName = constant.UNION_TECH_ATTRS[attrType]
    for k, v in pairs(union.soliders) do
        if soliderCfgId == 0 then
            v[attrName] = 0
        else
            if v.cfgId == soliderCfgId then
                v[attrName] = 0
            end
        end
    end
end

function SoliderAttrAddEffect:apply(union)
    assert(type(self.target) == "table")
    local soliderCfgId = self.target[1]
    local attrType = self.target[2]
    local attrName = constant.UNION_TECH_ATTRS[attrType]
    if attrName then --""
        for k, v in pairs(union.soliders) do
            if soliderCfgId == 0 then
                v[attrName] = v[attrName] + self.effectValue
            else
                if v.cfgId == soliderCfgId then
                    v[attrName] = v[attrName] + self.effectValue
                end
            end
        end
    end
end

local SoliderSpaceAddEffect = class("SoliderSpaceAddEffect", TechEffect)
function SoliderSpaceAddEffect:ctor(target, effectValue)
    SoliderSpaceAddEffect.super.ctor(self, target, effectValue)
end

function SoliderSpaceAddEffect:resetEffect(union)
    assert(type(self.target) == "table")
    union.soliderSpaceAdd = 0
end

function SoliderSpaceAddEffect:apply(union)
    assert(type(self.target) == "table")
    union.soliderSpaceAdd = self.effectValue
    return union
end