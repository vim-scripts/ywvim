" mY oWn VimIM.
" Author: Wu, Yue <ywupub@gmail.com>
" Last Change:	2015-02-11
" Release Version: 1.24
" License: BSD

" ~/projects/vimscript/ywvim/changelog
" ~/projects/vimscript/ywvim/manual

" ？TODO GB support doesnlt work as expected when swithing im.
" TODO EnMode 时可以切换中文输入法。

scriptencoding utf-8
if exists("s:loaded_ywvim") | finish | endif
let s:loaded_ywvim = 1

let s:ywvim_path = expand("<sfile>:p:h")
let s:ywvim_utfhanzi_rangehexlist = [
            \['0x4E00', '0x9FA5'],
            \['0x3400', '0x4DB5'],
            \['0x9FA6', '0x9FBB'],
            \['0xF900', '0xFA2D'],
            \['0xFA30', '0xFA6A'],
            \['0xFA70', '0xFAD9'],
            \['0x20000', '0x2A6D6'],
            \['0x2F800', '0x2FA1D']]

function s:Ywvim_SetVar(var, val) " Assign user var to script var{{{
    let s:{a:var} = a:val
    if exists('g:'.a:var)
        let s:{a:var} = g:{a:var}
        unlet g:{a:var}
    endif
endfunction "}}}

function s:Ywvim_loadvar() " Load global user vars.{{{
    let s:ywvim_ims = []
    if exists("g:ywvim_ims")
        for v in g:ywvim_ims
            let mbvar = v
            let mbintername = mbvar[0]
            let mbchinesename = mbvar[1]
            if get(mbvar, 2) != '' " Get mb file info
                let s:ywvim_{mbintername}_mbfile = mbvar[2]
                if !filereadable(expand(mbvar[2]))
                    let s:ywvim_{mbintername}_mbfile = matchstr(globpath(s:ywvim_path, '/**/'.mbvar[2]), "[^\n]*")
                    if s:ywvim_{mbintername}_mbfile == ''
                        continue
                    endif
                endif
            else
                continue
            endif
            call <SID>Ywvim_SetVar('ywvim_'.mbintername, {})
            call add(s:ywvim_ims, [mbintername, mbchinesename, s:ywvim_{mbintername}_mbfile])
        endfor
        unlet g:ywvim_ims
    endif
    if s:ywvim_ims==[]
        finish
    endif

    let varlst = [
                \["ywvim_theme", 'light'],
                \["ywvim_lockb", 1],
                \["ywvim_zhpunc", 1],
                \["ywvim_autoinput", 0],
                \["ywvim_circlecandidates", 1],
                \["ywvim_helpim_on", 0],
                \["ywvim_matchexact", 0],
                \["ywvim_chinesecode", 1],
                \["ywvim_gb", 0],
                \["ywvim_esc_autoff", 0],
                \["ywvim_listmax", 5],
                \['ywvim_conv', ""],
                \['ywvim_preconv', "g2b"],
                \['ywvim_pageupkeys', ",-"],
                \['ywvim_pagednkeys', ".="],
                \['ywvim_inputzh_keys', " 	"],
                \['ywvim_inputzh_secondkeys', ";"],
                \['ywvim_inputen_keys', ""],
                \['ywvim_extraimbarlength', 0],
                \]
    for v in varlst
        call <SID>Ywvim_SetVar(v[0], v[1])
    endfor

    if s:ywvim_listmax > 9
        let s:ywvim_listmax = 9
    endif
endfunction "}}}

