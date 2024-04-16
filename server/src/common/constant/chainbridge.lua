constant.CHAIN_BRIDGE_RECHARGE_STATE_WAITING = 0  --""
constant.CHAIN_BRIDGE_RECHARGE_STATE_CONFIRM = 1  --""
constant.CHAIN_BRIDGE_RECHARGE_STATE_SUCCESS = 2  --""
constant.CHAIN_BRIDGE_RECHARGE_STATE_ERROR = -1   --""

constant.CHAIN_BRIDGE_RECHARGE_DES_WAITING = "waiting"  --""
constant.CHAIN_BRIDGE_RECHARGE_DES_CONFIRM = "confirm"  --""
constant.CHAIN_BRIDGE_RECHARGE_DES_SUCCESS = "success"  --""
constant.CHAIN_BRIDGE_RECHARGE_DES_ERROR_NO_ACCOUNT = "NoBindAccount"        --""
constant.CHAIN_BRIDGE_RECHARGE_DES_ERROR_DIFFERENT_CHAIN = "DifferentChain"  --""

constant.CHAIN_BRIDGE_WITHDRAW_STATE_WAITING = 0  --""
constant.CHAIN_BRIDGE_WITHDRAW_STATE_APPROVAL = 1 --""
constant.CHAIN_BRIDGE_WITHDRAW_STATE_PENDING = 2  --""
constant.CHAIN_BRIDGE_WITHDRAW_STATE_SUCCESS = 3  --""
constant.CHAIN_BRIDGE_WITHDRAW_STATE_ERROR = -1   --""

constant.CHAIN_BRIDGE_WITHDRAW_DES_WAITING = "waiting"      --""
constant.CHAIN_BRIDGE_WITHDRAW_DES_APPROVAL = "approval"    --""
constant.CHAIN_BRIDGE_WITHDRAW_DES_PENDING = "pending"      --""
constant.CHAIN_BRIDGE_WITHDRAW_DES_SUCCESS = "success"      --""
constant.CHAIN_BRIDGE_WITHDRAW_DES_ERROR_REJECT = "reject"  --""


constant.CHAIN_BRIDGE_CHAIN_ID_ETH = 1
constant.CHAIN_BRIDGE_CHAIN_ID_RINKEBY = 4
constant.CHAIN_BRIDGE_CHAIN_ID_BSC = 56
constant.CHAIN_BRIDGE_CHAIN_ID_TEST_BSC = 97
constant.CHAIN_BRIDGE_CHAIN_ID_APTOS_TEST = 2
constant.CHAIN_BRIDGE_CHAIN_ID_APTOS_DEVNET = 32
constant.CHAIN_BRIDGE_CHAIN_ID_CFX = 1030
constant.CHAIN_BRIDGE_CHAIN_ID_TEST_CFX = 71
constant.CHAIN_BRIDGE_CHAIN_ID_ZKSYNC = 324
constant.CHAIN_BRIDGE_CHAIN_ID_TEST_ZKSYNC = 280
constant.CHAIN_BRIDGE_CHAIN_ID_OAS = 7225878
constant.CHAIN_BRIDGE_CHAIN_ID_SCROLL = 534352
constant.CHAIN_BRIDGE_CHAIN_ID_LINEA = 59144
constant.CHAIN_BRIDGE_CHAIN_ID_MANTA = 169
constant.CHAIN_BRIDGE_CHAIN_ID_SKALE = 2046399126
constant.CHAIN_BRIDGE_CHAIN_ID_MOONBEAM = 1284
constant.CHAIN_BRIDGE_CHAIN_ID_CRONOS = 25
constant.CHAIN_BRIDGE_CHAIN_ID_OP = 10
constant.CHAIN_BRIDGE_CHAIN_ID_ARBNOVE = 42170
constant.CHAIN_BRIDGE_CHAIN_ID_POLYGON = 137

function constant.getValidChain()
    local validChain = {}
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_ETH] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_RINKEBY] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_BSC] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_TEST_BSC] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_APTOS_TEST] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_APTOS_DEVNET] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_CFX] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_TEST_CFX] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_ZKSYNC] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_TEST_ZKSYNC] = true

    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_OAS] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_SCROLL] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_LINEA] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_MANTA] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_SKALE] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_MOONBEAM] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_CRONOS] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_OP] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_ARBNOVE] = true
    validChain[constant.CHAIN_BRIDGE_CHAIN_ID_POLYGON] = true
    return validChain
end


constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP = 1          --""
constant.CHAIN_BRIDGE_NFT_KIND_HERO = 2               --""
constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE = 3          --""
constant.CHAIN_BRIDGE_NFT_KIND_ITEM_NFT = 13          --nft""
constant.CHAIN_BRIDGE_NFT_KIND_ITEM_ARTIFACT = 14     --DAO""

constant.CHAIN_BRIDGE_ENTITY_NFT = {}
constant.CHAIN_BRIDGE_ENTITY_NFT[constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP] = true
constant.CHAIN_BRIDGE_ENTITY_NFT[constant.CHAIN_BRIDGE_NFT_KIND_HERO] = true
constant.CHAIN_BRIDGE_ENTITY_NFT[constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE] = true

constant.CHAIN_BRIDGE_ITEM_NFT = {}
constant.CHAIN_BRIDGE_ITEM_NFT[constant.CHAIN_BRIDGE_NFT_KIND_ITEM_NFT] = true
constant.CHAIN_BRIDGE_ITEM_NFT[constant.CHAIN_BRIDGE_NFT_KIND_ITEM_ARTIFACT] = true


constant.CHAIN_BRIDGE_CONFIG = {
    {chainId = 1, chainName = "Ethereum", open = 1},
    {chainId = 4, chainName = "Rinkeby", open = 1},
    {chainId = 56, chainName = "BSCMainNet", open = 1},
    {chainId = 97, chainName = "BSCTestNet", open = 1},
}

constant.CHAIN_BRIDGE_LAUNCH_FEE = {
    {min = 0, max = 5000 * 1000, fee = 2000},
    {min = 5000 * 1000, max = 30000 * 1000, fee = 2000},
    {min = 30000 * 1000, max = 100000 * 1000, fee= 2000},
    {min = 100000 * 1000, max = -1, fee = 2000},
}

constant.FEE_FOR_LP_RATE = 0.75