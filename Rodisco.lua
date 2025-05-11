local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DiscordWebhook = {}
DiscordWebhook.__index = DiscordWebhook

-- Validates a hex color and converts it to decimal
local function parseColor(color)
    if type(color) == "number" then
        return math.floor(color)
    elseif type(color) == "string" then
        if color:sub(1, 1) == "#" then
            color = color:sub(2)
        end
        return tonumber(color, 16)
    end
    return nil
end

-- Creates a new DiscordWebhook instance
function DiscordWebhook.new(webhookUrl)
    assert(type(webhookUrl) == "string", "Webhook URL must be a string")
    assert(string.find(webhookUrl, "^https?://"), "Invalid webhook URL format")
    
    local self = setmetatable({}, DiscordWebhook)
    self._webhookUrl = webhookUrl
    self._rateLimit = {
        lastRequest = 0,
        queue = {}
    }
    
    -- Set up rate limiting (5 requests per 5 seconds)
    if RunService:IsServer() then
        task.spawn(function()
            while true do
                task.wait(5)
                local now = os.time()
                while #self._rateLimit.queue > 0 and now - self._rateLimit.lastRequest >= 5 do
                    local nextRequest = table.remove(self._rateLimit.queue, 1)
                    nextRequest()
                end
            end
        end)
    end
    
    return self
end

-- Internal method to actually send the request
function DiscordWebhook:_sendRequest(data)
    local jsonData = HttpService:JSONEncode(data)
    
    if RunService:IsServer() then
        -- Rate limiting for server-side
        local now = os.time()
        if now - self._rateLimit.lastRequest < 1 then -- 1 request per second
            table.insert(self._rateLimit.queue, function()
                self:_sendRequest(data)
            end)
            return false, "Rate limited - queued request"
        end
        
        self._rateLimit.lastRequest = now
    end
    
    local success, response = pcall(function()
        return HttpService:PostAsync(self._webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        return false, response
    end
    
    return true, response
end

-- Sends a simple message to Discord
function DiscordWebhook:send(message, options)
    options = options or {}
    
    local data = {
        content = tostring(message),
        username = options.username or "Roblox Server",
        avatar_url = options.avatar_url or "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
    }
    
    return self:_sendRequest(data)
end

-- Sends an embed message to Discord
function DiscordWebhook:sendEmbed(embedData, options)
    options = options or {}
    
    -- Process embed fields
    local embed = {
        title = embedData.title,
        description = embedData.description,
        url = embedData.url,
        color = parseColor(embedData.color),
        timestamp = embedData.timestamp or DateTime.now():ToIsoDate(),
        footer = embedData.footer and {
            text = embedData.footer.text,
            icon_url = embedData.footer.icon_url
        },
        fields = {}
    }
    
    -- Add fields if provided
    if embedData.fields then
        for _, field in ipairs(embedData.fields) do
            table.insert(embed.fields, {
                name = field.name,
                value = field.value,
                inline = field.inline or false
            })
        end
    end
    
    local data = {
        embeds = {embed},
        username = options.username or "Roblox Server",
        avatar_url = options.avatar_url or "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=420&height=420&format=png"
    }
    
    return self:_sendRequest(data)
end

-- Attempts to send a message and returns status (doesn't throw errors)
function DiscordWebhook:trySend(message, options)
    local success, err = pcall(function()
        return self:send(message, options)
    end)
    
    if not success then
        return false, err
    end
    
    return true
end

-- Attempts to send an embed and returns status (doesn't throw errors)
function DiscordWebhook:trySendEmbed(embedData, options)
    local success, err = pcall(function()
        return self:sendEmbed(embedData, options)
    end)
    
    if not success then
        return false, err
    end
    
    return true
end

return DiscordWebhook
