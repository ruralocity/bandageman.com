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
  mkdir -p site/{{GAME}}
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.html site/{{GAME}}/index.html
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.js site/{{GAME}}/{{GAME}}.js
  @just _inject-metadata site/{{GAME}}/index.html {{GAME}}
  @just _inject-footer site/{{GAME}}/index.html

# Update game files
[group("carts")]
update GAME:
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.html site/{{GAME}}/index.html
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.js site/{{GAME}}/{{GAME}}.js
  @just _inject-metadata site/{{GAME}}/index.html {{GAME}}
  @just _inject-footer site/{{GAME}}/index.html

# Internal: Inject metadata into HTML file
_inject-metadata FILE GAME:
  ./scripts/inject-metadata.sh {{FILE}} {{GAME}}

# Internal: Inject footer into HTML file
_inject-footer FILE:
  ./scripts/inject-footer.sh {{FILE}}
