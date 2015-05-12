--
-- Created by IntelliJ IDEA.
-- User: Tornado.Wu
-- Date: 2015/5/11
-- Time: 18:09
-- To change this template use File | Settings | File Templates.
--

--写一个倒计时类
local cclog = function(...)
    print(string.format(...))
end

local Countdown = class("Countdown")

Countdown.__index = Countdown

Countdown.hour = nil   --小时
Countdown.minute = nil --分钟
Countdown.second = nil --秒钟
Countdown.func = nil
Countdown.showtype = true
function Countdown.create()
    local label = Countdown.new()
    return label
end

function Countdown:initTimer(callBackFunc,speedStep,Counts)

    self:ctor()
    self.callBackFunc = callBackFunc
    self.speedStep = speedStep
    self.Counts = Counts

    self:createSchedule(callBackFunc,speedStep)
end

function Countdown:ctor()
    Countdown.winsize = cc.Director:getInstance():getWinSize()
    Countdown.scheduler = cc.Director:getInstance():getScheduler()
    Countdown.schedulerID = nil
    print("======Countdown.ctor()=========")
end

--设置倒计时到00:00:00时调用这个函数，传入的参数是一个函数
function Countdown.function_(f)
    Countdown.func = f
end

function Countdown.settime(hour,minute,second)
    Countdown.hour = hour   --小时
    Countdown.minute = minute --分钟
    Countdown.second = second --秒钟
end

function Countdown:gettime()
    return Countdown.hour,Countdown.minute,Countdown.second
end

--倒计时刷新函数
function Countdown:createSchedule(func,step)
    --隔一秒刷新这个函数
    Countdown.schedulerID = Countdown.scheduler:scheduleScriptFunc(func,step,false)
end

--移除这个刷新函数
function Countdown:remove_scheduler()
    if Countdown.schedulerID ~= nil then
        Countdown.scheduler:unscheduleScriptEntry(Countdown.schedulerID)
        Countdown.schedulerID = nil
    end
end

--重设
function Countdown:reset(hour,minute,second)
    Countdown.remove_scheduler()
    Countdown.hour = hour   --小时
    Countdown.minute = minute --分钟
    Countdown.second = second --秒钟
    Countdown.scheduleFunc()

end

function Countdown:remove_hour()
    if Countdown.time ~= nil then
        if tonumber(Countdown.hour) == 0 then
            --设为分钟:秒 如09:11
            Countdown.time:setString(Countdown.minute ..":".. Countdown.second .. "后")
            Countdown.showtype = false
        end
    end

end

return Countdown