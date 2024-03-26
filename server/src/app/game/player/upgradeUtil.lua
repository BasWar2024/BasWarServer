upgradeUtil = upgradeUtil or {}

function upgradeUtil.calResCost(self, resDict, tick)
    local newResDict = {}
    local addResDict = {}
    for cfgId, count in pairs(resDict) do
        local curr = self.player.resBag:getRes(cfgId) + self.player.resBag:getRes(cfgId, true)
        if count - curr > 0 then
            addResDict[cfgId] = count - curr
            newResDict[cfgId] = curr
        else
            newResDict[cfgId] = count
        end
    end
    local resTesseract = self.player.resBag:resCostTesseract(addResDict)
    if tick then
        local timeTesseract = self.player.resBag:timeCostTesseract(tick)
        resTesseract = resTesseract + timeTesseract
    end
    newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] or 0
    newResDict[constant.RES_TESSERACT] = newResDict[constant.RES_TESSERACT] + resTesseract
    return newResDict
end

return upgradeUtil
