# msc.nvim

Tools for resolving MSC (Matrix Spec Proposal) references in nvim buffers.

## Features

- `:OpenMSC` command, which opens the MSC under the cursor in your browser.
- A [hover.nvim](https://github.com/lewis6991/hover.nvim) provider which shows
  MSC metadata and body in the hover window. This is a slightly tweaked version
  of the `hover.providers.gh` provider.

## Requirements

- Neovim (tested on 0.12+).
- [`gh`](https://cli.github.com/) CLI, authenticated (`gh auth login`), for
  the hover provider.
- [hover.nvim](https://github.com/lewis6991/hover.nvim) (optional; only
  needed if you want the hover provider)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'dkasak/msc.nvim',
    config = function()
        require('msc').setup()
    end,
},
```

`setup()` only defines the `:OpenMSC` command. It does not register the
hover provider.

## Hover integration

To enable the hover provider, add `'msc.hover'` to hover.nvim's `providers`
list:

```lua
require('hover').config({
    providers = {
        -- ...your other providers, if any...
        'msc.hover',
    },
})
```

## Usage

- With the cursor on an MSC identifier like `MSC4147`, run `:OpenMSC` to open
  it in the browser, or press `K` (or whatever you've bound to
  `require('hover').open`) to view its metadata inline.
- Recognized forms: `MSC1234`, `msc1234`, `MSC_1234` (4 or 5 digits).
