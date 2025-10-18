#!/usr/bin/env bash
set -euo pipefail

FILE_PATH="$1"
GAME_SLUG="$2"

if ! grep -q 'og:title' "$FILE_PATH"; then
  GAME_TITLE=$(echo "$GAME_SLUG" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

  if ! grep -q 'charset' "$FILE_PATH"; then
    sed -i '' "/<head>/a\\
  <meta charset=\"UTF-8\">
" "$FILE_PATH"
  fi

  printf '\n  <!-- SEO Meta Tags -->\n' > /tmp/metadata.tmp
  printf '  <meta name="description" content="Play %s, a PICO-8 game by Bandageman Studios">\n' "$GAME_TITLE" >> /tmp/metadata.tmp
  printf '  <meta name="keywords" content="%s, PICO-8, indie game, retro game, bandageman studios">\n' "$GAME_TITLE" >> /tmp/metadata.tmp
  printf '  <meta name="author" content="Bandageman Studios">\n\n' >> /tmp/metadata.tmp
  printf '  <!-- Open Graph / Facebook -->\n' >> /tmp/metadata.tmp
  printf '  <meta property="og:type" content="website">\n' >> /tmp/metadata.tmp
  printf '  <meta property="og:url" content="https://bandageman.com/%s/">\n' "$GAME_SLUG" >> /tmp/metadata.tmp
  printf '  <meta property="og:title" content="%s - Bandageman Studios">\n' "$GAME_TITLE" >> /tmp/metadata.tmp
  printf '  <meta property="og:description" content="Play %s, a PICO-8 game by Bandageman Studios">\n' "$GAME_TITLE" >> /tmp/metadata.tmp
  printf '  <meta property="og:image" content="https://bandageman.com/%s/%s-splash.png">\n\n' "$GAME_SLUG" "$GAME_SLUG" >> /tmp/metadata.tmp
  printf '  <!-- Twitter -->\n' >> /tmp/metadata.tmp
  printf '  <meta name="twitter:card" content="summary_large_image">\n' >> /tmp/metadata.tmp
  printf '  <meta name="twitter:url" content="https://bandageman.com/%s/">\n' "$GAME_SLUG" >> /tmp/metadata.tmp
  printf '  <meta name="twitter:title" content="%s - Bandageman Studios">\n' "$GAME_TITLE" >> /tmp/metadata.tmp
  printf '  <meta name="twitter:description" content="Play %s, a PICO-8 game by Bandageman Studios">\n' "$GAME_TITLE" >> /tmp/metadata.tmp
  printf '  <meta name="twitter:image" content="https://bandageman.com/%s/%s-splash.png">\n\n' "$GAME_SLUG" "$GAME_SLUG" >> /tmp/metadata.tmp
  printf '  <!-- Theme Color -->\n' >> /tmp/metadata.tmp
  printf '  <meta name="theme-color" content="#222222">\n\n' >> /tmp/metadata.tmp
  printf '  <!-- Canonical URL -->\n' >> /tmp/metadata.tmp
  printf '  <link rel="canonical" href="https://bandageman.com/%s/">\n' "$GAME_SLUG" >> /tmp/metadata.tmp

  sed -i '' "/<meta name=\"viewport\"/r /tmp/metadata.tmp" "$FILE_PATH"
  rm /tmp/metadata.tmp
  sed -i '' 's|<title>.*</title>|<title>'"$GAME_TITLE"' - Bandageman Studios</title>|' "$FILE_PATH"
fi
