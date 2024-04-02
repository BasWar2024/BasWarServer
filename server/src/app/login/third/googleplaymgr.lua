googleplaymgr = googleplaymgr or {}


googleplaymgr.signtureData = '{"orderId":"GPA.3374-0096-5261-09291","packageName":"com.gb.GalaxyBlitzWar","productId":"gb.tesseract.499","purchaseTime":1685069074550,"purchaseState":0,"purchaseToken":"dphelcknnmfcoelilphjmogm.AO-J1OxjbTgp4J95vsawJcvGUDj6481ENNvh1u_6XuMz-67P9qvzZ0JYO2wT4j6zrh8uc7OWMtHIdQT6pvCE2QyeLGPNEznZwFp6nUjiBDXQ69bZ6LxOp9A","quantity":1,"acknowledged":false}'
googleplaymgr.signture = 'nxteFf90gheFG5XngKu+mYpzkpCi7p/b5cU4m6kew+/VgfRUazaBXJMsqsJ7rH1PbjyK/T30zgJS66ZHnnk0F0hC4ssA/+EsQS0vi+twtZmh3NSZjYexoV17lytfTkYuWCvoAXt7Jfu5t35hNQxlVtFXAi5BzX2EDW5gGibWpWCJ+aBHfvnS1PhFeBCJ4j++G3d5LtU3dI/ClpHbOe40/lGnCLFvQALuOMxMKdnnyNeGiBpNDaec2TQNyuvFfNJPGmgNIRCO+qCdx6EwXVHAlaqwyFsH4F6okZumwLXxBa5JHxe+rseENQYaaEv4HhzJxIdPpMJOUYxTOroc/2OHfA=='

--local pem = "-----BEGIN PUBLIC KEY-----\n" .. 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvk40UFyuHAP4WwY2jPT7EwCH0JqYTPCOSkp2TwIDkU0LwifPbKyDF1OLWAzWUoVHbLRe2RrcZLwLxp2W334Xpb/CLXvv3FfqWMAJCzvvBIyB/uf9BaSuV02VAFnmXms0QW6gmTiiyCwt4FL+L2/cNil5Ym8o8sNDP7wVFan42s8QJrPkIfDMxjfu3bgbrWpVYWcOi0713VLM7FgxYlk+dTic7rdqn5pWud6+NrpVW6jxu9WXveQU2miQSyN6qlS+8BFcJdwrb3AVlUNqDkeoJ4QxKLP8GJF+G47YhWDHZGOLXx9wWG0oGaM+GoJAScoABR/nxq3d3+rhPubHUKeK/QIDAQAB' .. "\n-----END PUBLIC KEY-----"
local pem = "-----BEGIN PUBLIC KEY-----\n" .. 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqCTDjgTDWghCZqZzHoz2No7tSLeG1KaFbe7n3zkiO9bbetVlw5C6BaUf0+gRzpLR5BDrhCDQ8hY1cgN+McXiKIudQiiwiuZYz2kWjLmI6QWPATzgGrKJpUWs5IbDYhxiAv1u+24yxrtEYaxVqNCAB8UwMVV+en4dJPe+wfHcS93v/C7mWIzn7p+y2INoX51J/NbHOtGWIktKFHQyJIbeCn/qFbsySXxooJAoCWHkP3NaXx73bGj7pGoIlbAJpCWppaiOJHD1TBU52GOCU2yKndhnKnEZeOPbl6yMtmTrRzPZk3lIv+d3lCQVS93Uou/aQuuLILkGt5ZbPR1VBWzntQIDAQAB' .. "\n-----END PUBLIC KEY-----"

function googleplaymgr.verifySignture(signtureData, signture, account, orderId, productId)
    signtureData = signtureData or "default"
    signture = signture or "default"
    account = account or "default"
    orderId = orderId or "default"
    productId = productId or "default"

    local bs = codec.base64_decode(signture)
    local ret = codec.rsa_public_verify(signtureData, bs, pem, 0)

    logger.logf("info","googleplaymgr",string.format("op=verifySignture,account=%s,orderId=%s,productId=%s,signtureData=%s,signture=%s,ret=%s \n",account,orderId,productId,signtureData,signture,ret))

    if not ret then
        return false, "verify fail"
    end

    local data = cjson.decode(signtureData)
    local orderPackageName = data.packageName
    local orderProductId = data.productId
    
    --""
    if orderPackageName ~= "com.gb.GalaxyBlitzWar" then
        return false, "package error"
    end

    if orderProductId ~= productId then
        return false, "product error"
    end

    return true, "success"
end