# lichii-docker

[Lichii](https://github.com/zortos293/Lichii) (experimental Switch / Switch 2 emulator) packaged on top of
[Steam Headless](https://github.com/Steam-Headless/docker-steam-headless), which supplies the GPU-accelerated
KDE desktop and the Sunshine server you connect to with Moonlight.

Image: `ghcr.io/jamesrseal/lichii-docker:latest` (also tagged per upstream build for rollback).

## How the image gets built

`.github/workflows/build.yml` runs:

- **daily** – looks up the newest Lichii release and builds only if that version has no image yet
- **manually** – Actions tab → *Build Lichii image* → *Run workflow* (optional tag / force rebuild)
- **on push** – whenever the Dockerfile or `overlay/` changes

To use the PGO build, add a repository variable `LICHII_ASSET` = `lichii-linux-x86_64-pgo.AppImage`.

GitHub pauses scheduled workflows after 60 days with no repository activity; it emails you first, and one
click re-enables them.

## Running on Unraid

The image is `josh5/steam-headless:2` with Lichii added, so it is a drop-in replacement for an existing
Steam Headless v2 container.

### One-time host setup (NVIDIA)

These are host requirements of Steam Headless v2, not of Lichii, but without them games fail to boot.

1. **NVIDIA runtime.** Install the Nvidia-Driver plugin. In the container's Advanced View, **Extra Parameters**
   must include `--runtime=nvidia`. Without it the web UI (`steam-headless-shui`) crash-loops with
   `no element "nvh264enc"`.
2. **`/dev/nvidia-modeset`.** Unraid does not create this device on a server with no monitor attached. Without it
   the desktop falls back to software rendering (Steam reports `llvmpipe`) and Lichii fails with
   `Vulkan initialization failed with error: VK_ERROR_UNKNOWN`. The container's startup log warns about it:
   `docker logs steam-headless 2>&1 | grep nvidia-modeset`.
   - Create it: `nvidia-modprobe -c 0 -m`
   - Pass it to the container: add `--device=/dev/nvidia-modeset` to **Extra Parameters**, so the field reads
     `--runtime=nvidia --device=/dev/nvidia-modeset`.
   - Recreate it on every boot: in the **User Scripts** plugin, add a script (e.g. `nvidia-modeset`) containing
     `nvidia-modprobe -c 0 -m` and schedule it **At Startup of Array**. If the container ever refuses to start
     with an error about `nvidia-modeset`, run the script and start the container again.

### Switching the container to this image

1. Make the `lichii-docker` package public on GitHub, or log Unraid's Docker in to `ghcr.io`:
   `docker login ghcr.io -u jamesrseal` with a **classic** personal access token that has `read:packages`
   (a token with no scopes logs in fine but every pull is `denied`).
2. Edit the steam-headless container and change **Repository** from `josh5/steam-headless:2` to
   `ghcr.io/jamesrseal/lichii-docker:latest`, then click Apply. If the pull fails, Unraid may remove the
   container; re-add it from **Add Container** → Template → `steam-headless` (your settings are kept).
3. In the Steam Headless web desktop (`https://<server-ip>:8483/`), open **Lichii** from the application menu
   for first-time setup: keys, firmware, game folder, controller mapping. Its data (saves, shader cache, keys,
   firmware) lives in the User Profile path under `.local/share/lichii`.
4. In Moonlight, launch **Lichii**. Quitting the app from Moonlight closes the emulator.

### Game files

Mount game files from a single disk, not from `/mnt/user` (the Steam Headless template warns against FUSE paths).
Current setup: an Unassigned Devices drive, added to the container as an extra path.

| Setting        | Value                    |
|----------------|--------------------------|
| Container Path | `/mnt/switch`            |
| Host Path      | `/mnt/disks/disc/Switch` |
| Access Mode    | Read/Write - Slave       |

Add `/mnt/switch` as the game directory in Lichii. Network share: `\\TOWER\disc\Switch`.

### Updates

New Lichii builds show up as a normal "update available" on Unraid's Docker tab. Shader caches may partly
rebuild after an update.
