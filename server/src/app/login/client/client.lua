local cclient = reload_class("cclient")

function cclient:open()
    self:register_http("/api/rpc",require "app.login.client.http.api.rpc")
    self:register_http("/api/app/add",require "app.login.client.http.api.app.add")
    self:register_http("/api/account/register",require "app.login.client.http.api.account.register")
    self:register_http("/api/account/login",require "app.login.client.http.api.account.login")
    self:register_http("/api/account/vistorLogin",require "app.login.client.http.api.account.vistorLogin")
    self:register_http("/api/account/checktoken",require "app.login.client.http.api.account.checktoken")
    self:register_http("/api/account/role/add",require "app.login.client.http.api.account.role.add")
    self:register_http("/api/account/role/del",require "app.login.client.http.api.account.role.del")
    self:register_http("/api/account/role/recover",require "app.login.client.http.api.account.role.recover")
    self:register_http("/api/account/role/update",require "app.login.client.http.api.account.role.update")
    self:register_http("/api/account/role/get",require "app.login.client.http.api.account.role.get")
    self:register_http("/api/account/role/list",require "app.login.client.http.api.account.role.list")
    self:register_http("/api/account/role/rebindserver",require "app.login.client.http.api.account.role.rebindserver")
    self:register_http("/api/account/role/rebindaccount",require "app.login.client.http.api.account.role.rebindaccount")
    self:register_http("/api/account/server/add",require "app.login.client.http.api.account.server.add")
    self:register_http("/api/account/server/del",require "app.login.client.http.api.account.server.del")
    self:register_http("/api/account/server/update",require "app.login.client.http.api.account.server.update")
    self:register_http("/api/account/server/get",require "app.login.client.http.api.account.server.get")
    self:register_http("/api/account/server/list",require "app.login.client.http.api.account.server.list")
    self:register_http("/api/account/server/switchserverlist",require "app.login.client.http.api.account.server.switchserverlist")

    self:register_http("/api/account/pay/ready",require "app.login.client.http.api.account.pay.ready")
    self:register_http("/api/account/pay/settle",require "app.login.client.http.api.account.pay.settle")

    self:register_http("/api/account/bind",require "app.login.client.http.api.account.bind")
    self:register_http("/api/account/get",require "app.login.client.http.api.account.get")
end

function __hotfix(module)
    gg.client:open()
end

return cclient
