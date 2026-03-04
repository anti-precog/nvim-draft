syntax match alterText "^\t.*"
highlight alterText guifg=#6699CC

syntax match dialogue "—.*$"
highlight dialogue gui=italic

syntax match innerDialogue "—[^—]\+—"
highlight innerDialogue gui=italic

syntax match quote /„[^„]\+”/
syntax match quote2 /"[^"]\+"/
highlight quote gui=italic
highlight quote2 gui=italic

syntax match header "^ .*"
highlight! header guifg=#CC6699 gui=bold
