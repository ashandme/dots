"Plug-ins
call plug#begin('~/.config/nvim/plugged')
" Tools
    Plug 'junegunn/goyo.vim'
    Plug 'vifm/vifm.vim'
    Plug 'junegunn/limelight.vim'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'racer-rust/vim-racer'
" Syntax
    Plug 'w0rp/ale'
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    autocmd BufEnter * call ncm2#enable_for_buffer()
    set completeopt=noinsert,menuone,noselect
    Plug 'ncm2/ncm2-bufword'
    Plug 'ncm2/ncm2-path'
    Plug 'ncm2/ncm2-racer'
" something
    Plug 'aurieh/discord.nvim', { 'do': ':UpdateRemotePlugins'}
    Plug 'airblade/vim-rooter'
    Plug 'ap/vim-css-color'
call plug#end()
"General Settings
set encoding=UTF-8
set nu!
filetype plugin indent on  "Enabling Plugin & Indent
syntax on  "Turning Syntax on
noremap ; :
inoremap <C-j> <ESC>
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"



"color-scheme
hi Comment term=bold ctermfg=Cyan guifg=Red
hi Normal guifg=black guibg=white
hi Constant term=underline ctermfg=Magenta guifg=Magenta
hi Special term=bold ctermfg=Magenta guifg=Magenta
hi Identifier term=underline ctermfg=Blue guifg=Blue
hi Statement term=bold ctermfg=DarkRed gui=NONE guifg=Brown
hi PreProc term=underline ctermfg=Magenta guifg=Purple
hi Type term=underline ctermfg=Blue gui=NONE guifg=Blue
hi Visual term=reverse ctermfg=Yellow ctermbg=Red gui=NONE guifg=Black guibg=Yellow
hi Search term=reverse ctermfg=Black ctermbg=Cyan gui=NONE guifg=Black guibg=Cyan
hi Tag term=bold ctermfg=DarkGreen guifg=DarkGreen
hi Error term=reverse ctermfg=15 ctermbg=9 guibg=Red guifg=White
hi Todo term=standout ctermbg=Yellow ctermfg=Black guifg=Blue guibg=Yellow
hi StatusLine term=bold,reverse cterm=NONE ctermfg=Black ctermbg=White gui=NONE guifg=Yello guibg=DarkGray
hi! link MoreMsg Comment
hi! link ErrorMsg Visual
hi! link WarningMsg ErrorMsg
hi! link Question Comment
hi link String  Constant
hi link Character   Constant
hi link Number  Constant
hi link Boolean Constant
hi link Float       Number
hi link Function    Identifier
hi link Conditional Statement
hi link Repeat  Statement
hi link Label       Statement
hi link Operator    Statement
hi link Keyword Statement
hi link Exception   Statement
hi link Include PreProc
hi link Define  PreProc
hi link Macro       PreProc
hi link PreCondit   PreProc
hi link StorageClass    Type
hi link Structure   Type
hi link Typedef Type
hi link SpecialChar Special
hi link Delimiter   Special
hi link SpecialComment Special
hi link Debug       Special
