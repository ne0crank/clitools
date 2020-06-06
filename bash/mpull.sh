#!/bin/zsh
main="/Users/ne0crank/git"
for h in `ls $main`; do cd ${main}/${h}; echo; echo git pull $h; echo; git pull; cd $main; done
