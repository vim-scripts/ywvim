" mY oWn VimIM.
" Author: Yue Wu <vanopen@gmail.com>
" Last Change:	2009 Mar 24

" Copyright 2008-2009 Yue Wu. All rights reserved.

" Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
" Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
" Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

" THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" The views and conclusions contained in the software and documentation are those of the authors and should not be interpreted as representing official policies, either expressed or implied, of the FreeBSD Project.

if exists("s:loaded_ywvim") | finish | endif
let s:loaded_ywvim = 1

scriptencoding utf-8

" 输入法简称 = s:ywvim_ims[match(s:ywvim_ims, b:ywvim_active_mb)][0]
" 码表文件 = s:ywvim_ims[match(s:ywvim_ims, b:ywvim_active_mb)][1]
" 反查码表文件 = s:ywvim_ims[match(s:ywvim_ims, b:ywvim_active_mb)][2]
" 白名单文件 = s:ywvim_ims[match(s:ywvim_ims, b:ywvim_active_mb)][3]
if exists("g:ywvim_ims")
    let s:ywvim_ims = g:ywvim_ims
    unlet g:ywvim_ims
    let path = globpath(expand("<sfile>:p:h"), "**/*.ywvim")
    let midx = -1
    for m in s:ywvim_ims
        let midx += 1
        let fidx = 0
        for f in m[1 : -1]
            let fidx += 1
            if match(f, '.*\.ywvim') == -1
                continue
            endif
            if f != '' && !filereadable(f)
                let ffix = globpath(expand("<sfile>:p:h"), "*/**/" . f)
                if ffix != ''
                    let s:ywvim_ims[midx][fidx] = ffix
                else
                    let s:ywvim_ims[midx][fidx] = ''
                endif
            endif
        endfor
    endfor
else
    finish
endif
if exists("g:ywvim_chinesepunc")
    let s:ywvim_chinesepunc = g:ywvim_chinesepunc
    unlet g:ywvim_chinesepunc
else
    let s:ywvim_chinesepunc = 1
endif
if exists("g:ywvim_phasemaxlen")
    let s:ywvim_phasemaxlen = g:ywvim_phasemaxlen
    unlet g:ywvim_phasemaxlen
else
    let s:ywvim_phasemaxlen = 0
endif
if exists("g:ywvim_listmax")
    let s:ywvim_listmax = g:ywvim_listmax
    unlet g:ywvim_listmax
else
    let s:ywvim_listmax = 1
endif
if exists("g:ywvim_esc_autoff")
    let s:ywvim_esc_autoff = g:ywvim_esc_autoff
    unlet g:ywvim_esc_autoff
else
    let s:ywvim_esc_autoff = 0
endif

function s:Ywvim_getqflist() "{{{ TODO secure can't allow vimgrep except when in insert mode.
    execute 'vimgrep /^' . 'e' . '/j ' . '~/.vim/plugin/ywvim/cangjie.ywvim'
    let s:lst = []
    for d in getqflist()
        call add(s:lst, d.text)
    endfor
    return ''
