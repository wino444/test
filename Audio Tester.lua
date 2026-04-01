-- ============================================
-- EclipseLib Audio Tester
-- ทดสอบเล่นเสียงจาก asset ID ที่ค้นพบ
-- ============================================

-- โหลด EclipseLib
local EclipseLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/wino444/EclipseLib/main/Library%20ui.lua"
))()

-- สร้างหน้าต่างหลัก
local Win = EclipseLib:CreateWindow({
    Name             = "🎵 Audio Tester",
    LoadingTitle     = "🎧 ระบบเสียง",
    LoadingSubtitle  = "กำลังโหลดชุดทดสอบ...",
    ConfigurationSaving = {
        FolderName = "AudioTester"
    },
})

-- สร้างแท็บหลัก
local Tab = Win:CreateTab({
    Name = "🎶 เล่นเสียง",
    Icon = "🎵"
})

-- สร้างแท็บสำหรับข้อมูล
local InfoTab = Win:CreateTab({
    Name = "ℹ️ ข้อมูล",
    Icon = "📋"
})

-- เก็บ Sound object ของแต่ละ ID
local activeSounds = {}

-- ฟังก์ชันเล่นเสียง
local function playSound(id, volume)
    -- ถ้ามีเสียงนี้กำลังเล่นอยู่ ให้หยุดก่อน
    if activeSounds[id] then
        activeSounds[id]:Stop()
        activeSounds[id]:Destroy()
        activeSounds[id] = nil
    end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = volume or 0.5
    sound.Parent = workspace
    sound:Play()
    
    activeSounds[id] = sound
    
    -- เมื่อเสียงจบ ให้ลบออกจากตาราง
    sound.Ended:Connect(function()
        if activeSounds[id] == sound then
            activeSounds[id] = nil
        end
        sound:Destroy()
    end)
    
    return sound
end

-- ฟังก์ชันหยุดเสียง
local function stopSound(id)
    if activeSounds[id] then
        activeSounds[id]:Stop()
        activeSounds[id]:Destroy()
        activeSounds[id] = nil
        return true
    end
    return false
end

-- ฟังก์ชันหยุดทุกเสียง
local function stopAllSounds()
    for id, sound in pairs(activeSounds) do
        sound:Stop()
        sound:Destroy()
        activeSounds[id] = nil
    end
end

-- รายการเสียงทั้งหมด
local audioList = {
    {id = 114870502995953, name = "🚫 กันดักเพลงโดย 412 (กับดัก)", isTrap = true},
    {id = 140497415402103, name = "🌌 Celestial Reverie"},
    {id = 129569049476734, name = "🌙 Noite de uma lembrança"},
    {id = 137434811238124, name = "🌸 Harmonious Stillness"},
    {id = 112052998244603, name = "😊 MY LITTLE HAPPYNESS"},
    {id = 137555839480738, name = "❄️ Snow Outside The Window"},
    {id = 115819698454027, name = "💖 Dil Tum"},
    {id = 97254689160075, name = "🎶 Mryam Sablaxi"},
    {id = 101631982347841, name = "🔥 Das Feuerzeug"},
    {id = 122396455391746, name = "💭 Am I in a Dream"},
    {id = 72034120547897, name = "💔 Bewafai Ka Qissa"},
    {id = 97167526395722, name = "🌜 MOON FUNK"},
}

-- ส่วนหัวของ UI
Tab:AddSection({ Name = "🎛️ ควบคุมหลัก" })

-- ปุ่มหยุดทั้งหมด
Tab:AddButton({
    Name = "⏹️ หยุดเสียงทั้งหมด",
    Description = "หยุดทุกเสียงที่กำลังเล่น",
    Callback = function()
        stopAllSounds()
        EclipseLib:Notify({
            Title = "⏹️ หยุดทั้งหมด",
            Content = "หยุดเสียงทั้งหมดเรียบร้อย",
            Duration = 2,
            Type = "info"
        })
    end
})

-- ตัวเลื่อนระดับเสียงหลัก
local volumeSlider = Tab:AddSlider({
    Name = "🔊 ระดับเสียงหลัก",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Decimal = 2,
    ConfigKey = "MasterVolume",
    Callback = function(value)
        -- อัปเดต Volume ให้กับเสียงที่กำลังเล่นอยู่
        for _, sound in pairs(activeSounds) do
            sound.Volume = value
        end
    end
})

Tab:AddSection({ Name = "🎵 รายการเสียง" })

-- สร้างแต่ละเพลง
for _, audio in ipairs(audioList) do
    -- ใช้ Section แยกแต่ละเพลง
    Tab:AddSection({ Name = audio.name })
    
    -- แสดง ID
    Tab:AddLabel({ Text = "🆔 ID: " .. audio.id })
    
    -- แถวปุ่ม (แต่ EclipseLib ไม่มี Row layout เราจะใช้ปุ่มแยกกัน)
    Tab:AddButton({
        Name = "▶️ เล่น",
        Description = "เล่นเพลงนี้",
        Callback = function()
            local vol = volumeSlider:GetValue()
            playSound(audio.id, vol)
            EclipseLib:Notify({
                Title = "▶️ กำลังเล่น",
                Content = audio.name,
                Duration = 2,
                Type = "success"
            })
        end
    })
    
    Tab:AddButton({
        Name = "⏹️ หยุด",
        Description = "หยุดเพลงนี้",
        Callback = function()
            if stopSound(audio.id) then
                EclipseLib:Notify({
                    Title = "⏹️ หยุดแล้ว",
                    Content = audio.name,
                    Duration = 1,
                    Type = "info"
                })
            else
                EclipseLib:Notify({
                    Title = "⚠️ ไม่มีเสียง",
                    Content = audio.name .. " กำลังเล่นอยู่",
                    Duration = 1,
                    Type = "warn"
                })
            end
        end
    })
end

-- แท็บข้อมูล
InfoTab:AddSection({ Name = "📖 เกี่ยวกับ" })
InfoTab:AddParagraph({
    Title = "🎧 Audio Tester",
    Content = [[
UI นี้ใช้สำหรับทดสอบเล่นเสียงจาก Asset ID ที่ค้นพบในไฟล์ 191.lua

รายการเสียงทั้งหมด 12 รายการ:
- กันดักเพลง... (กับดักที่ตั้งใจให้เห็น)
- Celestial Reverie
- Noite de uma lembrança
- Harmonious Stillness
- MY LITTLE HAPPYNESS
- Snow Outside The Window
- Dil Tum
- Mryam Sablaxi
- Das Feuerzeug
- Am I in a Dream
- Bewafai Ka Qissa
- MOON FUNK

💡 วิธีใช้:
- กด "เล่น" เพื่อฟังเสียง
- กด "หยุด" เพื่อหยุดเฉพาะเสียงนั้น
- ปุ่ม "หยุดทั้งหมด" เพื่อหยุดทุกเสียง
- ปรับ "ระดับเสียงหลัก" เพื่อควบคุมเสียงทั้งหมด

⚠️ หมายเหตุ:
- เสียง "กันดักเพลง..." เป็นกับดักที่ผู้สร้างไฟล์ตั้งใจใส่ไว้
- หากเสียงใดไม่เล่น อาจเป็นเพราะเกมบล็อกการเล่นเสียงจาก Script
- ควรอยู่ในเกมที่อนุญาตให้สร้าง Sound ใน Workspace ได้
    ]]
})

InfoTab:AddSection({ Name = "🔗 ลิงก์" })
InfoTab:AddButton({
    Name = "🔍 เปิด ID ในเบราว์เซอร์",
    Description = "เลือก ID ที่ต้องการเปิด",
    Callback = function()
        -- สร้าง Dropdown ให้เลือก ID
        local options = {}
        for _, a in ipairs(audioList) do
            table.insert(options, tostring(a.id) .. " - " .. a.name)
        end
        local dropdown = InfoTab:AddDropdown({
            Name = "เลือก ID",
            Options = options,
            Callback = function(selected)
                local id = selected:match("^(%d+)")
                if id then
                    setclipboard("https://create.roblox.com/store/asset/" .. id)
                    EclipseLib:Notify({
                        Title = "📋 คัดลอกลิงก์แล้ว",
                        Content = "https://create.roblox.com/store/asset/" .. id,
                        Duration = 3,
                        Type = "info"
                    })
                end
            end
        })
        -- แสดง dropdown (EclipseLib ไม่มีฟังก์ชันเปิดทันที ต้องให้ผู้ใช้เลือก)
        EclipseLib:Notify({
            Title = "🔽 เลือก ID",
            Content = "Dropdown ปรากฏในแท็บข้อมูลแล้ว",
            Duration = 2,
            Type = "info"
        })
    end
})

-- แจ้งเตือนสำเร็จ
EclipseLib:Notify({
    Title = "✅ โหลดสำเร็จ",
    Content = "UI พร้อมใช้งานแล้ว",
    Duration = 3,
    Type = "success"
})
