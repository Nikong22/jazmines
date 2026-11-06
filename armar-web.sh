#!/usr/bin/env bash
# Genera las versiones autonomas (con <html>, <head> y todo) en docs/,
# que son las que sirve GitHub Pages y las que se pueden abrir con doble clic.
# Correlo cada vez que cambies album.html o puertas.html:   bash armar-web.sh
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p docs

envolver() {
  local src="$1" dest="$2"
  local titulo
  titulo=$(grep -o -m1 "<title>[^<]*</title>" "$src" || echo "<title>Jazmines</title>")
  {
    echo "<!doctype html>"
    echo "<html lang=\"es\">"
    echo "<head>"
    echo "<meta charset=\"utf-8\">"
    echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, viewport-fit=cover\">"
    echo "<meta name=\"robots\" content=\"noindex, nofollow, noarchive\">"
    echo "$titulo"
    echo "<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0;font:14px system-ui,-apple-system,sans-serif}img{max-width:100%}[hidden]{display:none!important}</style>"
    echo "</head>"
    echo "<body>"
    sed "0,/<title>/{/<title>/d;}" "$src"
    echo "</body>"
    echo "</html>"
  } > "$dest"
  echo "  $dest"
}

echo "armando:"
envolver album.html   docs/index.html
envolver puertas.html docs/puertas.html

# que ningun buscador la indexe
printf "User-agent: *\nDisallow: /\n" > docs/robots.txt
# GitHub Pages no toca las carpetas que empiezan con _
: > docs/.nojekyll

# si hay carpeta de fotos, va tal cual
if [ -d fotos ]; then
  rm -rf docs/fotos
  cp -r fotos docs/fotos
  # los LEEME son para vos, no para la web
  find docs/fotos -name "LEEME.txt" -delete
  echo "  docs/fotos/ (copiada)"
fi

echo "listo."
