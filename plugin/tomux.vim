if exists("g:loaded_tomux")
  finish
endif
let g:loaded_tomux = 1

command -nargs=1 TomuxSend call tomux#tmuxsend(g:tomux_config, <args>)
command -nargs=1 TomuxCommand call tomux#tmuxcommand(g:tomux_config, <args>)
command -bar TomuxUseClipboardToggle call tomux#useclipboardtoggle()

noremap <SID>Operator :<c-u>call tomux#save_winview()<cr>:set opfunc=tomux#send_op<cr>g@

noremap <unique> <script> <silent> <Plug>TomuxVisualSend :<c-u>call tomux#send_op(visualmode(), g:tomux_config, 1)<cr>
noremap <unique> <script> <silent> <Plug>TomuxMotionSend <SID>Operator

