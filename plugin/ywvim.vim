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

let s:ywvim_path = expand("<sfile>:p:h")
if exists("g:ywvim_ims")
    let s:ywvim_ims = g:ywvim_ims
    unlet g:ywvim_ims
    for m in s:ywvim_ims
        let mbsname = m[0]
        if get(m, 2) != ''
            if !filereadable(m[2])
                let s:ywvim_{mbsname}_mbfile = globpath(s:ywvim_path, '/**/' . m[2])
                if s:ywvim_{mbsname}_mbfile == ''
                    continue
                endif
            else
                let s:ywvim_{mbsname}_mbfile = m[2]
            endif
        else
            continue
        endif
        if exists("g:ywvim_{mbsname}")
            let s:ywvim_{mbsname} = g:ywvim_{mbsname}
            unlet g:ywvim_{mbsname}
        else
            let s:ywvim_{mbsname} = {}
        endif
        let s:ywvim_{mbsname}_imname = m[1]
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
if exists("g:ywvim_listmax")
    if g:ywvim_listmax > 9
        let s:ywvim_listmax = 9
    else
        let s:ywvim_listmax = g:ywvim_listmax
    endif
    unlet g:ywvim_listmax
else
    let s:ywvim_listmax = 5
endif
if exists("g:ywvim_esc_autoff")
    let s:ywvim_esc_autoff = g:ywvim_esc_autoff
    unlet g:ywvim_esc_autoff
else
    let s:ywvim_esc_autoff = 0
endif
if exists("g:ywvim_autoinput")
    let s:ywvim_autoinput = g:ywvim_autoinput
    unlet g:ywvim_autoinput
else
    let s:ywvim_autoinput = 0
endif
if exists("g:ywvim_pagec")
    let s:ywvim_pagec = g:ywvim_pagec
    unlet g:ywvim_pagec
else
    let s:ywvim_pagec = 1
endif
if exists("g:ywvim_helpmbstatus")
    let s:ywvim_helpmbstatus = g:ywvim_helpmbstatus
    unlet g:ywvim_helpmbstatus
else
    let s:ywvim_helpmbstatus = 0
endif
if exists("g:ywvim_matchexact")
    let s:ywvim_matchexact = g:ywvim_matchexact
    unlet g:ywvim_matchexact
else
    let s:ywvim_matchexact = 0
endif
if exists("g:ywvim_chinesecode")
    let s:ywvim_chinesecode = g:ywvim_chinesecode
    unlet g:ywvim_chinesecode
else
    let s:ywvim_chinesecode = 1
endif
if exists("g:ywvim_wlst_on")
    let s:ywvim_wlst_on = g:ywvim_wlst_on
    unlet g:ywvim_wlst_on
else
    let s:ywvim_wlst_on = 0
endif
if exists("g:ywvim_whitelstfile")
    if g:ywvim_whitelstfile != ''
        let s:ywvim_whitelstfile = g:ywvim_whitelstfile
    endif
    unlet g:ywvim_whitelstfile
endif
let s:ywvim_pageup_keys = ',-'
let s:ywvim_pagedn_keys = '.='
let s:ywvim_inputzh_keys = ' '
let s:ywvim_inputzh_secondkeys = ';'
let s:ywvim_inputen_keys = ''

" function s:Ywvim_getqflist() "{{{ TODO secure can't allow vimgrep except when in insert mode.
"     execute 'vimgrep /^' . 'e' . '/j ' . '~/.vim/plugin/ywvim/cangjie.ywvim'
"     let s:lst = []
"     for d in getqflist()
"         call add(s:lst, d.text)
"     endfor
"     return ''
" endfunction
" "}}}
function s:Ywvim_loadmb(...) "{{{
    if !exists("a:1")
        if !exists("b:ywvim_active_mb")
            let b:ywvim_active_mb = s:ywvim_ims[0][0]
        endif
        let mb = b:ywvim_active_mb
    else
        let mb = a:1
    endif
    if exists("s:ywvim_{mb}_loaded")
        return ''
    endif
    let s:ywvim_{mb}_flst = filter(readfile(s:ywvim_{mb}_mbfile), "v:val !~ '^\s*$'")
    " let s:ywvim_{mb}_flst = filter(readfile(s:ywvim_ims[match(s:ywvim_ims, mb)][1]), "v:val !~ '^\s*$'")
    " let s:ywvim_{mb}_flst = readfile(s:ywvim_ims[match(s:ywvim_ims, mb)][1])
    let s:ywvim_{mb}_desc_idxs = index(s:ywvim_{mb}_flst, '[Description]') + 1
    let s:ywvim_{mb}_desc_idxe = index(s:ywvim_{mb}_flst, '[CharDefinition]') - 1
    let s:ywvim_{mb}_chardef_idxs = index(s:ywvim_{mb}_flst, '[CharDefinition]') + 1
    let s:ywvim_{mb}_chardef_idxe = index(s:ywvim_{mb}_flst, '[Punctuation]') - 1
    let s:ywvim_{mb}_punc_idxs = index(s:ywvim_{mb}_flst, '[Punctuation]') + 1
    let s:ywvim_{mb}_punc_idxe = index(s:ywvim_{mb}_flst, '[Main]') - 1
    let s:ywvim_{mb}_main_idxs = index(s:ywvim_{mb}_flst, '[Main]') + 1
    let s:ywvim_{mb}_main_idxe = len(s:ywvim_{mb}_flst) - 1
    let desclst = s:ywvim_{mb}_flst[s:ywvim_{mb}_desc_idxs : s:ywvim_{mb}_desc_idxe]
    let s:ywvim_{mb}_usedcodes = matchstr(matchstr(desclst, '^UsedCodes'), '=\s*\zs.*')
    let s:ywvim_{mb}_endcodes = '[' . matchstr(matchstr(desclst, '^EndCodes'), '=\zs.*') . ']'
    if has_key(s:ywvim_{mb}, 'maxelement')
        let s:ywvim_{mb}_maxelement = s:ywvim_{mb}['maxelement']
    else
        let s:ywvim_{mb}_maxelement = matchstr(matchstr(desclst, '^MaxElement'), '=\s*\zs.*')
    endif
    let s:ywvim_{mb}_enchar = matchstr(matchstr(desclst, '^EnChar'), '=\s*\zs.*')
    let s:ywvim_{mb}_pychar = matchstr(matchstr(desclst, '^PyChar'), '=\s*\zs.*')
    let s:ywvim_{mb}_inputzh_secondkeys = '[' . matchstr(matchstr(desclst, '^InputZhSecKeys'), '=\zs.*') . ']'
    if s:ywvim_{mb}_inputzh_secondkeys == '[]'
        let s:ywvim_{mb}_inputzh_secondkeys = '[' . s:ywvim_inputzh_secondkeys . ']'
    endif
    let s:ywvim_{mb}_inputzh_keys = '[' . matchstr(matchstr(desclst, '^InputZhKeys'), '=\zs.*') . ']'
    if s:ywvim_{mb}_inputzh_keys == '[]'
        let s:ywvim_{mb}_inputzh_keys = '[' . s:ywvim_inputzh_keys . ']'
    endif
    let s:ywvim_{mb}_inputen_keys = '[' . matchstr(matchstr(desclst, '^InputEnKeys'), '=\zs.*') . ']'
    if s:ywvim_{mb}_inputen_keys == '[]'
        let s:ywvim_{mb}_inputen_keys = '[' . s:ywvim_inputen_keys . ']'
    endif
    let s:ywvim_{mb}_pageupextrakeys = matchstr(matchstr(desclst, '^PageUpExtraKeys'), '=\zs.*')
    let s:ywvim_{mb}_pagednextrakeys = matchstr(matchstr(desclst, '^PageDnExtraKeys'), '=\zs.*')
    let s:ywvim_{mb}_pageup_keys = '[' . s:ywvim_pageup_keys . s:ywvim_{mb}_pageupextrakeys . ']'
    let s:ywvim_{mb}_pagedn_keys = '[' . s:ywvim_pagedn_keys . s:ywvim_{mb}_pagednextrakeys . ']'
    let s:ywvim_{mb}_helpmbstatus = s:ywvim_helpmbstatus
    if has_key(s:ywvim_{mb}, 'helpim')
        let helpmb = s:ywvim_{mb}['helpim']
        if !exists("s:ywvim_{helpmb}_flst")
            call <SID>Ywvim_loadmb(helpmb)
        endif
        let s:ywvim_{mb}_helpmb = helpmb
    endif
    if has_key(s:ywvim_{mb}, 'wlst')
        let s:ywvim_{mb}_wlst_on = s:ywvim_{mb}['wlst']
    else
        let s:ywvim_{mb}_wlst_on = s:ywvim_wlst_on
    endif
    if has_key(s:ywvim_{mb}, 'whitelstfile')
        let wlstfile = s:ywvim_{mb}['whitelstfile']
    elseif exists("s:ywvim_whitelstfile")
        let wlstfile = s:ywvim_whitelstfile
    endif
    if exists("wlstfile") && wlstfile != ''
        if !filereadable(wlstfile)
            let wlstfile = globpath(s:ywvim_path, '/**/' . wlstfile)
            if wlstfile != ''
                let s:ywvim_{mb}_wlst = readfile(wlstfile)
            endif
        endif
    endif
    if has_key(s:ywvim_{mb}, 'matchexact')
        let s:ywvim_{mb}_matchexact = s:ywvim_{mb}['matchexact']
    else
        let s:ywvim_{mb}_matchexact = s:ywvim_matchexact
    endif
    if has_key(s:ywvim_{mb}, 'zhpunc')
        let s:ywvim_{mb}_chinesepunc = s:ywvim_{mb}['zhpunc']
    else
        let s:ywvim_{mb}_chinesepunc = s:ywvim_chinesepunc
    endif
    if has_key(s:ywvim_{mb}, 'listmax')
        let s:ywvim_{mb}_listmax = s:ywvim_{mb}['listmax']
    else
        let s:ywvim_{mb}_listmax = s:ywvim_listmax
    endif
    let s:ywvim_{mb}_punclst = s:ywvim_{mb}_flst[s:ywvim_{mb}_punc_idxs : s:ywvim_{mb}_punc_idxe]
    if &enc != 'utf-8' && has("iconv")
        for ip in range(0,len(s:ywvim_{mb}_punclst)-1)
            let s:ywvim_{mb}_punclst[ip] = iconv(s:ywvim_{mb}_punclst[ip], "utf-8", &encoding)
        endfor
    endif
    let s:ywvim_{mb}_chardefs = {}
    for def in s:ywvim_{mb}_flst[s:ywvim_{mb}_chardef_idxs : s:ywvim_{mb}_chardef_idxe]
        if &enc != 'utf-8' && has("iconv")
            let def = iconv(def, "utf-8", &encoding)
        endif
        let chardef = split(def, '\s\+')
        if len(chardef) == 2
            execute 'let s:ywvim_{mb}_chardefs["' . chardef[0] . '"] = "' . chardef[1] . '"'
        endif
    endfor
    let s:ywvim_{mb}_loaded = 1
    return ''
