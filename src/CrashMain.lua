--
-- Created by IntelliJ IDEA.
-- User: Tornado.Wu
-- Date: 2015/5/5
-- Time: 16:27
-- To change this template use File | Settings | File Templates.

local CrashItem = require "CrashItem"

local ROWS , COLS = 7,7
local SPRITE_WIDTH,SPRITE_HEIGHT = 64,64
local BORDER_WIDTH = 16
local hasChecked = 0

local rowSprList = {}
local colSprList = {}
local resultSprList = {} --比较后的结果列表


local startSpr  = nil
local endSpr    = nil

local cclog = function(...)
    print(string.format(...))
end

local CrashMain = class("CrashMain",function()
    return cc.Scene:create()
end)

function CrashMain.create()
    local scene = CrashMain.new()
    scene:addChild(scene:createLayerBack())

    return scene
end



function CrashMain:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    self.isActionRun = true
    self.isFillSprite = false
    self.isCanTouch = true
    self.iScore = 0
    self.initfirst = 1
    --背景图的初始摆放位置
    self.positionX,self.positionY = self.visibleSize.width / 2,self.visibleSize.height / 2
    --初始化资源
    CrashItem.tItemList = {}
    CrashItem:initData()
    self.vecSprite = {}
    for i=1,7 do
        self.vecSprite[i] = {}
        for j=1,7 do
            self.vecSprite[i][j] = nil
        end
    end

end

function CrashMain:reSetMap()
    self.initfirst = 1

    for i=1,7 do
        for j=1,7 do
            self.vecSprite[i][j]:removeFromParent()
            self.vecSprite[i][j] = nil
        end
    end

    self.isActionRun = false
    self.isFillSprite = false
    for r=1,ROWS do
        for c=1,COLS do
            --self:createItem(r,c)
            self:initCreateItem(r,c)
        end
    end

    --self:initCheckCrash()
    self:checkAndCrash()
    --self.iScore = 0
end

function CrashMain:initMap()

    self.isActionRun = false
    self.isFillSprite = false
    for r=1,ROWS do
        for c=1,COLS do
            --self:createItem(r,c)
            self:initCreateItem(r,c)
        end
    end

    --self:initCheckCrash()
    self:checkAndCrash()
    --self.iScore = 0

end


function CrashMain:initCreateItem(raw,col)
    --newSprite
    local sprite = CrashItem:createObj(raw,col)
    --setPosition
    local endX,endY = self:positionOfItem(raw,col)
    sprite:setPosition(cc.p(endX,endY))

    --sprite:runAction(cc.Sequence:create(cc.MoveTo:create(speed, cc.p(endX, endY)),cc.CallFunc:create(createAnimEnd)))

    self.layerBack:addChild(sprite)

    self.vecSprite[raw][col] = sprite

end

function CrashMain:createItem(raw,col)
    --newSprite
    local sprite = CrashItem:createObj(raw,col)
    --setPosition
    self.isActionRun = true
    self.isCanTouch = false
    local endX,endY = self:positionOfItem(raw,col)
    local startX = endX
    local startY = endY + self.visibleSize.height/2

    local function createAnimEnd()
        cclog("-------------createAnimEnd!!")
        self.isActionRun = false
        self.isCanTouch = true
    end
    sprite:setPosition(cc.p(startX,startY))
    --local speed = startY / (1 * self.visibleSize.height)
    local speed = 0.2
    --sprite:runAction(cc.MoveTo:create(speed, cc.p(endX, endY)))

    sprite:runAction(cc.Sequence:create(cc.MoveTo:create(speed, cc.p(endX, endY)),cc.CallFunc:create(createAnimEnd)))

    self.layerBack:addChild(sprite)

    self.vecSprite[raw][col] = sprite
    ---cclog("--------imageIndex = " .. sprite.imgIndex)
end

