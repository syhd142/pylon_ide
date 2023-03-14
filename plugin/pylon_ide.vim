if exists("pylon_ide_loaded")
    finish
endif
let pylon_ide_loaded = 1

" 获得项目的根目录
let s:prjroot=fnamemodify('',':p')

func! GeneratorIndex()
    silent execute  '! ~/.vim/bundle/pylon_ide/generator_index.sh ' . s:prjroot 
    execute "! echo -e --- Finished ---\n"
    :call UpdatePrjTags()
endf

func! UpdatePrjTags()
    " 将 _prj/ 下 tags 结尾的文件
    let a:tag_list=split(globpath(s:prjroot."_prj/", '*tags'), "\n")
    set tags=
    let i=0
    while i<len(a:tag_list)
        if filereadable(a:tag_list[i])
            " echo a:tag_list[i]
            execute "set tags+=".a:tag_list[i]            
        endif
        let i+=1
    endwhile
endf

function Pylon_prj_cmd(cmd)
    execute  '! ' . g:pylon_prjroot. '/_prj/' . a:cmd 
endfunction

function Pylon_debug_watch(varname,type)
    let n= line('.')  
    let pos = indent('.')
    let watchstr = repeat(" ",pos) .   printf("Debug::watch(__FILE__,__LINE__,%s,'%s');",a:varname,a:varname)
    if a:type == "up" 
        let    n = n-1
    endif
    call append(n,watchstr)
endfunction

function Pylon_dbc_add_nl2(varname,type)
    let pos = indent('.')
    let watchstr = repeat(" ",pos+4) . printf("DBC::%s(%s,'%s');",a:type,a:varname,a:varname)
    let n= line('.')  
    call append(n+1,watchstr)
endfunction

function Pylon_dbc_add(varname,type)
    let pos = indent('.')
    let watchstr = repeat(" ",pos) . printf("DBC::%s(%s,'%s');",a:type,a:varname,a:varname)
    let n= line('.')  
    call append(n,watchstr)
endfunction


let g:pylon_prj_init="init.sh"
let g:pylon_prj_ci  = "ci.sh"


function Pylon_ide_init(prjroot )
    let g:pylon_prjroot = a:prjroot 
    " noremap <F9> <Esc>: call Pylon_build_index() <CR>
    noremap <F8> <Esc>: call Pylon_prj_cmd(g:pylon_prj_init) <CR>
    " noremap <F7> <Esc>: call Pylon_prj_cmd("build_index.sh") <CR>
    map \zci <Esc>:call Pylon_prj_cmd(g:pylon_prj_ci) <CR>

    noremap \dw <Esc>:call Pylon_debug_watch(expand("<cword>"),"down")<CR> 
    noremap \dW <Esc>:call Pylon_debug_watch(expand("<cWORD>"),"down")<CR> 
    noremap \du <Esc>:call Pylon_debug_watch(expand("<cword>"),"up")<CR> 
    noremap \dU <Esc>:call Pylon_debug_watch(expand("<cWORD>"),"up")<CR> 

    noremap \re <Esc>:call Pylon_dbc_add_nl2(expand("<cword>"),"requireNotNull")<CR> 
    noremap \rn <Esc>:call Pylon_dbc_add_nl2(expand("<cword>"),"requireNotNull")<CR> 
    noremap \rt <Esc>:call Pylon_dbc_add_nl2(expand("<cword>"),"requireTrue")<CR> 
    noremap \rue <Esc>:call Pylon_dbc_add(expand("<cword>"),"unExpect")<CR> 
    noremap \rui <Esc>:call Pylon_dbc_add("__FUNCTION__"),"unImplement")<CR> 

    " ia s1   echo "---------------step 1 ---------------<br>\n";
    " ia s2   echo "---------------step 2 ---------------<br>\n";
    " ia s3   echo "---------------step 3 ---------------<br>\n";
    " ia s4   echo "---------------step 4 ---------------<br>\n";
    " ia s5   echo "---------------step 5 ---------------<br>\n";
    " ia s6   echo "---------------step 6 ---------------<br>\n";
    " ia s7   echo "---------------step 7 ---------------<br>\n";
    " ia s8   echo "---------------step 8 ---------------<br>\n";
    " ia s9   echo "---------------step 9 ---------------<br>\n";

endfunction

function Probe_ide_init(prjroot )
    :call Pylon_ide_init(a:prjroot)
endfunction
"noremap <unique> <script> <Plug><SID>Add


function MapUnitTest()
    if filereadable(s:prjroot.'test/unittest.sh')
        exec '!'. s:prjroot .'test/unittest.sh'
    else
        exec '! /home/q/tools/pylon_rigger/rigger start -s test'
    endif
endfunction

noremap <F9> <Esc> :call GeneratorIndex() <CR>

"若项目根目录下_prj/init.sh文件存在，则定义F2映射和加载Pylon插件
if filereadable(s:prjroot.'_prj/init.sh')
    noremap <F2> <Esc> :call MapUnitTest() <CR>
    call Probe_ide_init(strpart(s:prjroot, 0, strlen(s:prjroot)-1 ))
endif

if filereadable(s:prjroot.'_prj/_prj.vim')
    exec 'source '.s:prjroot.'_prj/_prj.vim'
endif