function s:Ywvim_loadmb(...) "{{{
    if exists("a:1")
        let mbintername = a:1
    elseif exists('b:ywvim_parameters["active_mb"]')
        let mbintername = b:ywvim_parameters["active_mb"]
    else
        let mbintername = s:ywvim_ims[0][0]
    endif
    if !exists("s:ywvim_{mbintername}_mb_encoding")
        let s:ywvim_{mbintername}_mb_encoding = 'utf-8'
    endif
    let b:ywvim_parameters["active_mb"] = mbintername
    if !exists("s:ywvim_{mbintername}_loaded")
        let s:ywvim_{mbintername}_mbdb = filter(readfile(s:ywvim_{mbintername}_mbfile), "v:val !~ '^\s*$'")
        let s:ywvim_{mbintername}_loaded = 1
        let loadmb = 1
    endif
    if s:ywvim_{mbintername}_mb_encoding != &encoding
        call map(s:ywvim_{mbintername}_mbdb, 'iconv(v:val, s:ywvim_{mbintername}_mb_encoding, &encoding)')
        let s:ywvim_{mbintername}_mb_encoding = &encoding
        let loadmb = 1
    endif
    if exists("loadmb")
        let s:ywvim_{mbintername}_desc_idxs = match(s:ywvim_{mbintername}_mbdb, '^\[Description]') + 1
        let s:ywvim_{mbintername}_desc_idxe = match(s:ywvim_{mbintername}_mbdb, '^\[[^]]\+]', s:ywvim_{mbintername}_desc_idxs) - 1
        let s:ywvim_{mbintername}_chardef_idxs = match(s:ywvim_{mbintername}_mbdb, '^\[CharDefinition]') + 1
        let s:ywvim_{mbintername}_chardef_idxe = match(s:ywvim_{mbintername}_mbdb, '^\[[^]]\+]', s:ywvim_{mbintername}_chardef_idxs) - 1
        let s:ywvim_{mbintername}_punc_idxs = match(s:ywvim_{mbintername}_mbdb, '^\[Punctuation]') + 1
        let s:ywvim_{mbintername}_punc_idxe = match(s:ywvim_{mbintername}_mbdb, '^\[[^]]\+]', s:ywvim_{mbintername}_punc_idxs) - 1
        let s:ywvim_{mbintername}_main_idxs = match(s:ywvim_{mbintername}_mbdb, '^\[Main]') + 1
        let s:ywvim_{mbintername}_main_idxe = len(s:ywvim_{mbintername}_mbdb) - 1

        let descriptlst = s:ywvim_{mbintername}_mbdb[s:ywvim_{mbintername}_desc_idxs : s:ywvim_{mbintername}_desc_idxe]
        let s:ywvim_{mbintername}_name = substitute(matchstr(matchstr(descriptlst, '^Name'), '^[^=]\+=\s*\zs.*'), '\s', '', 'g')
        let s:ywvim_{mbintername}_nameabbr = matchstr(s:ywvim_{mbintername}_name, '^.')
        let s:ywvim_{mbintername}_usedcodes =substitute(matchstr(matchstr(descriptlst, '^UsedCodes'), '^[^=]\+=\s*\zs.*'), '\s', '', 'g')
        let s:ywvim_{mbintername}_endcodes = '[' . matchstr(matchstr(descriptlst, '^EndCodes'), '^[^=]\+=\zs.*') . ']'
        call <SID>Ywvim_SetMbVar(mbintername, 'maxphraselength', matchstr(matchstr(descriptlst, '^MaxElement'), '^[^=]\+=\s*\zs.*'))
        let s:ywvim_{mbintername}_enchar = matchstr(matchstr(descriptlst, '^EnChar'), '^[^=]\+=\s*\zs.*')
        let s:ywvim_{mbintername}_pychar = matchstr(matchstr(descriptlst, '^PyChar'), '^[^=]\+=\s*\zs.*')
        call <SID>Ywvim_SetMbVar(mbintername, 'inputzh_secondkeys', matchstr(matchstr(descriptlst, '^InputZhSecKeys'), '^[^=]\+=\zs.*'))
        call <SID>Ywvim_SetMbVar(mbintername, 'inputzh_keys', matchstr(matchstr(descriptlst, '^InputZhKeys'), '^[^=]\+=\zs.*'))
        call <SID>Ywvim_SetMbVar(mbintername, 'inputen_keys', matchstr(matchstr(descriptlst, '^InputEnKeys'), '^[^=]\+=\zs.*'))
        let s:ywvim_{mbintername}_altpageupkeys = matchstr(matchstr(descriptlst, '^AltPageUpKeys'), '^[^=]\+=\zs.*')
        let s:ywvim_{mbintername}_altpagednkeys = matchstr(matchstr(descriptlst, '^AltPageDnKeys'), '^[^=]\+=\zs.*')
        let s:ywvim_{mbintername}_pageupkeys = '[' . s:ywvim_pageupkeys . s:ywvim_{mbintername}_altpageupkeys . ']'
        let s:ywvim_{mbintername}_pagednkeys = '[' . s:ywvim_pagednkeys . s:ywvim_{mbintername}_altpagednkeys . ']'
        let s:ywvim_{mbintername}_helpim_on = s:ywvim_helpim_on
        if has_key(s:ywvim_{mbintername}, 'helpim')
            let helpmb = s:ywvim_{mbintername}['helpim']
            if !exists("s:ywvim_{helpmb}_mbdb")
                call <SID>Ywvim_loadmb(helpmb)
            endif
            let s:ywvim_{mbintername}_helpmb = helpmb
        endif
        call <SID>Ywvim_SetScriptVar(mbintername, 'gb')
        call <SID>Ywvim_SetScriptVar(mbintername, 'matchexact')
        call <SID>Ywvim_SetScriptVar(mbintername, 'zhpunc')
        call <SID>Ywvim_SetScriptVar(mbintername, 'listmax')
        let s:ywvim_{mbintername}_puncdic = {}
        for p in s:ywvim_{mbintername}_mbdb[s:ywvim_{mbintername}_punc_idxs : s:ywvim_{mbintername}_punc_idxe]
            let pl = split(p, '\s\+')
            let s:ywvim_{mbintername}_puncdic[pl[0]] = pl[1 : -1]
        endfor
        let s:ywvim_{mbintername}_chardefs = {}
        for def in s:ywvim_{mbintername}_mbdb[s:ywvim_{mbintername}_chardef_idxs : s:ywvim_{mbintername}_chardef_idxe]
            let chardef = split(def, '\s\+')
            let s:ywvim_{mbintername}_chardefs[chardef[0]] = chardef[1]
        endfor
    endif

    if s:ywvim_conv != ''
        call <SID>YwvimLoadConvertList()
    endif
    if s:ywvim_{mbintername}_gb
        call <SID>YwvimLoadGBList()
    endif

    if !exists("a:1")
        let b:keymap_name=s:ywvim_{mbintername}_nameabbr
    endif

    call <SID>YwvimHighlight()
    return ''
endfunction "}}}

function s:Ywvim_SetScriptVar(m, n) "{{{
    let s:ywvim_{a:m}_{a:n} = s:ywvim_{a:n}
    if has_key(s:ywvim_{a:m}, a:n)
        let s:ywvim_{a:m}_{a:n} = s:ywvim_{a:m}[a:n]
    endif
