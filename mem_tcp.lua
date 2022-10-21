--- Used for TCP
local socket = require "socket"
--- Used to send payload in JSON
local json = require "json"
--- Used to get current time/date, Isaac.GetTime() is CPU time
local os = require "os"

function Memento:SendMessage(msg)
    local tosend
    if Memento.Tcpclient then
        if type(msg) ~= "table" then
            tosend = {
                seed = Game():GetSeeds():GetStartSeedString(),
                token = Memento.Token,
                type = "msg",
                version = Memento.Version,
                msg = tostring(msg),
                epoch = os.time(),
                ingame_time = Game():GetFrameCount() / 30,
				cpu_time = Isaac.GetTime()
            }
        else
          tosend = msg
			tosend.token = Memento.Token
			tosend.version = Memento.Version
			tosend.ingame_time = Game():GetFrameCount() / 30
			tosend.seed = Game():GetSeeds():GetStartSeedString()
			tosend.epoch = os.time()
			tosend.cpu_time = Isaac.GetTime()
        end
        Memento.Tcpclient:send(json.encode(tosend) .. "\n")
    end
end

function Memento:TryConnect(initial)
    if initial then
        -- Memento:VerifyToken()
        Memento.Tcpclient = socket.tcp()
        local success = Memento.Tcpclient:connect(Memento.Url, Memento.Port)
        if success then
            Memento.Tcpclient:settimeout(0.01)
            Isaac.DebugString("Done: " .. tostring(Memento.Tcpclient))

            Memento.InitialInit = true
        else
            Memento.Tcpclient = nil
            Memento:ClearCallback()
        end
    end
    if Memento.Tcpclient then
        return
	end
end