return {
  "robitx/gp.nvim",
  config = function()
    local code_model = "qwen2.5-coder:14b"
    local chat_model = "deepseek-r1:14b"

    local conf = {
      default_provider = "ollama",
      default_command_agent = code_model,
      default_chat_agent = code_model,
      command_prompt_prefix_template = "Prompt:",
      chat_confirm_delete = false,

      providers = {
        ollama = {
          disable = false,
          endpoint = "http://localhost:11434/v1/chat/completions",
        },
      },
      agents = {
        {
          provider = "ollama",
          name = code_model,
          chat = false,
          command = true,
          model = code_model,
          system_prompt = "You are a general AI coding assistant. You will only output code. No explanations, comments or reasoning",
        },
        {
          provider = "ollama",
          name = chat_model,
          chat = true,
          command = false,
          model = chat_model,
          system_prompt = "You are a helpful AI assistant specialized in explaining and working with code.",
        },
      },
      hooks = {
        BufferChatNew = function(gp, _)
          -- call GpChatNew command in range mode on whole buffer
          vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatToggle popup")
        end,
        -- example of adding command which writes unit tests for the selected code
        UnitTests = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by giving me the code for appropriate unit tests."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.vnew, agent, template)
        end,
      },
    }
    require("gp").setup(conf)

    vim.keymap.set("n", "<leader>aa", "<cmd>GpChatToggle vsplit<cr>")
    vim.keymap.set("v", "<leader>ae", ":<C-u>'<,'>GpRewrite<cr>")
    vim.keymap.set("n", "<leader>ad", "<cmd>GpChatDelete<cr>")
  end,
}
