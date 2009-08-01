" mY oWn VimIM.
" Author: Wu, Yue <vanopen@gmail.com>
" Last Change:	2009 Jun 11
" License: BSD

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
            let s:ywvim_{mbsname}_mbfile = m[2]
            if !filereadable(m[2])
                let s:ywvim_{mbsname}_mbfile = matchstr(globpath(s:ywvim_path, '/**/' . m[2]), "[^\n]*")
                if s:ywvim_{mbsname}_mbfile == ''
                    continue
                endif
            endif
        else
            continue
        endif
        let s:ywvim_{mbsname} = {}
        if exists("g:ywvim_{mbsname}")
            let s:ywvim_{mbsname} = g:ywvim_{mbsname}
            unlet g:ywvim_{mbsname}
        endif
        let s:ywvim_{mbsname}_imname = m[1]
        if &encoding != 'utf-8' && has("iconv")
            let s:ywvim_{mbsname}_imname = iconv(s:ywvim_{mbsname}_imname, 'utf-8', &encoding)
        endif
        let s:ywvim_{mbsname}_imnameabbr = matchstr(s:ywvim_{mbsname}_imname, '^.')
    endfor
else
    finish
endif
let s:ywvim_zhpunc = 1
if exists("g:ywvim_zhpunc")
    let s:ywvim_zhpunc = g:ywvim_zhpunc
    unlet g:ywvim_zhpunc
endif
let s:ywvim_listmax = 5
if exists("g:ywvim_listmax")
    let s:ywvim_listmax = g:ywvim_listmax
    if s:ywvim_listmax > 9
        let s:ywvim_listmax = 9
    endif
    unlet g:ywvim_listmax
endif
let s:ywvim_esc_autoff = 0
if exists("g:ywvim_esc_autoff")
    let s:ywvim_esc_autoff = g:ywvim_esc_autoff
    unlet g:ywvim_esc_autoff
endif
let s:ywvim_autoinput = 0
if exists("g:ywvim_autoinput")
    let s:ywvim_autoinput = g:ywvim_autoinput
    unlet g:ywvim_autoinput
endif
let s:ywvim_pagec = 1
if exists("g:ywvim_pagec")
    let s:ywvim_pagec = g:ywvim_pagec
    unlet g:ywvim_pagec
endif
let s:ywvim_helpim_on = 0
if exists("g:ywvim_helpim_on")
    let s:ywvim_helpim_on = g:ywvim_helpim_on
    unlet g:ywvim_helpim_on
endif
let s:ywvim_matchexact = 0
if exists("g:ywvim_matchexact")
    let s:ywvim_matchexact = g:ywvim_matchexact
    unlet g:ywvim_matchexact
endif
let s:ywvim_chinesecode = 1
if exists("g:ywvim_chinesecode")
    let s:ywvim_chinesecode = g:ywvim_chinesecode
    unlet g:ywvim_chinesecode
endif
let s:ywvim_gb = 0
if exists("g:ywvim_gb")
    let s:ywvim_gb = g:ywvim_gb
    unlet g:ywvim_gb
endif
let s:ywvim_conv = ''
if exists("g:ywvim_conv")
    let s:ywvim_conv = g:ywvim_conv
    unlet g:ywvim_conv
    let s:ywvim_preconv = 'g2b'
    if exists("g:ywvim_preconv")
        let s:ywvim_preconv = g:ywvim_preconv
    endif
endif
let s:ywvim_lockb = 0
if exists("g:ywvim_lockb")
    let s:ywvim_lockb = g:ywvim_lockb
    unlet g:ywvim_lockb
endif
let s:ywvim_pageup_keys = ',-'
let s:ywvim_pagedn_keys = '.='
let s:ywvim_inputzh_keys = ' 	'
let s:ywvim_inputzh_secondkeys = ';'
let s:ywvim_inputen_keys = ''

