tomux
=====

A minimalistic plugin for sending text with *tmux*.

Installation
------------

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'mroavi/vim-tomux'
```


Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```vim
use 'mroavi/vim-tomux'
```

Usage
-----

Configure tmux's *socket name* and *target pane* in your configuration file, for
example:

```vim
let b:tomux_config = {"socket_name": "default", "target_pane": "{right-of}"}
```

*tomux* exposes two `<Plug>` mappings to send motions and selections:

- `<Plug>TomuxMotionSend` → Send {count}{motion}.
- `<Plug>TomuxVisualSend` → Send {visual} text.

You need to map these in your configuration file, for example:

```vim
nmap <buffer> s <Plug>TomuxMotionSend
xmap <buffer> s <Plug>TomuxVisualSend
```

Open a tmux pane to the right of the pane running vim. To send "a" paragraph,
type <kbd>s</kbd><kbd>a</kbd><kbd>p</kbd> in normal mode, or alternatively,
type <kbd>v</kbd><kbd>a</kbd><kbd>p</kbd> to first select the paragraph and
then <kbd>s</kbd> to send it.

A few useful text-objects/motions that you can use with the <kbd>s</kbd>
operator include:

- <kbd>s</kbd><kbd>a</kbd><kbd>p</kbd> → send "a" paragraph
- <kbd>s</kbd><kbd>_</kbd> → send the current line
- <kbd>s</kbd><kbd>j</kbd> → send the current line and the one below

Any of these operations can be preceded by a `{count}`.

You can use the mapping below to send lines with (the more vim-oriented way)
<kbd>s</kbd><kbd>s</kbd> 

```vim
omap s _
```

You can also use the <kbd>s</kbd> operator together with custom text-objects.
For example, here is the definition of a custom text-object that selects the
entire document:

```vim
" Custom 'inner document' text object (from first line to last)
onoremap <silent> id :<c-u>normal! ggVG<cr>
xnoremap <silent> id :<c-u>normal! ggVG<cr>
```

Now you can type <kbd>s</kbd><kbd>i</kbd><kbd>d</kbd> to send the entire
buffer.

Clipboard
---------

Sending code to a REPL is a common use case of *tomux*. By default, *tomux*
uses an intermediary file to communicate with tmux. One of the drawbacks of
using this approach is that every character sent is echoed in the REPL, which
can be annoying if you are sending large chunks of code.

To solve this, *tomux* provides an option to communicate over the clipboard
instead. Several programming languages provide a method to run the contents of
the clipboard in the REPL. To enable this option, assign a string to
`b:tomux_clipboard_paste`. This string should be the method that pastes and
runs the content of the clipboard quietly in the REPL. For example, to enable
this functionality for IPython, add the line below inside Python's filetype
plugin file
```vim
let b:tomux_clipboard_paste = "paste -q"
```
For Julia, add
```vim
let b:tomux_clipboard_paste = "include_string(Main, clipboard())"
```
inside Julia's filetype plugin file.

Options
-------

#### b:tomux_config

A dictionary with tmux's *socket name* and *target pane*. For information on
these options and their possible values see the [tmux
manual](http://man.openbsd.org/OpenBSD-current/man1/tmux.1#_last__2).

Example: `b:tomux_config = {"socket_name": "default", "target_pane": "{right-of}"}`

Default: empty

#### b:tomux_clipboard_paste

If defined, the text that is being sent is first yanked to the clipboard
and then the string assigned to this variable is sent to tmux using an
intermediary file.

Default: empty

#### g:tomux_paste_file

Path to an intermediary file that is used to transfer data to tmux. 

*WARNING: this file is not removed by tomux.*

Default: `g:tomux_paste_file = "$HOME/.tomux_paste"`
 
Credits
-------

- vim-slime
- vim-ipython-cell

