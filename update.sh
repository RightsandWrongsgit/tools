#!/usr/bin/env bash

VERSION=2020-11-14-18-14
DEBUG=0
GITHUB=https://raw.githubusercontent.com
REPOSITORY=druidfi/tools
BRANCH=master
TARGET=tools/make
PROJECT_MAKEFILE=Makefile.project.dist
REPOSITORY_URL=https://github.com/druidfi/tools

while true; do
  case "$1" in
    -d | --debug ) DEBUG=1; shift ;;
    -b | --branch ) BRANCH="$2"; shift ;;
    * ) break ;;
  esac
done

RED="[0;31m"
GREEN="[0;32m"
YELLOW="[0;33m"
NORMAL="[0m"
CYAN="[0;36m"

declare -a files=(
  "Makefile"
  "utils.mk"
  "include.mk"
  "common.mk"
  "docker.mk"
  "composer.mk"
  "javascript.mk"
  "drupal.mk"
  "symfony.mk"
  "amazeeio.mk"
  "qa.mk"
  "wordpress.mk"
)

main() {
  if [[ ${DEBUG} -eq 1 ]]; then
    mkdir -p debug
    cd debug || exit
  fi

  printf "\n\e%s%s updater (version %s)\e%s\n\n" "${YELLOW}" "${REPOSITORY}" "${VERSION}" "${NORMAL}"

  info "Download main Makefile..."

  if [[ ${DEBUG} -eq 1 ]]; then
    debug "curl -LJs -H 'Cache-Control: no-cache' -o Makefile ${GITHUB}/${REPOSITORY}/${BRANCH}/make/${PROJECT_MAKEFILE}"
  fi

  curl -LJs -H 'Cache-Control: no-cache' -o Makefile ${GITHUB}/${REPOSITORY}/${BRANCH}/make/${PROJECT_MAKEFILE}

  if [[ ! -d ${TARGET} ]]; then
    info "Folder ${TARGET} does not exist, creating it..."

    if [[ ${DEBUG} -eq 1 ]]; then
      debug "mkdir -p ${TARGET}"
    fi

    mkdir -p "${TARGET}"
  fi

  cd "${TARGET}" || exit

  info "Download following files from ${REPOSITORY_URL}:"
  printf '%s\n' "${files[@]}"

  for i in "${!files[@]}"
  do
     file=${files[i]}
     timestamp=$(date +%s)
     urls[${i}]="${GITHUB}/${REPOSITORY}/${BRANCH}/make/${file}?t=${timestamp}"
  done

  for i in "${!files[@]}"
  do
    if [[ ${DEBUG} -eq 1 ]]; then
      debug "curl -LJs -o ${files[i]} ${urls[i]}"
    fi

    curl -LJs -o "${files[i]}" "${urls[i]}"
  done

  if [[ $? -eq 0 ]]
  then
    printf "\n\e%s[OK]\e%s Update complete!\e%s\n" "${GREEN}" "${YELLOW}" "${NORMAL}"
    exit 0
  else
    printf "\n\e%s[ERROR]\e%s Check if update.sh has correct settings\n" "${RED}" "${NORMAL}"
    exit 1
  fi
}

info() {
  printf "\e%s[Info]\e%s %s\n" "${YELLOW}" "${NORMAL}" "${1}"
}

debug() {
  printf "\e%s[Debug]\e%s %s\n" "${CYAN}" "${NORMAL}" "${1}"
}

main