endfunction "}}}
function s:Ywvim_SetMbVar(m, n, v) "{{{
    let s:ywvim_{a:m}_{a:n} = a:v
    if s:ywvim_{a:m}_{a:n} == ''
        let s:ywvim_{a:m}_{a:n} = s:ywvim_{a:n}
    endif
endfunction "}}}
function s:YwvimLoadConvertList() "{{{
    if !exists("s:ywvim_clst")
        let s:ywvim_g2b_mb_encoding = 'utf-8'
        let s:ywvim_clst = []
        let clstfile = matchstr(globpath(s:ywvim_path, '/**/g2b.ywvim'), "[^\n]*")
        if filereadable(clstfile)
            let s:ywvim_clst = readfile(clstfile)
            let s:ywvim_clst_sep = index(s:ywvim_clst, '') + 1
        endif
    endif
    if s:ywvim_g2b_mb_encoding != &encoding
        call map(s:ywvim_clst, 'iconv(v:val, s:ywvim_g2b_mb_encoding, &encoding)')
        let s:ywvim_g2b_mb_encoding = &encoding
    endif
endfunction "}}}
function s:YwvimLoadGBList() "{{{ old dirty but quick way
        if !exists("s:ywvim_gbfilterlist")
            let s:ywvim_gbfilter_mb_encoding = 'utf-8'
            let s:ywvim_gbfilterlist = []
            let gblstfile = matchstr(globpath(s:ywvim_path, '/**/gb2312.ywvim'), "[^\n]*")
            if filereadable(gblstfile)
                let s:ywvim_gbfilterlist = readfile(gblstfile)
            endif
        endif
        if s:ywvim_gbfilter_mb_encoding != &encoding
            call map(s:ywvim_gbfilterlist, 'iconv(v:val, s:ywvim_gbfilter_mb_encoding, &encoding)')
            let s:ywvim_gbfilter_mb_encoding = &encoding
        endif
        " FIXME gb 过滤 only work on 'utf-8', doesn't work in other &encoding
        if &encoding == 'utf-8'
            let s:ywvim_hanzi_rangelist = map(copy(s:ywvim_utfhanzi_rangehexlist), '[nr2char(str2nr(v:val[0],16)), nr2char(str2nr(v:val[1],16))]')
        endif
endfunction "}}}
function s:YwvimHighlight() "{{{
    if s:ywvim_theme == 'dark'
        if &t_Co == 8
            highlight ywvimIMnormal ctermfg=7 ctermbg=0
            highlight ywvimIMname ctermfg=4 ctermbg=0
            highlight ywvimIMCursor ctermbg=4
            highlight ywvimIMnr term=underline ctermfg=4 ctermbg=0
            highlight ywvimIMcode ctermfg=1 ctermbg=0
        elseif &t_Co == 16
            highlight ywvimIMnormal ctermfg=7 ctermbg=0
            highlight ywvimIMname ctermfg=1 ctermbg=0
            highlight ywvimIMCursor ctermbg=1
            highlight ywvimIMnr term=underline ctermfg=1 ctermbg=0
            highlight ywvimIMcode ctermfg=4 ctermbg=0
        else
            highlight ywvimIMnormal ctermfg=LightGrey guifg=LightGrey ctermbg=Black guibg=Black
            highlight ywvimIMname ctermfg=DarkBlue guifg=Blue ctermbg=Black guibg=Black
            highlight ywvimIMCursor ctermbg=DarkBlue guibg=Blue
            highlight ywvimIMnr term=underline ctermfg=DarkBlue guifg=Blue ctermbg=Black guibg=Black
            highlight ywvimIMcode ctermfg=DarkRed guifg=Red ctermbg=Black guibg=Black
        endif
    else
        if &t_Co == 8
            highlight ywvimIMnormal ctermfg=0 ctermbg=7
            highlight ywvimIMname ctermfg=4 ctermbg=7
            highlight ywvimIMCursor ctermbg=4
            highlight ywvimIMnr term=underline ctermfg=4 ctermbg=7
            highlight ywvimIMcode ctermfg=1 ctermbg=7
        elseif &t_Co == 16
            highlight ywvimIMnormal ctermfg=0 ctermbg=7
            highlight ywvimIMname ctermfg=1 ctermbg=7
            highlight ywvimIMCursor ctermbg=1
            highlight ywvimIMnr term=underline ctermfg=1 ctermbg=7
            highlight ywvimIMcode ctermfg=4 ctermbg=7
        else
            highlight ywvimIMnormal ctermfg=black guifg=black ctermbg=LightGrey guibg=LightGrey
            highlight ywvimIMname ctermfg=DarkBlue guifg=Blue ctermbg=LightGrey guibg=LightGrey
            highlight ywvimIMCursor ctermbg=DarkBlue guibg=Blue
            highlight ywvimIMnr term=underline ctermfg=DarkBlue guifg=Blue ctermbg=LightGrey guibg=LightGrey
            highlight ywvimIMcode ctermfg=Red guifg=Red ctermbg=LightGrey guibg=LightGrey
        endif
    endif
    if s:ywvim_conv != '' " 打开简繁转换
        if &t_Co == 8
            highlight ywvimIMname ctermfg=1 ctermbg=3
            highlight ywvimIMCursor ctermbg=1
        elseif &t_Co == 16
            highlight ywvimIMname ctermfg=4 ctermbg=6
            highlight ywvimIMCursor ctermbg=4
        else
            highlight ywvimIMname ctermfg=Red guifg=Red ctermbg=Yellow guibg=Yellow
            highlight ywvimIMCursor ctermbg=Red guibg=Red
        endif
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_gb == 1 " 打开只输入gb2312
            if &t_Co == 8
                highlight ywvimIMname ctermfg=4 ctermbg=3
                highlight ywvimIMCursor ctermbg=4
            elseif &t_Co == 16
                highlight ywvimIMname ctermfg=1 ctermbg=6
                highlight ywvimIMCursor ctermbg=1
            else
                highlight ywvimIMname ctermfg=DarkBlue guifg=Blue ctermbg=Yellow guibg=Yellow
                highlight ywvimIMCursor ctermbg=DarkBlue guibg=Blue
            endif
        endif
    elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_gb == 0 " 关闭只输入gb2312
        if s:ywvim_theme == 'dark'
            if &t_Co == 8
                highlight ywvimIMname ctermfg=1 ctermbg=0
                highlight ywvimIMCursor ctermbg=1
            elseif &t_Co == 16
                highlight ywvimIMname ctermfg=4 ctermbg=0
                highlight ywvimIMCursor ctermbg=4
            else
                highlight ywvimIMname ctermfg=Red guifg=Red ctermbg=DarkGrey guibg=Black
                highlight ywvimIMCursor ctermbg=Red guibg=Red
            endif
        else
            if &t_Co == 8
                highlight ywvimIMname ctermfg=1 ctermbg=7
                highlight ywvimIMCursor ctermbg=1
            elseif &t_Co == 16
                highlight ywvimIMname ctermfg=4 ctermbg=7
                highlight ywvimIMCursor ctermbg=4
            else
                highlight ywvimIMname ctermfg=Red guifg=Red ctermbg=LightGrey guibg=LightGrey
                highlight ywvimIMCursor ctermbg=Red guibg=Red
            endif
        endif
    endif
