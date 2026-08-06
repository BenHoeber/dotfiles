local count = ya.sync(function()
    return #cx.tabs
end)

local function quit(no_cwd)
    if no_cwd then
        ya.emit("quit", { no_cwd_file = true })
    else
        ya.emit("quit", {})
    end
end

local function entry(_, job)
    -- `entry_cwd` means: exit without changing the shell directory
    local no_cwd = job.args[1] == "entry_cwd"

    if count() < 2 then
        return quit(no_cwd)
    end

    local yes = ya.confirm({
        pos = { "center", w = 62, h = 10 },
        title = "Quit?",
        body = ui.Text(
            "There are multiple tabs open. Are you sure you want to quit?"
        ):wrap(ui.Wrap.YES),
    })

    if yes then
        quit(no_cwd)
    end
end

return { entry = entry }
