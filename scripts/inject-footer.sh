#!/usr/bin/env bash
set -euo pipefail

FILE_PATH="$1"

if ! grep -q 'bandageman-transparent.png' "$FILE_PATH"; then
  printf '\n<style>\n' > /tmp/footer.tmp
  printf '.footer-logo-link:hover img {\n' >> /tmp/footer.tmp
  printf '\tanimation: pop 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);\n' >> /tmp/footer.tmp
  printf '}\n' >> /tmp/footer.tmp
  printf '@keyframes pop {\n' >> /tmp/footer.tmp
  printf '\t0%% { transform: scale(1); }\n' >> /tmp/footer.tmp
  printf '\t50%% { transform: scale(1.2); }\n' >> /tmp/footer.tmp
  printf '\t100%% { transform: scale(1); }\n' >> /tmp/footer.tmp
  printf '}\n' >> /tmp/footer.tmp
  printf '</style>\n\n' >> /tmp/footer.tmp
  printf '<div style="text-align: center; margin-top: 40px; padding-bottom: 20px;">\n' >> /tmp/footer.tmp
  printf '\t<a href="/" class="footer-logo-link">\n' >> /tmp/footer.tmp
  printf '\t\t<img src="/images/bandageman-transparent.png" alt="Bandageman Studios" style="max-width: 50px; height: auto;">\n' >> /tmp/footer.tmp
  printf '\t</a>\n' >> /tmp/footer.tmp
  printf '</div>\n' >> /tmp/footer.tmp

  sed -i '' '/<\/div> <!-- body_0 -->/e cat /tmp/footer.tmp' "$FILE_PATH"
  rm /tmp/footer.tmp
fi