endfunction
"}}}
function s:Ywvim_keymap() "{{{
    for key in sort(split(s:ywvim_{b:ywvim_active_mb}_usedcodes,'\zs'))
        execute 'lnoremap <buffer> <expr> ' . key . '  <SID>Ywvim_char("' . key . '")'
    endfor
    if s:ywvim_{b:ywvim_active_mb}_chinesepunc == 1
        call <SID>Ywvim_keymap_punc()
    endif
    if s:ywvim_{b:ywvim_active_mb}_enchar != ''
        execute 'lnoremap <buffer> <expr> ' . s:ywvim_{b:ywvim_active_mb}_enchar . ' <SID>Ywvim_enmode()'
    endif
    if s:ywvim_{b:ywvim_active_mb}_pychar != ''
        execute 'lnoremap <buffer> <expr> ' . s:ywvim_{b:ywvim_active_mb}_pychar . ' <SID>Ywvim_onepinyin()'
    endif
    lnoremap <silent> <buffer> <C-^> <C-^><C-R>=<SID>Ywvim_parameters()<CR>
    lmap <silent> <buffer> <C-m> <C-R>=<SID>Ywvim_wlst_toggle()<CR>
    if s:ywvim_esc_autoff
        inoremap <silent> <buffer> <esc> <C-R>=Ywvim_toggle(0)<CR><ESC>
    endif
    return ''
endfunction
" imap <silent> <expr> <C-\> Ywvim_toggle()
" cmap <silent> <expr> <C-\> Ywvim_toggle()
map! <silent> <expr> <C-\> Ywvim_toggle()
"}}}
function s:Ywvim_keymap_punc() "{{{
    for p in s:ywvim_{b:ywvim_active_mb}_punclst
        let pl = split(p, '\s\+')
        if index(split(s:ywvim_{b:ywvim_active_mb}_usedcodes,'\zs'), pl) == -1
            if len(pl) == 2
                execute 'lnoremap <buffer> ' . escape(pl[0], '|') . ' ' . pl[1]
            elseif len(pl) == 3
                execute 'lnoremap <buffer> <expr> ' . escape(pl[0], '|') . ' <SID>Ywvim_puncp(' . index(s:ywvim_{b:ywvim_active_mb}_punclst, p) . ',"s:ywvim_{b:ywvim_active_mb}_punc_' . char2nr(pl[0]) . '")'
            endif
        endif
    endfor
endfunction
"}}}
function s:Ywvim_parameters() "{{{
    if s:ywvim_{b:ywvim_active_mb}_chinesepunc == 0
        let punc='.'
    else
        let punc='。'
    endif
    if s:ywvim_{b:ywvim_active_mb}_wlst_on == 1
        let wlst='on'
    else
        let wlst='off'
    endif
    redraw
    echon "ywvim 参数设置[当前状态]\n"
    echohl Title
    echon "(m)码表切换[" . s:ywvim_{b:ywvim_active_mb}_imname . "]\n"
    echon "(.)中英标点切换[" . punc . "]\n"
    echon "(p)最大词长[" . s:ywvim_{b:ywvim_active_mb}_maxelement . "]\n"
    echon "(w)白名单开关[" . wlst . "]\n"
    if exists("s:ywvim_{b:ywvim_active_mb}_helpmb")
        echon "(h)反查码表开关[" . s:ywvim_{b:ywvim_active_mb}_helpmbstatus . "]\n"
    endif
    echohl None
    let par = ''
    while par !~ '[m.pwh]'
        let parcode = getchar()
        if parcode == 13
            redraw!
            return ''
        endif
        let par = nr2char(parcode)
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
                echon '. ' . s:ywvim_{im[0]}_imname . " "
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
        if s:ywvim_{b:ywvim_active_mb}_chinesepunc == 0
            call <SID>Ywvim_keymap_punc()
            let s:ywvim_{b:ywvim_active_mb}_chinesepunc = 1
        else
            for p in s:ywvim_{b:ywvim_active_mb}_punclst
                let pl = split(p, '\s\+')
                execute 'lunmap <silent> <buffer> ' . escape(pl[0], '|')
            endfor
            let s:ywvim_{b:ywvim_active_mb}_chinesepunc = 0
        endif
    elseif par == 'p'
        let s:ywvim_{b:ywvim_active_mb}_maxelement = input('最大词长: ', s:ywvim_{b:ywvim_active_mb}_maxelement)
    elseif par == 'w'
        call <SID>Ywvim_wlst_toggle()
    elseif par == 'h'
        if s:ywvim_{b:ywvim_active_mb}_helpmbstatus == 1
            let s:ywvim_{b:ywvim_active_mb}_helpmbstatus = 0
        else
            let s:ywvim_{b:ywvim_active_mb}_helpmbstatus = 1
        endif
    endif
    redraw
    return "\<C-^>"
