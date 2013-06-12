task :build do
  `
  cat headers/coffee-comment.txt  > sneaker.coffee
  cat headers/headline.txt       >> sneaker.coffee
  cat headers/version.txt        >> sneaker.coffee
  cat headers/license.txt        >> sneaker.coffee
  cat headers/coffee-comment.txt >> sneaker.coffee
  
  files=( "source/core.coffee" "source/view.coffee" "source/press.coffee" "source/box.coffee" "source/api.coffee" "source/apimock.coffee" )
  for filename in "${files[@]}"; do
    echo "\n\n" && cat "${filename}"
  done >> sneaker.coffee
  
  coffee --print sneaker.coffee > sneaker.js
  
  
  
  cat headers/coffee-comment.txt     > sneaker-matchers.coffee
  cat headers/headline-matchers.txt >> sneaker-matchers.coffee
  cat headers/version.txt           >> sneaker-matchers.coffee
  cat headers/license.txt           >> sneaker-matchers.coffee
  cat headers/coffee-comment.txt    >> sneaker-matchers.coffee  

  cat source/matchers.coffee >> sneaker-matchers.coffee
  
  coffee --print --bare sneaker-matchers.coffee > sneaker-matchers.js
  `
end