if exists("g:loaded_nerdtree_filter_menu")
    finish
endif
let g:loaded_nerdtree_filter_menu = 1


call NERDTreeAddMenuItem({
            \'text': '(f)Filter file''s extension', 
            \'shortcut': 'f', 
            \'callback': 'NERDTreeFilterExtension'})

function! NERDTreeFilterExtension()
    let a:input_ext = input("Please input the extension of files, use <space> to separate, such as「js json css」: ")
    let a:input_ext_list = split(a:input_ext)

    if a:input_ext_list != []
        let a:list = [] 
        for a:ext in a:input_ext_list
            let a:ext = '\.'.a:ext.'$'
            let a:extlist = split(a:ext)
            let a:list += a:extlist
        endfor
        let g:NERDTreeIgnore = a:list
    else
        let g:NERDTreeIgnore = ['\~$']
    endif
    call NERDTreeRender()
endfunction

