#!/usr/bin/env bash
set -euo pipefail
readonly version='9.6.1-dev'
readonly asset="kenny-launcher-${version}-ubuntu-x86_64.tar.xz"
readonly base='https://github.com/Tuxeodoman/kenny-launcher-ubuntu/releases/download/v9.6.1-dev-ubuntu'
readonly expected='ea5c0239042998a6a11f470ce319e53348c2f99b3be42f3a81ae31420658db67'
die() { printf '%s\n' "$*" >&2; exit 1; }
[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] || die 'Нужен Ubuntu x86_64 или совместимый дистрибутив.'
[[ $EUID -ne 0 ]] || die 'Запустите bash install.sh без sudo.'
[[ ! -f /etc/NIXOS ]] || die 'Для NixOS есть отдельный пакет: https://github.com/Tuxeodoman/kenny-launcher-nixos'
command -v apt-get >/dev/null || die 'Этот установщик рассчитан на Ubuntu и системы на её базе.'
glibc=$(getconf GNU_LIBC_VERSION | awk '{print $2}')
[[ $(printf '%s\n' 2.39 "$glibc" | sort -V | head -n 1) == 2.39 ]] || die 'Нужна Ubuntu 24.04 или новее (glibc 2.39+).'
[[ $# -le 1 ]] || die 'Использование: bash install.sh [путь-к-архиву.tar.xz]'

if [[ $# == 1 ]]; then
    archive=$(realpath -- "$1")
    [[ -f "$archive" ]] || die "Нет архива: $archive"
else
    command -v curl >/dev/null || die 'Сначала установите curl: sudo apt install curl'
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/kenny-launcher-ubuntu/$version"
    mkdir -p -- "$cache"
    archive="$cache/$asset"
    if [[ ! -f "$archive" ]]; then
        curl --fail --location --retry 4 --connect-timeout 30 --continue-at - \
            --output "$archive.partial" "$base/$asset"
        mv -- "$archive.partial" "$archive"
    fi
fi
actual=$(sha256sum -- "$archive")
[[ ${actual%% *} == "$expected" ]] || die "Контрольная сумма не совпала. Скачайте архив заново: $archive"

sudo apt-get update
sudo apt-get install -y --no-install-recommends xdg-utils xz-utils libstdc++6 libgcc-s1 libssl3t64 \
    libgl1 libegl1 libopengl0 libx11-6 libxext6 libxrandr2 libxcursor1 libxi6 \
    libxkbcommon-x11-0 libxcb-cursor0 libxcb-xinerama0 libfontconfig1 libfreetype6 \
    libdbus-1-3 libpulse0 libasound2t64 libopenal1 xwayland

root="$HOME/.local/opt/kenny-launcher-ubuntu"
mkdir -p -- "$root" "$HOME/.local/bin"
stage=$(mktemp -d "$root/.incoming-XXXXXX")
trap 'printf "При ошибке временная папка остаётся здесь: %s\n" "$stage" >&2' ERR
tar --extract --xz --file "$archive" --directory "$stage" --no-same-owner
[[ -x "$stage/KennyLauncher" && -f "$stage/.KennyLauncher.bin" ]] || die 'В архиве нет лаунчера.'
dest="$root/$version"
if [[ -e "$dest" ]]; then
    mv -- "$dest" "$root/$version.previous-$(date +%s)"
fi
mv -- "$stage" "$dest"
trap - ERR
ln -sfn -- "$dest/KennyLauncher" "$HOME/.local/bin/kenny-launcher-ubuntu"
applications="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p -- "$applications"
desktop_exec=${dest//\\/\\\\}
desktop_exec=${desktop_exec//\"/\\\"}
cat > "$applications/kenny-launcher-ubuntu.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Kenny Launcher Dev
Exec="$desktop_exec/KennyLauncher" %u
Terminal=false
Categories=Game;
MimeType=x-scheme-handler/kenny;
StartupWMClass=KennyLauncher
EOF
printf 'Готово. Откройте Kenny Launcher Dev в меню или выполните:\n%s\n' "$HOME/.local/bin/kenny-launcher-ubuntu"