endfunction
"}}}
function s:Ywvim_loadmb(...) "{{{
    if !exists("a:1")
        if !exists("b:ywvim_active_mb")
            let b:ywvim_active_mb = s:ywvim_ims[0][0]
        endif
        let mb = b:ywvim_active_mb
    else
        let mb = a:1
    endif
    if !exists("b:ywvim_chinesepunc_on")
        let b:ywvim_chinesepunc = s:ywvim_chinesepunc
    endif
    if !exists("b:ywvim_wlst_on")
        let b:ywvim_wlst_on=1
    endif
    if !exists("b:ywvim_phasemaxlen")
        let b:ywvim_phasemaxlen = s:ywvim_phasemaxlen
    endif
    if !exists("b:ywvim_listmax")
        let b:ywvim_listmax = s:ywvim_listmax
    endif
    if exists("s:ywvim_{mb}_loaded")
        return ''
    endif
    " let s:ywvim_{mb}_flst = filter(readfile(s:ywvim_ims[match(s:ywvim_ims, mb)][1]), "v:val !~ '^\s*$'")
    let s:ywvim_{mb}_flst = readfile(s:ywvim_ims[match(s:ywvim_ims, mb)][1])

    let s:ywvim_{mb}_desc_idxs = index(s:ywvim_{mb}_flst, '[Description]') + 1
    let s:ywvim_{mb}_desc_idxe = index(s:ywvim_{mb}_flst, '[Punctuation]') - 1
    let s:ywvim_{mb}_punc_idxs = index(s:ywvim_{mb}_flst, '[Punctuation]') + 1
    let s:ywvim_{mb}_punc_idxe = index(s:ywvim_{mb}_flst, '[Main]') - 1
    let s:ywvim_{mb}_main_idxs = index(s:ywvim_{mb}_flst, '[Main]') + 1
    let s:ywvim_{mb}_main_idxe = len(s:ywvim_{mb}_flst) - 1
    let desclst = s:ywvim_{mb}_flst[s:ywvim_{mb}_desc_idxs : s:ywvim_{mb}_desc_idxe]
    let s:ywvim_{mb}_usedcodes = matchstr(matchstr(desclst, '^UsedCodes'), '=\s*\zs.*')
    let s:ywvim_{mb}_maxcodes = matchstr(matchstr(desclst, '^MaxCodes'), '=\s*\zs.*')
    let s:ywvim_{mb}_enchar = matchstr(matchstr(desclst, '^EnChar'), '=\s*\zs.*')
    let s:ywvim_{mb}_pychar = matchstr(matchstr(desclst, '^PyChar'), '=\s*\zs.*')
    let helpmb = get(s:ywvim_ims[match(s:ywvim_ims, mb)], 2)
    let helpmbp = match(s:ywvim_ims, helpmb)
    if helpmb != '' && helpmbp != -1
        if !exists("s:ywvim_{helpmb}_flst")
            call <SID>Ywvim_loadmb(helpmb)
        endif
        let s:ywvim_{mb}_helpmb = helpmb
    else
        unlet! s:ywvim_{mb}_helpmb
    endif
    let wlstfile = get(s:ywvim_ims[match(s:ywvim_ims, mb)], 3)
    if filereadable(wlstfile)
        execute 'let s:ywvim_' . mb . '_wlst = readfile(wlstfile)'
    else
        unlet! s:ywvim_{mb}_wlst
    endif
    let s:ywvim_{mb}_imname = matchstr(matchstr(desclst, '^Name'), '=\s*\zs.*')
    let s:ywvim_{mb}_punclst = s:ywvim_{mb}_flst[s:ywvim_{mb}_punc_idxs : s:ywvim_{mb}_punc_idxe]
    if &enc != 'utf-8' && has("iconv")
        let s:ywvim_{mb}_imname = iconv(s:ywvim_{mb}_imname, "utf-8", &encoding)
        for ip in range(0,len(s:ywvim_{mb}_punclst)-1)
            let s:ywvim_{mb}_punclst[ip] = iconv(s:ywvim_{mb}_punclst[ip], "utf-8", &encoding)
        endfor
    endif
    let s:ywvim_{mb}_loaded = 1
    return ''
endfunction
"}}}
function s:Ywvim_keymap() "{{{
    for key in sort(split(s:ywvim_{b:ywvim_active_mb}_usedcodes,'\zs'))
        execute 'lnoremap <buffer> <expr> ' . key . '  <SID>Ywvim_char("' . key . '")'
    endfor
    if b:ywvim_chinesepunc == 1
        call <SID>Ywvim_keymap_punc()
    endif
    execute 'lnoremap <buffer> <expr> ' . s:ywvim_{b:ywvim_active_mb}_enchar . ' <SID>Ywvim_enmode()'
    if s:ywvim_{b:ywvim_active_mb}_pychar != ''
        execute 'lnoremap <buffer> <expr> ' . s:ywvim_{b:ywvim_active_mb}_pychar . ' <SID>Ywvim_onepinyin()'
    endif
    lnoremap <silent> <buffer> <C-^> <C-^><C-R>=<SID>Ywvim_parameters()<CR>
    if s:ywvim_esc_autoff
        inoremap <silent> <buffer> <esc> <C-R>=Ywvim_toggle(1)<CR><ESC>
    endif
    return ''
