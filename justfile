# List available recipes
list:
  @just --list

# Run server locally
[group("development")]
run:
  python3 -m http.server --directory site

# Add game
[group("carts")]
add GAME:
  mkdir -p site/games/{{GAME}}
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}.html site/{{GAME}}/index.html
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}.js site/{{GAME}}/{{GAME}}.js

# Update game files
[group("carts")]
update GAME:
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}.html site/{{GAME}}/index.html
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}.js site/{{GAME}}/{{GAME}}.js
