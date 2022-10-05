if exists("b:cfg_markdown_ft_done")
  finish
endif

if expand("%:p") =~ "/notes/"
  setlocal spell
endif

" Hide things like triple backticks and urls
setlocal conceallevel=2

iabbrev <buffer> pr pull request
iabbrev <buffer> af ## Afternoon*

let b:cfg_markdown_ft_done = 1
