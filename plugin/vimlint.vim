" ============================================================================
" File:        vimlint.vim
" Description: Vim plugin that checks your Vim environment, settings and
"              loaded scripts for conflicts, omissions and ill-advised
"              configurations.
" Author:      Barry Arthur <barry.arthur at gmail dot com>
" Last Change: 30 June, 2010
"
" See vimlint.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimlint
"
" Licensed under the same terms as Vim itself.
" ============================================================================
let s:VimLint_version = '0.0.2'  " alpha, unreleased

" allow line continuation
let s:old_cpo = &cpo
set cpo&vim

"NOTES:{{{1
"  (From a discussion on #vim:
"     It occurs to me that a Vim Option lint might be useful. When a newcomer
"     has grief we can ask them to run the lint and have it check for bad
"     options set ('gdefault' comes to mind, as does 'tabstop'), bad
"     combinations set ('expandtab' and 'tabstop'), essential options unset
"     ('hidden') or set poorly ('cpoptions', 'formatoptions')...  Does this
"     already exist? What are your thoughts on the utility of such a tool?
"
"     Often it's enough to just tell people to paste their .vimrc, but it
"     could be nice with something that ran :scriptnames, displayed a bunch
"     of particularly tricky options, echoed the result of e.g.
"     has("+clipboard"), environment variables, etc.
"
"     SHELL, TERM, COLORTERM, VIM and VIMRUNTIME
"
"     full vim
"     syntax on  filetype plugin indent on
"     remove mswin.vim
"     $TERM <> &term is mostly bad.
"

" Essential Options: {{{1
" TODO: trim following options list to just the essentials
" TODO: add fail/requires/conflicts to essential options
" TODO: provide a better set of C filetypes in cindent check
let indent_reason = 'Remove all indent options from your .vimrc (except autoindent) and let your ftplugins handle indenting.'
let s:chk_opt = {
      \  'cindent' : {
      \    'reason' : indent_reason,
      \    'fail-expr' : ['&cindent == 1']
      \  },
      \  'compatible' : {
      \    'reason' : "Use Vim, not vi.",
      \    'fail-expr' : ['&compatible == 1']
      \  },
      \  'cpoptions' : {
      \    'reason' : "Controls how 'vi' compatible Vim is. Set with care.",
      \    'warn-expr' : ['&cpoptions != "aABceFs"']
      \  },
      \  'edcompatible' : {
      \    'reason' : "Sets the 'g' and 'c' flags of \":substitute\" toggle, rather than acting for that call only.",
      \    'warn-expr' : ['&edcompatible == 1']
      \  },
      \  'exrc' : {
      \    'reason' : "Allows reading .vimrc/.exrc/.gvimrc in the current directory. This is a potential security risk!",
      \    'fail-expr' : ['&exrc == 1']
      \  },
      \  'gdefault' : {
      \    'reason' : "Sets the 'g' flag for \":substitute\" by default.",
      \    'warn-expr' : ['&gdefault == 1']
      \  },
      \  'hidden' : {
      \    'reason' : "Prevents having unsaved files open in Vim. Setting this on is highly recommended.",
      \    'warn-expr' : ['&hidden == 0']
      \  },
      \  'insertmode' : {
      \    'reason' : "Use Insert mode by default. This is not the Vim way.",
      \    'warn-expr' : ['&insertmode == 1']
      \  },
      \  'lisp' : {
      \    'reason' : indent_reason,
      \    'fail-expr' : ['&lisp == 1']
      \  },
      \  'loadplugins' : {
      \    'reason' : "Prevents loading plugin scripts when starting Vim. Setting this on is highly recommended.",
      \    'warn-expr' : ['&loadplugins == 0']
      \  },
      \  'magic' : {
      \    'reason' : "Changes the special characters in search patterns. To avoid compatibility problems, always leave this on.",
      \    'warn-expr' : ['&magic == 0']
      \  },
      \  'modeline' : {
      \    'reason' : "Evaluates settings from modelines when reading files. Disable modelines before editing untrusted text.",
      \    'warn-expr' : ['&modeline == 1']
      \  },
      \  'smartindent' : {
      \    'reason' : indent_reason,
      \    'fail-expr' : ['&smartindent == 1']
      \  },
      \  'tabstop' : {
      \    'reason' : "Don't change 'tabstop' when using 'expandtab'.",
      \    'fail-expr' : ['(&tabstop != 8) && (&expandtab == 1)']
      \  },
      \}

" Essential Environment Variables: {{{1
" TODO: fill in more fail entries
" XXX: Are $VIM, $VIMRUNTIME and $COLORTERM useful? I could imagine checking
" matches between $TERM and $COLORTERM... but that might be an ugly matrix?
let s:chk_env_vars = {
      \  'SHELL' : {
      \    'reason' : "Vim requires a POSIX shell.",
      \    'fail-expr' : ["s:VL_Include(['\\<fish\\>'], $SHELL)"]
      \  },
      \  'TERM' : {
      \    'reason' : "Some terminals are not standards compliant. Xterm is the safest terminal to use with Vim.",
      \    'warn-expr' : ["! s:VL_Include(['^xterm'], $TERM)"]
      \  },
      \  'COLORTERM' : {
      \    'reason' : "",
      \    'warn-expr' : ["! s:VL_Include(['^gnome-terminal'], $COLORTERM)"]
      \  },
      \  'VIM' : {
      \    'reason' : "For you to not have a valid $VIM environment variable, something must be very wrong with your Vim installation.",
      \    'fail-expr' : ["$VIM == ''"]
      \  },
      \  'VIMRUNTIME' : {
      \    'reason' : "For you to not have a valid $VIMRUNTIME environment variable, something must be very wrong with your Vim installation.",
      \    'fail-expr' : ["$VIMRUNTIME == ''"]
      \  },
      \}

" Private Functions: {{{1

let s:vl_fail_status = '!! '
let s:vl_warn_status = '!  '

" helper function for checking if a var matches any of a set of regex patterns
function! s:VL_Include(array, item)
  return len(filter(map(a:array, 'a:item =~ v:val'), 'v:val == 1'))
endfunction

" helper function for expanding environment vars and vim options without
" having to litter the code with exe "let..." statements
function! s:VL_Expand(var_type, var_name)
  exe "let val = " . a:var_type . a:var_name
  return val
endfunction

function! s:VL_CheckVimVersion()
  if v:version < 700
    silent echo "!! NOT Running Vim 7!"
  endif

  echo "\n== Version =="
  version
endfunction

" Check a set of 'fail' and then 'warn' expressions, short-circuiting at the
" first successful failure.
function! s:VL_EvaluateExpressions(var_inf)
  let status = '   '
  for check_type in ['fail', 'warn']
    exe "let trigger_status = s:vl_" . check_type . "_status"
    let check_expr = check_type . '-expr'
    if has_key(a:var_inf, check_expr)
      for expr in a:var_inf[check_expr]
        exe "if " . expr . " | let status = '" . trigger_status . "' | endif"
        if status =~ '!' | break | endif
      endfor
    endif
  endfor
  return status
endfunction

function! s:VL_FailReason(status, reason)
  return (a:status =~ '!') ? "		" . escape(a:reason, "'\"") : ''
endfunction

" Complain if the environment variable doesn't match the vim variable
function! s:VL_CheckEnvVsVimVar(env_var, vim_var)
  let env_val = s:VL_Expand('$', a:env_var)
  let vim_val = s:VL_Expand('&', a:vim_var)
  if env_val != vim_val
    exe "echo \"\n" . s:vl_fail_status . "$" . a:env_var . " != &" . a:vim_var . " => " . env_val . " != " . vim_val . "\""
  endif
endfunction

" compares environment variables with corresponding vim options
function! s:VL_CrossCheckEnvVarsAgainstVimOpts()
  if "builtin_gui" != &term
    call s:VL_CheckEnvVsVimVar('TERM', 'term')
  endif
  call s:VL_CheckEnvVsVimVar('SHELL', 'shell')
endfunction

" checks important environment variables
function! s:VL_CheckEnvironmentVars()
  echo "\n== Environment Variables ==\n"
  for [env_var, var_inf] in sort(items(s:chk_env_vars))
    let env_val = s:VL_Expand('$', env_var)
    let status = s:VL_EvaluateExpressions(var_inf)
    let reason = s:VL_FailReason(status, var_inf['reason'])
    exe "echo \"" . status . env_var . "=" . env_val . reason . "\""
  endfor
  call s:VL_CrossCheckEnvVarsAgainstVimOpts()
endfunction

" checks important vim options
function! s:VL_CheckEssentialOptions()
  echo "\n== Essential Options ==\n"
  for [v_opt, v_inf] in sort(items(s:chk_opt))
    let val = s:VL_Expand('&', v_opt)
    if val =~ '^[01]$'
      let s_opt = (val ? '' : 'no') . v_opt
      let e_val = ''
    else
      let s_opt = v_opt
      let e_val = ' = ' . escape(val, "'\"")
    end
    let status = s:VL_EvaluateExpressions(v_inf)
    let reason = s:VL_FailReason(status, v_inf['reason'])
    exe "echo \"" . status . "'" . s_opt . e_val . reason . "\""
  endfor
endfunction

function! s:VL_CheckScripts()
  if has('eval')
    echo "\n== Scripts ==\n"
    silent scriptnames
  endif
endfunction

function! s:VL_CheckAllOptions()
  echo "\n== All Settings ==\n"
  silent set all
endfunction

function! s:VL_CheckTermOptions()
  echo "\n== Termcap Settings ==\n"
  silent set termcap
endfunction

function! s:VL_CollectData()
  call s:VL_CheckVimVersion()
  call s:VL_CheckEnvironmentVars()
  call s:VL_CheckEssentialOptions()
  call s:VL_CheckScripts()
  call s:VL_CheckAllOptions()
  call s:VL_CheckTermOptions()
endfunction

function! s:VL_RunReport()
  echo "= Vim Lint v" . s:VimLint_version . " ="
  echo "\nThis is a summary of your current Vim configuration, with suggestions to correct bad or dangerous options.\n"
  echo "warnings are shown in red on white background (usually with ! at the start of the line)."
  echo "errors are shown in white on red background (usually with !! at the start of the line)."
  call s:VL_CollectData()
  echo "\n= END of Vim Lint ="
  echo "  vim: set ft=vimlint:"
endfunction

" Public Interface: {{{1
function! VimLint()
  let vimlintreport = tempname()

  new  " use a new window / buffer so that filetype is clear
  exe "redir > " . vimlintreport
  silent call s:VL_RunReport()
  redir END

  exe "edit " . vimlintreport
  silent set filetype=vimlint
  " nicer to see the report in a full window if we can
  if &hidden == 1
    only
  endif

  echo "Vim Lint Report saved in " . vimlintreport
endfunction

command! -nargs=0 VimLint call VimLint()

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:old_cpo

" vim: set sw=2 sts=2 et fdm=marker:
