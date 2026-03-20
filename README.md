# draft.nvim

**draw** is a simple plugin for Neovim to improve the experience of writing prose.

> [!WARNING]  
> Project is still in early stage of development.

## Idea

The plugin is designed to help writers use characters such as dashes and quotation marks to create the most complete draft possible. The text should have no additional formatting, with *one line representing a single paragraph*.

## Features

- indents for better reading experince
- syntax for dialogues and quotes and in-file comments to distinguish it from actulal story
- auto repleacment for dashes and quotation marks
- (WIP) fast/not distracting jumping through mulitple project files

## Requirements

- Neovim >= 0.10.0

## Installation

Install the plugin with lazy package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

Minimal setup:

```lua
{
	"anti-precog/draft.nvim",
    opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    },
}
```

For proper lazy loading, it’s best to add the creation of the new file type in your neovim configuration:

Proposed (out of box) setup:

```lua
{
	"anti-precog/draft.nvim",
	ft = "draft",
	init = function()
		-- add assiciated filetype
		vim.filetype.add({
			extension = {
				draft = "draft",
			},
		})
	end,
	config = function()
		-- add new highlight group
		vim.api.nvim_set_hl(0, "Italic", { italic = true })
		-- load main module
		require("draft").setup({
            -- your configuration comes here
            -- refer to the configuration section below
			syntax = {
				quote = "Italic",
				dialogue = "Italic",
			},
		})
	end,
}
```

## Configuration

Defualt options:

```lua
 {
	-- all loaded features works only fot that filetypes
	filetypes = { "draft" },

	-- select how to recognize dialogues as em-dash or en-dash
	dash = "—",

	-- improved moved on features
	-- true - navigating [j/k] through the file ignore line wraping
	-- false - disable that feature
	move_by_visual_lines = true,

	-- emdahs(—) and dash(–) can be auto replace by selected phraze
	-- it can be symbol one even characters string
	-- nil - disable that repleacment
	auto_repleace_symbols = {
		dash = "--", -- used to mark dialogues
		smart_quotes = '"', -- curly quotes („”)
	},

	-- load paginator feature
	paginator = false,

	-- set indent size for all paragraph
	indent = 2, -- set to 0 to disable

	-- use accessible highlight-groups to syntax specific section
	-- nil - disable syntax
	syntax = {
		dialogue = "Statement",
		quote = "Statement",
		comment = "NonText",
		header = "Title",
	},

	-- center selected sections
	-- nil - leave default indent
	center = {
		header = false,
		asterix = true,
	},
}
```

## Suggestions for other plugins

- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) - to focus only on writing
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - for better comment expose
- [catppucin](https://github.com/catppuccin/nvim) - syntax proposition 