endfunction "}}}

function s:Ywvim_keymap_punc(t) "{{{
    if a:t == 1
        for p in keys(s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic)
            execute 'lnoremap <buffer> <expr> '.escape(p, '\|')." <SID>Ywvim_puncp(".string(escape(p, '\|')).")"
        endfor
    elseif a:t == 0
        for p in keys(s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic)
            execute 'lunmap <buffer> ' . escape(p, '\|')
        endfor
    endif
endfunction "}}}

function s:Ywvim_puncp(p) "{{{
    let pmap = s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic[a:p]
    let lenpmap = len(pmap)
    if lenpmap == 1
        return pmap[0]
    else
        let pid = char2nr(a:p)
        if !exists('b:ywvim_{b:ywvim_parameters["active_mb"]}_punc_{pid}')
            let b:ywvim_{b:ywvim_parameters["active_mb"]}_punc_{pid} = 1
            return pmap[0]
        else
            unlet b:ywvim_{b:ywvim_parameters["active_mb"]}_punc_{pid}
            return pmap[1]
        endif
    endif
endfunction "}}}

function s:Ywvim_keymap(m) "{{{
    if (a:m == 'a') || (a:m == 'k')
        for key in sort(split(s:ywvim_{b:ywvim_parameters["active_mb"]}_usedcodes,'\zs'))
            execute 'lnoremap <buffer> <expr> '.escape(key, '\|').'  <SID>Ywvim_char("'.key.'")'
        endfor
    endif
    if (a:m == 'a') || (a:m == 'p')
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc == 1
            call <SID>Ywvim_keymap_punc(1)
        endif
    endif
    if (a:m == 'a') || (a:m == 'e')
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_enchar != ''
            execute 'lnoremap <buffer> <expr> '.s:ywvim_{b:ywvim_parameters["active_mb"]}_enchar.' <SID>Ywvim_enmode()'
        endif
    endif
    if (a:m == 'a') || (a:m == 'y')
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_pychar != ''
            execute 'lnoremap <buffer> <expr> '.escape(s:ywvim_{b:ywvim_parameters["active_mb"]}_pychar, '\').' <SID>Ywvim_onepinyin()'
        endif
    endif
    if (a:m == 'a')
        lnoremap <buffer> <C-^> <C-^><C-R>=<SID>Ywvim_UIsetting(1)<CR>
        if s:ywvim_esc_autoff
            inoremap <buffer> <esc> <ESC>:setlocal iminsert=0<bar>redraw!<CR>
        endif
    endif
    return ''
endfunction "}}}

function s:Ywvim_UIsetting(m) "{{{1
    let punc = s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc == 0 ? 'en.' : 'zh。'
    let pars = ''
    "{{{2 菜单显示
    echohl DiffChange | redraw | echon "ywvim 参数设置 [当前值]\n"
    echohl Title | echon "(m) 码表切换 [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_name . "]\n"
    let pars .= 'm'
    echon "(.) 中英标点切换 [" . punc . "]\n"
    let pars .= '.'
    echon "(l) 候选项个数 [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_listmax . "]\n"
    let pars .= 'l'
    echon "(p) 最长词长 [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength . "]\n"
    let pars .= 'p'
    echon "(g) 只输入GB2312 [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_gb . "]\n"
    let pars .= 'g'
    echon "(c) 简繁转换 [" . s:ywvim_conv . "]\n"
    let pars .= 'c'
    if exists('s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb')
        echon "(h) 辅助编码提示开关 [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on . "]\n"
        let pars .= 'h'
    endif
    let pars .= 'q'
    echon "(q) 退出"
    echohl None
    "}}}
    let par = ''
    while par !~ '[' . pars . ']'
        let par = nr2char(getchar())
    endwhile
    redraw
    if par == 'q' "{{{2
    elseif par == 'm' "{{{2
        echon "mb switch:\n"
        let nr = 0
        for im in s:ywvim_ims
            let nr += 1
            echohl Number | echon nr
            echohl None | echon '. ' . im[1] . '(' . im[0] . ")\n"
        endfor
        let getnr = ''
        while getnr !~ '[' . join(range(1, nr), '') . ']'
            let getnr = nr2char(getchar())
        endwhile
        lmapclear <buffer>
        let b:ywvim_parameters["active_mb"] = s:ywvim_ims[getnr - 1][0]
        call <SID>Ywvim_loadmb()
        call <SID>Ywvim_keymap('a')
    elseif par == '.' "{{{2
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc == 0
            call <SID>Ywvim_keymap_punc(1)
        else
            call <SID>Ywvim_keymap_punc(0)
        endif
        call <SID>Ywvim_keymap('e')
        call <SID>Ywvim_keymap('y')
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc = 1 - s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc
    elseif par == 'l' "{{{2
        let listmax = input('Max list length: ', s:ywvim_{b:ywvim_parameters["active_mb"]}_listmax)
        if listmax =~ '^\d\+$'
            let s:ywvim_{b:ywvim_parameters["active_mb"]}_listmax = listmax
        endif
    elseif par == 'p' "{{{2
        let maxphraselength = input('Max phrase length: ', s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength)
        if maxphraselength =~ '^\d\+$'
            let s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength = maxphraselength
        endif
    elseif par == 'g' "{{{2
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_gb = 1 - s:ywvim_{b:ywvim_parameters["active_mb"]}_gb
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_gb
            call <SID>YwvimLoadGBList()
        endif
    elseif par == 'h' "{{{2
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on = 1 - s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on
        let helpmb = s:ywvim_{b:ywvim_parameters["active_mb"]}['helpim']
        if !exists("s:ywvim_{helpmb}_mbdb")
            call <SID>Ywvim_loadmb(helpmb)
        endif
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb = helpmb
    elseif par == 'c' "{{{2
        if s:ywvim_conv != ''
            let s:oldywvim_conv = s:ywvim_conv
            let s:ywvim_conv = ''
        else
            call <SID>YwvimLoadConvertList()
            if exists("s:oldywvim_conv")
                let s:ywvim_conv = s:oldywvim_conv
            else
                let s:ywvim_conv = s:ywvim_preconv
            endif
        endif
        "}}}
    endif
    call <SID>YwvimHighlight()
    redraw
    return a:m ? "\<C-^>" : ''
