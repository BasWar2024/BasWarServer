local Army = class("Army")

function Army.create(param)
    return Army.new(param)
end
function Army:ctor(param)
    self.player = param.player
    self.armyId = param.armyId or snowflake.uuid()
    self.armyName = param.armyName or nil
    self.teams = param.teams or {}          -- ""+""
end

function Army:serialize()
    local data = {}
    data.armyId = self.armyId
    data.armyName = self.armyName
    data.teams = self.teams
    return data
end

function Army:deserialize(data)
    self.armyId = data.armyId
    self.armyName = data.armyName
    self.teams = data.teams
end

return Army