function CrashMain:positionOfItem(raw,col)

    local x = self.origin.x + col * SPRITE_WIDTH + (self.visibleSize.width - 512)/2
    local y = self.origin.y + raw * SPRITE_HEIGHT - 16
    return x,y
end


--添加背景
function CrashMain:createLayerBack()
    self.layerBack = cc.Layer:create()
    local layerBack = self.layerBack

    local bg2 = cc.Sprite:create("test/bg_1.png")
    bg2:setPosition(self.positionX,self.positionY)

    local label1 = cc.LabelBMFont:create("SCORE", "test/boundsTestFont.fnt")
    local label2 = cc.LabelBMFont:create("0", "test/boundsTestFont.fnt")

    local timeDec = cc.LabelBMFont:create("TIME", "test/boundsTestFont.fnt")
    local timeCount = cc.LabelBMFont:create("", "test/boundsTestFont.fnt")
    self.lableScore = label2
    self.lableTime = timeCount
    label1:setPosition(130,self.visibleSize.height-30)
    label2:setPosition(130,self.visibleSize.height-60)

    timeDec:setPosition(self.visibleSize.width,self.visibleSize.height-60)
    timeCount:setPosition(self.visibleSize.width,self.visibleSize.height-90)

    bg2:addChild(label1)
    bg2:addChild(label2)
    bg2:addChild(timeDec)
    bg2:addChild(timeCount)
    --label1:setString(string)
    ----------------------------------------
    self.iTimeCounts = 30
    local speedStep = 1
    local Timer = require("CountTimer")  --将倒计时类赋给一个值
    local function callBackFunc()
        --cclog("-------------count down!!")
        if self.iTimeCounts and self.iTimeCounts == 0 then
            Timer:remove_scheduler()
            local resultSence = require("Result")
            local sence = resultSence.create()
            --cclog("bbbbbbbbbbbbbbbb self.iScore = " .. self.iScore)
            sence:initData(self.iScore)
            if cc.Director:getInstance():getRunningScene() then
                cc.Director:getInstance():replaceScene(sence)
            else
                cc.Director:getInstance():runWithScene(sence)
            end
            return
        end
        self.iTimeCounts = self.iTimeCounts - 1
        self.lableTime:setString(self.iTimeCounts)
    end


    Timer:initTimer(callBackFunc,speedStep,self.iTimeCounts)
    -----------------------------------------



    -------------------------------------------------
    local layerMenu = cc.Layer:create()
    local function menuCallbackClosePopup()
        --self:reSetMap()
        os.exit()
    end
    local menuPopupItem = cc.MenuItemImage:create("exit_s.png", "exit_s.png")
    menuPopupItem:setPosition(0,0)
    menuPopupItem:registerScriptTapHandler(menuCallbackClosePopup)
    local menuPopup = cc.Menu:create(menuPopupItem)
    menuPopup:setPosition(self.visibleSize.width,40)
    bg2:addChild(menuPopup)
    -------------------------------------------------
    layerBack:addChild(bg2)

    local bg = cc.Sprite:create("test/bg_2.png")
    bg:setPosition(self.positionX,self.positionY)
    layerBack:addChild(bg)


    math.randomseed(os.time())
    local index = math.random(1,6)

    --启动后初始化棋盘
    self:initMap()

    local function tick()
        self:updateScene()
    end

    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0, false)


    --local touchBeginPoint = nil
    local function onTouchBegan(touch, event)
        startSpr = nil
        endSpr   =  nil
        --self.isActionRun = false
        if self.isCanTouch then
            local location = touch:getLocation()
            startSpr = self:spriteOfPoint(location)
            self:checkAndCrash()
        end

        return self.isCanTouch
    end

    local function onTouchMoved(touch, event)


        if (not startSpr) or (not self.isCanTouch) or (self.isActionRun)then
            return
        end
        local location = touch:getLocation()
        --cclog("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
        self:movedDetected(touch)
    end

    local function onTouchEnded(touch, event)
        local location = touch:getLocation()

    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layerBack:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerBack)

    local function onNodeEvent(event)
        if "exit" == event then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        end
    end
    layerBack:registerScriptHandler(onNodeEvent)

    return layerBack
