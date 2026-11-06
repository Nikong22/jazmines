#!/usr/bin/env bash
# Sube los dos regalos a GitHub Pages. La primera vez crea el repo;
# despues de eso, cada corrida publica los cambios.   bash subir.sh
set -euo pipefail
cd "$(dirname "$0")"

REPO="jazmines"
USUARIO="Nikong22"

bash armar-web.sh

if [ ! -d .git ]; then
  git init -b main
  git config user.name "$USUARIO"
  git config user.email "nico.alejandrousa@gmail.com"
  printf "scratch/\n*.tmp\n" > .gitignore
fi

git add -A
if git diff --cached --quiet; then
  echo "nada nuevo para subir."
else
  git commit -q -F - <<'MSG'
Album y veinticuatro puertas

Dos paginas de regalo en paleta pastel (celeste, amarillo, verde, violeta)
con jazmines y flores amarillas. docs/ tiene las versiones autonomas que
sirve GitHub Pages.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
MSG
  echo "commit hecho."
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  gh repo create "$REPO" --public --source=. --remote=origin --push
else
  git push -u origin main
fi

# Pages sirviendo desde main:/docs
if ! gh api "repos/$USUARIO/$REPO/pages" >/dev/null 2>&1; then
  printf '{"source":{"branch":"main","path":"/docs"}}' > .pages.json
  gh api --method POST "repos/$USUARIO/$REPO/pages" --input .pages.json
  rm -f .pages.json
  echo "Pages activado. Tarda entre 1 y 10 minutos en responder la primera vez."
fi

echo
echo "album:   https://$USUARIO.github.io/$REPO/"
echo "puertas: https://$USUARIO.github.io/$REPO/puertas.html"