endfunction
" inoremap <silent> <expr> <C-\> Ywvim_toggle()
" cnoremap <silent> <expr> <C-\> Ywvim_toggle()
map! <silent> <expr> <C-\> Ywvim_toggle()
"}}}
function s:Ywvim_keymap_punc() "{{{
    for p in s:ywvim_{b:ywvim_active_mb}_punclst
        let pl = split(p, '\s\+')
        if len(pl) == 2
            execute 'lnoremap <buffer> ' . escape(pl[0], '|') . ' ' . pl[1]
        elseif len(pl) == 3
            execute 'lnoremap <buffer> <expr> ' . escape(pl[0], '|') . ' <SID>Ywvim_puncp(' . index(s:ywvim_{b:ywvim_active_mb}_punclst, p) . ',"s:ywvim_{b:ywvim_active_mb}_punc_' . char2nr(pl[0]) . '")'
        endif
    endfor
endfunction
"}}}
function s:Ywvim_parameters() "{{{
    if b:ywvim_chinesepunc == 0
        let punc='.'
    else
        let punc='。'
    endif
    if b:ywvim_wlst_on == 1
        let wlst='on'
    else
        let wlst='off'
    endif
    redraw
    echon "ywvim 参数设置[当前状态]\n"
    echohl Title
    echon "(m)码表切换[" . b:ywvim_active_mb . "]\n"
    echon "(.)标点切换[" . punc . "]\n"
    echon "(p)最大词长[" . b:ywvim_phasemaxlen . "]\n"
    echon "(w)白名单开关[" . wlst . "]\n"
    echon "(l)候选项数[" . b:ywvim_listmax . "]\n"
    echohl None
    let par = ''
    while par !~ '[m.pwl]'
        let par = nr2char(getchar())
    endwhile
    redraw
    if par == 'm'
        if &l:iminsert != 1
            echon "码表切换:\n"
            let nr = 0
            for im in s:ywvim_ims
                let nr += 1
                echohl Number
                echon nr
                echohl None
                echon '. ' . im[0] . " "
            endfor
            let getnr = ''
            while getnr !~ '[' . join(range(1, nr), '') . ']'
                let getnr = nr2char(getchar())
            endwhile
            let b:ywvim_active_mb = s:ywvim_ims[getnr - 1][0]
            lmapclear <buffer>
            call <SID>Ywvim_loadmb()
            call <SID>Ywvim_keymap()
        endif
    elseif par == '.'
        if b:ywvim_chinesepunc == 0
            call <SID>Ywvim_keymap_punc()
            let b:ywvim_chinesepunc = 1
        else
            for p in s:ywvim_{b:ywvim_active_mb}_punclst
                let pl = split(p, '\s\+')
                execute 'lunmap <buffer> ' . escape(pl[0], '|')
            endfor
            let b:ywvim_chinesepunc = 0
        endif
    elseif par == 'p'
        let b:ywvim_phasemaxlen = input('最大词长: ', b:ywvim_phasemaxlen)
    elseif par == 'w'
        if b:ywvim_wlst_on == 1
            let b:ywvim_wlst_on = 0
        else
            let b:ywvim_wlst_on = 1
        endif
    elseif par == 'l'
        let b:ywvim_listmax = input('候选项数: ', b:ywvim_listmax)
    endif
    redraw
    return "\<C-^>"
