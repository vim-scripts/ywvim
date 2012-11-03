" mY oWn VimIM.
" Author: Wu, Yue <ywupub@gmail.com>
" Last Change:	2012-11-03
" Release Version: 1.22
" License: BSD

" ~/projects/vimscript/ywvim/changelog
" ~/projects/vimscript/ywvim/manual

scriptencoding utf-8
if exists("s:loaded_ywvim") | finish | endif
let s:loaded_ywvim = 1

let s:ywvim_path = expand("<sfile>:p:h")

function s:Ywvim_SetVar(var, val) " Assign user var to script var{{{
    let s:{a:var} = a:val
    if exists('g:'.a:var)
        let s:{a:var} = g:{a:var}
        unlet g:{a:var}
    endif
endfunction "}}}

let s:ywvim_ims_encoding='utf-8'
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
        let s:ywvim_{mbintername}_loaded = 1
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
function s:YwvimLoadGBList() "{{{
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
endfunction "}}}
function s:YwvimHighlight() "{{{
    let b:ywvim_parameters["highlight_imname"] = 'MoreMsg'
    if s:ywvim_conv != ''
        let b:ywvim_parameters["highlight_imname"] = 'ErrorMsg'
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_gb == 1
            let b:ywvim_parameters["highlight_imname"] = 'Todo'
        endif
    elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_gb == 0
        let b:ywvim_parameters["highlight_imname"] = 'WarningMsg'
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
            inoremap <buffer> <esc> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR><ESC>
        endif
    endif
    return ''
endfunction "}}}

function s:Ywvim_UIsetting(m) "{{{
    let punc='zh'
    if s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc == 0
        let punc='en'
    endif
    let pars = ''
    echohl Pmenu | redraw | echon "ywvim preferences [current value]\n"
    echohl Title | echon "(m) mb switch [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_name . "]\n"
    let pars .= 'm'
    echon "(.) zh/en punctuation [" . punc . "]\n"
    let pars .= '.'
    echon "(p) Max phrase length [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength . "]\n"
    let pars .= 'p'
    echon "(g) gb2312 [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_gb . "]\n"
    let pars .= 'g'
    echon "(c) simplified <-> traditional [" . s:ywvim_conv . "]\n"
    let pars .= 'c'
    if exists('s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb')
        echon "(h) help im [" . s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on . "]\n"
        let pars .= 'h'
    endif
    echohl None
    let par = ''
    while par !~ '[' . pars . ']'
        let par = nr2char(getchar())
    endwhile
    redraw
    if par == 'm'
        echon "mb switch:\n"
        let nr = 0
        for im in s:ywvim_ims
            let nr += 1
            echohl Number | echon nr
            if s:ywvim_ims_encoding != &encoding
                let im[1] = iconv(im[1], s:ywvim_ims_encoding, &encoding)
            endif
            echohl None | echon '. ' . im[1] . " "
        endfor
        let s:ywvim_ims_encoding = &encoding
        let getnr = ''
        while getnr !~ '[' . join(range(1, nr), '') . ']'
            let getnr = nr2char(getchar())
        endwhile
        lmapclear <buffer>
        let b:ywvim_parameters["active_mb"] = s:ywvim_ims[getnr - 1][0]
        call <SID>Ywvim_loadmb()
        call <SID>Ywvim_keymap('a')
    elseif par == '.'
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc == 0
            call <SID>Ywvim_keymap_punc(1)
        else
            call <SID>Ywvim_keymap_punc(0)
        endif
        call <SID>Ywvim_keymap('e')
        call <SID>Ywvim_keymap('y')
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc = 1 - s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc
    elseif par == 'p'
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength = input('Max phrase length: ', s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength)
    elseif par == 'g'
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_gb = 1 - s:ywvim_{b:ywvim_parameters["active_mb"]}_gb
        if s:ywvim_{b:ywvim_parameters["active_mb"]}_gb
            call <SID>YwvimLoadGBList()
        endif
    elseif par == 'h'
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on = 1 - s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on
        let helpmb = s:ywvim_{b:ywvim_parameters["active_mb"]}['helpim']
        if !exists("s:ywvim_{helpmb}_mbdb")
            call <SID>Ywvim_loadmb(helpmb)
        endif
        let s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb = helpmb
    elseif par == 'c'
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
    endif
    call <SID>YwvimHighlight()
    redraw
    if a:m
        return "\<C-^>"
    endif
    return ""
endfunction "}}}

function s:Ywvim_char(key) "{{{ 输入中文的主要模块
		if !exists("b:ywuvim_char")
				let b:ywuvim_char = ''
				let b:ywuvim_showchar = ''
				let b:ywuvim_candidatelist = []
		endif
		let keycode = char2nr(a:key)
		while 1 " enter ywvim mode 进入中文模式
				let key = nr2char(keycode)
				let keypat = '\V'.escape(key, '\')
                " 0 键取消中文输入 Thanks 蒋国华20121030 15805165530 <jghua@139.com>
                if keycode == char2nr("0")
                    " if keycode == char2nr("\<C-w>")
                    return <SID>Ywvim_ReturnChar()
                elseif keycode == "\<BS>"
						let pgnr = 1
						let b:ywuvim_char = matchstr(b:ywuvim_char, '.*\ze.')
						let b:ywuvim_showchar = matchstr(b:ywuvim_showchar, '.*\ze.')
						if b:ywuvim_char != ''
								let b:ywuvim_candidatelist = <SID>Ywvim_comp(b:ywuvim_char)
								call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', b:ywuvim_candidatelist])
						else
								return <SID>Ywvim_ReturnChar()
						endif
				" {{{ 测试是否是有效的码表可用字母，如果是，则开始查询对应汉字
				elseif (key != '') && (match(s:ywvim_{b:ywvim_parameters["active_mb"]}_usedcodes, keypat) != -1)
						let pgnr = 1
						if key != ' '
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
						if (charcomplen == 0) && (s:ywvim_matchexact == 0)
								if s:ywvim_lockb
										let b:ywuvim_char = matchstr(b:ywuvim_char, '.*\ze.')
										let b:ywuvim_showchar = matchstr(b:ywuvim_showchar, '.*\ze.')
										let b:ywuvim_candidatelist = <SID>Ywvim_comp(b:ywuvim_char)
								elseif !exists("b:ywuvim_lock_char") " FIXME 0: 输出首选字，然后继续输入中文。
										let old_ywuvim_char = matchstr(b:ywuvim_char, '.*\ze.')
										let b:ywuvim_lock_char = <SID>Ywvim_comp(old_ywuvim_char)[0]["word"]
										let b:ywuvim_char = b:ywuvim_lock_char.key
										let b:ywuvim_showchar = b:ywuvim_lock_char.showkey
										"     return <SID>Ywvim_ReturnChar(0) . <SID>Ywvim_char(key)
								endif
						endif
						if (s:ywvim_autoinput == 2) && (len(s:ywvim_pgbuf[s:ywvim_pagenr]) == 1)
								return <SID>Ywvim_ReturnChar(0)
						endif
						call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', b:ywuvim_candidatelist])
                " }}}
                " {{{ 翻下页
				elseif (key != '') && (s:ywvim_{b:ywvim_parameters["active_mb"]}_pagednkeys =~ keypat)
						let s:ywvim_pagenr += 1
						if !has_key(s:ywvim_pgbuf, s:ywvim_pagenr)
								let page = <SID>Ywvim_comp(b:ywuvim_char,s:ywvim_zhcode_startidx,s:ywvim_continue_idx)
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
								return <SID>Ywvim_ReturnChar(0)
						endif
                " }}}
                " {{{ 翻上页
				elseif (key != '') && (s:ywvim_{b:ywvim_parameters["active_mb"]}_pageupkeys =~ keypat) " PageUp
						if s:ywvim_pagenr > 0
								let s:ywvim_pagenr -= 1
						elseif s:ywvim_circlecandidates
								let s:ywvim_pagenr = s:ywvim_lastpagenr
						endif
						call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', s:ywvim_pgbuf[s:ywvim_pagenr]])
				elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_inputzh_keys =~ keypat " input Chinese
						if s:ywvim_pgbuf[s:ywvim_pagenr] != []
								return <SID>Ywvim_ReturnChar(0)
						elseif s:ywvim_lockb == 0
								return <SID>Ywvim_ReturnChar(b:ywuvim_showchar)
						else
								return <SID>Ywvim_ReturnChar()
						endif
                " }}}
                " {{{ 输入第二候选词
				elseif '['.s:ywvim_{b:ywvim_parameters["active_mb"]}_inputzh_secondkeys.']' =~ keypat
						if s:ywvim_pgbuf[s:ywvim_pagenr] != []
								let secondcharidx = 0
								if len(s:ywvim_pgbuf[s:ywvim_pagenr][0]) > 1
										let secondcharidx = 1
								endif
								return <SID>Ywvim_ReturnChar(secondcharidx)
						endif
						return <SID>Ywvim_ReturnChar()
                " }}}
                " {{{ 数字键选候选词
				elseif key =~ '[1-' . s:ywvim_{b:ywvim_parameters["active_mb"]}_listmax . ']' " number selection
						if key <= len(s:ywvim_pgbuf[s:ywvim_pagenr])
								return <SID>Ywvim_ReturnChar(key - 1)
						else
								call <SID>Ywvim_echofinalresult([b:ywuvim_showchar, '[' . (s:ywvim_pagenr + 1) . ']', b:ywuvim_candidatelist])
						endif
                " }}}
				elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_inputen_keys =~ keypat " input English
						return <SID>Ywvim_ReturnChar(b:ywuvim_char)
				elseif keycode == char2nr("\<C-^>")
						return <SID>Ywvim_ReturnChar(0).<SID>Ywvim_UIsetting(0)
				elseif keycode == char2nr("\<C-\>")
						return <SID>Ywvim_ReturnChar(b:ywuvim_showchar)."\<C-^>"
				elseif s:ywvim_pgbuf[s:ywvim_pagenr] != []
						if s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc && has_key(s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic, key)
								let key = <SID>Ywvim_puncp(key)
						endif
						return <SID>Ywvim_ReturnChar(0) . key
				endif
				let keycode = getchar()
		endwhile
		return ''
endfunction "}}}

function s:Ywvim_comp(zhcode,...) "{{{
    " a:1: startline. a:2: endidx.
    if a:zhcode == ''
        return []
    endif
    let s:ywvim_complst = []
    let len_zhcode = len(a:zhcode)
    let exactp = '' " If match string extractly
    if s:ywvim_{b:ywvim_parameters["active_mb"]}_matchexact
        let exactp = ' '
    endif
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
        let s:ywvim_continue_idx = a:2
    else
        let s:ywvim_continue_idx = 1
    endif
    for i in lst
        let ilst = split(i, '\s\+')
        let suf = strpart(ilst[0], len_zhcode)
        for c in ilst[s:ywvim_continue_idx : -1]
            if s:ywvim_continue_idx == len(ilst) - 1
                let s:ywvim_zhcode_startidx += 1
                let s:ywvim_continue_idx = 1
            else
                let s:ywvim_continue_idx += 1
            endif
            let help = ''
            let cup = '\<' . c . '\>'
            if (s:ywvim_{b:ywvim_parameters["active_mb"]}_gb == 1) && (strlen(c) <= 3) && (index(s:ywvim_gbfilterlist, c) == -1)
                " strchars(c) == 1, strlen(c) <= 3: doesn't exist before vim 7.3!
                continue
            endif
            if s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength && (strlen(c) > 3 * s:ywvim_{b:ywvim_parameters["active_mb"]}_maxphraselength)
                continue
            endif
            if s:ywvim_{b:ywvim_parameters["active_mb"]}_helpim_on && exists('s:ywvim_{b:ywvim_parameters["active_mb"]}_helpmb') && (strlen(c) == 3)
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
            call add(s:ywvim_complst, dic)
            if nr == s:ywvim_{b:ywvim_parameters["active_mb"]}_listmax
                let s:ywvim_terminate = 1
                break
            endif
        endfor
        if exists("s:ywvim_terminate")
            break
        endif
        let s:ywvim_continue_idx = 1
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

function s:Ywvim_GetMode() "{{{
    let prepre = ''
    if mode() !~ '[in]'
        let cmdtype = getcmdtype()
        if cmdtype != '@'
            let prepre = cmdtype . getcmdline() . "\n"
        endif
    endif
    return prepre
endfunction "}}}

function s:Ywvim_echofinalresult(list) "{{{
    let ywvimbarlist = a:list
    let columns = &columns
    let ywvimbar = <SID>Ywvim_GetMode() . '[' . s:ywvim_{b:ywvim_parameters["active_mb"]}_nameabbr . ']' . ' ' . ywvimbarlist[0] . ' ' . ywvimbarlist[1] . ' ' . ywvimbarlist[0]
    for c in ywvimbarlist[2][0:-1]
        let ywvimbar .= ' ' . c.nr . ':' . c.word . c.suf . c.help
    endfor
    " Try to prevent hit-enter-prompt.
    let extralength = 2
    if (&laststatus == 0) || ((&laststatus == 1) && winnr("$") == 1)
        " 22 is ruler's width?
        let extralength = 22
    endif
    let cmdheight = ((strlen(ywvimbar) + extralength) / columns) + 1
    if cmdheight != &cmdheight
        execute 'setlocal cmdheight=' . cmdheight
        if mode() == 'i'
            redraw!
        endif
    endif
    let ModeStr = <SID>Ywvim_GetMode()
    echo ModeStr
    execute 'echohl '.b:ywvim_parameters["highlight_imname"]
    echon '['.s:ywvim_{b:ywvim_parameters["active_mb"]}_nameabbr.']' | echohl None
    echon ' '
    echon a:list[0]
    echon ' '
    echon a:list[1]
    echon ' '
    for c in a:list[2][0:-1]
        echon " "
        echohl LineNr | echon c.nr | echohl None
        echon ':' | echon c.word
        echohl Comment | echon c.suf | echohl None
        echon c.help
    endfor
endfunction "}}}

function s:Ywvim_enmode() "{{{
    execute 'echohl ' . b:ywvim_parameters["highlight_imname"]
    echo <SID>Ywvim_GetMode() . "[En]: "
    let keycode = getchar()
    let enchar = s:ywvim_{b:ywvim_parameters["active_mb"]}_enchar
    if keycode != char2nr(s:ywvim_{b:ywvim_parameters["active_mb"]}_enchar)
        let enstr = input("[En]: ", nr2char(keycode)) | echohl None
        call histdel("input", -1)
    elseif s:ywvim_{b:ywvim_parameters["active_mb"]}_zhpunc && has_key(s:ywvim_{b:ywvim_parameters["active_mb"]}_puncdic, enchar)
        let enstr = <SID>Ywvim_puncp(enchar)
    else
        let enstr = enchar
    endif
    if mode() != 'c'
        echo ''
    endif
    return enstr
endfunction "}}}

function s:Ywvim_onepinyin() "{{{
    let ywvim_active_oldmb = b:ywvim_parameters["active_mb"]
    let pychar = s:ywvim_{b:ywvim_parameters["active_mb"]}_pychar
    let b:ywvim_parameters["active_mb"] = 'py'
    call <SID>Ywvim_loadmb()
    echo <SID>Ywvim_GetMode()
    execute 'echohl ' . b:ywvim_parameters["highlight_imname"]
    echon '[' | echon s:ywvim_py_nameabbr | echon ']'
    echohl None | echon ' '
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

function s:Ywvim_ReturnChar(...) "{{{
    let sb = ''
    if exists("a:1")
        let sb = a:1
        if a:1 =~ '\d\+'
            let sb = s:ywvim_pgbuf[s:ywvim_pagenr][a:1].word
            if s:ywvim_conv != ''
                let g2bidx = index(s:ywvim_clst, sb)
                if g2bidx != -1
                    if s:ywvim_conv == 'g2b' && g2bidx < s:ywvim_clst_sep
                        let sb = s:ywvim_clst[g2bidx + s:ywvim_clst_sep]
                    elseif s:ywvim_conv == 'b2g' && g2bidx > s:ywvim_clst_sep
                        let sb = s:ywvim_clst[g2bidx - s:ywvim_clst_sep]
                    endif
                endif
            endif
        endif
    elseif getcmdtype() != '@'
        echo getcmdtype() . getcmdline()
    endif
    unlet! b:ywuvim_char
    unlet! b:ywuvim_showchar
	unlet! b:ywuvim_lock_char
    if mode() != 'c'
        echo ''
        " Thanks 蒋国华(15805165530 <jghua@139.com>)'s advice
        return sb . "\<Ins>\<Ins>"
    else
        " "\<Ins>\<Ins>" doesn't work well.
        return sb . " \<BS>"
    endif
endfunction "}}}

function Ywvim_toggle() "{{{
    if !exists("s:ywvim_ims")
        call <SID>Ywvim_loadvar()
    endif
    let togglekey = "\<C-^>"
    if !exists("b:ywvim_parameters")
        let b:ywvim_parameters = {}
        let b:ywvim_parameters["mode"] = ''
        if &iminsert == 1
            let togglekey .= "\<C-^>"
        endif
    endif
    let current_mode = mode()
    let on_modes = b:ywvim_parameters["mode"]
    if match(on_modes, current_mode) == -1
        let b:ywvim_parameters["oldcmdheight"] = &cmdheight
        call <SID>Ywvim_loadmb()
        call <SID>Ywvim_keymap('a')
        let b:ywvim_parameters["mode"] .= current_mode
    else
        execute 'setlocal cmdheight=' . b:ywvim_parameters["oldcmdheight"]
        unlet! s:ywvim_zhcode_idxs
        unlet! s:ywvim_zhcode_idxe
        unlet! s:ywvim_complst
        let puncvardic = filter(keys(getbufvar("",'')), "v:val=~'_punc_\\d'")
        for p in puncvardic
            unlet b:{p}
        endfor
        let b:ywvim_parameters["mode"] = substitute(b:ywvim_parameters["mode"], current_mode, '', '')
    endif
    return togglekey
endfunction "}}}

function Ywvim_toggle_post() "{{{
    if mode() =~ '[i]'
        redrawstatus
    endif
    return ""
endfunction "}}}

imap <silent> <C-\> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
cmap <silent> <C-\> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
imap <silent> <C-Space> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
cmap <silent> <C-Space> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
imap <silent> <C-S-Space> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
cmap <silent> <C-S-Space> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
if exists("$OSSO_PRODUCT_NAME") && $OSSO_PRODUCT_NAME == 'N900' " vim on maemo.
    imap <silent> <C-@> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
    cmap <silent> <C-@> <C-R>=Ywvim_toggle()<CR><C-R>=Ywvim_toggle_post()<CR>
endif

" vim: foldmethod=marker:
