return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
            vim.keymap.set("n", "<leader>m", ":Mason<cr>", {})
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            local mason_lspconfig = require("mason-lspconfig")
            local lspconfig = require("lspconfig")
            local home = os.getenv("HOME")

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            capabilities.offsetEncoding = { "utf-16" }

            mason_lspconfig.setup({
                ensure_installed = { "lua_ls", "ts_ls", "clangd", "cssls" },

                handlers = {
                    -- 1. Default handler for all servers not listed below
                    function(server_name)
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,

                    -- 2. Empty handler — clangd is configured manually below
                    ["clangd"] = function() end,

                    -- 3. Arduino
                    ["arduino_language_server"] = function()
                        if vim.fn.executable("arduino-language-server") == 1 then
                            lspconfig.arduino_language_server.setup({
                                capabilities = capabilities,
                                cmd = {
                                    "arduino-language-server",
                                    "-cli-config", home .. "/.arduino15/arduino-cli.yaml",
                                    "-fqbn", "arduino:avr:uno",
                                    "-cli", "arduino-cli",
                                    "-clangd", "clangd",
                                    "-log"
                                },
                                filetypes = { "arduino" }
                            })
                        end
                    end,
                }
            })

            -- ================================================================
            -- CLANGD — configured after mason_lspconfig.setup() so our config
            -- wins over lspconfig built-in defaults.
            --
            -- IMPORTANT: vim.lsp.config() (Neovim 0.11+ native API) requires
            -- root_markers (a plain list), NOT a root_dir function. Using a
            -- function causes clangd to never start because the native API
            -- silently ignores it.
            --
            -- For ESP-IDF projects, create a .clangd file in your project root:
            --
            --   CompileFlags:
            --     CompilationDatabase: build
            --
            -- ================================================================
            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--fallback-style=llvm",
                    "--query-driver=/usr/bin/clang++,/usr/bin/g++,/usr/bin/gcc,/usr/bin/*,"
                        .. home .. "/.espressif/tools/xtensa-esp-elf/*/bin/*,"
                        .. home .. "/.espressif/tools/riscv32-esp-elf/*/bin/*",
                },
                capabilities = capabilities,
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
                -- root_markers: clangd will walk up from the current file and
                -- use the directory containing the first match as the project root.
                -- sdkconfig and sdkconfig.defaults are listed first so ESP-IDF
                -- projects are rooted at the correct location.
                root_markers = {
                    "sdkconfig",
                    "sdkconfig.defaults",
                    ".clangd",
                    ".clang-tidy",
                    ".clang-format",
                    "compile_commands.json",
                    "compile_flags.txt",
                    ".git",
                },
            })
            vim.lsp.enable("clangd")

            -- =================================================================
            -- KEYMAPS & DIAGNOSTICS
            -- =================================================================
            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
            vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
            vim.keymap.set("n", "]e", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
            vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Show Diagnostic" })

            vim.diagnostic.config({
                virtual_text = {
                    filter = function(diagnostic)
                        if string.find(diagnostic.message, "using_decl_conflict") then return false end
                        if string.find(diagnostic.message, "declaration conflicts with target") then return false end
                        return true
                    end
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })
        end,
    },

    {
        "https://gitlab.com/schrieveslaach/sonarlint.nvim",
        ft = { "python", "typescript", "typescriptreact", "typescript.tsx" },
        dependencies = { "mfussenegger/nvim-jdtls" },
        config = function()
            local home = os.getenv("HOME")
            local sonar_path = home .. "/.config/nvim/sonarlint/"
            if vim.fn.isdirectory(sonar_path) == 1 then
                require("sonarlint").setup({
                    server = {
                        cmd = {
                            "java", "-cp", sonar_path .. "*", "-jar", sonar_path .. "sonarlint-server.jar",
                            "-stdio", "-analyzers", sonar_path .. "sonarpython.jar", sonar_path .. "sonarjs.jar",
                        },
                    },
                    filetypes = { "python", "typescript", "typescriptreact" },
                })
            end
        end,
    },
}
