local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/stavratum/ULA/main/ULA.lua"))()

local function Load()
  Library:Init()

  Library:AddToggle {
    Text = "Toggle",
    Flag = "MyToggle",
    Value = false,
    
    Callback = print,
    Arguments = {"Toggle"}
  }

  Library:AddSlider {
    Text = "Slider",
    Flag = "MySlider",
    Value = 0,
    
    Callback = print,
    Arguments = {"Slider"}
  }
  
  Library:AddKeybind {
    Text = "Keybind",
    Flag = "MyKeybind",
    Value = Enum.KeyCode.Space,
    
    Callback = print,
    Arguments = {"Keybind"}
  }
  
  return tick()
end

local Elapsed = tick() - Load()
print(string.format("[%s] Loaded in %.2f seconds", -Elapsed))
