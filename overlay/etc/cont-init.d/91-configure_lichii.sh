# Sourced by the Steam Headless entrypoint on every container start.
print_header "Configure Lichii"
print_step_header "Lichii version: $(cat /opt/lichii/VERSION 2>/dev/null || echo unknown)"

# Add a "Lichii" entry to Sunshine's app list so it shows up in Moonlight.
# Fresh homes get it from the template; existing homes get it merged in once.
__lichii_app=/templates/lichii/sunshine-app.json
__add_lichii_app() {
    local apps_file="$1"
    [ -f "${apps_file}" ] || return 0
    if jq -e '.apps | any(.name == "Lichii")' "${apps_file}" >/dev/null 2>&1; then
        return 0
    fi
    if jq --slurpfile app "${__lichii_app}" '.apps += $app' "${apps_file}" > "${apps_file}.lichii-tmp"; then
        cat "${apps_file}.lichii-tmp" > "${apps_file}"   # keep the file's owner and mode
        print_step_header "Added Lichii to ${apps_file}"
    else
        print_warning "Could not add Lichii to ${apps_file}"
    fi
    rm -f "${apps_file}.lichii-tmp"
}
__add_lichii_app /templates/sunshine/apps.json
__add_lichii_app "${USER_HOME:?}/.config/sunshine/apps.json"

echo -e "\e[34mDONE\e[0m"
