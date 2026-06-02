# Conduit

A minimal SSH client for Android and iOS. (no accounts or subscriptions)

Conduit stores connection profiles and trusted host keys in platform secure
storage, uses device authentication when available, and provides a tabbed
terminal workspace with on-screen modifier and function keys for mobile use.

## Build

This project targets Flutter 3.44.0.

```
flutter pub get
flutter build apk --split-per-abi
```

## Tests

```
flutter analyze
flutter test
```

## Third-party assets

The bundled terminal font is AtkynsonMono Nerd Font Mono from the
[Nerd Fonts v3.4.0 release](https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.4.0).
Its license is included in `assets/fonts/LICENSE-AtkynsonMono.txt`.