endfunction
"}}}
function s:Ywvim_comp(base,...) "{{{
    let len_base = len(a:base)
    if exists("a:1")
        let b:ywvim_base_idxs = a:1
    else
        let b:ywvim_base_idxs = match(s:ywvim_{b:ywvim_active_mb}_flst, '^' . a:base, s:ywvim_{b:ywvim_active_mb}_main_idxs)
        let b:ywvim_startline = b:ywvim_base_idxs
        let b:ywvim_base_idxe = match(s:ywvim_{b:ywvim_active_mb}_flst, '^\(' . a:base . '\)\@!', b:ywvim_base_idxs) - 1
        if b:ywvim_base_idxe == -2
            let b:ywvim_base_idxe = s:ywvim_{b:ywvim_active_mb}_main_idxe
        endif
    endif
    let b:ywvim_complst = []
    let lst = s:ywvim_{b:ywvim_active_mb}_flst[b:ywvim_base_idxs : b:ywvim_base_idxe]
    let nr = 0
    if exists("a:2")
        let b:ywvim_endchar = a:2
    else
        let b:ywvim_endchar = 1
    endif
    for i in lst
        if &encoding != 'utf-8' && has("iconv")
            let i = iconv(i, "utf-8", &encoding)
        endif
        let ilst = split(i, '\s\+')
        let suf = strpart(ilst[0], len_base)
        for c in ilst[b:ywvim_endchar : -1]
            if b:ywvim_endchar == len(ilst) - 1
                let b:ywvim_startline += 1
                let b:ywvim_endchar = 1
            else
                let b:ywvim_endchar += 1
            endif
            let help = ''
            if exists("s:ywvim_".b:ywvim_active_mb."_wlst") && b:ywvim_wlst_on == 1 && strlen(c) <= 3
                let cu = c
                if &encoding != 'utf-8' && has("iconv")
                    let cu = iconv(cu, &encoding, "utf-8")
                endif
                if index(s:ywvim_{b:ywvim_active_mb}_wlst, cu) == -1 && b:ywvim_wlst_on == 1
                    continue
                endif
            endif
            if b:ywvim_phasemaxlen > 0 && strlen(c) > 3 * b:ywvim_phasemaxlen
                continue
            endif
            let nr += 1
            if exists("s:ywvim_".b:ywvim_active_mb."_helpmb")
                let help = matchstr(matchstr(s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_flst[s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxs : s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxe], '\<'.c.'\>'), '^\S\+')
                if help != ''
                    let help = '<' . help . '>'
                endif
            endif
            let dic = {}
            let dic["word"] = c
            let dic["suf"] = suf
            let dic["nr"] = nr
            let dic["help"] = help
            let help = ''
            call add(b:ywvim_complst, dic)
            if nr == b:ywvim_listmax
                let s:ywvim_terminate = 1
                break
            endif
        endfor
        if exists("s:ywvim_terminate")
            break
        endif
        let b:ywvim_endchar = 1
    endfor
    unlet! s:ywvim_terminate
    if !exists("a:1")
        let b:ywvim_pagemax = 1
        let b:ywvim_pagenr = 0
        let b:ywvim_pgbuf = {}
        let b:ywvim_pgbuf[0] = b:ywvim_complst
    else
        if b:ywvim_complst != []
            let b:ywvim_pagemax += 1
        endif
    endif
    return b:ywvim_complst
endfunction
"}}}
function s:Ywvim_echopre() "{{{
    let prepre = ''
    if mode() !~ '[in]'
        let cmdtype = getcmdtype()
        let cmdline = getcmdline()
        if cmdtype != '@'
            let prepre = cmdtype.cmdline."\n"
        endif
    endif
    return prepre
