local pingMenubar = hs.menubar.new()
local function splitByNewline(str)
  local t = {}
  local function helper(line) table.insert(t, line) return '' end
  helper((str:gsub('(.-)\n', helper)))
  return t
end
local function updateMenubar(summary)
  local avg = summary:match('%/(%d+)%.%d+%/')
  local splitSummary = splitByNewline(summary)
  local menu = {}

  for i, v in ipairs(splitSummary) do
    table.insert(menu, {
      title = v,
      disabled = true
    })
  end

  pingMenubar:setMenu(menu)
  pingMenubar:setTitle(avg..'ms')
end
local function measurePing()
  local p = hs.network.ping('bbc.co.uk', 10, 0.5, 5.0, 'any', function(pingObj, message)
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

setIcon()
pingMenubar:setMenu({
  {
    title = 'measuring ping',
    disabled = true
  }
})

measurePing()
