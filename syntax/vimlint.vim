" Vim syntax file
" Language:     VimLint
" Maintainer:   Barry Arthur <barry.arthur at gmail dot org>

if exists("b:current_syntax")
  finish
endif

syn sync fromstart

hi def vimlintCompilerString term=bold ctermfg=6 guifg=DarkCyan
hi def vimlintOption term=bold ctermfg=5 guifg=Purple
hi def vimlintError term=standout ctermfg=15 ctermbg=1 guifg=White guibg=Red
hi def vimlintWarning term=standout ctermfg=1 guifg=Red
hi def vimlintFeatures term=none cterm=bold ctermfg=0 guifg=LightGray
hi def vimlintPresentFeature term=bold ctermfg=2 gui=bold guifg=SeaGreen
hi def vimlintTitle term=none cterm=bold ctermfg=4 guifg=Blue
hi def vimlintComment term=none cterm=bold ctermfg=0 guifg=SlateGray

syn match vimlintEvilScript 'mswin\.vim'

syn match vimlintErrorWord      '^errors'
syn match vimlintWarningWord    '^warnings'
syn match vimlintError          '^!! \@='
syn match vimlintWarning        '^! \@='
syn match vimlintFeatures       '^[-+].*' contains=vimlintPresentFeature,vimlintMissingFeatures
syn match vimlintPresentFeature contained '+\w\+'
syn match vimlintCompilerString '^Compilation:.*$'
syn match vimlintCompilerString '^Linking:.*$'
syn match vimlintH1             '^= .* =$'
syn match vimlintH2             '^== .* ==$'
syn match vimlintH3             '^--- .* ---$'
syn match vimlintComment        '		.*'

syn match vimlintMissingFeatures contained '-\<autocmd\>\|-\<cindent\>\|-\<clipboard\>\|-\<cmdline_compl\>\|-\<cmdline_hist\>\|-\<cmdline_info\>\|-\<comments\>\|-\<diff\>\|-\<digraphs\>\|-\<eval\>\|-\<ex_extra\>\|-\<extra_search\>\|-\<file_in_path\>\|-\<find_in_path\>\|-\<folding\>\|-\<iconv\>\|-\<insert_expand\>\|-\<jumplist\>\|-\<keymap\>\|-\<listcmds\>\|-\<localmap\>\|-\<modify_fname\>\|-\<mouse\>\|-\<multi_byte\>\|-\<multi_lang\>\|-\<path_extra\>\|-\<quickfix\>\|-\<scrollbind\>\|-\<statusline\>\|-\<syntax\>\|-\<tag_binary\>\|-\<textobjects\>\|-\<title\>\|-\<user_commands\>\|-\<vertsplit\>\|-\<visual\>\|-\<visualextra\>'

if has('unix') || has('macunix')
  syn match vimlintMissingFeatures contained '-\<terminfo\>\|-\<termresponse\>\|-\<mouse_xterm\>\|-\<X11\>'
endif

syn region vimlintOptionRegion matchgroup=vimlintH2 start=/^== Essential Options ==$/ end=/^== Scripts ==$/ skipwhite contains=vimlintOption,vimlintComment,vimlintError,vimlintWarning
syn region vimlintOptionRegion matchgroup=vimlintH2 start=/^--- Options ---$/ end=/^== Termcap Settings ==$/ skipwhite contains=vimlintOption,vimlintComment,vimlintEvilOption,vimlintWarningOption

" TODO: Find a nicer way to highlight Vim options. I would like all options in
" the vimlint report to start with a ' char so that <F1> :help map works
" properly.

syn match vimlintOption contained '\(\<aleph\>\|\<allowrevins\>\|\<altkeymap\>\|\<ambiwidth\>\|\<arabic\>\|\<arabicshape\>\|\<autochdir\>\|\<autoindent\>\|\<autoread\>\|\<autowrite\>\|\<autowriteall\>\|\<background\>\|\<backspace\>\|\<backup\>\|\<backupcopy\>\|\<backupdir\>\|\<backupext\>\|\<backupskip\>\|\<balloondelay\>\|\<ballooneval\>\|\<balloonexpr\>\|\<binary\>\|\<bomb\>\|\<breakat\>\|\<browsedir\>\|\<bufhidden\>\|\<buflisted\>\|\<buftype\>\|\<casemap\>\|\<cdpath\>\|\<cedit\>\|\<charconvert\>\|\<cindent\>\|\<cinkeys\>\|\<cinoptions\>\|\<cinwords\>\|\<clipboard\>\|\<cmdheight\>\|\<cmdwinheight\>\|\<columns\>\|\<comments\>\|\<commentstring\>\|\<compatible\>\|\<complete\>\|\<completefunc\>\|\<completeopt\>\|\<confirm\>\|\<copyindent\>\|\<cpoptions\>\|\<cscopepathcomp\>\|\<cscopeprg\>\|\<cscopequickfix\>\|\<cscopetag\>\|\<cscopetagorder\>\|\<cscopeverbose\>\|\<cursorcolumn\>\|\<cursorline\>\|\<debug\>\|\<define\>\|\<delcombine\>\|\<dictionary\>\|\<diff\>\|\<diffexpr\>\|\<diffopt\>\|\<digraph\>\|\<directory\>\)'

