-- mod-version:3 -- lite-xl 2.1
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local md = require "plugins.mdpreview.md"

local htmlStart = [[
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.1.0/github-markdown.min.css">
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
<article class="markdown-body">

]]

--local htmlFragment = md.render([[
--  # Hello
--  Let's try this and see how this goes
--  
--  > all the problems we have with websites are ones we create ourselves. Websites aren't broken by default, they are functional, high-performing, and accessible.
--]])


command.add("core.docview", {
  ["mdpreview:show-preview"] = function()
    local dv = core.active_view
    local mdSource = dv.doc:get_text(1, 1, math.huge, math.huge)
    local htmlFragment, err = md.render(mdSource)
    if not htmlFragment then
      core.error("mdpreview has a problem with your markdown file! details are as follows: " .. err)
      return
    end
    
    local htmlfile = core.temp_filename(".html")
    local fp = io.open(htmlfile, "w")
    fp:write(htmlStart)
    fp:write(htmlFragment)
    fp:close()

    core.log("Opening markdown preview...")
    if PLATFORM == "Windows" then
      system.exec("start " .. htmlfile)
    else
      system.exec(string.format("xdg-open %q", htmlfile))
    end

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
