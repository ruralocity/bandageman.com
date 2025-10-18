# List available recipes
list:
  @just --list

# Build the site from templates
[group("development")]
build:
  uv run build.py

# Run server locally (builds first)
[group("development")]
run:
  @just build
  uv run python -m http.server --directory site

# Add game to PICO-8 cart directory
[group("carts")]
add GAME:
  mkdir -p site/{{GAME}}
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.html site/{{GAME}}/index.html
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.js site/{{GAME}}/{{GAME}}.js
  uv run build.py --add-game {{GAME}}
  @echo "\nRun 'just build' to regenerate the homepage with the new game."

# Update game files from PICO-8
[group("carts")]
update GAME:
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.html site/{{GAME}}/index.html
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.js site/{{GAME}}/{{GAME}}.js
  @echo "✓ Updated {{GAME}} files from PICO-8"
