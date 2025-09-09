# witty.nvim
A simple terminal window plugin for neovim with a witty name

## Installation

### lazy.nvim
```Lua
{
    "winstonji/witty.nvim",
    opts = {},
}
```

## Configuration
Here is an example configuration that represents all the default options:
```Lua
opts = {
    keybinds = {
        witty_toggle = "<Leader><CR>"
        float_toggle = "<Leader>wf"
        split_toggle = "<Leader>ws"
        vertical_toggle = "<Leader>wv"
        witty_hide = "<Esc>"
    }
}
```

## Usage
Witty.nvim wraps the builtin Neovim terminal emulator with some simple keybinds. `witty_toggle` allows you to open and close the builtin terminal emulator. It will also maintain all state from the previous time you opened terminal emulator. There are 3 states: "floating", "split", and "vertical". When you toggle to one of the states, it will remember for the next time you toggle the terminal back on.

<!-- vim: set wrap: -->
