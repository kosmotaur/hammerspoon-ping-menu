local pingMenubar = hs.menubar.new()
local function splitByNewline(str)
  local t = {}
  local function helper(line) table.insert(t, line) return '' end
  helper((str:gsub('(.-)\n', helper)))
  return t
end
local host = 'bbc.co.uk'
local function askForHost()
  local dialogAS = [[
    set hostname to text returned of (display dialog "Hostname" default answer "%s" buttons {"OK", "Cancel"} default button 1 with icon note)
    return hostname
  ]]
  return hs.osascript.applescript(string.format(dialogAS, host))
end
local function updateMenubar(summary)
  local avg = summary:match('%/(%d+)%.%d+%/')
  local splitSummary = splitByNewline(summary)
  local menu = {
    {
      title = 'Change host',
      fn = function()
        filled,answer = askForHost()
        if filled then
          host = answer
        end
      end
    }
  }

  for i, v in ipairs(splitSummary) do
    table.insert(menu, {
      title = v,
      disabled = true,
      indent = 2
    })
  end

  pingMenubar:setMenu(menu)
  pingMenubar:setTitle(avg..'ms')
end
local function measurePing()
  local p = hs.network.ping(host, 10, 0.5, 5, 'any', function(pingObj, message)
    if message == 'didFinish' then
      updateMenubar(pingObj:summary())
      measurePing()
    end
  end)
end
local function setIcon()
  local icon = hs.image.imageFromPath(os.getenv('HOME') .. '/.hammerspoon/hammerspoon-ping-menu/ping.png'):setSize({w=16,h=16})

  pingMenubar:setIcon(icon)
end
local function initMenubar()
  setIcon()
  pingMenubar:setMenu({
    {
      title = 'measuring ping',
      disabled = true
    }
  })
end

initMenubar()
measurePing()
