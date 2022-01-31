--- Used for TCP
local socket = require "socket"
--- Used to send payload in JSON
local json = require "json"
--- Used to get current time/date, Isaac.GetTime() is CPU time
local os = require "os"

Url = "goat.memento.ma"

Port = "8666"
Token = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
Version = "1.0"

function SendMessage(msg)
    local tosend
    if Tcpclient then
        if type(msg) ~= "table" then
            tosend = {
                seed = Game():GetSeeds():GetStartSeedString(),
                token = Token,
                type = "msg",
                version = Version,
                msg = tostring(msg),
                epoch = os.time(),
                ingame_time = Game():GetFrameCount() / 30,
				cpu_time = Isaac.GetTime()
            }
        else
          tosend = msg
            tosend.token = Token
            tosend.version = Version
            tosend.ingame_time = Game():GetFrameCount() / 30
            tosend.seed = Game():GetSeeds():GetStartSeedString()
            tosend.epoch = os.time()
			tosend.cpu_time = Isaac.GetTime()
        end
        Tcpclient:send(json.encode(tosend) .. "\n")
    end
end

function TryConnect(initial)
    if initial then
        Tcpclient = socket.tcp()
        local success = Tcpclient:connect(Url, Port)
        if success then
            Tcpclient:settimeout(0.01)
            Isaac.DebugString("Done: " .. tostring(Tcpclient))

            InitialInit = true
        else
            Tcpclient = nil
        end
    end
    if Tcpclient then
        return
	end
end


-- http? 
-- https://www.educba.com/lua-http/
-- http://lua-users.org/lists/lua-l/2008-07/msg00206.html
-- https://stackoverflow.com/questions/17372330/lua-socket-post
-- http://lua-users.org/lists/lua-l/2012-05/msg00568.html