function s:Ywvim_loadmb(...) "{{{
    if !exists("a:1")
        if !exists("b:ywvim_active_mb")
            let b:ywvim_active_mb = s:ywvim_ims[0][0]
        endif
        let mb = b:ywvim_active_mb
    else
        let mb = a:1
    endif
    if !exists("s:ywvim_clst")
        let s:ywvim_clst = readfile(matchstr(globpath(s:ywvim_path, '/**/g2b.ywvim'), "[^\n]*"))
        let s:ywvim_clst_sep = index(s:ywvim_clst, '') + 1
    endif
    if !exists("s:ywvim_gblst")
        let s:ywvim_gblst = readfile(matchstr(globpath(s:ywvim_path, '/**/gb2312.ywvim'), "[^\n]*"))
    endif
    if exists("s:ywvim_{mb}_loaded")
        return ''
    endif
    let s:ywvim_{mb}_flst = filter(readfile(s:ywvim_{mb}_mbfile), "v:val !~ '^\s*$'")
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
    let s:ywvim_{mb}_maxelement = matchstr(matchstr(desclst, '^MaxElement'), '=\s*\zs.*')
    if has_key(s:ywvim_{mb}, 'maxelement')
        let s:ywvim_{mb}_maxelement = s:ywvim_{mb}['maxelement']
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
    let s:ywvim_{mb}_helpim_on = s:ywvim_helpim_on
    if has_key(s:ywvim_{mb}, 'helpim')
        let helpmb = s:ywvim_{mb}['helpim']
        if !exists("s:ywvim_{helpmb}_flst")
            call <SID>Ywvim_loadmb(helpmb)
        endif
        let s:ywvim_{mb}_helpmb = helpmb
    endif
    let s:ywvim_{mb}_gb = s:ywvim_gb
    if has_key(s:ywvim_{mb}, 'gb')
        let s:ywvim_{mb}_gb = s:ywvim_{mb}['gb']
    endif
    let s:ywvim_{mb}_matchexact = s:ywvim_matchexact
    if has_key(s:ywvim_{mb}, 'matchexact')
        let s:ywvim_{mb}_matchexact = s:ywvim_{mb}['matchexact']
    endif
    let s:ywvim_{mb}_zhpunc = s:ywvim_zhpunc
    if has_key(s:ywvim_{mb}, 'zhpunc')
        let s:ywvim_{mb}_zhpunc = s:ywvim_{mb}['zhpunc']
    endif
    let s:ywvim_{mb}_listmax = s:ywvim_listmax
    if has_key(s:ywvim_{mb}, 'listmax')
        let s:ywvim_{mb}_listmax = s:ywvim_{mb}['listmax']
    endif
    let s:ywvim_{mb}_punclst = s:ywvim_{mb}_flst[s:ywvim_{mb}_punc_idxs : s:ywvim_{mb}_punc_idxe]
    if &encoding != 'utf-8' && has("iconv")
        for ip in range(0, len(s:ywvim_{mb}_punclst) - 1)
            let s:ywvim_{mb}_punclst[ip] = iconv(s:ywvim_{mb}_punclst[ip], "utf-8", &encoding)
        endfor
    endif
    let s:ywvim_{mb}_chardefs = {}
    for def in s:ywvim_{mb}_flst[s:ywvim_{mb}_chardef_idxs : s:ywvim_{mb}_chardef_idxe]
        if &encoding != 'utf-8' && has("iconv")
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
    if s:ywvim_{b:ywvim_active_mb}_zhpunc == 1
        call <SID>Ywvim_keymap_punc()
    endif
    if s:ywvim_{b:ywvim_active_mb}_enchar != ''
        execute 'lnoremap <buffer> <expr> ' . s:ywvim_{b:ywvim_active_mb}_enchar . ' <SID>Ywvim_enmode()'
    endif
    if s:ywvim_{b:ywvim_active_mb}_pychar != ''
        execute 'lnoremap <buffer> <expr> ' . s:ywvim_{b:ywvim_active_mb}_pychar . ' <SID>Ywvim_onepinyin()'
    endif
    lnoremap <buffer> <C-^> <C-^><C-R>=<SID>Ywvim_parameters()<CR>
    if s:ywvim_esc_autoff
        inoremap <buffer> <esc> <C-R>=Ywvim_toggle()<CR><C-^><C-R>=Ywvim_clean()<CR><ESC>
    endif
    return ''
