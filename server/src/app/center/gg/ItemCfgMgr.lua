local ItemCfgMgr = class("ItemCfgMgr")

function ItemCfgMgr:ctor()
    self.itemProductCfg = {}
    self.itemTotalCfg = {}
    -- self:initItemProductCfg()
    -- self:initItemProductTotal()
end

--- ""
function ItemCfgMgr:initItemProductCfg()
    self.itemProductCfg = {}
    local itemProductCfg = gg.shareProxy:call("getItemProductCfg")
    if not itemProductCfg or not next(itemProductCfg) then
        itemProductCfg = {}
        local itemCfg = cfg.get("etc.cfg.item")
        for k, v in pairs(itemCfg) do
            if v.product then
                self.itemProductCfg[v.cfgId] = { cfgId = v.cfgId, product = v.product }
                itemProductCfg[#itemProductCfg+1] = self.itemProductCfg[v.cfgId]
            end
        end
        gg.shareProxy:call("setItemProductCfg", itemProductCfg)
    else
        for k, v in pairs(itemProductCfg) do
            self.itemProductCfg[v.cfgId] = v
        end
    end
end

-- ""
function ItemCfgMgr:initItemProductTotal()
    self.itemTotalCfg = {}
    for quality=2,5 do
        local total =  gg.shareProxy:call("getProductTotal", quality)
        if not total then
            local defaultValue = 0
            if quality == 5 then
                defaultValue = gg.getGlobalCfgIntValue("ProductTotal5",9)
            elseif quality == 4 then
                defaultValue = gg.getGlobalCfgIntValue("ProductTotal4",999)
            elseif quality == 3 then
                defaultValue = gg.getGlobalCfgIntValue("ProductTotal3",9999)
            elseif quality == 2 then
                defaultValue = gg.getGlobalCfgIntValue("ProductTotal2",99999)
            end
            self.itemTotalCfg[quality] = defaultValue
            gg.shareProxy:call("setProductTotal", quality, defaultValue)
        else
            self.itemTotalCfg[quality] = tonumber(total)
        end
    end
end

--- ""
function ItemCfgMgr:updateItemProductCfg()
    local itemProductCfg = gg.shareProxy:call("getItemProductCfg")
    if itemProductCfg and next(itemProductCfg)  then
        for k, v in pairs(itemProductCfg) do
            self.itemProductCfg[v.cfgId] = v
        end
    end
end

-- ""
function ItemCfgMgr:updateItemTotalCfg()
    self.itemTotalCfg = {}
    for quality=2,5 do
        local total =  gg.shareProxy:call("getProductTotal", quality)
        if total then
            self.itemTotalCfg[quality] = tonumber(total)
        else
            self.itemTotalCfg[quality] = 0
        end
    end
end

--""
function ItemCfgMgr:randomPaperByPiece(pieceCfgId)
    local productCfg = self.itemProductCfg[pieceCfgId]
    if not productCfg then
        return
    end
    local product = table.chooseByValue(productCfg.product, function(v)
        return v[2]
    end)
    if not product then
        return
    end
    local paperCfgId = product[1]
    return paperCfgId
end

--""id""nft
function ItemCfgMgr:randomItemByPaper(paperCfgId)
    local productCfg = self.itemProductCfg[paperCfgId]
    if not productCfg then
        return
    end
    if not productCfg.product or not next(productCfg.product) then
        return
    end
    local total = 0
    local quality = 0
    local itemCfgId = 0
    local needUpdate = false
    while true do
        local product = table.chooseByValue(productCfg.product, function(arr)
            return arr[3]
        end)
        if product == nil then
            quality = constant.ITEM_INIT_QUALITY
            break
        end
        quality = product[2]
        if quality == constant.ITEM_INIT_QUALITY then --""
            itemCfgId = product[1]
            break
        end
        total = self.itemTotalCfg[quality]
        assert(total, "total is nil quality=".. tostring(quality))
        if total > 0 then
            total = total - 1
            self.itemTotalCfg[quality] = total
            needUpdate = true
            itemCfgId = product[1]
            break
        end
        --"",""0,""
        product[3] = 0
    end
    if needUpdate then
        gg.shareProxy:send("setProductTotal", quality, total)
    end
    if quality == 0 or itemCfgId == 0 then
        return
    end
    return itemCfgId, quality
end

return ItemCfgMgr