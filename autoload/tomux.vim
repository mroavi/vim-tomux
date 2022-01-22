let g:tomux_paste_file = get(g:, "tomux_paste_file", expand("$HOME/.tomux_paste"))
let g:tomux_use_clipboard = get(g:, "tomux_use_clipboard", 1)

function! tomux#send_op(type, ...) abort
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
	call setreg('"', substitute(@", "\n\\+", "\n", "g"), 'v') " remove empty lines
	" If both `g:tomux_use_clipboard` and `b:tomux_clipboard_paste` are defined, 
	" then send `b:tomux_clipboard_paste` to tmux instead of the motion/text-object
	if g:tomux_use_clipboard && exists("b:tomux_clipboard_paste")
		call setreg('+', @", 'V') " set the yanked text in the clipboard register
		call setreg('"', b:tomux_clipboard_paste, 'V')
	end
	call tomux#tmuxsend(b:tomux_config, @") " send unnamed register's content using a file
	let &selection = sel_opt
	if exists("s:winview")
		call winrestview(s:winview)
		unlet s:winview
	endif
endfunction

function! tomux#save_winview()
	let s:winview = winsaveview()
endfunction

function! tomux#tmuxsend(config, text)
  if !exists("$TMUX") | echom("fatal: not running in a tmux session") | return | endif
	call system("cat > " . g:tomux_paste_file, a:text)
  call tomux#tmuxcommand(a:config, "send-keys -t " . shellescape(a:config["target_pane"]) . " -X cancel")
	call tomux#tmuxcommand(a:config, "load-buffer " . g:tomux_paste_file)
	call tomux#tmuxcommand(a:config, "paste-buffer -d -t " . shellescape(a:config["target_pane"]))
endfunction

function! tomux#tmuxcommand(config, args)
  if !exists("$TMUX") | echom("fatal: not running in a tmux session") | return | endif
	let l:socket = a:config["socket_name"]
	let l:socket_option = l:socket[0] ==? "/" ? "-S" : "-L"
	return system("tmux " . l:socket_option . " " . shellescape(l:socket) . " " . a:args)
endfunction

function! tomux#useclipboardtoggle() abort
	if g:tomux_use_clipboard
		let g:tomux_use_clipboard = 0
		echo "let g:tomux_use_clipboard = 0"
	else
		let g:tomux_use_clipboard = 1
		echo "let g:tomux_use_clipboard = 1"
	endif
endfunction