endfunction
" map! <silent> <C-\> <C-R>=Ywvim_toggle_1()<CR><C-R>=Ywvim_toggle_2()<CR><C-^><C-R>=Ywvim_clean()<CR>
map! <silent> <C-\> <C-R>=Ywvim_toggle()<CR><C-^><C-R>=Ywvim_clean()<CR>
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
    let punc='。'
    if s:ywvim_{b:ywvim_active_mb}_zhpunc == 0
        let punc='.'
    endif
    let pars = ''
    redraw
    echon "ywvim 参数设置[当前状态]\n"
    echohl Title | echon "(m)码表切换[" . s:ywvim_{b:ywvim_active_mb}_imname . "]\n"
    let pars .= 'm'
    echon "(.)中英标点切换[" . punc . "]\n"
    let pars .= '.'
    echon "(p)最大词长[" . s:ywvim_{b:ywvim_active_mb}_maxelement . "]\n"
    let pars .= 'p'
    echon "(g)b2312开关[" . s:ywvim_{b:ywvim_active_mb}_gb . "]\n"
    let pars .= 'g'
    echon "(c)简繁转换开关[" . s:ywvim_conv . "]\n"
    let pars .= 'c'
    if exists("s:ywvim_{b:ywvim_active_mb}_helpmb")
        echon "(h)反查码表开关[" . s:ywvim_{b:ywvim_active_mb}_helpim_on . "]\n"
        let pars .= 'h'
    endif
    echohl None
    let par = ''
    while par !~ '[' . pars . ']'
        let parcode = getchar()
        let par = nr2char(parcode)
    endwhile
    redraw
    if par == 'm'
        echon "码表切换:\n"
        let nr = 0
        for im in s:ywvim_ims
            let nr += 1
            echohl Number | echon nr
            echohl None | echon '. ' . s:ywvim_{im[0]}_imname . " "
        endfor
        let getnr = ''
        while getnr !~ '[' . join(range(1, nr), '') . ']'
            let getnr = nr2char(getchar())
        endwhile
        lmapclear <buffer>
        let b:ywvim_active_mb = s:ywvim_ims[getnr - 1][0]
        call <SID>Ywvim_loadmb()
        call <SID>Ywvim_keymap()
    elseif par == '.'
        if s:ywvim_{b:ywvim_active_mb}_zhpunc == 0
            call <SID>Ywvim_keymap_punc()
        else
            for p in s:ywvim_{b:ywvim_active_mb}_punclst
                let pl = split(p, '\s\+')
                execute 'lunmap <buffer> ' . escape(pl[0], '|')
            endfor
        endif
        if s:ywvim_{b:ywvim_active_mb}_enchar != ''
            execute 'lnoremap <buffer> <expr> ' . s:ywvim_{b:ywvim_active_mb}_enchar . ' <SID>Ywvim_enmode()'
        endif
        let s:ywvim_{b:ywvim_active_mb}_zhpunc = 1 - s:ywvim_{b:ywvim_active_mb}_zhpunc
    elseif par == 'p'
        let s:ywvim_{b:ywvim_active_mb}_maxelement = input('最大词长: ', s:ywvim_{b:ywvim_active_mb}_maxelement)
    elseif par == 'g'
        let s:ywvim_{b:ywvim_active_mb}_gb = 1 - s:ywvim_{b:ywvim_active_mb}_gb
    elseif par == 'h'
        let s:ywvim_{b:ywvim_active_mb}_helpim_on = 1 - s:ywvim_{b:ywvim_active_mb}_helpim_on
    elseif par == 'c'
        if s:ywvim_conv != ''
            let s:oldywvim_conv = s:ywvim_conv
            let s:ywvim_conv = ''
        elseif exists("s:oldywvim_conv")
            let s:ywvim_conv = s:oldywvim_conv
        else
            let s:ywvim_conv = s:ywvim_preconv
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
            if s:ywvim_{b:ywvim_active_mb}_gb == 1 && strlen(c) <= 3 && index(s:ywvim_gblst, cu) == -1
                continue
            endif
            if s:ywvim_{b:ywvim_active_mb}_maxelement > 0 && strlen(c) > 3 * s:ywvim_{b:ywvim_active_mb}_maxelement
                continue
            endif
            if s:ywvim_{b:ywvim_active_mb}_helpim_on && exists("s:ywvim_{b:ywvim_active_mb}_helpmb") && strlen(c) <= 3
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
                    let help = '[' . help . ']'
                endif
            endif
            let nr += 1
            let dic = {}
            let dic["word"] = c
            let dic["suf"] = suf
            let dic["nr"] = nr
            let dic["help"] = help
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
        if cmdtype != '@'
            let prepre = cmdtype . getcmdline() . "\n"
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
            if charcomp == [] && s:ywvim_matchexact == 0 && s:ywvim_lockb
                let char = matchstr(char, '.*\ze.')
                let showchar = matchstr(showchar, '.*\ze.')
                let charcomp = <SID>Ywvim_comp(char)
            elseif exists("b:ywvim_stra_start") && key =~ s:ywvim_{b:ywvim_active_mb}_endcodes
                    let b:ywvim_stra_end = ''
            endif
            if b:ywvim_pgbuf[b:ywvim_pagenr] != [] && s:ywvim_autoinput == 2 && b:ywvim_pgbuf[b:ywvim_pagenr][0] == b:ywvim_pgbuf[b:ywvim_pagenr][-1]
                return <SID>Ywvim_returnchar(0)
            endif
            let b:ywvim_stra_start = ''
            call <SID>Ywvim_echoresult([showchar, '[' . (b:ywvim_pagenr + 1) . ']', charcomp])
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
            call <SID>Ywvim_echoresult([showchar, '[' . (b:ywvim_pagenr + 1) . ']', b:ywvim_pgbuf[b:ywvim_pagenr]])
            if b:ywvim_pgbuf[b:ywvim_pagenr] != [] && s:ywvim_autoinput && b:ywvim_pgbuf[b:ywvim_pagenr][0] == b:ywvim_pgbuf[b:ywvim_pagenr][-1]
                return <SID>Ywvim_returnchar(0)
            endif
        elseif keycode == expand("\<PageUp>") || key =~ s:ywvim_{b:ywvim_active_mb}_pageup_keys
            " <pageup>
            if b:ywvim_pagenr > 0
                let b:ywvim_pagenr -= 1
            elseif s:ywvim_pagec
                let b:ywvim_pagenr = b:ywvim_lastpagenr
            endif
            call <SID>Ywvim_echoresult([showchar, '[' . (b:ywvim_pagenr + 1) . ']', b:ywvim_pgbuf[b:ywvim_pagenr]])
        else
            if key =~ s:ywvim_{b:ywvim_active_mb}_inputzh_keys
                " input Chinese
                if b:ywvim_pgbuf[b:ywvim_pagenr] != []
                    return <SID>Ywvim_returnchar(0)
                endif
                return <SID>Ywvim_returnchar()
            elseif key =~ s:ywvim_{b:ywvim_active_mb}_inputzh_secondkeys
                " input Second Chinese
                if b:ywvim_pgbuf[b:ywvim_pagenr] != []
                    let rei = 0
                    if len(b:ywvim_pgbuf[b:ywvim_pagenr][0]) > 1
                        let rei = 1
                    endif
                    return <SID>Ywvim_returnchar(rei)
                endif
                return <SID>Ywvim_returnchar()
            elseif key =~ '[1-' . s:ywvim_{b:ywvim_active_mb}_listmax . ']'
                " number selection
                if key <= len(b:ywvim_pgbuf[b:ywvim_pagenr])
                    return <SID>Ywvim_returnchar(key - 1)
                else
                    call <SID>Ywvim_echoresult([showchar, '[' . (b:ywvim_pagenr + 1) . ']', charcomp])
                endif
            elseif key =~ s:ywvim_{b:ywvim_active_mb}_inputen_keys
                " input English
                return <SID>Ywvim_returnchar(showchar)
            elseif keycode == "28"
                " <C-\>
                return <SID>Ywvim_returnchar(showchar) . "\<C-^>"
            elseif keycode == "30"
                " <C-^>
                return <SID>Ywvim_returnchar()
            elseif keycode == 23
                " <C-w>
                return <SID>Ywvim_returnchar()
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
                    call <SID>Ywvim_echoresult([showchar, '[' . (b:ywvim_pagenr + 1) . ']', charcomp])
                else
                    return <SID>Ywvim_returnchar()
                endif
            else
                if b:ywvim_pgbuf[b:ywvim_pagenr] != []
                    return <SID>Ywvim_returnchar(0) . key
                endif
                return <SID>Ywvim_returnchar(key)
            endif
        endif
        let keycode = getchar()
    endwhile
