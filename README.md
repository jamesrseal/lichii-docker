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

1. Make the `lichii-docker` package public on GitHub (or log Unraid's Docker in to `ghcr.io` with a token
   that has `read:packages`).
2. Edit the steam-headless container and change **Repository** from `josh5/steam-headless:2` to
   `ghcr.io/jamesrseal/lichii-docker:latest`. Leave everything else as it is and click Apply.
3. In the Steam Headless web desktop, open **Lichii** from the application menu for first-time setup
   (keys, firmware, game folder under `/mnt/games`, controller mapping). Its data lives in the User Profile path.
4. In Moonlight, launch **Lichii**. Quitting the app from Moonlight closes the emulator.

New Lichii builds show up as a normal "update available" on Unraid's Docker tab.
