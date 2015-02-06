--------------------------------------------------------------------------------
-- EasyWebConfig module for NODEMCU
-- LICENCE: http://opensource.org/licenses/MIT
-- yangbo<gyangbo@gmail.com>
--------------------------------------------------------------------------------

--[[
here is the demo.lua:
require("EasyWebConfig")
--EasyWebConfig.addVar("gateWay")
--EasyWebConfig.addVar("userKey")
EasyWebConfig.doMyFile("demo.lua")
--]]
local moduleName = ...
local M = {}
_G[moduleName] = M
_G["wifiStatue"] = nil

_G["config"]  = {}

local userScriptFile = ""


function M.doMyFile(fName)
     userScriptFile = fName
end

function M.addVar(vName)
     table.insert(_G["config"],{name=vName,value=""})
end

M.addVar("ssid")
M.addVar("password")

--try to open user configuration file
if( file.open("network_user_cfg.lua") ~= nil) then
     require("network_user_cfg")
     if true then  --change to if true
          --print("set up wifi mode")
          wifi.setmode(wifi.STATION)
          --please config ssid and password according to settings of your wireless router.
          wifi.sta.config(ssid,password)
          wifi.sta.connect()
          cnt = 0
          tmr.alarm(1, 1000, 1, function()
               if (wifi.sta.getip() == nil) and (cnt < 10) then
                    --print(".")
                    cnt = cnt + 1
               else
                    tmr.stop(1)
                    if (cnt < 10) then print("IP:"..wifi.sta.getip())
                         --_G["wifiStatue"] = "OK"
                         node.led(0,0)
                         if(userScriptFile ~="") then 
                              --print(node.heap())
                              --for n in pairs(_G) do print(n) end
                              ssid= nil
                              password = nil
                              _G["config"] = nil
                              --M = nil
                              --print("---")
                              --for n in pairs(_G) do print(n) end
                              --print(node.heap())
                              dofile(userScriptFile) 
                         end
                    else print("FailToConnect,LoadDefault")
                         _G["wifiStatue"] = "Failed"
                         node.led(800,50)
                         _G["wifissid"] = ssid
                         require("network_default_cfg")
                         print ("LoadDefault")
                    end
               end
          end)
     end
else--not exist user config file,use default one
     require("network_default_cfg")
     print ("LoadDefault")
     node.led(800,800)
end