endfunction
"}}}
function s:Ywvim_echoresult(str) "{{{
    echo ''
    echon | echon <SID>Ywvim_echopre()
    if s:ywvim_conv != '' && s:ywvim_{b:ywvim_active_mb}_gb == 1
        echohl Todo | echon '[' . s:ywvim_{b:ywvim_active_mb}_imnameabbr . ']'
    elseif s:ywvim_conv != ''
        echohl ErrorMsg | echon '[' . s:ywvim_{b:ywvim_active_mb}_imnameabbr . ']'
    elseif s:ywvim_{b:ywvim_active_mb}_gb == 1
        echohl MoreMsg | echon '[' . s:ywvim_{b:ywvim_active_mb}_imnameabbr . ']'
    else
        echohl WarningMsg | echon '[' . s:ywvim_{b:ywvim_active_mb}_imnameabbr . ']'
    endif
    echohl None | echon ' '
    echon a:str[0]
    echon ' '
    echon a:str[1]
    echon ' '
    for c in a:str[2][0:-1]
        echon " "
        echohl LineNr | echon c.nr
        echohl None | echon ':'
        echon c.word
        echohl Comment | echon c.suf
        echohl None | echon c.help
    endfor
endfunction
"}}}
function s:Ywvim_enmode() "{{{
    echo ''
    echon <SID>Ywvim_echopre() . "[En]: "
    let keycode = getchar()
    let enstr = s:ywvim_{b:ywvim_active_mb}_enchar
    if keycode != char2nr(s:ywvim_{b:ywvim_active_mb}_enchar)
        let enstr = input("[En]: ", nr2char(keycode))
        call histdel("input", -1)
    elseif s:ywvim_{b:ywvim_active_mb}_zhpunc == 1
            let enstrpre = matchstr(matchstr(s:ywvim_{b:ywvim_active_mb}_punclst, enstr), '.$')
            if enstrpre != ''
                let enstr = enstrpre
            endif
    endif
    redraw!
    return enstr
