local socket = nil
local os = nil

local isSandboxed, racingSandbox = pcall(require, "sandbox")
if isSandboxed then
	Isaac.DebugString("Sandboxed!")
else
    --- Used for TCP
    local ok, requiredSocket = pcall(require, "socket")
    if ok then
      socket = requiredSocket
    end
    
    --- Used to get current time/date, Isaac.GetTime() is CPU time
    local ok, requiredOs = pcall(require, "os")
    if ok then
      os = requiredOs
    end
end



--- Used to send payload in JSON
local json = require "json"

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
                ingame_time = Game():GetFrameCount() / 30,
				cpu_time = Isaac.GetTime()
            }
        else
          tosend = msg
			tosend.token = Memento.Token
			tosend.version = Memento.Version
			tosend.ingame_time = Game():GetFrameCount() / 30
			tosend.seed = Game():GetSeeds():GetStartSeedString()
			tosend.cpu_time = Isaac.GetTime()
        end
		
		if isSandboxed then
			tosend.rplus = true
			tosend.epoch = racingSandbox.getUnixTime()
		else
			tosend.rplus = false
			tosend.epoch = os.time()
		end
        Memento.Tcpclient:send(json.encode(tosend) .. "\n")
    end
end

function Memento:TryConnect(initial)
    if initial then
        if isSandboxed then
            Memento.Tcpclient = racingSandbox.connect(Memento.Url, Memento.Port, true)
            Isaac.DebugString("Done with R+: " .. tostring(Memento.Tcpclient))
            Memento.InitialInit = true
        else
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
    end
    if Memento.Tcpclient then
        return
	end
end