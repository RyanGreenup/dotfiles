local create_ollama_config = function(host, model)
  return {
    __inherited_from = "openai",
    api_key_name = "",
    endpoint = string.format("http://%s:11434/v1", host),
    model = model,
    max_tokens = 4096,
  }
end


return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    auto_suggestions_provider = "qwen",
    provider = "qwen",
    providers = {
      openai = {
        model = "o1-preview",
      },
      ---@type AvanteProvider
      qwen = create_ollama_config("vale", "qwen2.5:32b"),
      qwen16 = create_ollama_config("vale", "ai_tools/qwen2.5-coder:32b__16384"),
      qwen8 = create_ollama_config("vale", "ai_tools/qwen2.5-coder:32b__8192"),
      codestral = create_ollama_config("vale", "codestral"),
      commandR = create_ollama_config("vale", "command-r"),
      yi = create_ollama_config("vale", "yi:34b"),
      ---@type AvanteProvider
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-20241022",
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
        },
      },
      gpt4o = {
        endpoint = "https://api.openai.com/v1",
        model = "o1",
        timeout = 30000,
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
          reasoning_effort = "high" -- only supported for reasoning models (o1, etc.)
        }
      },
      o1 = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        timeout = 30000,
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
        },
      },
      r1 = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-reasoner",
      },
      deepseek = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-coder",
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua",      -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
