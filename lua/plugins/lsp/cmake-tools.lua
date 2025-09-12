return {
  {
    'Civitasv/cmake-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('cmake-tools').setup {
        cmake_runner = { -- runner to use
          name = 'terminal', -- name of the runner
          opts = {}, -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
          default_opts = { -- a list of default and possible values for runners
            quickfix = {
              show = 'always', -- "always", "only_on_error"
              position = 'belowright', -- "bottom", "top"
              size = 10,
              encoding = 'utf-8',
              auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
            },
            toggleterm = {
              direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
              close_on_exit = false, -- whether close the terminal when exit
              auto_scroll = true, -- whether auto scroll to the bottom
              singleton = true, -- single instance, autocloses the opened one, if present
            },
            overseer = {
              new_task_opts = {
                strategy = {
                  'toggleterm',
                  direction = 'horizontal',
                  autos_croll = true,
                  quit_on_exit = 'success',
                },
              }, -- options to pass into the `overseer.new_task` command
              on_new_task = function(task) end, -- a function that gets overseer.Task when it is created, before calling `task:start`
            },
            terminal = {
              name = 'Main Terminal',
              prefix_name = '[CMakeTools]: ', -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
              split_direction = 'horizontal', -- "horizontal", "vertical"
              split_size = 11,

              -- Window handling
              single_terminal_per_instance = true, -- Single viewport, multiple windows
              single_terminal_per_tab = true, -- Single viewport per tab
              keep_terminal_static_location = true, -- Static location of the viewport if avialable
              auto_resize = true, -- Resize the terminal if it already exists

              -- Running Tasks
              start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
              focus = false, -- Focus on terminal when cmake task is launched.
              do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
            },
          },
        },
      }
    end,
  },
}

-- return {
--   {
--     'ilyachur/cmake4vim',
--     dependencies = { 'SantinoKeupp/telescope-cmake4vim.nvim' },
--   },
-- }