syn match vimlintOption contained '\(\<display\>\|\<eadirection\>\|\<edcompatible\>\|\<encoding\>\|\<endofline\>\|\<equalalways\>\|\<equalprg\>\|\<errorbells\>\|\<errorfile\>\|\<errorformat\>\|\<esckeys\>\|\<eventignore\>\|\<expandtab\>\|\<exrc\>\|\<fileencoding\>\|\<fileencodings\>\|\<fileformat\>\|\<fileformats\>\|\<filetype\>\|\<fillchars\>\|\<fkmap\>\|\<foldclose\>\|\<foldcolumn\>\|\<foldenable\>\|\<foldexpr\>\|\<foldignore\>\|\<foldlevel\>\|\<foldlevelstart\>\|\<foldmarker\>\|\<foldmethod\>\|\<foldminlines\>\|\<foldnestmax\>\|\<foldopen\>\|\<foldtext\>\|\<formatexpr\>\|\<formatlistpat\>\|\<formatoptions\>\|\<formatprg\>\|\<fsync\>\|\<gdefault\>\|\<grepformat\>\|\<grepprg\>\|\<guicursor\>\|\<guifont\>\|\<guifontwide\>\|\<guiheadroom\>\|\<guioptions\>\|\<guipty\>\|\<guitablabel\>\|\<guitabtooltip\>\|\<helpfile\>\|\<helpheight\>\|\<helplang\>\|\<hidden\>\|\<highlight\>\|\<history\>\|\<hkmap\>\|\<hkmapp\>\|\<hlsearch\>\|\<icon\>\|\<iconstring\>\|\<ignorecase\>\|\<imactivatekey\>\|\<imcmdline\>\|\<imdisable\>\)'

syn match vimlintOption contained '\(\<iminsert\>\|\<imsearch\>\|\<include\>\|\<includeexpr\>\|\<incsearch\>\|\<indentexpr\>\|\<indentkeys\>\|\<infercase\>\|\<insertmode\>\|\<isfname\>\|\<isident\>\|\<iskeyword\>\|\<isprint\>\|\<joinspaces\>\|\<keymap\>\|\<keymodel\>\|\<keywordprg\>\|\<langmap\>\|\<langmenu\>\|\<laststatus\>\|\<lazyredraw\>\|\<linebreak\>\|\<lines\>\|\<linespace\>\|\<lisp\>\|\<lispwords\>\|\<list\>\|\<listchars\>\|\<loadplugins\>\|\<magic\>\|\<makeef\>\|\<makeprg\>\|\<matchpairs\>\|\<matchtime\>\|\<maxcombine\>\|\<maxfuncdepth\>\|\<maxmapdepth\>\|\<maxmem\>\|\<maxmempattern\>\|\<maxmemtot\>\|\<menuitems\>\|\<mkspellmem\>\|\<modeline\>\|\<modelines\>\|\<modifiable\>\|\<modified\>\|\<more\>\|\<mouse\>\|\<mousefocus\>\|\<mousehide\>\|\<mousemodel\>\|\<mouseshape\>\|\<mousetime\>\|\<nrformats\>\|\<number\>\|\<numberwidth\>\|\<omnifunc\>\|\<operatorfunc\>\|\<paragraphs\>\|\<paste\>\|\<pastetoggle\>\|\<patchexpr\>\|\<patchmode\>\|\<path\>\|\<preserveindent\>\|\<previewheight\>\|\<previewwindow\>\)'

syn match vimlintOption contained '\(\<printdevice\>\|\<printencoding\>\|\<printexpr\>\|\<printfont\>\|\<printheader\>\|\<printmbcharset\>\|\<printmbfont\>\|\<printoptions\>\|\<pumheight\>\|\<quoteescape\>\|\<readonly\>\|\<redrawtime\>\|\<remap\>\|\<report\>\|\<revins\>\|\<rightleft\>\|\<rightleftcmd\>\|\<ruler\>\|\<rulerformat\>\|\<runtimepath\>\|\<scroll\>\|\<scrollbind\>\|\<scrolljump\>\|\<scrolloff\>\|\<scrollopt\>\|\<sections\>\|\<secure\>\|\<selection\>\|\<selectmode\>\|\<sessionoptions\>\|\<shell\>\|\<shellcmdflag\>\|\<shellpipe\>\|\<shellquote\>\|\<shellredir\>\|\<shelltemp\>\|\<shellxquote\>\|\<shiftround\>\|\<shiftwidth\>\|\<shortmess\>\|\<shortname\>\|\<showbreak\>\|\<showcmd\>\|\<showfulltag\>\|\<showmatch\>\|\<showmode\>\|\<showtabline\>\|\<sidescroll\>\|\<sidescrolloff\>\|\<smartcase\>\|\<smartindent\>\|\<smarttab\>\|\<softtabstop\>\|\<spell\>\|\<spellcapcheck\>\|\<spellfile\>\|\<spelllang\>\|\<spellsuggest\>\|\<splitbelow\>\|\<splitright\>\|\<startofline\>\|\<statusline\>\|\<suffixes\>\)'

