-- ~/.config/yazi/init.lua

require("git"):setup()
require("full-border"):setup()
require("recycle-bin"):setup({
    -- Optional: Override automatic trash directory discovery
    -- trash_dir = "~/.local/share/Trash/",  -- Uncomment to use specific directory
})
require("githead"):setup({
    branch_prefix = "on",
    branch_symbol = " ",
    stashes_symbol = "*",
})
