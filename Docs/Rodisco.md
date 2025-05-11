# 📢 Модуль Rodisco для Roblox (Luau)

**Простой модуль для отправки сообщений из Roblox в Discord**

## 🚀 Быстрый старт

```lua
local DiscordWebhook = require(путь.к.модулю)

local webhook = DiscordWebhook.new("https://discord.com/api/webhooks/ваш_вебхук")
webhook:send("Привет из Roblox!")
```

## 🔧 Основные функции

### 📨 Отправка сообщений
```lua
webhook:send("Текст сообщения", {
    username = "Мой Бот",  -- необязательно
    avatar_url = "URL"      -- необязательно
})
```

### 🎨 Встроенные сообщения (Embeds)
```lua
webhook:sendEmbed({
    title = "Заголовок",
    description = "Описание",
    color = 0xFF0000,  -- красный
    fields = {
        {name = "Поле 1", value = "Значение 1", inline = true},
        {name = "Поле 2", value = "Значение 2"}
    }
})
```

## ⚙️ Дополнительные возможности

### 🔄 Безопасная отправка
```lua
local success, err = webhook:trySend("Тест")
if not success then
    warn("Ошибка:", err)
end
```

### 🎨 Цвета для Embeds
- 🔴 Красный: `0xFF0000`
- 🟢 Зеленый: `0x00FF00`
- 🔵 Синий: `0x0000FF`

## 💡 Пример использования
```lua
game.Players.PlayerAdded:Connect(function(player)
    webhook:sendEmbed({
        title = "Новый игрок!",
        description = player.Name .. " присоединился",
        color = 0x00FF00,
        fields = {
            {name = "ID", value = player.UserId}
        }
    })
end)
```

## 📜 Лицензия
MIT License - свободное использование
