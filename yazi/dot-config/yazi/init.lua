-- ~/.config/yazi/init.lua

th.git                = th.git or {}

-- letters instead of icons
th.git.modified_sign  = "M"
th.git.added_sign     = "A"
th.git.untracked_sign = "U"
th.git.ignored_sign   = "I"
th.git.deleted_sign   = "D"
th.git.updated_sign   = "S" -- or "U" if you prefer; many use "R" for updated

-- colors / emphasis (adjust to taste)
th.git.modified       = ui.Style():fg("blue")
th.git.added          = ui.Style():fg("green")
th.git.untracked      = ui.Style():fg("yellow")
th.git.ignored        = ui.Style():fg("gray")
th.git.deleted        = ui.Style():fg("red"):bold()
th.git.updated        = ui.Style():fg("cyan")

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
