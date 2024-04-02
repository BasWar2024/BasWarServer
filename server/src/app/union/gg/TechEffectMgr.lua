local TechEffectMgr = class("TechEffectMgr")

function TechEffectMgr.getUnionTechCfg(cfgId, level)
    local techCfgs = cfg.get("etc.cfg.unionTechConfig")
    return techCfgs[string.format("%s_%s", tostring(cfgId), tostring(level))]
end

function TechEffectMgr.getUnionTechEffectCfg(effectCfgId)
    local effectCfgs = cfg.get("etc.cfg.unionTechEffect")
    return effectCfgs[effectCfgId]
end

function TechEffectMgr:ctor()
    self.effects = {}
    self.effectsByType = {}
    self:init()
end

function TechEffectMgr:init()
    local techCfgs = cfg.get("etc.cfg.unionTechConfig")
    for key, techCfg in pairs(techCfgs) do
        for kk, vv in pairs(techCfg.techEffects) do
            local effectCfgId = vv[1]
            local effectValue = vv[2]
            local effectCfg = TechEffectMgr.getUnionTechEffectCfg(effectCfgId)
            if effectCfg then
                local className = constant.UNION_TECH_KEYS[effectCfg.effectType]
                local effectKey = string.format("%s_%s", key, effectCfgId)
                local effect = ggclass[className].new(effectCfg.target, effectValue)
                self.effects[effectKey] = effect
                self.effectsByType[effectCfg.effectType] = self.effectsByType[effectCfg.effectType] or {}
                table.insert(self.effectsByType[effectCfg.effectType], effectKey)
            end
        end
    end
end

function TechEffectMgr:resetEffect(techs, effectType, target)
    local targetEffects = {}
    for k, v in pairs(techs) do
        local techCfg = TechEffectMgr.getUnionTechCfg(v.cfgId, v.level)
        if techCfg then
            for kk, vv in pairs(techCfg.techEffects) do
                local effectCfgId = vv[1]
                local effectValue = vv[2]
                
                local effectCfg = TechEffectMgr.getUnionTechEffectCfg(effectCfgId)
                if effectCfg and effectCfg.effectType == effectType then
                    local effectKey = string.format("%s_%s_%s", v.cfgId, v.level, effectCfgId)
                    local effect = self.effects[effectKey]
                    if effect then
                        targetEffects[effectKey] = effect
                    end
                end
            end
        end
    end

    --""
    for _, effect in pairs(targetEffects) do
        effect:resetEffect(target)
    end
end

function TechEffectMgr:apply(techs, effectType, target)
    local targetEffects = {}
    for k, v in pairs(techs) do
        local techCfg = TechEffectMgr.getUnionTechCfg(v.cfgId, v.level)
        if techCfg then
            for kk, vv in pairs(techCfg.techEffects) do
                local effectCfgId = vv[1]
                local effectValue = vv[2]
                
                local effectCfg = TechEffectMgr.getUnionTechEffectCfg(effectCfgId)
                if effectCfg and effectCfg.effectType == effectType then
                    local effectKey = string.format("%s_%s_%s", v.cfgId, v.level, effectCfgId)
                    local effect = self.effects[effectKey]
                    if effect then
                        targetEffects[effectKey] = effect
                    end
                end
            end
        end
    end
    --""
    for _, effect in pairs(targetEffects) do
        effect:apply(target)
    end
end

return TechEffectMgr