constant.REF_NONE = 0             --""
constant.REF_UNION = 4            --"", "",""
constant.REF_GRID = 5             --"", refby""cfgId
constant.REF_LEVELUP = 6          --""
constant.REF_SKILLUP = 7          --""
constant.REF_LAUNCH = 8           --""
constant.REF_BATTLE = 9           --""
constant.REF_MINT = 10            --""
constant.REF_ARMY = 11            --""

constant.REF_CANLEVELUP = {
    [constant.REF_NONE] = 0,             --""
    [constant.REF_LEVELUP] = 6,          --""
    [constant.REF_SKILLUP] = 7,          --""
    [constant.REF_ARMY] = 11,            --""
}

function constant.setRef(obj, ref)
    obj.ref = ref
end 

function constant.cancelRef(obj, ref)
    if obj.ref == ref then
        obj.ref = constant.REF_NONE
    end
end

function constant.IsRefNone(obj)
    return obj.ref == constant.REF_NONE
end

function constant.IsRefUnion(obj)
    return obj.ref == constant.REF_UNION
end

function constant.IsRefGrid(obj)
    return obj.ref == constant.REF_GRID
end

function constant.IsRefLevelUp(obj)
    return obj.ref == constant.REF_LEVELUP
end

function constant.IsRefSkillUp(obj)
    return obj.ref == constant.REF_SKILLUP
end

function constant.IsRefLaunch(obj)
    return obj.ref == constant.REF_LAUNCH
end

function constant.IsRefBattle(obj)
    return obj.ref == constant.REF_BATTLE
end

function constant.IsRefMint(obj)
    return obj.ref == constant.REF_MINT
end

function constant.IsRefArmy(obj)
    return obj.ref == constant.REF_ARMY
end