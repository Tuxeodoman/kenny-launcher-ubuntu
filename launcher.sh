#!/bin/sh
set -eu
root=$(dirname -- "$(readlink -f -- "$0")")
export KENNY_EXTERNAL_UPDATES=1
export KENNY_JAVA_PATHS="$root/java/8/bin/java:$root/java/17/bin/java:$root/java/21/bin/java:$root/java/25/bin/java"
export QT_PLUGIN_PATH="$root/plugins"
export QML_IMPORT_PATH="$root/qml"
export QML2_IMPORT_PATH="$root/qml"
export LD_LIBRARY_PATH="$root/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# The previous Linux distribution used the dev profile. Continue using it only
# when no stable profile exists; never copy, move or overwrite user data here.
# Respect explicit profiles and Qt's rule that XDG_DATA_HOME must be absolute.
if [ -z "${KENNY_LAUNCHER_DATA_DIR:-}" ]; then
    case "${XDG_DATA_HOME:-}" in
        /*) data_home=$XDG_DATA_HOME ;;
        *) data_home="$HOME/.local/share" ;;
    esac
    stable_profile="${data_home%/}/Kenny/KennyLauncher"
    legacy_profile="${data_home%/}/Kenny/KennyLauncherDev"
    if [ ! -e "$stable_profile" ] && [ ! -L "$stable_profile" ]; then
        # Match Paths::root()'s compatibility layout for older installations.
        if [ -f "$legacy_profile/KennyLauncher/settings.json" ]; then
            legacy_profile="$legacy_profile/KennyLauncher"
        fi
        if [ -f "$legacy_profile/settings.json" ] ||
           [ -f "$legacy_profile/session.json" ] ||
           [ -f "$legacy_profile/mc_accounts.json" ]; then
            export KENNY_LAUNCHER_DATA_DIR="$legacy_profile"
        fi
    fi
fi

exec "$root/.KennyLauncher.bin" "$@"