endfunction "}}}

let s:ywvim_inputkey = ' '
function s:Ywvim_char(key) "{{{1 输入中文的主要模块
    if !exists("b:ywuvim_char")
        let b:ywuvim_char = ''
        let b:ywuvim_showchar = ''
        let b:ywuvim_candidatelist = []
    endif
    let key = a:key
    let keycode = char2nr(key)
    while 1 " enter ywvim mode 进入中文模式
        let keypat = '\V'.escape(key, '\')
        " 0 键取消中文输入 Thanks 蒋国华20121030 15805165530 <jghua@139.com>
        if key == "0" " 取消中文输入键
            return <SID>Ywvim_ReturnChar('')
            " 退格键{{{2
        elseif keycode == "\<BS>"
            let pgnr = 1
            let b:ywuvim_char = matchstr(b:ywuvim_char, '^.*\ze.$')
            let b:ywuvim_showchar = matchstr(b:ywuvim_showchar, '^.*\ze.$')
            if b:ywuvim_char != ''
                let b:ywuvim_candidatelist = <SID>Ywvim_comp(b:ywuvim_char)
                call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', b:ywuvim_candidatelist])
            else
                return <SID>Ywvim_ReturnChar('')
            endif
            " {{{2 测试是否是有效的码表可用字母，如果是，则开始查询对应汉字
        elseif match(s:ywvim_{b:ywvim_parameters["active_mb"]}_usedcodes, keypat) != -1
            let pgnr = 1
            if key != s:ywvim_inputkey
                let b:ywuvim_char .= key
                if s:ywvim_chinesecode && has_key(s:ywvim_{b:ywvim_parameters["active_mb"]}_chardefs, key)
                    let showkey = s:ywvim_{b:ywvim_parameters["active_mb"]}_chardefs[key]
                else
                    let showkey = key
                endif
                let b:ywuvim_showchar .= showkey
            endif
            let b:ywuvim_candidatelist = <SID>Ywvim_comp(b:ywuvim_char)
            let charcomplen = len(s:ywvim_complst)
            if charcomplen == 0
                if s:ywvim_lockb
                    let b:ywuvim_char = matchstr(b:ywuvim_char, '.*\ze.')
                    let b:ywuvim_showchar = matchstr(b:ywuvim_showchar, '.*\ze.')
                    let b:ywuvim_candidatelist = <SID>Ywvim_comp(b:ywuvim_char)
                elseif !exists("b:ywuvim_lock_char") " FIXME 0: 输出首选字，然后继续输入中文。
                    let old_ywuvim_char = matchstr(b:ywuvim_char, '.*\ze.')
                    let b:ywuvim_lock_char = <SID>Ywvim_comp(old_ywuvim_char)[0]["word"]
                    let b:ywuvim_char = b:ywuvim_lock_char.key
                    let b:ywuvim_showchar = b:ywuvim_lock_char.showkey
                endif
            endif
            if (s:ywvim_autoinput == 2) && (len(s:ywvim_pgbuf[s:ywvim_pagenr]) == 1)
                return <SID>Ywvim_ReturnChar(s:ywvim_pgbuf[s:ywvim_pagenr][0].word)
            endif
            call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', b:ywuvim_candidatelist])
            " {{{2 翻下页 PageDn
        elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_pagednkeys =~ keypat
            let s:ywvim_pagenr += 1
            if !has_key(s:ywvim_pgbuf, s:ywvim_pagenr)
                let page = <SID>Ywvim_comp(b:ywuvim_char,s:ywvim_zhcode_startidx,b:ywvim_continue_idx)
                if page != []
                    if s:ywvim_lastpagenr <= s:ywvim_pagenr
                        let s:ywvim_lastpagenr = s:ywvim_pagenr
                    endif
                    let s:ywvim_pgbuf[s:ywvim_pagenr] = page
                else
                    if s:ywvim_circlecandidates
                        let s:ywvim_pagenr = 0
                    else
                        let s:ywvim_pagenr -= 1
                    endif
                endif
            endif
            call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', s:ywvim_pgbuf[s:ywvim_pagenr]])
            if s:ywvim_autoinput && (len(s:ywvim_pgbuf[s:ywvim_pagenr]) == 1)
                return <SID>Ywvim_ReturnChar(s:ywvim_pgbuf[s:ywvim_pagenr][0].word)
            endif
            " {{{2 翻上页 PageUp
        elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_pageupkeys =~ keypat
            if s:ywvim_pagenr > 0
                let s:ywvim_pagenr -= 1
            elseif s:ywvim_circlecandidates
                let s:ywvim_pagenr = s:ywvim_lastpagenr
            endif
            call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', s:ywvim_pgbuf[s:ywvim_pagenr]])
            " input Chinese{{{2
        elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_inputzh_keys =~ keypat
            if s:ywvim_pgbuf[s:ywvim_pagenr] != []
                return <SID>Ywvim_ReturnChar(s:ywvim_pgbuf[s:ywvim_pagenr][0].word)
            elseif s:ywvim_lockb == 0
                return <SID>Ywvim_ReturnChar(b:ywuvim_showchar)
            else
                return <SID>Ywvim_ReturnChar('')
            endif
            " {{{2 输入第二候选词
        elseif '['.s:ywvim_{b:ywvim_parameters["active_mb"]}_inputzh_secondkeys.']' =~ keypat
            if s:ywvim_pgbuf[s:ywvim_pagenr] != []
                let secondcharidx = 0
                if len(s:ywvim_pgbuf[s:ywvim_pagenr][0]) > 1
                    let secondcharidx = 1
                endif
                return <SID>Ywvim_ReturnChar(s:ywvim_pgbuf[s:ywvim_pagenr][secondcharidx].word)
            endif
            return <SID>Ywvim_ReturnChar('')
            " {{{2 数字键选候选词
        elseif key =~ '[1-' . s:ywvim_{b:ywvim_parameters["active_mb"]}_listmax . ']' " number selection
            if key <= len(s:ywvim_pgbuf[s:ywvim_pagenr])
                return <SID>Ywvim_ReturnChar(s:ywvim_pgbuf[s:ywvim_pagenr][key - 1].word)
            else
                call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', b:ywuvim_candidatelist])
            endif
            "{{{2 input English
        elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_inputen_keys =~ keypat
            return <SID>Ywvim_ReturnChar(b:ywuvim_char)
            "{{{2 <C-^>
        elseif keycode == char2nr("\<C-^>")
            return <SID>Ywvim_ReturnChar(s:ywvim_pgbuf[s:ywvim_pagenr][0].word).<SID>Ywvim_UIsetting(0)
            "{{{2 <C-\>
        elseif keycode == char2nr("\<C-\>")
            return <SID>Ywvim_ReturnChar(b:ywuvim_showchar)."\<C-^>"
            "{{{2 标点符号
        elseif s:ywvim_pgbuf[s:ywvim_pagenr] != []
            if s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc && has_key(s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic, key)
                let key = <SID>Ywvim_puncp(key)
            endif
            return <SID>Ywvim_ReturnChar(s:ywvim_pgbuf[s:ywvim_pagenr][0].word).key
        endif "}}}
        let keycode = getchar()
        let key = nr2char(keycode)
    endwhile
    return ''
endfunction "}}}

function s:Ywvim_comp(zhcode,...) "{{{1
    " a:1: startline. a:2: endidx.
    let s:ywvim_complst = []
    if a:zhcode == ''
        return s:ywvim_complst
    endif
    " match string extractly
    let exactp = s:ywvim_{b:ywvim_parameters["active_mb"]}_matchexact ? ' ' : ''
    let zhcodep = '\V'.escape(a:zhcode, '\').exactp
    if exists("a:1")
        let s:ywvim_zhcode_idxs = a:1
    else
        let s:ywvim_zhcode_idxs = match(s:ywvim_{b:ywvim_parameters["active_mb"]}_mbdb, '^'.zhcodep, s:ywvim_{b:ywvim_parameters["active_mb"]}_main_idxs)
        let s:ywvim_zhcode_startidx = s:ywvim_zhcode_idxs
        let s:ywvim_zhcode_idxe = match(s:ywvim_{b:ywvim_parameters["active_mb"]}_mbdb, '^\%('.zhcodep.'\)\@!', s:ywvim_zhcode_idxs) - 1
        if s:ywvim_zhcode_idxe == -2
            let s:ywvim_zhcode_idxe = s:ywvim_{b:ywvim_parameters["active_mb"]}_main_idxe
        endif
    endif
    let lst = s:ywvim_{b:ywvim_parameters["active_mb"]}_mbdb[s:ywvim_zhcode_idxs : s:ywvim_zhcode_idxe]
    let nr = 0
    if exists("a:2")
        let b:ywvim_continue_idx = a:2
    else
        let b:ywvim_continue_idx = 1
    endif
    " Try to prevent hit-enter-prompt.
    let s:ywvim_testshowbar = ''
    for i in lst
        let ilst = split(i, '\s\+')
        let suf = matchstr(ilst[0], a:zhcode.'\zs.*')
        for c in ilst[b:ywvim_continue_idx : -1]
            if b:ywvim_continue_idx == len(ilst) - 1
                let s:ywvim_zhcode_startidx += 1
                let b:ywvim_continue_idx = 1
            else
                let b:ywvim_continue_idx += 1
            endif
            let help = ''
            let cup = '\<'.c.'\>'
            let ccharlist = split(c, '\zs')
            let ccharlen = len(ccharlist)
            " strchars(c) == 1, strlen(c) <= 3: strchars() doesn't exist before vim 7.3!
            if s:ywvim_{b:ywvim_parameters["active_mb"]}_gb
                let char = matchstr(c, '^.')
                if index(s:ywvim_gbfilterlist, char) == -1
                    if (&encoding == 'utf-8') && exists("s:ywvim_hanzi_rangelist")
                        for r in s:ywvim_hanzi_rangelist
                            if (char >= r[0]) && (char <= r[1])
                                let ishan=1
                                break
                            endif
                        endfor
                        if exists("ishan")
                            continue
                        endif
                    else
                        continue
                    endif
                endif
            endif
            if s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength && (ccharlen > s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength)
                continue
            endif
            if s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on && exists('s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb') && (ccharlen == 1)
                " FIXME too slow
                let help = matchstr(matchstr(s:ywvim_{s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb}_mbdb[s:ywvim_{s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb}_main_idxs : s:ywvim_{s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb}_main_idxe], cup), '^\S\+')
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
            " Try to prevent hit-enter-prompt.
            let s:ywvim_testshowbar .= ' ' . nr . ':' . c . suf . help
            call add(s:ywvim_complst, dic)
            if nr == s:ywvim_{b:ywvim_parameters["active_mb"]}_listmax
                let s:ywvim_terminate = 1
                break
            endif
        endfor
        if exists("s:ywvim_terminate")
            break
        endif
        let b:ywvim_continue_idx = 1
    endfor
    unlet! s:ywvim_terminate
    if !exists("a:1")
        let s:ywvim_pagenr = 0
        let s:ywvim_lastpagenr = 0
        let s:ywvim_pgbuf = {}
        let s:ywvim_pgbuf[0] = s:ywvim_complst
    endif
    return s:ywvim_complst
endfunction "}}}

function s:Ywvim_echofinalresult(list) "{{{1
    let ywvimbarlist = a:list
    if mode() != 'c'
        " Try to prevent hit-enter-prompt.
        let s:ywvim_testshowbar .= '['.s:ywvim_{b:ywvim_parameters["active_mb"]}_nameabbr.']'.' '.ywvimbarlist[0].' '.ywvimbarlist[1]
        let cmdheight = ((strlen(s:ywvim_testshowbar) + s:ywvim_extraimbarlength) / &columns) + 1
        if cmdheight != &cmdheight
            execute 'setlocal cmdheight='.cmdheight
        endif
        if mode() != 'c'
            redraw
        endif
    endif
    echohl ywvimIMname
    echo '['.s:ywvim_{b:ywvim_parameters["active_mb"]}_nameabbr.']'
    echohl ywvimIMnormal
    echon ' '
    echon ywvimbarlist[0].' '.ywvimbarlist[1]
    for c in ywvimbarlist[2][0:-1]
        echon " "
        echohl ywvimIMnr | echon c.nr | echohl ywvimIMnormal
        echon '.' . c.word
        echohl ywvimIMcode | echon c.suf | echohl ywvimIMnormal
        echon c.help
    endfor
    echohl None
endfunction "}}}

function s:Ywvim_enmode() "{{{
    echohl ywvimIMname
    echo "[En]: "
    let keycode = getchar()
    let enchar = s:ywvim_{b:ywvim_parameters["active_mb"]}_enchar
    if (keycode == 10) || (keycode == 13) || (keycode == 27)
        " 10: ESC   13: <RE>    27: <Ctrl-j>
        let enstr = ''
    elseif keycode != char2nr(s:ywvim_{b:ywvim_parameters["active_mb"]}_enchar)
        let enstr = input("[En]: ", nr2char(keycode))
        echohl ywvimIMnormal
        call histdel("input", -1)
    elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc && has_key(s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic, enchar)
        let enstr = <SID>Ywvim_puncp(enchar)
    else
        let enstr = enchar
    endif
    return enstr != '' ? enstr : enstr." \<BS>"
endfunction "}}}

function s:Ywvim_onepinyin() "{{{
    let ywvim_active_oldmb = b:ywvim_parameters["active_mb"]
    let pychar = s:ywvim_{b:ywvim_parameters["active_mb"]}_pychar
    let b:ywvim_parameters["active_mb"] = 'py'
    call <SID>Ywvim_loadmb()
    echohl ywvimIMname
    echo '[' | echon s:ywvim_py_nameabbr | echon ']'
    echohl ywvimIMnormal | echon ' '
    let keycode = getchar()
    if keycode != char2nr(pychar)
        let char = <SID>Ywvim_char(nr2char(keycode))
    elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc && has_key(s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic, pychar)
        let char = <SID>Ywvim_puncp(pychar)
    else
        let char = pychar
    endif
    let b:ywvim_parameters["active_mb"] = ywvim_active_oldmb
    call <SID>Ywvim_loadmb()
    return char
endfunction "}}}

function s:Ywvim_ReturnChar(s) "{{{
    let sb = a:s
    if sb != '' && s:ywvim_conv != ''
        let g2bidx = index(s:ywvim_clst, sb)
        if g2bidx != -1
            if s:ywvim_conv == 'g2b' && g2bidx < s:ywvim_clst_sep
                let sb = s:ywvim_clst[g2bidx + s:ywvim_clst_sep]
            elseif s:ywvim_conv == 'b2g' && g2bidx > s:ywvim_clst_sep
                let sb = s:ywvim_clst[g2bidx - s:ywvim_clst_sep]
            endif
        endif
    endif
    unlet! b:ywuvim_char
    unlet! b:ywuvim_showchar
    unlet! b:ywuvim_lock_char
    let b:ywvim_parameters["lastinput"] = sb
    if mode() != 'c' " TODO prevent -More- message when escape from insert mode.
        redraw
    endif
    return sb
    " 确保输入空字符后光标位置也能正确。redraw! 会造成屏幕闪动。
    " return sb != '' ? sb : sb." \<BS>"
endfunction "}}}

function Ywvim_toggle() "{{{1
    if !exists("s:ywvim_ims")
        call <SID>Ywvim_loadvar()
    endif
    let togglekey = "\<C-^>"
    if !exists("b:ywvim_parameters")
        let b:ywvim_parameters = {}
        let b:ywvim_parameters["mode"] = ''
    endif
    if match(b:ywvim_parameters["mode"], mode()) == -1
        call <SID>Ywvim_toggle_on()
    else
        call <SID>Ywvim_toggle_off()
    endif
    return togglekey
endfunction "}}}

function s:Ywvim_toggle_on() "{{{1
    let b:ywvim_parameters["oldcmdheight"] = &cmdheight
    call <SID>Ywvim_loadmb()
    call <SID>Ywvim_keymap('a')
    let b:ywvim_parameters["mode"] .= mode()
    " redir => b:ywvim_hl_cursor
    " silent highlight Cursor
    " redir END
    " let b:ywvim_parameters["hl_cursor"] = matchstr(b:ywvim_hl_cursor, 'xxx\s*\zs.*')
    " highlight! link Cursor ywvimIMCursor
endfunction "}}}
function s:Ywvim_toggle_off() "{{{1
    if &cmdheight != b:ywvim_parameters["oldcmdheight"]
        execute 'silent! setlocal cmdheight=' . b:ywvim_parameters["oldcmdheight"]
    endif
    unlet! s:ywvim_zhcode_idxs
    unlet! s:ywvim_zhcode_idxe
    unlet! s:ywvim_complst
    let puncvardic = filter(keys(getbufvar("",'')), "v:val=~'_punc_\\d'")
    for p in puncvardic
        unlet b:{p}
    endfor
    let b:ywvim_parameters["mode"] = substitute(b:ywvim_parameters["mode"], mode(), '', '')
    " execute 'highlight Cursor '.b:ywvim_parameters["hl_cursor"]
    setlocal iminsert=0
endfunction "}}}

function s:Ywvim_NewBufFix() "{{{1 Fix new buffer's (lang) bug
    if !exists("b:ywvim_parameters") && (&iminsert == 1)
        setlocal iminsert=0
    endif
endfunction "}}}
autocmd BufEnter * call <SID>Ywvim_NewBufFix()

imap <silent> <C-\> <C-R>=Ywvim_toggle()<CR>
cmap <silent> <C-\> <C-R>=Ywvim_toggle()<CR>
imap <silent> <C-Space> <C-R>=Ywvim_toggle()<CR>
cmap <silent> <C-Space> <C-R>=Ywvim_toggle()<CR>
imap <silent> <C-S-Space> <C-R>=Ywvim_toggle()<CR>
cmap <silent> <C-S-Space> <C-R>=Ywvim_toggle()<CR>
imap <silent> <C-@> <C-R>=Ywvim_toggle()<CR>
cmap <silent> <C-@> <C-R>=Ywvim_toggle()<CR>

" vim: foldmethod=marker:
