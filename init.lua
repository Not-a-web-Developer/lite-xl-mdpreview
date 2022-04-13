-- mod-version:2 -- lite-xl 2.0
-- change the mod version to 3 and lite-xl to 2.1 for compatibility with nightly releases

local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local md = require "plugins.mdpreview.md"

-- the thing to be inserted before the rendered html

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
<link rel="stylesheet" href="]]..github_css:gsub("\\", "/")..[[">
<title>{{title}}</title>
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

--local htmlFragment = md.render([[
--  # Hello
--  Let's try this and see how this goes
--  
--  > all the problems we have with websites are ones we create ourselves. Websites aren't broken by default, they are functional, high-performing, and accessible.
--]])


command.add("core.docview", {
  ["mdpreview:show-preview"] = function()
  
    -- getting the markdown material
    local dv = core.active_view
    local mdSource = dv.doc:get_text(1, 1, math.huge, math.huge)
    local realhtmlStart = htmlStart:gsub("{{title}}", dv:get_name() .. " preview")
    -- rendering the markdown into html
    local htmlFragment, err = md.render(mdSource)
    if not htmlFragment then
      core.error("mdpreview has a problem with your markdown file! details are as follows: " .. err)
      return
    end
    
    -- writing the html content to a temporary file
    
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
    
    -- deleting the temporary file

    core.add_thread(function()
      coroutine.yield(5)
      os.remove(htmlfile)
    end)
  end
})

keymap.add {
  ["ctrl+shift+v"] = "mdpreview:show-preview",
}

-- core.log("this plugin works!")
