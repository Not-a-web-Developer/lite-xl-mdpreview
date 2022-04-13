-- mod-version:2 -- lite-xl 2.0
-- change the mod version to 3 and lite-xl to 2.1 for compatibility with nightly releases

local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require 'core.common'
local config = require 'core.config'

config.plugins.mdpreview = common.merge({
  pandoc_path = "pandoc"
}, config.plugins.mdpreview)

local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local github_css = "file://" .. script_path() .. "github-markdown.css"

 local htmlStart = [[
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{title}}</title>
<link rel="stylesheet" href="]]..github_css:gsub("\\", "/")..[[">
<style>
    .markdown-body {
        box-sizing: border-box;
        min-width: 200px;
        max-width: 980px;
        margin: 0 auto;
        padding: 45px;
    }

    @media (max-width: 767px) {
        .markdown-body {
            padding: 15px;
        }
    }
</style>
</head>
<body class="markdown-body">

]]

local htmlEnd = [[
</body>
</html>
]]

--[[local mdSource = [[
# Hello
Let's try this and see how this goes
  
> all the problems we have with websites are ones we create ourselves. Websites aren't broken by default, they are functional, high-performing, and accessible.

]]

command.add("core.docview", {
  ["mdpreview:show-preview"] = function()
  
    
    
    local dv = core.active_view
    local mdSource = dv.doc:get_text(1, 1, math.huge, math.huge)
    local realhtmlStart = htmlStart:gsub("{{title}}", dv:get_name() .. " preview")
    
    -- Making a file out of the markdown material    
    
    local inputfile = core.temp_filename(".md")
    local fp = io.open(inputfile, "w")
    print(mdSource)
    fp:write(mdSource)
    fp:close()
    
    -- the actual conversion to html
    
    local handle = io.popen(string.format("%s %s %q", config.plugins.mdpreview.pandoc_path, "-f gfm -t html", inputfile))
    local htmlFragment = handle:read("*a")
    print(htmlFragment)
    handle:close()
    
    -- deleting the temporary input file
     
    core.add_thread(function()
      coroutine.yield(5)
      os.remove(inputfile)
    end)
    
    -- writing the output to a temporary html file
    
    local htmlfile = core.temp_filename(".html")
    local fp = io.open(htmlfile, "w")
    fp:write(realhtmlStart)
    fp:write(htmlFragment)
    fp:write(htmlEnd)
    fp:close()
    
    -- opening markdown preview (duh)

    core.log("Opening markdown preview...")
    if PLATFORM == "Windows" then
      system.exec("start " .. htmlfile)
    else
      system.exec(string.format("xdg-open %q", htmlfile))
    end
    
    -- deleting the temporary html file

    core.add_thread(function()
      coroutine.yield(5)
      os.remove(htmlfile)
    end)
  end
})

keymap.add {
  ["ctrl+shift+v"] = "mdpreview:show-preview",
}