endfunction
"}}}
function s:Ywvim_char(key) "{{{
    let char = ''
    let keycode = char2nr(a:key)
    while 1
        if keycode =~ '^\d\+$'
            let key = nr2char(keycode)
            if key =~ '[' . s:ywvim_{b:ywvim_active_mb}_usedcodes . ']'
                " code keys
                let pgnr = 1
                let char .= key
                let charcomp = <SID>Ywvim_comp(char)
                let charcomplen = len(b:ywvim_complst)
                if charcomp == []
                    let char = matchstr(char, '.*\ze.')
                    let charcomp = <SID>Ywvim_comp(char)
                endif
                let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', char, "[".(b:ywvim_pagenr+1)."]", charcomp]
                call <SID>Ywvim_echoresult(statusl)
            elseif key =~ '[,-]'
                " <pageup>
                if b:ywvim_pagenr > 0
                    let b:ywvim_pagenr -= 1
                endif
                let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', char, "[".(b:ywvim_pagenr+1)."]", b:ywvim_pgbuf[b:ywvim_pagenr]]
                call <SID>Ywvim_echoresult(statusl)
            elseif key =~ '[.=]'
                " <pagedown>
                let b:ywvim_pagenr += 1
                if !has_key(b:ywvim_pgbuf, b:ywvim_pagenr)
                    let page = <SID>Ywvim_comp(char,b:ywvim_startline,b:ywvim_endchar)
                    if page != []
                        let b:ywvim_pgbuf[b:ywvim_pagenr] = page
                    else
                        let b:ywvim_pagenr -= 1
                    endif
                endif
                let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', char, "[".(b:ywvim_pagenr+1)."]", b:ywvim_pgbuf[b:ywvim_pagenr]]
                call <SID>Ywvim_echoresult(statusl)
            else
                redraw
                if key == ' '
                    " <space>
                    return b:ywvim_pgbuf[b:ywvim_pagenr][0].word
                elseif key =~ '[1-' . b:ywvim_listmax . ']'
                    " <num>
                    if key <= len(b:ywvim_pgbuf[b:ywvim_pagenr])
                        return b:ywvim_pgbuf[b:ywvim_pagenr][key - 1].word
                    else
                        return key
                    endif
                elseif keycode == "13"
                    " <CR>
                    return char
                elseif keycode == "28"
                    " <C-\>
                    return char . "\<C-^>"
                elseif keycode == "30"
                    " <C-^>
                    return ""
                elseif keycode == 23
                    " <C-w>
                    return ""
                else
                    return key
                endif
            endif
        else
            let key = expand(keycode)
            if key == "\<BS>"
                " <BS>
                let pgnr = 1
                let char = matchstr(char, '.*\ze.')
                if char != ''
                    let charcomp = <SID>Ywvim_comp(char)
                    let charcomplen = len(b:ywvim_complst)
                    let pgmax = charcomplen / b:ywvim_listmax
                    if charcomplen % b:ywvim_listmax
                        let pgmax += 1
                    endif
                    let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', char, "[".(b:ywvim_pagenr+1)."]", charcomp]
                    call <SID>Ywvim_echoresult(statusl)
                else
                    redraw!
                    return ""
                endif
            else
                redraw
                return char . key
            endif
        endif
        let keycode = getchar()
    endwhile
endfunction
"}}}
function s:Ywvim_echoresult(str) "{{{
    redraw
    echohl Title | echon a:str[0]
    echohl None | echon ' '
    echon a:str[1]
    echon ' '
    echon a:str[2]
    echon ' '
    for c in a:str[3][0:-1]
        echon " "
        echohl LineNr | echon c.nr
        echohl None | echon ':'
        echon c.word
        echon c.suf
        echon c.help
    endfor
endfunction
"}}}
function s:Ywvim_enmode() "{{{
    redraw
    echon (<SID>Ywvim_echopre())."[En]: "
    let keycode = getchar()
    if keycode == char2nr(s:ywvim_{b:ywvim_active_mb}_enchar)
        let enstr = s:ywvim_{b:ywvim_active_mb}_enchar
    else
        let enstr = input("[En]: ", nr2char(keycode))
        call histdel("input", -1)
    endif
    redraw!
    return enstr
endfunction
"}}}
function s:Ywvim_onepinyin() "{{{
    let ywvim_active_oldmb = b:ywvim_active_mb
    let b:ywvim_active_mb = 'py'
    call <SID>Ywvim_loadmb()
    redraw
    echon (<SID>Ywvim_echopre()) . '[' . matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.') . '] '
    let char = <SID>Ywvim_char(nr2char(getchar()))
    let b:ywvim_active_mb = ywvim_active_oldmb
    call <SID>Ywvim_loadmb()
    return char
endfunction
"}}}
function s:Ywvim_puncp(p,n) "{{{
    let pl = split(s:ywvim_{b:ywvim_active_mb}_punclst[a:p], '\ ')
    if !exists(a:n)
        execute 'let ' . a:n . '=1'
        return pl[1]
    else
        execute 'unlet ' . a:n
        return pl[2]
    endif
endfunction
"}}}
function Ywvim_toggle(...) "{{{
    if &l:iminsert != 1 && !exists("a:1")
        call <SID>Ywvim_loadmb()
        call <SID>Ywvim_keymap()
    elseif &l:iminsert == 1
        unlet! b:ywvim_base_idxs
        unlet! b:ywvim_base_idxe
        unlet! b:ywvim_complst
    endif
    return "\<C-^>\<C-R>=Ywvim_clean()\<CR>"
endfunction
"}}}
function Ywvim_clean() "{{{
    if &l:iminsert != 1
        lmapclear <buffer>
        if s:ywvim_esc_autoff
            iunmap <buffer> <esc>
        endif
    endif
    return ""
endfunction
"}}}
"{{{1 vim: foldmethod=marker:
