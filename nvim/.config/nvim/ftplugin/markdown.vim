if exists("b:cfg_markdown_ft_done")
  finish
endif

setlocal spell

iabbrev <buffer> pr pull request
iabbrev <buffer> af ## Afternoon*

let b:cfg_markdown_ft_done = 1
