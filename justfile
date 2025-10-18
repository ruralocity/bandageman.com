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
  #!/usr/bin/env bash
  set -euo pipefail
  # Check if metadata already exists
  if ! grep -q 'og:title' "{{FILE}}"; then
    # Convert game name to title (capitalize first letter of each word)
    GAME_TITLE=$(echo "{{GAME}}" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
    # Add charset if missing
    if ! grep -q 'charset' "{{FILE}}"; then
      sed -i '' '/<head>/a\
<meta charset="UTF-8">\
' "{{FILE}}"
    fi
    # Inject metadata after viewport tag
    sed -i '' '/<meta name="viewport"/a\
\
<!-- SEO Meta Tags -->\
<meta name="description" content="Play '"$GAME_TITLE"', a PICO-8 game by Bandageman Studios">\
<meta name="keywords" content="'"$GAME_TITLE"', PICO-8, indie game, retro game, bandageman studios">\
<meta name="author" content="Bandageman Studios">\
\
<!-- Open Graph / Facebook -->\
<meta property="og:type" content="website">\
<meta property="og:url" content="https://bandageman.com/{{GAME}}/">\
<meta property="og:title" content="'"$GAME_TITLE"' - Bandageman Studios">\
<meta property="og:description" content="Play '"$GAME_TITLE"', a PICO-8 game by Bandageman Studios">\
<meta property="og:image" content="https://bandageman.com/{{GAME}}/{{GAME}}.gif">\
\
<!-- Twitter -->\
<meta name="twitter:card" content="summary_large_image">\
<meta name="twitter:url" content="https://bandageman.com/{{GAME}}/">\
<meta name="twitter:title" content="'"$GAME_TITLE"' - Bandageman Studios">\
<meta name="twitter:description" content="Play '"$GAME_TITLE"', a PICO-8 game by Bandageman Studios">\
<meta name="twitter:image" content="https://bandageman.com/{{GAME}}/{{GAME}}.gif">\
\
<!-- Theme Color -->\
<meta name="theme-color" content="#222222">\
\
<!-- Canonical URL -->\
<link rel="canonical" href="https://bandageman.com/{{GAME}}/">\
' "{{FILE}}"
    # Also update the title tag
    sed -i '' 's|<title>.*</title>|<title>'"$GAME_TITLE"' - Bandageman Studios</title>|' "{{FILE}}"
  fi

# Internal: Inject footer into HTML file
_inject-footer FILE:
  #!/usr/bin/env bash
  set -euo pipefail
  # Check if footer already exists
  if ! grep -q 'bandageman-transparent.png' "{{FILE}}"; then
    # Find the line with </div> <!-- body_0 --> and inject footer before it
    sed -i '' '/<\/div> <!-- body_0 -->/i\
\
<style>\
.footer-logo-link:hover img {\
	animation: pop 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);\
}\
@keyframes pop {\
	0% { transform: scale(1); }\
	50% { transform: scale(1.2); }\
	100% { transform: scale(1); }\
}\
</style>\
\
<div style="text-align: center; margin-top: 40px; padding-bottom: 20px;">\
	<a href="/" class="footer-logo-link">\
		<img src="/images/bandageman-transparent.png" alt="Bandageman Studios" style="max-width: 50px; height: auto;">\
	</a>\
</div>\
' "{{FILE}}"
  fi
