function! s:TryGlobs(...)
	let n = a:0

	for i in range(n)
		let ext = a:000[i]

		let target = expand("%:r") . "." . ext

		if glob(target) != "" || i is n - 1
			return target
		endif
	endfor

	throw "unreachable"
endfunction

function! s:CAltFile()
	let ext = expand("%:e")
	echom "ext" ext

	if ext ==? "c" || ext ==? "cpp" || ext ==? "cc" || ext ==? "cxx" || ext ==? "m" || ext ==? "mm"
		return s:TryGlobs("hxx", "h")
	else
		return s:TryGlobs("m", "mm", "cpp", "cxx", "cc", "c")
	endif
endfunction

function! s:SpecAlt()
	if expand("%:e:e:r") ==? "spec"
		return expand("%:r:r") . "." . expand("%:e")
	else
		return expand("%:r") . ".spec." . expand("%:e")
	endif
endfunction

function! s:VimAlt()
	let dir = expand("%:h:t")

	if dir ==# "autoload"
		let replace = "/plugin/"
	elseif dir ==# "plugin"
		let replace = "/autoload/"
	else
		echohl Error
		echo "No vim alt-file for current buffer (not in autoload/ or plugin/)"
		echohl None
		return ""
	endif

	return expand("%:h:h") . replace . expand("%:t")
endfunction

function! s:Alt()
	if &ft ==# "c" || &ft ==# "cpp" || &ft ==# "objc" || &ft ==# "objcpp"
		return s:CAltFile()
	elseif &ft ==# "javascript" || &ft ==# "python" || &ft ==# "ruby" || &ft ==# "typescript"
		return s:SpecAlt()
	elseif &ft ==# "vim"
		return s:VimAlt()
	endif

	echohl Error
	echo "Can't handle filetype \"" . &ft . "\""
	echohl None
endfunction

function! s:AFileToggle(command, mods)
	let alt = s:Alt()

	if empty(alt)
		return
	endif

	execute a:mods . " " . a:command . " " . alt
endfunction

command! -bar A  call s:AFileToggle("edit", <q-mods>)
command! -bar AS call s:AFileToggle("split", <q-mods>)
command! -bar AV call s:AFileToggle("vsplit", <q-mods>)
command! -bar AT call s:AFileToggle("tabe", <q-mods>)
