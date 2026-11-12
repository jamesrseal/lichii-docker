# Lichii (Switch / Switch 2 emulator) on top of Steam Headless, which provides
# the NVIDIA-accelerated Xorg desktop and the Sunshine streaming server.
# Debian 13 base => glibc 2.41, which satisfies the AppImage's glibc >= 2.39.
ARG BASE_IMAGE=josh5/steam-headless:latest
FROM ${BASE_IMAGE}

# Set by the GitHub Actions workflow from the upstream release.
ARG LICHII_TAG
ARG LICHII_URL

RUN set -eux \
    && test -n "${LICHII_TAG}" && test -n "${LICHII_URL}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl jq libxcb-cursor0 libvulkan1 \
    && rm -rf /var/lib/apt/lists/* \
    # Containers have no FUSE at build time, so unpack the AppImage instead of mounting it.
    && cd /tmp \
    && curl -fL --retry 3 -o lichii.AppImage "${LICHII_URL}" \
    && chmod +x lichii.AppImage \
    && ./lichii.AppImage --appimage-extract >/dev/null \
    && rm -rf /opt/lichii \
    && mv squashfs-root /opt/lichii \
    && chmod -R a+rX /opt/lichii \
    && test -x /opt/lichii/AppRun \
    && echo "${LICHII_TAG}" > /opt/lichii/VERSION \
    && if [ -e /opt/lichii/.DirIcon ]; then cp -L /opt/lichii/.DirIcon /usr/share/pixmaps/lichii.png; fi \
    && rm -f /tmp/lichii.AppImage

COPY overlay /
RUN chmod +x /usr/bin/lichii /etc/cont-init.d/91-configure_lichii.sh

LABEL org.opencontainers.image.title="lichii-docker" \
      org.opencontainers.image.description="Lichii emulator on Steam Headless (Sunshine/Moonlight streaming)" \
      lichii.version="${LICHII_TAG}"