syn match vimlintOption contained '\(\<suffixesadd\>\|\<swapfile\>\|\<swapsync\>\|\<switchbuf\>\|\<synmaxcol\>\|\<syntax\>\|\<tabline\>\|\<tabpagemax\>\|\<tabstop\>\|\<tagbsearch\>\|\<taglength\>\|\<tagrelative\>\|\<tags\>\|\<tagstack\>\|\<term\>\|\<termbidi\>\|\<termencoding\>\|\<terse\>\|\<textauto\>\|\<textmode\>\|\<textwidth\>\|\<thesaurus\>\|\<tildeop\>\|\<timeout\>\|\<timeoutlen\>\|\<title\>\|\<titlelen\>\|\<titleold\>\|\<titlestring\>\|\<toolbar\>\|\<toolbariconsize\>\|\<ttimeout\>\|\<ttimeoutlen\>\|\<ttybuiltin\>\|\<ttyfast\>\|\<ttymouse\>\|\<ttyscroll\>\|\<ttytype\>\|\<undolevels\>\|\<updatecount\>\|\<updatetime\>\|\<verbose\>\|\<verbosefile\>\|\<viewdir\>\|\<viewoptions\>\|\<viminfo\>\|\<virtualedit\>\|\<visualbell\>\|\<warn\>\|\<weirdinvert\>\|\<whichwrap\>\|\<wildchar\>\|\<wildcharm\>\|\<wildignore\>\|\<wildmenu\>\|\<wildmode\>\|\<winaltkeys\>\|\<winfixheight\>\|\<winfixwidth\>\|\<winheight\>\|\<winminheight\>\|\<winminwidth\>\|\<winwidth\>\|\<wrap\>\|\<wrapmargin\>\|\<wrapscan\>\|\<write\>\|\<writeany\>\|\<writebackup\>\|\<writedelay\>\)'

" These are the turn-off setting variants
syn match vimlintOption contained '\(\<noacd\>\|\<noallowrevins\>\|\<noantialias\>\|\<noarabic\>\|\<noarshape\>\|\<noautoread\>\|\<noaw\>\|\<noballooneval\>\|\<nobinary\>\|\<nobk\>\|\<nobuflisted\>\|\<nocin\>\|\<noconfirm\>\|\<nocopyindent\>\|\<nocscopeverbose\>\|\<nocuc\>\|\<nocursorline\>\|\<nodg\>\|\<nodisable\>\|\<noeb\>\|\<noedcompatible\>\|\<noendofline\>\|\<noequalalways\>\|\<noesckeys\>\|\<noex\>\|\<noexrc\>\|\<nofk\>\|\<nofoldenable\>\|\<nogdefault\>\|\<nohid\>\|\<nohk\>\|\<nohkmapp\>\|\<nohls\>\|\<noic\>\|\<noignorecase\>\|\<noimc\>\|\<noimd\>\|\<noinf\>\|\<noinsertmode\>\|\<nojoinspaces\>\|\<nolazyredraw\>\|\<nolinebreak\>\|\<nolist\>\|\<nolpl\>\|\<noma\>\|\<nomagic\>\|\<noml\>\|\<nomodeline\>\|\<nomodified\>\|\<nomousef\>\|\<nomousehide\>\|\<nonumber\>\|\<noopendevice\>\|\<nopi\>\|\<nopreviewwindow\>\|\<nopvw\>\|\<noremap\>\|\<norevins\>\|\<norightleft\>\|\<norl\>\|\<noro\>\|\<noru\>\|\<nosb\>\|\<noscb\>\|\<noscs\>\|\<nosft\>\|\<noshelltemp\>\|\<noshortname\>\|\<noshowfulltag\>\|\<noshowmode\>\|\<nosm\>\|\<nosmartindent\>\|\<nosmd\>\|\<nosol\>\|\<nosplitbelow\>\|\<nospr\>\|\<nossl\>\|\<nostartofline\>\|\<noswapfile\>\|\<nota\>\|\<notagrelative\>\|\<notbi\>\|\<notbs\>\|\<noterse\>\|\<notextmode\>\|\<notgst\>\|\<notimeout\>\|\<noto\>\|\<notr\>\|\<nottybuiltin\>\|\<notx\>\|\<novisualbell\>\|\<nowarn\>\|\<noweirdinvert\>\|\<nowfw\>\|\<nowinfixheight\>\|\<nowiv\>\|\<nowrap\>\|\<nowrite\>\|\<nowritebackup\>\)'

syn match vimlintOption contained '\(\<noai\>\|\<noaltkeymap\>\|\<noar\>\|\<noarabicshape\>\|\<noautochdir\>\|\<noautowrite\>\|\<noawa\>\|\<nobeval\>\|\<nobiosk\>\|\<nobl\>\|\<nocf\>\|\<nocindent\>\|\<noconsk\>\|\<nocp\>\|\<nocst\>\|\<nocul\>\|\<nodeco\>\|\<nodiff\>\|\<noea\>\|\<noed\>\|\<noek\>\|\<noeol\>\|\<noerrorbells\>\|\<noet\>\|\<noexpandtab\>\|\<nofen\>\|\<nofkmap\>\|\<nogd\>\|\<noguipty\>\|\<nohidden\>\|\<nohkmap\>\|\<nohkp\>\|\<nohlsearch\>\|\<noicon\>\|\<noim\>\|\<noimcmdline\>\|\<noincsearch\>\|\<noinfercase\>\|\<nois\>\|\<nojs\>\|\<nolbr\>\|\<nolisp\>\|\<noloadplugins\>\|\<nolz\>\|\<nomacatsui\>\|\<nomh\>\|\<nomod\>\|\<nomodifiable\>\|\<nomore\>\|\<nomousefocus\>\|\<nonu\>\|\<noodev\>\|\<nopaste\>\|\<nopreserveindent\>\|\<noprompt\>\|\<noreadonly\>\|\<norestorescreen\>\|\<nori\>\|\<norightleftcmd\>\|\<norlc\>\|\<nors\>\|\<noruler\>\|\<nosc\>\|\<noscrollbind\>\|\<nosecure\>\|\<noshellslash\>\|\<noshiftround\>\|\<noshowcmd\>\|\<noshowmatch\>\|\<nosi\>\|\<nosmartcase\>\|\<nosmarttab\>\|\<nosn\>\|\<nospell\>\|\<nosplitright\>\|\<nosr\>\|\<nosta\>\|\<nostmp\>\|\<noswf\>\|\<notagbsearch\>\|\<notagstack\>\|\<notbidi\>\|\<notermbidi\>\|\<notextauto\>\|\<notf\>\|\<notildeop\>\|\<notitle\>\|\<notop\>\|\<nottimeout\>\|\<nottyfast\>\|\<novb\>\|\<nowa\>\|\<nowb\>\|\<nowfh\>\|\<nowildmenu\>\|\<nowinfixwidth\>\|\<nowmnu\>\|\<nowrapscan\>\|\<nowriteany\>\|\<nows\>\)'

syn match vimlintOption contained '\(\<noakm\>\|\<noanti\>\|\<noarab\>\|\<noari\>\|\<noautoindent\>\|\<noautowriteall\>\|\<nobackup\>\|\<nobin\>\|\<nobioskey\>\|\<nobomb\>\|\<noci\>\|\<nocompatible\>\|\<noconskey\>\|\<nocscopetag\>\|\<nocsverb\>\|\<nocursorcolumn\>\|\<nodelcombine\>\|\<nodigraph\>\)'

"TODO: put more evil options here
syn match vimlintEvilOption '\(\<compatible\>\|\<edcompatible\>\|\<exrc\>\|\<gdefault\>\|\<nohidden\>\|\<insertmode\>\|\<lisp\>\|\<noloadplugins\>\|\<nomagic\>\|\<smartindent\>\)' contained

"TODO: put more warning-worthy options here
syn match vimlintWarningOption '\(\<cindent\>\|\<autochdir\>\|\<autoread\>\|\<autowrite\>\|\<autowriteall\>\|\<modeline\>\|\<nomodifiable\>\|\<readonly\>\|\<paste\>\|\<secure\>\|\<noswapfile\>\|\<nottyfast\>\|\<nowrite\>\|\<writeany\>\)' contained

hi def link vimlintEvilOption            vimlintError
hi def link vimlintEvilScript            vimlintError
hi def link vimlintWarningOption         vimlintWarning
hi def link vimlintErrorWord             vimlintError
hi def link vimlintWarningWord           vimlintWarning
hi def link vimlintMissingFeatures       vimlintWarning
hi def link vimlintH1                    vimlintTitle
hi def link vimlintH2                    vimlintTitle
hi def link vimlintH3                    vimlintTitle

let b:current_syntax = "vimlint"

" vim:set sw=2:
