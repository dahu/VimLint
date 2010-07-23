" ============================================================================
" File:        vimlint.vim
" Description: Vim plugin that checks your Vim environment, settings and
"              loaded scripts for conflicts, omissions and ill-advised
"              configurations.
" Author:      Barry Arthur <barry.arthur at gmail dot com>
" Last Change: 22 July, 2010
" Website:     http://github.com/dahu/VimLint
"
" See vimlint.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vimlint
"
" Licensed under the same terms as Vim itself.
" ============================================================================
let s:VimLint_version = '0.0.5'  " alpha, unreleased

" History:{{{1
" v.0.0.5 changes:
" * replaced awful 'redirect to temporary file and run ex commands' with the
"   approach of redirecting to a register and using vimscript. (thanks,
"   godlygeek)
" * replaced method of collecting All Options by using :help option-list
"   (thanks, jamessan)
" * fixed a bug that assumed 'hidden' was enabled. (thanks, Raimondi)
"
" v.0.0.4 changes:
" * check &runtimepath for sane entries
" * show the current   :filetype   settings in the vimlint report
" * Tried to DRY up the way temporary redirections are done.
"
" v.0.0.3 changes:
" * environment variables check list now allows multiple {:reason, :fail_expr}
"   sets
" * limit the set of -feature highlights in vimlint report
" * checks for ~/.vimrc / ~/_vimrc
" * removed checks against $TERM - just showing its value now
" * verify that $VIM and $VIMRUNTIME dirs exist
" * change way All Options are collected and displayed - now uses
"   :verbose set   to show where each option was last set
"
" v0.0.2 changes:
" * only check 'tabstop' when 'expandtab' is set
" * use :new to clear 'filetype' is
" * add version to report header.
"
" v0.0.1:
" * initial release

" TODO / Issues:{{{1
"
" [Features]
" * dump :scriptnames to a register and parse it for 'bad scripts', adding !!
"   and ! as appropriate.
" * add lots more help in the doc/vimlint.txt file explaining *why* these
"   recommendations are made.
" * add tags to easily jump from the report to the help entries.
" * should autocmds be dumped?
"
" [Script Robustness]
" * learn what needs protecting:
" ** if not running under Vim 7.
" ** given the possibility of missing features - should I wrap has('feature')
"    checks around everything?
"
" [Code Style]
" * see the various TODO's throughout

" allow line continuation
let s:old_cpo = &cpo
set cpo&vim

" Error Messages:{{{1
" Repeatedly used error messages (used by the s:E() function below)
let s:vl_error_messages = {
      \ 'critical_error'  : "Something must be very wrong with your Vim installation.",
      \ 'help'            : "	|VL-%s|",
      \ 'indent_reason'   : "Use 'filetype indent on' instead, for smart per-filetpe indenting.",
      \ 'env_var_missing' : "You have an invalid %s environment variable.",
      \ 'env_var_invalid' : "Your %s environment variable points to an invalid directory.",
      \ 'after_dir_missing' : "%s/after needs to be added to your runtimepath because it contains %s and a corresponding '/after' directory exists on disk."
      \}

" Error Message Expander
function! s:E(code, ...)
  if a:0 > 0
    let params = [s:vl_error_messages[a:code]] + a:000
    return call (function('printf'), params)
  else
    return s:vl_error_messages[a:code]
  endif
endfunction

" Essential Options: {{{1
let indent_reason = ''
let s:chk_opt = {
      \  'cindent' : {
      \    'reason' : s:E('indent_reason'),
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
      \    'reason' : "Makes the 'g' and 'c' flags of \":substitute\" toggle, rather than acting for that call only.",
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
      \    'reason' : s:E('indent_reason'),
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
      \    'reason' : s:E('indent_reason'),
      \    'fail-expr' : ['&smartindent == 1']
      \  },
      \  'tabstop' : {
      \    'reason' : "Don't change 'tabstop' when using 'expandtab'.",
      \    'fail-expr' : ['(&tabstop != 8) && (&expandtab == 1)']
      \  },
      \}

" Essential Environment Variables: {{{1
" TODO: either decide to keep the consistent data structure (allowing the
" hideous [{}]), or change the VL_CheckEnvironmentVars() function to allow
" single entry {...} or multiple entry [{..},{...}] variants.
"
" NOTE: It seems that Vim defaults the $VIM and $VIMRUNTIME env vars if
" they're empty, so that test is probably moot.
let s:chk_env_vars = {
      \  'SHELL' : [{
      \    'reason' : "Vim requires a POSIX shell.",
      \    'fail-expr' : ["s:VL_Include(['\\<fish\\>'], $SHELL)"]
      \  }],
      \  'TERM' : [{}],
      \  'VIM' : [
      \    {
      \      'reason' : s:E('env_var_missing', '$VIM') . ' ' . s:E('critical_error'),
      \      'fail-expr' : ["$VIM == ''"]
      \    },
      \    {
      \      'reason' : s:E('env_var_invalid', '$VIM') . ' ' . s:E('critical_error'),
      \      'fail-expr' : ["! isdirectory($VIM)"]
      \    }
      \  ],
      \  'VIMRUNTIME' : [
      \    {
      \      'reason' : s:E('env_var_missing', '$VIMRUNTIME') . ' ' . s:E('critical_error'),
      \      'fail-expr' : ["$VIMRUNTIME == ''"]
      \    },
      \    {
      \      'reason' : s:E('env_var_invalid', '$VIM') . ' ' . s:E('critical_error'),
      \      'fail-expr' : ["! isdirectory($VIMRUNTIME)"]
      \    }
      \  ],
      \}

" Private Functions: {{{1

let s:vl_pass_status = '   '
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

" helper function to trim leading whitespace from strings
function! s:VL_TrimLeft(string)
  return substitute(a:string, '^\_.\{-}\(\w\)', '\1', '')
endfunction

" helper wrapper for temporarily redirecting output to the 'a' register for
" capturing info.
" Example: call s:VL_Execute('filetype')
" NOTE: This re-sets redirection and resets it back to the Vim Report afterwards.
function! s:VL_Execute(command)
  let save_reg = @a
  redir @a
  exe a:command
  redir END
  exe "redir >> " . s:vimlintreport
  let ret_val = @a
  let @a = save_reg
  return ret_val
endfunction

function! s:VL_CheckVimVersion()
  if v:version < 700
    silent echo s:vl_fail_status . " NOT Running Vim 7!"
  endif

  echo "\n== Version =="
  version
endfunction

" Check a set of 'fail' and then 'warn' expressions, short-circuiting at the
" first successful failure.
function! s:VL_EvaluateExpressions(var_inf)
  let status = s:vl_pass_status
  for check_type in ['fail', 'warn']
    exe "let trigger_status = s:vl_" . check_type . "_status"
    let check_expr = check_type . '-expr'
    if has_key(a:var_inf, check_expr)
      for expr in a:var_inf[check_expr]
        exe "if " . expr . " | let status = '" . trigger_status . "' | endif"
        if status !~ s:vl_pass_status | break | endif
      endfor
    endif
  endfor
  return status
endfunction

function! s:VL_FailReason(status, reason)
  return (a:status !~ s:vl_pass_status ) ? "		" . escape(a:reason, "'\"") : ''
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
  for [env_var, var_inf_list] in sort(items(s:chk_env_vars))
    let env_val = s:VL_Expand('$', env_var)
    for var_inf in var_inf_list
      let status = s:VL_EvaluateExpressions(var_inf)
      let reason = has_key(var_inf, 'reason') ? s:VL_FailReason(status, var_inf['reason']) : ''
      if status !~ s:vl_pass_status | break | endif
    endfor
    exe "echo \"" . status . env_var . "=" . env_val . reason . "\""
  endfor
  call s:VL_CrossCheckEnvVarsAgainstVimOpts()
endfunction

" checks for the presence of ~/.vimrc or ~/_vimrc
function! s:VL_CheckVimrc()
  if exists('$MYVIMRC')
    let vimrc = expand('$MYVIMRC')
    if ! filereadable(vimrc)
      " I imagine this to be a very improbable edge case - it's Vim who sets
      " the $MYVIMRC variable when it finds and loads a personal vimrc, so for
      " it to be set but missing on disk would mean that it was deleted/moved
      " since starting Vim.
      echo s:vl_fail_status . " Your personal vimrc file (" . vimrc . ") doesn't exist!"
    endif
  else
    " Although the two variants (.vimrc and _vimrc) are actually tolerated on
    " each platform, I advise the 'more correct' version only.
    if has('win32') || has('dos32') || has('win16') || has('dos16') || has('win95')
      let platform_vimrc = '$HOME/_vimrc'
    elseif has('unix') || has('macunix')
      let platform_vimrc = '$HOME/.vimrc'
    else
      echo s:vl_warn_status . " Can't detect what operating system you're using. Kindly let the developer know your OS, thanks. :)"
    endif
    echo s:vl_fail_status . " You don't have a personal vimrc file! You really should create a '" . platform_vimrc . "' file."
  endif
endfunction

" checks for sane entries in &runtimepath
function! s:VL_CheckVimRuntimePath()
  " TODO: I have the feeling that DRYing the next two checks would be more
  " hassle than it's worth, and more verbose than this simple but ugly way.
  if finddir($VIM, &rtp) == ''
    echo s:vl_fail_status . " $VIM is not in your runtimepath! " . s:E('critical_error')
  endif
  if finddir($VIMRUNTIME, &rtp) == ''
    echo s:vl_fail_status . " $VIMRUNTIME is not in your runtimepath! " . s:E('critical_error')
  endif
  let started_afters = 0
  for v_dir in split(&runtimepath, '\\\@<!,')
    if v_dir =~# '/after$'
      let started_afters = 1
    else
      if started_afters
        echo s:vl_fail_status . " Must not have normal directories following '/after' directories in runtimepath: " . v_dir
      endif
      if isdirectory(v_dir . "/after") && finddir(v_dir . "/after", &rtp) == ''
        " TODO: this seems clumsy... What is the alternative? Is there a way
        " for printf() to repeat the final argument if not enough are supplied...?
        echo s:vl_fail_status . s:E('after_dir_missing', v_dir, v_dir)
      endif
    endif
  endfor
endfunction

" look for and warn about /off/i within :filetype output
function! s:VL_CheckFiletypeSettings()
  echo "\n== Filetype Settings ==\n"
  let ft = s:VL_TrimLeft(s:VL_Execute('filetype'))
  let status = s:vl_pass_status
  let help = ''
  if match(ft, '\coff') != -1
    let status = s:vl_fail_status
    let help = s:E('help', 'filetype')
  endif
  echo status . ft . help
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
    exe "echo \"" . status . s_opt . e_val . reason . "\""
  endfor
endfunction

function! s:VL_CheckScripts()
  if has('eval')
    echo "\n== Scripts ==\n"
    silent scriptnames
  endif
endfunction

function! s:VL_CheckAllOptions()
  let save_reg = @@
  call s:VL_Execute("help option-list | .,/^---/y | close")
  " wrap all options in '' and separate with commas  
  " strip leading guff and open the array  
  " strip trailing guff and close the array
  exe "let g:VL_all_options = " . substitute(substitute(substitute(@@,
        \ '\(''\w\+''\).\{-}\n', '\1,', 'g'),
        \ '^.\{-}''', '[''', ''),            
        \ ',----*', ']', '')                 
  echo "\n== All Settings ==\n"
  echo "--- Options ---"
  for v_opt in g:VL_all_options
    try
      silent exe "verbose set " . v_opt . "?"
    catch
    endtry
  endfor
  let @@ = save_reg
endfunction

function! s:VL_CheckTermOptions()
  echo "\n== Termcap Settings ==\n"
  silent set termcap
endfunction

function! s:VL_CollectData()
  call s:VL_CheckVimVersion()
  call s:VL_CheckEssentialOptions()
  call s:VL_CheckEnvironmentVars()
  call s:VL_CheckVimRuntimePath()
  call s:VL_CheckVimrc()
  call s:VL_CheckFiletypeSettings()
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
  let s:vimlintreport = tempname()

  new  " use a new window / buffer so that filetype is clear
  exe "redir > " . s:vimlintreport
  silent call s:VL_RunReport()
  redir END

  silent exe "edit " . s:vimlintreport
  silent set filetype=vimlint
  " nicer to see the report in a full window if we can
  if &hidden == 1
    only
  endif

  echo "Vim Lint Report saved in " . s:vimlintreport
endfunction

command! -nargs=0 VimLint call VimLint()

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:old_cpo

" Credits:{{{1
"
" Thanks to godlygeek, jamessan, spiiph and Raimondi for contributing ideas,
" suggestions, algorithms and corrections.
"
" vim: set sw=2 sts=2 et fdm=marker:
