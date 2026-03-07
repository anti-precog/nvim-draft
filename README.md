# draft.nvim

**nvim-draw** is a lua plugin for Neovim to improve the experience of writing prose.

> [!WARNING]  
> Project is still in early stage of development.

## Features
- file extension "draft" 
- **highlight** for dialogs, quotes, headers and comments
- autorepleace for dash '–'  and em-dash '—'
- fast jumping between files (chapters/scenes/parts)

## Installation

Install the plugin with lazy package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
	"anti-precog/draft.nvim",
    opts = {},
    ft = "draft"
}
```
## Requirements

For proper lazy loading, it’s best to add the creation of the draft file type in your neovim configuration:

```lua
vim.filetype.add({
	extension = {
		draft = "draft",
	},
})
```

## Navigation

You can fast jumps between your chapters, scenes or pages if the files have number in it.

### Commands
 - SelectPage - jump to file by number
 - NextPage/PrefPage - open existed or create new file with according number

