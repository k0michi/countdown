# Countdown

A tiny macOS menu bar app that shows how many days are left until a date you choose.

- Shows e.g. `Trip: 12 days` in the menu bar (`Today` on the day, `3 days ago` after)
- Click it to set the target date, an optional title, and whether the title is shown
- Settings persist across restarts; optional **Launch at login**

Requires macOS 14 or later.

## Install

Download `Countdown-x.y.z.zip` from [Releases](../../releases), unzip it, and move `Countdown.app` to `/Applications`.

The app is not notarized, so macOS blocks it the first time. To allow it:

1. Open `Countdown.app` once and dismiss the warning.
2. Go to **System Settings → Privacy & Security**, scroll down and click **Open Anyway** next to the Countdown message, then confirm.

Or remove the quarantine flag from Terminal:

```sh
xattr -dr com.apple.quarantine /Applications/Countdown.app
```

## Build

```sh
./build-app.sh   # builds build/Countdown.app
swift test       # run tests
```

The version is taken from `git describe`: `1.2.3` when built on an `x.y.z` tag, otherwise something like `1.2.3-4-gabc1234` or `abc1234-dirty`. It is shown at the bottom of the app's panel.

## Release

Push a tag in `x.y.z` form. CI runs the tests, builds the app and publishes a GitHub release with the zipped app.

```sh
git tag 1.0.0
git push origin 1.0.0
```

## License

[MIT](LICENSE)