end

function CrashMain:spriteOfPoint(point)
    local rect = cc.rect(0,0,0,0)
    local size = cc.size(SPRITE_WIDTH,SPRITE_HEIGHT)
    for r=1,ROWS do
        for c=1,COLS do
            local spr = self.vecSprite[r][c]
            if spr then
                rect.x = spr:getPositionX()- (SPRITE_WIDTH / 2)
                rect.y = spr:getPositionY() - (SPRITE_HEIGHT / 2)
                rect.width = SPRITE_WIDTH
                rect.height = SPRITE_HEIGHT
                rect.size = size
                if cc.rectContainsPoint( rect, point ) then
                    cclog("-------------sprite.iRow = " .. spr.iRow .. " sprite.iCol = " .. spr.iCol)
                    return spr
                end

            end

        end
    end

end

function CrashMain:movedDetected(touch)
    local row = startSpr.iRow
    local col = startSpr.iCol
    local location = touch:getLocation()
    if (not self.isCanTouch) or (not startSpr) then
        return
    end
    if (not startSpr) or (not self.isCanTouch)then
        return
    end
    --是否向上滑动？
    local upRect = cc.rect(startSpr:getPositionX() - (SPRITE_WIDTH/2),
        startSpr:getPositionY() +(SPRITE_HEIGHT/2),
        SPRITE_WIDTH,
        SPRITE_HEIGHT)
    if cc.rectContainsPoint(upRect,location) then
        row = row + 1
        if row <= ROWS then
            endSpr = self.vecSprite[row][col]
        end

        cclog("---------向上滑动！")
        self:swapSprite()
        return
    end

    --是否向下滑动？
    local downRect = cc.rect(startSpr:getPositionX() - (SPRITE_WIDTH/2),
        startSpr:getPositionY() - (SPRITE_HEIGHT/2) * 3,
        SPRITE_WIDTH,
        SPRITE_HEIGHT)
    if cc.rectContainsPoint(downRect,location) then
        row = row - 1
        if row >= 1 then
            endSpr = self.vecSprite[row][col]
        end
        cclog("---------向下滑动！")
        self:swapSprite()
        return
    end

    --是否向左滑动？
    local leftRect = cc.rect(startSpr:getPositionX() - (SPRITE_WIDTH/2) * 3,
        startSpr:getPositionY() - (SPRITE_HEIGHT/2),
        SPRITE_WIDTH,
        SPRITE_HEIGHT)
    if cc.rectContainsPoint(leftRect,location) then
        col = col - 1
        if col >= 1 then
            endSpr = self.vecSprite[row][col]
        end
        cclog("---------向左滑动！")
        self:swapSprite()
        return
    end

    --是否向右滑动？
    local rightRect = cc.rect(startSpr:getPositionX() + (SPRITE_WIDTH/2),
        startSpr:getPositionY() - (SPRITE_HEIGHT/2),
        SPRITE_WIDTH,
        SPRITE_HEIGHT)
    if cc.rectContainsPoint(rightRect,location) then
        col = col + 1
        if col <= COLS then
            endSpr = self.vecSprite[row][col]
        end
        cclog("---------向右滑动！")
        self:swapSprite()
        return
    end

end

function CrashMain:swapSprite()
    cclog("------------------swapSprite called!")
    self.isActionRun = true
    self.isCanTouch = false

    if (not startSpr) or (not endSpr) then
        return
    end

    local srcPosition = cc.p(startSpr:getPosition())
    local destPosition = cc.p(endSpr:getPosition())
    local time = 0.2
    self.colListOfFirst = {}
    self.rowListOfFirst = {}
    self.colListOfSecond = {}
    self.rowListOfSecond = {}



    self.vecSprite[startSpr.iRow][startSpr.iCol] = endSpr
    self.vecSprite[endSpr.iRow][endSpr.iCol] = startSpr
    local temRow = startSpr.iRow
    local temCol = startSpr.iCol
    startSpr.iRow = endSpr.iRow
    startSpr.iCol = endSpr.iCol
    endSpr.iRow = temRow
    endSpr.iCol = temCol

    self:checkRowsSwap(startSpr,1)

    self:checkColsSwap(startSpr,1)

    self:checkRowsSwap(endSpr,2)

    self:checkColsSwap(endSpr,2)

    local function swapEnd()
        cclog("------------------swap anim play ended!!!")
        self.isActionRun = false
        self.isCanTouch = true
    end
--    cclog("------self.colListOfFirst = " .. table.getn(self.colListOfFirst))
--    cclog("------self.rowListOfFirst = " .. table.getn(self.rowListOfFirst))
--    cclog("------self.colListOfSecond = " .. table.getn(self.colListOfSecond))
--    cclog("------self.rowListOfSecond = " .. table.getn(self.rowListOfSecond))
    if table.getn(self.colListOfFirst) >= 3 or
       table.getn(self.rowListOfFirst) >= 3 or
       table.getn(self.colListOfSecond) >= 3 or
       table.getn(self.rowListOfSecond) >= 3 then
        self.isActionRun = true
--        startSpr:runAction(cc.MoveTo:create(0.2,destPosition))
--        endSpr:runAction(cc.MoveTo:create(0.2,srcPosition))


        startSpr:runAction(cc.Sequence:create(cc.MoveTo:create(time,destPosition)))
        endSpr:runAction(cc.Sequence:create(cc.MoveTo:create(time,srcPosition),cc.CallFunc:create(swapEnd)))

        return
        --sprite:runAction(cc.MoveTo:create(speed, cc.p(endX, endY)))
    end

    self.vecSprite[startSpr.iRow][startSpr.iCol] = endSpr
    self.vecSprite[endSpr.iRow][endSpr.iCol] = startSpr
    local temRow = startSpr.iRow
    local temCol = startSpr.iCol
    startSpr.iRow = endSpr.iRow
    startSpr.iCol = endSpr.iCol
    endSpr.iRow = temRow
    endSpr.iCol = temCol
    startSpr:runAction(cc.Sequence:create(cc.MoveTo:create(time,destPosition),cc.MoveTo:create(time,srcPosition)))
    endSpr:runAction(cc.Sequence:create(cc.MoveTo:create(time,srcPosition),cc.MoveTo:create(time,destPosition),cc.CallFunc:create(swapEnd)))

