if exists("b:cfg_markdown_ft_done")
  finish
endif

setlocal spell

" Hide things like triple backticks
setlocal conceallevel=2

iabbrev <buffer> pr pull request
iabbrev <buffer> af ## Afternoon*

let b:cfg_markdown_ft_done = 1
