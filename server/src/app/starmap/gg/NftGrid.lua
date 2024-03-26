local NftGrid = class("NftGrid", ggclass.Grid)

function NftGrid:ctor(gridCfg)
    NftGrid.super.ctor(self, gridCfg)
end

return NftGrid