local system_prompt = string.format(
  [[
# You are a DevOps assistant with access to tools that helps with executing various tasks.
The user is called Fred.
When asked for your name, you must respond with "Serge Faute".
You are Fred's intern.
Follow the user's requirements carefully & to the letter.
Avoid content that violates copyrights.
The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
The user is working on a %s machine. Please respond with system specific commands if applicable.
You will receive code snippets that include line number prefixes - use these to maintain correct position references but remove them when generating output.

# When presenting code changes:

1. For each change, first provide a header outside code blocks with format:
   [file:<file_name>](<file_path>) line:<start_line>-<end_line>
2. Then wrap the actual code in triple backticks with the appropriate language identifier.
3. Keep changes minimal and focused to produce short diffs.
4. Include complete replacement code for the specified line range with:
   - Proper indentation matching the source
   - All necessary lines (no eliding with comments)
   - No line number prefixes in the code
5. Address any diagnostics issues when fixing code.
6. If multiple changes are needed, present them as separate blocks with their own headers.

# You will be provided with specific task instructions

1. Stay terse, unless asked for explanations
2. Do not halucinate answers, if you don't know, say so
3. Avoid infinite loops or redundant operations
4. Prefer using search and replace instead of writting a file
]], vim.uv.os_uname().sysname)

return {
  vim.env.CHAT_FORK and {
    "CopilotChatFork",
    dir = vim.env.CHAT_FORK,
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    config = function()
      local CopilotChat = require 'CopilotChat'
      CopilotChat.setup({
        auto_follow_cursor = false,
        debug = true,
        question_header = "# 🙋 Fred the human (fork) ",
        answer_header = "# 🤖 Serge Faute (Fred's intern) ",
        show_help = false,
        prompts = {
          SergeFaute = {
            system_prompt = system_prompt,
            description = [[ Fred's intern, supports tool calling ]],
          }
        },
        sticky = {
          '$gemini-2.0-flash-001',
          '/SergeFaute',
          'What is the latest version of the actions/checkout github action?'
        },
      })

      vim.keymap.set({ 'n', 'v' }, '<leader>cc', function() CopilotChat.open() end, { desc = "Open CopilotChat" })
      vim.keymap.set({ 'v' }, '<leader>ce', ':CopilotChatExplain<CR>',
        { desc = "Ask Copilot to explain the selected lines" })
    end,
  } or {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    tag = "v3.9.1",
    config = function()
      local CopilotChat = require 'CopilotChat'
      CopilotChat.setup({
        auto_follow_cursor = true,
        debug = false,
        question_header = "# 🙋 Fred the human ",
        answer_header = "# 🤖 Serge Faute (Fred's intern) ",
        model = "gpt-4o-2024-11-20",
        show_help = false,
        prompts = {
          SergeFaute = {
            system_prompt = system_prompt,
            description = [[ Fred's intern, supports tool calling ]],
          }
        },

        -- sticky = {
        --   '$gemini-2.0-flash-001',
        --   '/SergeFaute',
        --   'What is the latest version of the actions/checkout github action?'
        -- },
      })

      vim.keymap.set({ 'n', 'v' }, '<leader>cc', function() CopilotChat.open() end, { desc = "Open CopilotChat" })
      vim.keymap.set({ 'v' }, '<leader>ce', ':CopilotChatExplain<CR>',
        { desc = "Ask Copilot to explain the selected lines" })
    end,
  }
}
