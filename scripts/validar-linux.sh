#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/nutribox-api"
INFRA_DIR="$ROOT_DIR/infra-jenkins"

ok() { printf '  [OK] %s\n' "$1"; }
fail() { printf '  [ERROR] %s\n' "$1" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "Falta el comando: $1"; }

printf '\n1/5 Entorno Linux y herramientas\n'
[[ "$(uname -s)" == "Linux" ]] || fail 'Este script debe ejecutarse en Linux'
need docker
need node
need npm
need git
docker info >/dev/null 2>&1 || fail 'Docker Engine no está disponible para el usuario actual'
docker compose version >/dev/null 2>&1 || fail 'Docker Compose v2 no está disponible'
ok "Linux, Docker, Compose, Node, npm y Git disponibles"

printf '\n2/5 Estructura del proyecto\n'
for file in package.json package-lock.json Jenkinsfile Dockerfile eslint.config.mjs; do
  [[ -f "$APP_DIR/$file" ]] || fail "Falta nutribox-api/$file"
done
[[ -f "$INFRA_DIR/docker-compose.yml" ]] || fail 'Falta infra-jenkins/docker-compose.yml'
[[ -f "$INFRA_DIR/jenkins/Dockerfile" ]] || fail 'Falta la imagen personalizada de Jenkins'
ok 'Archivos obligatorios presentes'

printf '\n3/5 Dependencias, pruebas y cobertura\n'
cd "$APP_DIR"
npm ci --no-audit --no-fund
npm run test:ci
ok 'Pruebas y umbral de cobertura aprobados'

printf '\n4/5 Controles de seguridad\n'
npm run lint
npm run audit:gate
ok 'SAST y SCA aprobados'

printf '\n5/5 Configuración Docker Compose\n'
cd "$INFRA_DIR"
docker compose config --quiet
docker compose --profile sonar config --quiet
ok 'Compose base y perfil SonarQube válidos'

printf '\nVALIDACIÓN COMPLETA: OK\n'

