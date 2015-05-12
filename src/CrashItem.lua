--
-- Created by IntelliJ IDEA.
-- User: Tornado.Wu
-- Date: 2015/5/5
-- Time: 18:15
-- To change this template use File | Settings | File Templates.
--
-- cclog
local cclog = function(...)
    print(string.format(...))
end

local CrashItem = class("CrashItem",function()
    return cc.Scene:create()
end)

function CrashItem.create()
    local scene = CrashItem.new()
    --scene:addChild(scene:createLayerFarm())
    cclog("-------------CrashItem.create() called !!")
    return scene
end

function CrashItem:initData()
    for i=1,6 do
        table.insert(self.tItemList,"c_" .. i .. ".png")
        cclog("----------self.tItemList[" .. i .. "]=" .. self.tItemList[i])
    end
end

function CrashItem:createObj(raw,col)

    local index = math.random(1,6)
    local spriteObj = cc.Sprite:create(self.tItemList[index])
    spriteObj.imgIndex = index
    spriteObj.iRow = raw
    spriteObj.iCol = col
    spriteObj.bDelMarked = 0
    spriteObj.getIsNeedRemove = self.getIsNeedRemove
    spriteObj.getRow = self.getRow
    spriteObj.getCol = self.getCol
    spriteObj.getImgIndex = self.getImgIndex


    return spriteObj
end

function CrashItem:getRow(obj)
    return obj.iRow
end

function CrashItem:getCol(obj)
    return obj.iCol
end

function CrashItem:getImgIndex(obj)
    return obj.imgIndex
end

function CrashItem:getIsNeedRemove(obj)
    if obj.bDelMarked then
        return true
    else
        return false
    end

end

function CrashItem:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

return CrashItem