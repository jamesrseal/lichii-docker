# lichii-docker

[Lichii](https://github.com/zortos293/Lichii) (experimental Switch / Switch 2 emulator) packaged on top of
[Steam Headless](https://github.com/Steam-Headless/docker-steam-headless), which supplies the GPU-accelerated
desktop and the Sunshine server you connect to with Moonlight.

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

The image is based on Steam Headless **v1** (`josh5/steam-headless:debian`). The steam-headless template in
Community Apps now targets v2, which is laid out differently, so use `docker-compose.yml` from this repo instead.

1. Install the **Nvidia-Driver** and **Docker Compose Manager** plugins.
2. Add a new stack, paste in `docker-compose.yml`, and edit:
   - the two `appdata` paths and the games path
   - `SUNSHINE_USER` / `SUNSHINE_PASS` / `USER_PASSWORD`
3. Compose up. The browser desktop is at `http://<server-ip>:8083` for first-time setup (keys, firmware,
   game folder `/mnt/games`, controller mapping).
4. Open `https://<server-ip>:47990` to pair Moonlight with a PIN, then launch **Lichii** from Moonlight.

The container uses host networking; keep it LAN/VPN-only.

If the package is private, log Unraid's Docker in to `ghcr.io` with a GitHub token that has `read:packages`.
To update, pull and recreate the stack (Compose Manager's *Update Stack*).
