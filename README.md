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

1. Install **steam-headless** from Community Apps (needs the Nvidia-Driver plugin).
2. In the template, change **Repository** to `ghcr.io/jamesrseal/lichii-docker:latest`.
3. Advanced View → Extra Parameters must include `--runtime=nvidia`. Network type: `host`.
4. Set `ENABLE_SUNSHINE=true`, and `SUNSHINE_USER` / `SUNSHINE_PASS` to your own values.
   Set `ENABLE_STEAM=false` if you don't want Steam starting too.
5. Keep the `/home/default` mapping on appdata: Lichii's keys, firmware, saves and shader cache live there.
   Point `/mnt/games` at your game dumps.
6. Start it, open `https://<server-ip>:47990` to pair Moonlight with a PIN, then launch **Lichii** from
   Moonlight (or **Desktop** to set things up with a mouse first).

If the package is private, add a GitHub token with `read:packages` under Unraid's Docker registry login.
Updates arrive through Unraid's normal "update available" check.
