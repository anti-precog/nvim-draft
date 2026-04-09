# draft.nvim

**draw** is a simple plugin for Neovim to improve the experience of writing prose.

> [!WARNING]  
> Project is still in early stage of development.

> [!NOTE]  
> The upcoming plan is to integrate with **tree-sitter** by creating a new dedicated parser.

<img width="1192" height="930" alt="Image" src="https://github.com/user-attachments/assets/8b29467b-bea8-4b2e-b2e3-ae0dd95f4c5a" />

## Idea

The plugin is designed to help writers by visual text formatting (indents, highlightx) and use characters (dashes and quotation marks) to create the most complete story draft possible. The text should have no additional formatting, with the rule:  **one line representing a single paragraph**.
Text should be fully portabled to other filetypes.

## Features

- indents for better reading experince
- syntax for dialogues and quotes and in-file comments to distinguish it from actulal story
- auto repleacment for dashes and quotation marks
- fast/not distracting jumping through mulitple project files

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
<details>
<summary>Installation snippet.</summary>

```lua
{
	"anti-precog/draft.nvim",
	ft = "draft",
	init = function()
		-- add filetype before lazy load
		vim.filetype.add({
			extension = {
				draft = "draft",
			},
		})
	end,
    opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    },
}
```
</details>

Example with additionl custom highlight groups.

<details>
<summary>Installation snippet.</summary>

```lua
{
	"anti-precog/draft.nvim",
	ft = "draft",
	init = function()
		-- add filetype before lazy load
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
			typography = {
				center_header = false,
				header_hl = false,
				quote_hl = "Italic",
				dialogue_hl = "Italic",
			},
		})
	end,
}
```
</details>

## Configuration

Defualt options:

```lua
{
	-- select how to recognize dialogues as em-dash or en-dash
	dash_symbol = "em-dash",

	-- Configuration for core module
	core = {
		repleace_dash = "--",
		repleace_ellipsis = "...",
		smart_quotes = true,
		move_by_visual_lines = true,
		auto_turn_page = true,
		skip_meta_lines = true, -- experimental
	},

	-- Configuration for typography module
	typography = {
		indent_size = 4,
		center_header = false,
		center_asterix = true,
		dialogue_hl = "Statement",
		quote_hl = "Statement",
		comment_hl = "NonText",
		header_hl = "Title",
	},
}
```

## Suggestions for other plugins

- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) - to focus only on writing
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) - for better comment expose
- [catppucin](https://github.com/catppuccin/nvim) - syntax proposition 