end
function CrashMain:checkRowsSwap(sprite,type)
    if type == 1 then
        table.insert(self.rowListOfFirst,sprite)
    elseif type == 2 then
        table.insert(self.rowListOfSecond,sprite)
    end
    --向上查找
    local neighborRow = sprite.iRow - 1
    while neighborRow >= 1 do
        local neighborSpri = self.vecSprite[neighborRow][sprite.iCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            --table.insert(rowSprList,neighborSpri)
            if type == 1 then
                table.insert(self.rowListOfFirst,neighborSpri)
            elseif type == 2 then
                table.insert(self.rowListOfSecond,neighborSpri)
            end
            neighborRow = neighborRow - 1
        else
            break
        end

    end

    --向下查找
    local neighborRow = sprite.iRow + 1
    while neighborRow <= ROWS do
        local neighborSpri = self.vecSprite[neighborRow][sprite.iCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            --table.insert(rowSprList,neighborSpri)
            if type == 1 then
                table.insert(self.rowListOfFirst,neighborSpri)
            elseif type == 2 then
                table.insert(self.rowListOfSecond,neighborSpri)
            end
            neighborRow = neighborRow + 1
        else
            break
        end

    end
end
function CrashMain:checkColsSwap(sprite,type)
    --table.insert(colSprList,sprite)
    if type == 1 then
        table.insert(self.colListOfFirst,sprite)
    elseif type == 2 then
        table.insert(self.colListOfSecond,sprite)
    end
    --向左查找
    local neighborCol = sprite.iCol - 1
    while neighborCol >= 1 do
        local neighborSpri = self.vecSprite[sprite.iRow][neighborCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            --table.insert(colSprList,neighborSpri)
            if type == 1 then
                table.insert(self.colListOfFirst,neighborSpri)
            elseif type == 2 then
                table.insert(self.colListOfSecond,neighborSpri)
            end
            neighborCol = neighborCol - 1
        else
            break
        end

    end

    --向右查找
    local neighborCol = sprite.iCol + 1
    while neighborCol <= COLS do
        local neighborSpri = self.vecSprite[sprite.iRow][neighborCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            --table.insert(colSprList,neighborSpri)
            if type == 1 then
                table.insert(self.colListOfFirst,neighborSpri)
            elseif type == 2 then
                table.insert(self.colListOfSecond,neighborSpri)
            end
            neighborCol = neighborCol + 1
        else
            break
        end

    end
end



function CrashMain:updateScene()
    self:checkIfCanTouch()

    if not self.isActionRun then
        self:checkAndCrash()
    end

    if not self.isFillSprite and not self.isActionRun then
        self:checkAndCrash()
    end

    if self.isFillSprite then
        self:fillSprite()
        self.isFillSprite = false
        self:checkAndCrash()
    end
end


function CrashMain:checkIfCanTouch()
    if self.isActionRun or self.isCanTouch then
        for r=1,ROWS do
            for c=1,COLS do
                local spr = self.vecSprite[ROWS][COLS]
                if spr and spr:getNumberOfRunningActions() > 0 then
                    self.isActionRun = true
                    self.isCanTouch = false
                    break
                end
            end
        end
    end
end


function CrashMain:checkAndCrash()
    --cclog("-------------------checkAndCrash called!!")
    for r=1,ROWS do
        for c=1,COLS do
            local spr = self.vecSprite[r][c]
            --cclog("-----------curSpr row = " .. spr.iRow .. " col = " .. spr.iCol)

            --只有还没有被标记的精灵才会被检查
            if spr and spr.bDelMarked == 0 then
                rowSprList = {}
                colSprList = {}
                resultSprList = {} --比较后的结果列表
                --checkCol 查找与本次遍历的精灵上下相邻的精灵
                self:checkCols(spr)
                --checkRow 查找与本次遍历的精灵左右相邻的精灵
                self:checkRows(spr)
                --combine long --保存相邻数最多精灵的列表
                if table.getn(rowSprList) > table.getn(colSprList) then
                    resultSprList = rowSprList
                else
                    resultSprList = colSprList
                end

                if table.getn(resultSprList) >= 3 then
                    for i,v in pairs(resultSprList) do
                        --mark delete标记确定下来的精灵
                        self.vecSprite[v.iRow][v.iCol].bDelMarked = 1
                    end

                    --标记有东西要删除
                    self.isFillSprite = true

                    --delete一次性删除确定下来的精灵
                    self:deleteMarkedSprite()
                end
            end

        end
    end


end

function CrashMain:runDelete(sprite)

    self.isActionRun = true
    self.isFillSprite = false
    local function callBack()
        sprite:removeFromParent()
        self.isActionRun = false
        self.isFillSprite = true
    end
    sprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,0.8,0.8),cc.ScaleTo:create(0.3,1.3,1.3),cc.CallFunc:create(callBack)))
end

function CrashMain:deleteMarkedSprite()
    for r=1,ROWS do
        for c=1,COLS do
            if self.vecSprite[r][c] and self.vecSprite[r][c].bDelMarked == 1 then

                if not (self.initfirst == 1) then
                    self:runDelete(self.vecSprite[r][c])
                    self.iScore = self.iScore + 10
                else
                    self.vecSprite[r][c]:removeFromParent()
                    self.iScore = 0
                end

                self.lableScore:setString(self.iScore)
                self.vecSprite[r][c] = nil
            end
        end
    end
    --self.isFillSprite = true
end

function CrashMain:checkRows(sprite)
    --cclog("--------------------checkRows!!")
    table.insert(rowSprList,sprite)
    --向上查找
    local neighborRow = sprite.iRow - 1
    while neighborRow >= 1 do
        local neighborSpri = self.vecSprite[neighborRow][sprite.iCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            table.insert(rowSprList,neighborSpri)
            neighborRow = neighborRow - 1
        else
            break
        end

    end

    --向下查找
    local neighborRow = sprite.iRow + 1
    while neighborRow <= ROWS do
        local neighborSpri = self.vecSprite[neighborRow][sprite.iCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            table.insert(rowSprList,neighborSpri)
            neighborRow = neighborRow + 1
        else
            break
        end

    end

end

function CrashMain:checkCols(sprite)
    --cclog("-------------checkCols!!")
    table.insert(colSprList,sprite)
    --向左查找
    local neighborCol = sprite.iCol - 1
    while neighborCol >= 1 do
        local neighborSpri = self.vecSprite[sprite.iRow][neighborCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            table.insert(colSprList,neighborSpri)
            neighborCol = neighborCol - 1
        else
            break
        end

    end

    --向右查找
    local neighborCol = sprite.iCol + 1
    while neighborCol <= COLS do
        local neighborSpri = self.vecSprite[sprite.iRow][neighborCol]
        if neighborSpri and (neighborSpri.imgIndex == sprite.imgIndex) and neighborSpri.bDelMarked == 0 then
            table.insert(colSprList,neighborSpri)
            neighborCol = neighborCol + 1
        else
            break
        end

    end


end

function CrashMain:fillSprite()
    local sprite = nil
    local colEmpty = {}

    for i=1,COLS do
        colEmpty[i] = 0
    end

    local function fillEnd()
        cclog("-------------------fillEnd!!")
        self.isActionRun = false
        self.isFillSprite = false
        self.initfirst = 0
    end
    local function firstFillEnd()
        cclog("-------------------fillEnd!!")
        self.isActionRun = false
        self.isFillSprite = false
        self.initfirst = 0
        self.iScore = 0
        self.lableScore:setString(self.iScore)
    end

    for c=1,COLS do
        local removedSprOfCol = 0
        for r=1,ROWS do
            sprite = self.vecSprite[r][c]
            if sprite == nil then
                removedSprOfCol = removedSprOfCol + 1
            else
                if removedSprOfCol > 0 then
                    local newRow = r - removedSprOfCol
                    self.vecSprite[newRow][c] = sprite
                    self.vecSprite[r][c] = nil

                    local starPosition = cc.p(sprite:getPosition())
                    local endPositionX,endPositionY = self:positionOfItem(newRow,c)

                    local speed = 0.1
                    sprite:stopAllActions()
                    self.isActionRun = true
                    self.isFillSprite = true
                    if self.initfirst == 1 then
                        sprite:setPosition(cc.p(endPositionX,endPositionY))
                        sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(firstFillEnd)))
                    else
                        sprite:runAction(cc.Sequence:create(cc.MoveTo:create(speed,cc.p(endPositionX,endPositionY)),cc.CallFunc:create(fillEnd)))
                    end

                    sprite.iRow = newRow
                else
                    --fillEnd()
                end

            end

        end

        colEmpty[c] = removedSprOfCol

    end

    for c=1,COLS do
        for r=ROWS - colEmpty[c] + 1 ,ROWS do

            if self.initfirst == 1 then
                --对第一次初始化作特殊处理
                self:initCreateItem(r,c)
            else
                self:createItem(r,c)
            end

        end
    end

end


return CrashMain
