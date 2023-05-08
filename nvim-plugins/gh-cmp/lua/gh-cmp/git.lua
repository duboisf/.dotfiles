local git = {}

local Job = require("plenary.job")

--- Get the remote URL for the `origin` remote.
---@param remote string The remote name.
---@param callback fun(remote: string)
---@return nil
function git.remote(remote, callback)
  Job:new({
    "git",
    "remote",
    "get-url",
    "--push",
    remote,
    on_exit = function(job, exit_code)
      if exit_code == 0 then
        callback(job:result()[1])
      end
    end,
  }):start()
end

return git
