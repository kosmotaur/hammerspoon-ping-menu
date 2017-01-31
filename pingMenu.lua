local pingMenubar = hs.menubar.new()
local function splitByNewline(str)
  local t = {}
  local function helper(line) table.insert(t, line) return '' end
  helper((str:gsub('(.-)\n', helper)))
  return t
end
local function updatePing()
  local p = hs.network.ping('bbc.co.uk')
  hs.timer.doAfter(5, function()
      p:cancel()
      local summary = p:summary()
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
    end)
end

pingMenubar:setTitle('ping')
hs.timer.doEvery(5, updatePing)
updatePing()
