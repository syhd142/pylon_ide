if exists('g:pylon_ide_config')
  finish
endif 

let g:pylon_ide_config = 1

let g:vjFileTypeList = ['php','javascript','html']

func! VjFileTypeToggle()
    let a:curFt = &filetype
    let a:ftIndex = index(g:vjFileTypeList, a:curFt)  
    if a:ftIndex  != -1
        let a:nextFt=g:vjFileTypeList[( (a:ftIndex + 1) % len(g:vjFileTypeList) )]
        exec "set ft=".a:nextFt
        echo ':set filetype ='a:nextFt
    endif
endfunction

"Go to last file(s) if invoked without arguments.
autocmd VimLeave * NERDTreeClose
autocmd VimLeave * TagbarClose
autocmd BufWinLeave * call VjBufClose()
autocmd VimLeave * nested call VjClose()

" 实验性特性
" 若离开前窗口不是NERDTree 且只有两个窗口 且 NerdTree是打开状态，则保存session
func! VjBufClose()
    if ! exists("b:NERDTreeType") && winnr("$") == 2 
        if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
            call SaveSession(FindProjectName())
        endif 
    endif 
endf

if ! isdirectory('~/.vim/sessions/')
   silent exec '!mkdir -p ~/.vim/sessions'
endif

func! FindProjectName()
    let s:name = getcwd()
    if !isdirectory(".git")
        let s:name = substitute(finddir(".git", ".;"), "/.git", "", "")
    endif 
    if s:name != ""
        let s:name = matchstr(s:name, ".*", strridx(s:name, "/") + 1)
    endif 
    return s:name
endf

func! RestoreSession(name)
    if a:name != ""
        if filereadable($HOME . "/.vim/sessions/" . a:name)
            execute 'source ' . $HOME . "/.vim/sessions/" . a:name
        end
    end
endf

func! SaveSession(name)
    if a:name != ""
        execute 'mksession! ' . $HOME.'/.vim/sessions/'.a:name
    end
endf

 if ! exists("g:vj_open_last_file_mode")
     " set ssop+=resize
     " set ssop+=winpos
     set ssop-=winpos
     set ssop-=options
     set ssop-=curdir
     set ssop-=tabpages
     set ssop-=blank
     set ssop-=buffers 
    let g:vj_open_last_file_mode=1
 endif

if ! exists("g:vj_source_from_code_mode")
    let g:vj_source_from_code_mode=0
endif

func! VjClose()
    call SaveSession(FindProjectName()) 
endf

func! VjOpen()
    let session_name = FindProjectName()
    if g:vj_open_last_file_mode != 0 && session_name != ''
        call RestoreSession(session_name)
    endif
    if g:vj_source_from_code_mode == 0
        NERDTreeTabsToggle
    else
        NERDTreeFind
    endif
endf

function! VjMaximizeToggle()
    if exists("s:maximize_session")
        exec "source " . s:maximize_session
        call delete(s:maximize_session)
        unlet s:maximize_session
        let &hidden=s:maximize_hidden_save
        unlet s:maximize_hidden_save
    else
        let s:maximize_hidden_save = &hidden
        let s:maximize_session = tempname()
        set hidden
        exec "mksession! " . s:maximize_session
        only
    endif
endfunction

command! -nargs=0 VJMaximizeToggle call VjMaximizeToggle()
command! -nargs=0 VJFileTypeToggle call VjFileTypeToggle()

function! VjPhpBeautify()
    exec '% ! php_beautifier --filters "Pear() ListClassFunction() NewLines(before=T_COMMENT:T_CLASS:if,after=T_COMMENT) ArrayNested()"'
    " exec '% ! php_beautifier --filters "Pear() NewLines(before=T_CLASS:function:T_COMMENT,after=T_COMMENT) EqualsAlign() ArrayNested()"'
    " exec '% ! php_beautifier --filters "Pear() ArrayNested() IndentStyles(style=k&r)"'
endfunction