endfunction
"}}}
function s:Ywvim_onepinyin() "{{{
    let ywvim_active_oldmb = b:ywvim_active_mb
    let b:ywvim_active_mb = 'py'
    call <SID>Ywvim_loadmb()
    echo ''
    echon <SID>Ywvim_echopre() . '[' . s:ywvim_{b:ywvim_active_mb}_imnameabbr . '] '
    let char = <SID>Ywvim_char(nr2char(getchar()))
    let b:ywvim_active_mb = ywvim_active_oldmb
    call <SID>Ywvim_loadmb()
    return char
endfunction
"}}}
function s:Ywvim_puncp(p,n) "{{{
    let pl = split(s:ywvim_{b:ywvim_active_mb}_punclst[a:p], '\ ')
    if !exists(a:n)
        execute 'let ' . a:n . ' = 1'
        return pl[1]
    else
        execute 'unlet ' . a:n
        return pl[2]
    endif
endfunction
"}}}
function s:Ywvim_returnchar(...) "{{{
    unlet! b:ywvim_stra_end
    unlet! b:ywvim_stra_start
    let sb = ''
    if exists("a:1")
        let sb = a:1
        if a:1 =~ '\d\+'
            let sb = b:ywvim_pgbuf[b:ywvim_pagenr][a:1].word
            let sbu = sb
            if &encoding != 'utf-8' && has("iconv")
                let sbu = iconv(sb, &encoding, "utf-8")
            endif
            if s:ywvim_conv != ''
                let g2bidx = index(s:ywvim_clst, sbu)
                if g2bidx != -1
                    if s:ywvim_conv == 'g2b' && g2bidx < s:ywvim_clst_sep
                        let sb = s:ywvim_clst[g2bidx + s:ywvim_clst_sep]
                    elseif s:ywvim_conv == 'b2g' && g2bidx > s:ywvim_clst_sep
                        let sb = s:ywvim_clst[g2bidx - s:ywvim_clst_sep]
                    endif
                    if &encoding != 'utf-8' && has("iconv")
                        let sb = iconv(sb, "utf-8", &encoding)
                    endif
                endif
            endif
        endif
    elseif mode() =~ '[i]'
        redraw!
    elseif getcmdtype() != '@'
        echo '' | echon getcmdtype() . getcmdline()
    endif
    if mode() !~ '[i]'
        let sb = sb . " \<BS>"
    endif
    return sb
endfunction
"}}}
function Ywvim_toggle() "{{{
    let onvar = 'b:ywvim_on_' . mode()
    if !exists(onvar)
        call <SID>Ywvim_loadmb()
        call <SID>Ywvim_keymap()
        execute 'let ' . onvar . '= ""'
    else
        unlet! b:ywvim_base_idxs
        unlet! b:ywvim_base_idxe
        unlet! b:ywvim_complst
        execute 'unlet ' . onvar
    endif
    return ""
endfunction
"}}}
function Ywvim_clean() "{{{
    let onvar = 'b:ywvim_on_' . mode()
    " if !exists(onvar)
    "     lmapclear <buffer>
    "     if s:ywvim_esc_autoff
    "         iunmap <buffer> <esc>
    "     endif
    " endif
    return ""
endfunction
"}}}
"{{{1 vim: foldmethod=marker:
