if vim.b.did_ftplugin then
    return
end
vim.b.did_ftplugin = true

-- See |diagnostic-quickstart|
local nsid = vim.api.nvim_create_namespace("typst_spellcheck")
--- @type vim.diagnostic.Opts
local diagnostic_opts = {
    float = true,
    signs = true,
    underline = true,
    virtual_text = false,
    update_in_insert = false,
    severity_sort = true,
}
vim.diagnostic.config(diagnostic_opts, nsid)

-- Generate and set diagnostics regularly
vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinEnter" }, {
    pattern = { "*.typ" },
    desc = "check spelling for typst documents",
    callback = vim.schedule_wrap(function(cb_obj)
        local bufnr = cb_obj.buf or vim.fn.bufnr("%")
        local filename = cb_obj.file or vim.api.nvim_buf_get_name(bufnr)

        --- @param exit vim.SystemCompleted
        local on_exit = function(exit)
            -- exit 1 means we found spelling mistakes
            if exit.code > 1 or exit.signal ~= 0 then
                local reason = nil
                if exit.code ~= 0 then
                    reason = "exit code " .. tostring(exit.code)
                else
                    reason = "signal " .. tostring(exit.signal)
                end
                vim.notify(
                    "spellcheck exited with " .. reason .. ":\n" .. exit.stderr,
                    vim.log.levels.ERROR,
                    {}
                )
                return
            end

            if exit.stderr ~= "" then
                if exit.stderr:match("Error: Found %d+ files with bad spelling") then
                    -- This is ok
                else
                    vim.notify(
                        "spellcheck reported error:\n" .. exit.stderr,
                        vim.log.levels.WARNING,
                        {}
                    )
                end
            end

            local state = "scanning"
            --- @type vim.Diagnostic[]
            local all_diagnostics = {}
            --- @type vim.Diagnostic?
            local current_diagnostic = nil
            --- @type string
            for line in exit.stdout:gmatch("([^\n]*)\n") do
                -- strip pesky ANSI escape sequences
                line = line:gsub("%\x1B%[[0-9;]+m", "")
                ::_RESTART::
                if state == "scanning" then
                    local lnum, col, end_lnum, end_col, word = line:match(
                        "^(%d+):(%d+)--(%d+):(%d+): Possibly bad word '(.+)'$")
                    if lnum then
                        current_diagnostic = {
                            namespace = nsid,
                            source = "spelling",
                            severity = vim.diagnostic.severity.WARN,
                            bufnr = bufnr,
                            lnum = tonumber(lnum) - 1,
                            col = tonumber(col) - 1,
                            end_lnum = tonumber(end_lnum) - 1,
                            end_col = tonumber(end_col) - 1,
                            message = "Bad word '" .. word .. "'"
                        }
                        state = "awaiting_suggestions"
                    end
                elseif state == "awaiting_suggestions" then
                    local new_line = line:match("^(%d+):(%d+)--(%d+):(%d+): Suggestions:")
                    if new_line then
                        -- Sanity check
                        local diagnostic = current_diagnostic or {}
                        local current_line = diagnostic.lnum or -1
                        if tonumber(new_line) - 1 ~= current_line then
                            vim.notify_once(
                                "diagnostic mismatch: started with line " ..
                                tostring(current_line) .. " and continued with line " ..
                                tostring(new_line - 1),
                                vim.log.levels.ERROR,
                                {}
                            )
                            state = "scanning"
                        else
                            state = "collecting_suggestions"
                            current_diagnostic.message = (diagnostic.message or "") ..
                                "\n\nDid you mean:\n"
                        end
                    end
                elseif state == "collecting_suggestions" then
                    local word = line:match("^ - (.+)$")
                    if word then
                        local message = (current_diagnostic or {}).message or ""
                        current_diagnostic.message = message .. word .. "\n"
                    else
                        -- Finish the diagnostic
                        table.insert(all_diagnostics, current_diagnostic)
                        current_diagnostic = nil
                        state = "scanning"
                        goto _RESTART
                    end
                else
                    -- FIXME(hartan): Invalid state
                end
            end

            -- Can't set diagnostics from regular callback
            vim.schedule(function()
                vim.diagnostic.set(nsid, bufnr, all_diagnostics)
            end)
        end

        --- @type vim.SystemObj
        vim.system(
            { "spelling", "-p", "dictionary.txt", "spell", filename },
            {
                text = true,
                detach = false,
            },
            on_exit
        )
        -- Reset diagnostics while we wait to at least indicate we're waiting.
        vim.diagnostic.reset(nsid, bufnr)
    end)
})
