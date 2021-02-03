if exists("g:loaded_tomux")
  finish
endif
let g:loaded_tomux = 1

let g:tomux_config = get(g:, "tomux_config", {"socket_name": "default", "target_pane": "{right-of}"})
let g:tomux_paste_file = get(g:, "tomux_paste_file", expand("$HOME/.tomux_paste"))

function! s:send_op(type, ...) abort
  let sel_opt = &selection " backup
  let &selection = "inclusive"
  " Store the motion/text-object in the unnamed register by yanking it
  if a:0
    silent exe "keepjumps normal! `<" . a:type . '`>y'
  elseif a:type == 'line'
    silent exe "keepjumps normal! '[V']y"
  elseif a:type == 'block'
    silent exe "keepjumps normal! `[\<C-V>`]\y"
  else
    silent exe "keepjumps normal! `[v`]y"
  endif
  " If defined, send `b:tomux_clipboard_paste` to tmux instead of the motoin/text-object
  if exists("b:tomux_clipboard_paste")
    call setreg('+', @", 'V') " set the yanked text in the clipboard register
    call setreg('"', b:tomux_clipboard_paste, 'V')
  end
  call s:tmuxsend(g:tomux_config, @") " Send unnamed register's content using a file
  let &selection = sel_opt
  if exists("s:winview")
    call winrestview(s:winview)
    unlet s:winview
  endif
endfunction

function! s:save_winview()
  let s:winview = winsaveview()
endfunction

function! s:tmuxsend(config, text)
  call system("cat > " . g:tomux_paste_file, a:text)
  call s:tmuxcommand(a:config, "load-buffer " . g:tomux_paste_file)
  call s:tmuxcommand(a:config, "paste-buffer -d -t " . shellescape(a:config["target_pane"]))
endfunction

function! s:tmuxcommand(config, args)
  let l:socket = a:config["socket_name"]
  let l:socket_option = l:socket[0] ==? "/" ? "-S" : "-L"
  return system("tmux " . l:socket_option . " " . shellescape(l:socket) . " " . a:args)
endfunction

command -nargs=1 TomuxSend call s:tmuxsend(g:tomux_config, <args>)

noremap <SID>Operator :<c-u>call <SID>save_winview()<cr>:set opfunc=<SID>send_op<cr>g@

noremap <unique> <script> <silent> <Plug>TomuxVisualSend :<c-u>call <SID>send_op(visualmode(), 1)<cr>
noremap <unique> <script> <silent> <Plug>TomuxMotionSend <SID>Operator

