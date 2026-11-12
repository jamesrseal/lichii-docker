# Sourced by steam-headless-init (as root) on every container start.
# Adds a "Lichii" entry to an existing Sunshine app list in the persisted home so it
# shows up in Moonlight. New homes get it from /usr/share/sunshine/apps.json instead.
# Runs in a subshell with errors ignored so it can never block container startup.
(
    set +eu
    trap - ERR
    apps_file="/home/steamheadless/.config/sunshine/apps.json"
    app_file="/usr/share/lichii/sunshine-app.json"
    echo "steam-headless-init: Lichii $(cat /opt/lichii/VERSION 2>/dev/null || echo unknown) installed."
    [ -f "${apps_file}" ] || exit 0
    jq -e '.apps | any(.name == "Lichii")' "${apps_file}" >/dev/null 2>&1 && exit 0
    if jq --slurpfile app "${app_file}" '.apps += $app' "${apps_file}" > "${apps_file}.lichii-tmp" 2>/dev/null \
        && [ -s "${apps_file}.lichii-tmp" ]; then
        cat "${apps_file}.lichii-tmp" > "${apps_file}"   # keeps the file's owner and mode
        echo "steam-headless-init: Added Lichii to Sunshine's app list."
    else
        echo "steam-headless-init: WARNING: could not add Lichii to ${apps_file}."
    fi
    rm -f "${apps_file}.lichii-tmp"
) || true
