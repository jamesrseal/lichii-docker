# Lichii (Switch / Switch 2 emulator) added to Steam Headless v2, which provides the
# GPU-accelerated KDE desktop and the Sunshine streaming server (Fedora, glibc >= 2.39).
ARG BASE_IMAGE=josh5/steam-headless:2
FROM ${BASE_IMAGE}

# Set by the GitHub Actions workflow from the upstream release.
ARG LICHII_TAG
ARG LICHII_URL

COPY overlay /

RUN set -eux \
    && test -n "${LICHII_TAG}" && test -n "${LICHII_URL}" \
    && chmod 0755 /usr/bin/lichii /usr/bin/lichii-stop /usr/local/sh-init.d/80-lichii.sh \
    # No FUSE at build time, so unpack the AppImage instead of mounting it.
    && cd /tmp \
    && curl -fL --retry 3 -o lichii.AppImage "${LICHII_URL}" \
    && chmod +x lichii.AppImage \
    && ./lichii.AppImage --appimage-extract >/dev/null \
    && rm -rf /opt/lichii lichii.AppImage \
    && mv squashfs-root /opt/lichii \
    && chmod -R a+rX /opt/lichii \
    && test -x /opt/lichii/AppRun \
    && echo "${LICHII_TAG}" > /opt/lichii/VERSION \
    # Icon for the desktop menu and the Moonlight tile (Sunshine needs a PNG).
    && if [ -e /opt/lichii/.DirIcon ] && [ "$(head -c 4 /opt/lichii/.DirIcon | tail -c 3)" = "PNG" ]; then \
           cp -L /opt/lichii/.DirIcon /usr/share/pixmaps/lichii.png; \
           cp -L /opt/lichii/.DirIcon /usr/share/sunshine/lichii.png; \
       else \
           jq 'del(."image-path")' /usr/share/lichii/sunshine-app.json > /tmp/app.json \
           && cat /tmp/app.json > /usr/share/lichii/sunshine-app.json && rm -f /tmp/app.json; \
       fi \
    # Default Sunshine app list, used for homes that have no apps.json yet.
    && jq --slurpfile app /usr/share/lichii/sunshine-app.json '.apps += $app' /usr/share/sunshine/apps.json > /tmp/apps.json \
    && cat /tmp/apps.json > /usr/share/sunshine/apps.json && rm -f /tmp/apps.json \
    && jq -e '.apps | any(.name == "Lichii")' /usr/share/sunshine/apps.json \
    # Report (but do not fail on) libraries the bundled binaries cannot resolve.
    && (find /opt/lichii -maxdepth 3 -type f -perm -u+x -path '*/bin/*' -exec sh -c \
          'LD_LIBRARY_PATH=/opt/lichii/usr/lib:/opt/lichii/lib ldd "$1" 2>/dev/null | grep "not found" | sed "s|^|MISSING LIB for $1:|"' _ {} \; || true)

LABEL org.opencontainers.image.title="lichii-docker" \
      org.opencontainers.image.description="Lichii emulator on Steam Headless v2 (Sunshine/Moonlight streaming)" \
      lichii.version="${LICHII_TAG}"