endfunction
"}}}
function s:Ywvim_comp(base,...) "{{{
    let len_base = len(a:base)
    let exactp = ''
    if s:ywvim_{b:ywvim_active_mb}_matchexact
        let exactp = ' '
    endif
    let basep = escape(a:base, ']./[') . exactp
    if exists("a:1")
        let b:ywvim_base_idxs = a:1
    else
        let b:ywvim_base_idxs = match(s:ywvim_{b:ywvim_active_mb}_flst, '^' . basep, s:ywvim_{b:ywvim_active_mb}_main_idxs)
        let b:ywvim_startline = b:ywvim_base_idxs
        let b:ywvim_base_idxe = match(s:ywvim_{b:ywvim_active_mb}_flst, '^\(' . basep . '\)\@!', b:ywvim_base_idxs) - 1
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
            let cu = c
            let cup = '\<' . cu . '\>'
            if &encoding != 'utf-8' && has("iconv")
                let cu = iconv(c, &encoding, "utf-8")
                let cup = ' ' . cu . ' '
            endif
            if exists("s:ywvim_{b:ywvim_active_mb}_wlst") && s:ywvim_{b:ywvim_active_mb}_wlst_on == 1 && strlen(c) <= 3
                if index(s:ywvim_{b:ywvim_active_mb}_wlst, cu) == -1 && s:ywvim_{b:ywvim_active_mb}_wlst_on == 1
                    continue
                endif
            endif
            if s:ywvim_{b:ywvim_active_mb}_maxelement > 0 && strlen(c) > 3 * s:ywvim_{b:ywvim_active_mb}_maxelement
                continue
            endif
            if s:ywvim_{b:ywvim_active_mb}_helpmbstatus && exists("s:ywvim_{b:ywvim_active_mb}_helpmb") && strlen(c) <= 3
                let help = matchstr(matchstr(s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_flst[s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxs : s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxe], cup), '^\S\+')
                " let leng = (s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxe - s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxs) / 2
                " let lengs = s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxs
                " let lenge = s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxs + leng
                " while help == ''
                "     if help == ''
                "         let help = matchstr(matchstr(s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_flst[lengs : lenge], cup), '^\S\+')
                "     endif
                "     if lenge < s:ywvim_{s:ywvim_{b:ywvim_active_mb}_helpmb}_main_idxe
                "         let lengs += leng
                "         let lenge += leng
                "     else
                "         break
                "     endif
                " endwhile
                if help != ''
                    let help = '<' . help . '>'
                endif
            endif
            let nr += 1
            let dic = {}
            let dic["word"] = c
            let dic["suf"] = suf
            let dic["nr"] = nr
            let dic["help"] = help
            let help = ''
            call add(b:ywvim_complst, dic)
            if nr == s:ywvim_{b:ywvim_active_mb}_listmax
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
        let b:ywvim_lastpagenr = 0
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
    let showchar = ''
    let keycode = char2nr(a:key)
    while 1
        let key = nr2char(keycode)
        if index(split(s:ywvim_{b:ywvim_active_mb}_usedcodes, '\zs'), key) != -1 && !exists("b:ywvim_stra_end")
            " code keys
            let pgnr = 1
            if key != ' '
                let char .= key
                if has_key(s:ywvim_{b:ywvim_active_mb}_chardefs, key) && s:ywvim_chinesecode
                    let showchar .= s:ywvim_{b:ywvim_active_mb}_chardefs[key]
                else
                    let showchar .= key
                endif
            endif
            let charcomp = <SID>Ywvim_comp(char)
            let charcomplen = len(b:ywvim_complst)
            if charcomp == [] && s:ywvim_matchexact == 0
                let char = matchstr(char, '.*\ze.')
                let showchar = matchstr(showchar, '.*\ze.')
                let charcomp = <SID>Ywvim_comp(char)
            elseif exists("b:ywvim_stra_start") && key =~ s:ywvim_{b:ywvim_active_mb}_endcodes
                    let b:ywvim_stra_end = ''
            endif
            if b:ywvim_pgbuf[b:ywvim_pagenr] != [] && s:ywvim_autoinput == 2 && b:ywvim_pgbuf[b:ywvim_pagenr][0] == b:ywvim_pgbuf[b:ywvim_pagenr][-1]
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_start
                return b:ywvim_pgbuf[b:ywvim_pagenr][0].word
            endif
            let b:ywvim_stra_start = ''
            let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', showchar, "[".(b:ywvim_pagenr+1)."]", charcomp]
            call <SID>Ywvim_echoresult(statusl)
        elseif keycode == expand("\<PageDown>") || key =~ s:ywvim_{b:ywvim_active_mb}_pagedn_keys
            " <pagedown>
            let b:ywvim_pagenr += 1
            if !has_key(b:ywvim_pgbuf, b:ywvim_pagenr)
                let page = <SID>Ywvim_comp(char,b:ywvim_startline,b:ywvim_endchar)
                if page != []
                    if b:ywvim_lastpagenr <= b:ywvim_pagenr
                        let b:ywvim_lastpagenr = b:ywvim_pagenr
                    endif
                    let b:ywvim_pgbuf[b:ywvim_pagenr] = page
                else
                    if s:ywvim_pagec
                        let b:ywvim_pagenr = 0
                    else
                        let b:ywvim_pagenr -= 1
                    endif
                endif
            endif
            let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', showchar, "[".(b:ywvim_pagenr+1)."]", b:ywvim_pgbuf[b:ywvim_pagenr]]
            call <SID>Ywvim_echoresult(statusl)
            if b:ywvim_pgbuf[b:ywvim_pagenr] != [] && s:ywvim_autoinput && b:ywvim_pgbuf[b:ywvim_pagenr][0] == b:ywvim_pgbuf[b:ywvim_pagenr][-1]
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_start
                return b:ywvim_pgbuf[b:ywvim_pagenr][0].word
            endif
        elseif keycode == expand("\<PageUp>") || key =~ s:ywvim_{b:ywvim_active_mb}_pageup_keys
            " <pageup>
            if b:ywvim_pagenr > 0
                let b:ywvim_pagenr -= 1
            elseif s:ywvim_pagec
                let b:ywvim_pagenr = b:ywvim_lastpagenr
            endif
            let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', showchar, "[".(b:ywvim_pagenr+1)."]", b:ywvim_pgbuf[b:ywvim_pagenr]]
            call <SID>Ywvim_echoresult(statusl)
        else
            redraw
            if key =~ s:ywvim_{b:ywvim_active_mb}_inputzh_keys
                " input Chinese
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_start
                if b:ywvim_pgbuf[b:ywvim_pagenr] != []
                    return b:ywvim_pgbuf[b:ywvim_pagenr][0].word
                endif
                redraw!
                return ""
            elseif key =~ s:ywvim_{b:ywvim_active_mb}_inputzh_secondkeys
                " input Second Chinese
                if b:ywvim_pgbuf[b:ywvim_pagenr] != []
                    if b:ywvim_pgbuf[b:ywvim_pagenr][0] != b:ywvim_pgbuf[b:ywvim_pagenr][-1]
                        unlet! b:ywvim_stra_end
                        unlet! b:ywvim_stra_start
                        return b:ywvim_pgbuf[b:ywvim_pagenr][1].word
                    else
                        return b:ywvim_pgbuf[b:ywvim_pagenr][0].word . key
                    endif
                endif
                redraw!
                return ""
            elseif key =~ '[1-' . s:ywvim_{b:ywvim_active_mb}_listmax . ']'
                " select
                if key <= len(b:ywvim_pgbuf[b:ywvim_pagenr])
                    unlet! b:ywvim_stra_end
                    unlet! b:ywvim_stra_start
                    return b:ywvim_pgbuf[b:ywvim_pagenr][key - 1].word
                else
                    call <SID>Ywvim_echoresult(statusl)
                endif
            elseif key =~ s:ywvim_{b:ywvim_active_mb}_inputen_keys
                " input English
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_start
                return showchar
            elseif keycode == "28"
                " <C-\>
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_start
                return showchar . "\<C-^>"
            elseif keycode == "30"
                " <C-^>
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_start
                redraw!
                return ""
            elseif keycode == 23
                " <C-w>
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_start
                redraw!
                return ""
            elseif keycode == expand("\<BS>")
                " <BS>
                let pgnr = 1
                unlet! b:ywvim_stra_end
                let char = matchstr(char, '.*\ze.')
                let showchar = matchstr(showchar, '.*\ze.')
                if char != ''
                    let charcomp = <SID>Ywvim_comp(char)
                    let charcomplen = len(b:ywvim_complst)
                    let pgmax = charcomplen / s:ywvim_{b:ywvim_active_mb}_listmax
                    if charcomplen % s:ywvim_{b:ywvim_active_mb}_listmax
                        let pgmax += 1
                    endif
                    let statusl = [(<SID>Ywvim_echopre()).'['.matchstr(s:ywvim_{b:ywvim_active_mb}_imname, '^.').']', showchar, "[".(b:ywvim_pagenr+1)."]", charcomp]
                    call <SID>Ywvim_echoresult(statusl)
                else
                    redraw!
                    unlet! b:ywvim_stra_start
                    return ""
                endif
            else
                redraw
                unlet! b:ywvim_stra_end
                unlet! b:ywvim_stra_end
                if b:ywvim_pgbuf[b:ywvim_pagenr] != []
                    return b:ywvim_pgbuf[b:ywvim_pagenr][0].word . key
                endif
                return key
            endif
        endif
        let keycode = getchar()
    endwhile
endfunction
"}}}
function s:Ywvim_echoresult(str) "{{{
    redraw
    if exists("s:ywvim_{b:ywvim_active_mb}_wlst") && s:ywvim_{b:ywvim_active_mb}_wlst_on == 1
        echohl Title | echon a:str[0]
    else
        echohl WarningMsg | echon a:str[0]
    endif
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
function s:Ywvim_wlst_toggle() "{{{
    if s:ywvim_{b:ywvim_active_mb}_wlst_on == 1
        let s:ywvim_{b:ywvim_active_mb}_wlst_on = 0
    else
        let s:ywvim_{b:ywvim_active_mb}_wlst_on = 1
    endif
    return ''
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
