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
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "ts_ls", "clangd", "cssls" },
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})

			lspconfig.cssls.setup({
				capabilities = capabilities,
			})

			-- Function to detect project type
			local function is_esp_project()
				local cwd = vim.fn.getcwd()
				local indicators = {
					"sdkconfig",
					"sdkconfig.defaults", 
					"main/main.c",
					"main/main.cpp",
					"components"
				}
				for _, indicator in ipairs(indicators) do
					if vim.fn.filereadable(cwd .. "/" .. indicator) == 1 or vim.fn.isdirectory(cwd .. "/" .. indicator) == 1 then
						return true
					end
				end
				return false
			end

			-- ESP32 specific clangd configuration or standard C/C++ clangd
			local esp32_ok, esp32 = pcall(require, "esp32")
			if esp32_ok and is_esp_project() then
				-- Use ESP32 configuration for ESP projects
				lspconfig.clangd.setup(esp32.lsp_config())
			else
				-- Standard C/C++ clangd configuration with conflict resolution
				lspconfig.clangd.setup({
					capabilities = capabilities,
					cmd = {
						vim.fn.expand("~/.local/share/nvim/mason/bin/clangd"), -- Use Mason's clangd
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
						"--query-driver=/usr/bin/c,/usr/bin/c++,/usr/bin/clang,/usr/bin/clang++,/opt/homebrew/bin/gcc,/opt/homebrew/bin/g++",
						"--enable-config", -- Enable .clangd config files
						"--offset-encoding=utf-16", -- Better compatibility
					},
					init_options = {
						useLSPDiagnostics = false, -- Let clangd handle diagnostics
						clangdFileStatus = true,
						-- Don't use fallback flags - let clangd detect language from file extension
					},
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "arduino" },
					root_dir = function(fname)
						return require('lspconfig.util').root_pattern(
							'compile_commands.json',
							'compile_flags.txt',
							'.clangd',
							'.git',
							'platformio.ini'
						)(fname) or require('lspconfig.util').path.dirname(fname)
					end,
					on_new_config = function(new_config, new_root_dir)
						-- Only adjust for PlatformIO projects
						local pio_ini = new_root_dir and (new_root_dir .. "/platformio.ini") or nil
						if pio_ini and vim.fn.filereadable(pio_ini) == 1 then
							local uv = vim.uv or vim.loop
							local function exists(p)
								return uv.fs_stat(p) ~= nil
							end
							local build_dir = new_root_dir .. "/.pio/build"
							local chosen_env_dir = nil
							if exists(build_dir) then
								local scan = uv.fs_scandir(build_dir)
								while scan do
									local name, t = uv.fs_scandir_next(scan)
									if not name then break end
									if t == "directory" then
										local cdb = build_dir .. "/" .. name .. "/compile_commands.json"
										if exists(cdb) then
											chosen_env_dir = build_dir .. "/" .. name
											break
										end
									end
								end
							end
							-- If we found a PlatformIO env with compile_commands.json, point clangd to it
							if chosen_env_dir then
								-- Avoid duplicating the flag
								local flag = "--compile-commands-dir=" .. chosen_env_dir
								local has_flag = false
								for _, v in ipairs(new_config.cmd or {}) do
									if v == flag then has_flag = true; break end
								end
								if not has_flag then
									table.insert(new_config.cmd, flag)
								end
							end
						end
					end,
				})
			end

			-- Arduino Language Server configuration
			lspconfig.arduino_language_server.setup({
				capabilities = capabilities,
				cmd = {
					"/Users/hiken/.local/share/nvim/mason/bin/arduino-language-server",
					"-cli-config", "/Users/hiken/Library/Arduino15/arduino-cli.yaml",
					"-fqbn", "arduino:avr:uno",
					"-cli", "arduino-cli",
					"-clangd", "/Users/hiken/.local/share/nvim/mason/bin/clangd",
					"-log"
				},
				filetypes = { "arduino" }
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

			vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
			vim.keymap.set("n", "]e", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

			vim.api.nvim_set_keymap(
				"n",
				"<space>e",
				"<cmd>lua vim.diagnostic.open_float()<CR>",
				{ desc = "Enable Diagnostic Popup" }
			)

			-- Configure diagnostics to filter out specific clangd warnings
			vim.diagnostic.config({
				virtual_text = {
					filter = function(diagnostic)
						-- Filter out using declaration conflicts
						if string.find(diagnostic.message, "using_decl_conflict") then
							return false
						end
						if string.find(diagnostic.message, "declaration conflicts with target of using declaration") then
							return false
						end
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
		dependencies = {
			"mfussenegger/nvim-jdtls",
		},
		config = function()
			require("sonarlint").setup({
			server = {
				cmd = {
					"java",
					"-cp",
					".:/Users/hiken/.config/nvim/sonarlint/*",
					"-jar",
					"/Users/hiken/.config/nvim/sonarlint/sonarlint-server.jar",
					-- Ensure that sonarlint-language-server uses stdio channel
					"-stdio",
					"-analyzers",
					-- paths to the analyzers you need, using those for python and java in this example
					"/Users/hiken/.config/nvim/sonarlint/sonarpython.jar",
					"/Users/hiken/.config/nvim/sonarlint/sonarjs.jar",
					"/Users/hiken/.config/nvim/sonarlint/sonartext.jar",
					"/Users/hiken/.config/nvim/sonarlint/sonarhtml.jar",
				},
				},
				filetypes = {
					"python",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
			})
		end,
	},
}
