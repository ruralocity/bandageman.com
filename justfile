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
  @just _inject-footer site/{{GAME}}/index.html

# Update game files
[group("carts")]
update GAME:
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.html site/{{GAME}}/index.html
  cp ~/Library/Application\ Support/pico-8/carts/{{GAME}}/{{GAME}}.js site/{{GAME}}/{{GAME}}.js
  @just _inject-footer site/{{GAME}}/index.html

# Internal: Inject footer into HTML file
_inject-footer FILE:
  #!/usr/bin/env bash
  set -euo pipefail
  # Check if footer already exists
  if ! grep -q 'bandageman-transparent.png' "{{FILE}}"; then
    # Find the line with </div> <!-- body_0 --> and inject footer before it
    sed -i '' '/<\/div> <!-- body_0 -->/i\
\
<div style="text-align: center; margin-top: 40px; padding-bottom: 20px;">\
	<a href="/">\
		<img src="/images/bandageman-transparent.png" alt="Bandageman Studios" style="max-width: 50px; height: auto;">\
	</a>\
</div>\
' "{{FILE}}"
  fi
