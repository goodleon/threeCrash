--
-- Created by IntelliJ IDEA.
-- User: Tornado.Wu
-- Date: 2015/5/11
-- Time: 22:03
-- To change this template use File | Settings | File Templates.
--

--
-- cclog
local cclog = function(...)
    print(string.format(...))
end

local ResultSecene = class("ResultSecene",function()
    return cc.Scene:create()
end)

function ResultSecene.create()
    local scene = ResultSecene.new()
    scene:addChild(scene:createlayerBack())
    return scene
end

function ResultSecene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function ResultSecene:initData(score)
    self.iScore = score
    self.lableScore:setString(self.iScore)
    cclog("---------set score = " .. self.iScore)
end

function ResultSecene:createlayerBack()
    local backLayer = cc.Layer:create()
    local sprite = cc.Sprite:create("result.png")
    sprite:setPosition(self.visibleSize.width/2,self.visibleSize.height/2)
    backLayer:addChild(sprite)

    local lableScore = cc.LabelBMFont:create("", "test/boundsTestFont.fnt")

    self.lableScore = lableScore

    lableScore:setPosition(self.visibleSize.width/2,(self.visibleSize.height/2)+50)
    backLayer:addChild(lableScore)

    local function btnAgainCallback()
        cclog("----------Againe")
        local scene = require("CrashMain")
        local gameScene = scene.create()
        --gameScene:playBgMusic()

        if cc.Director:getInstance():getRunningScene() then
            cc.Director:getInstance():replaceScene(gameScene)
        else
            cc.Director:getInstance():runWithScene(gameScene)
        end
    end
    local btnItem = cc.MenuItemImage:create("agine.jpg", "agine.jpg")
    btnItem:setPosition(0,0)
    btnItem:registerScriptTapHandler(btnAgainCallback)
    local BtnCon = cc.Menu:create(btnItem)
    BtnCon:setPosition(self.visibleSize.width/3,self.visibleSize.height/3)
    --    menuPopup:setVisible(false)
    backLayer:addChild(BtnCon)

    local function btnExitCallback()
        cclog("----------btnExitCallback")
        os.exit()
    end
    local btnItem2 = cc.MenuItemImage:create("exit.jpg", "exit.jpg")
    btnItem2:setPosition(0,0)
    btnItem2:registerScriptTapHandler(btnExitCallback)
    local BtnCon2 = cc.Menu:create(btnItem2)
    BtnCon2:setPosition((self.visibleSize.width/3)*2,self.visibleSize.height/3)
    --    menuPopup:setVisible(false)
    backLayer:addChild(BtnCon2)


    return backLayer
end

return ResultSecene