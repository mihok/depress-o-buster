# Releasing: an installable Android build from your phone

Every push to `main` runs `.github/workflows/android-release.yml`, which analyzes, tests, builds a signed release
APK and publishes it as a GitHub Release. Nothing needs a laptop.

## Install or update on the phone

1. Open https://github.com/mihok/depress-o-buster/releases/latest/download/depress-o-buster.apk in the phone's
   browser. It always points at the newest build.
2. Open the downloaded file. The first time, Android asks to allow installs from the browser; allow it.
3. Tap Install. Updates install over the previous version and keep history, tasks and settings, because every
   build is signed with the same key and the build number always goes up.

## One-time setup: the signing key

Android only installs an update if it is signed with the same key as the installed app, so the key must be the
same forever. It lives in two repository secrets that the workflow reads:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_PASSWORD` | the keystore and key password |
| `ANDROID_KEYSTORE_BASE64` | the PKCS12 keystore (`release.jks`, alias `depressobuster`) as one base64 line |

Add them at https://github.com/mihok/depress-o-buster/settings/secrets/actions (this works from a phone's
browser). Until both exist the workflow still analyzes, tests and builds, but it signs with a throwaway debug
key and does not publish a release, and it says so in the run summary.

The first key was generated with:

```sh
keytool -genkeypair -v -keystore release.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 \
  -alias depressobuster -dname "CN=Depress-o-buster, O=mihok, C=US"
base64 -w0 release.jks > ANDROID_KEYSTORE_BASE64.txt
```

Keep `release.jks` and the password somewhere safe. If they are lost, a new key means the next build cannot
update the installed app: it would have to be uninstalled first, which deletes its local database.

## How the pieces fit

* `android/app/build.gradle.kts` reads `android/key.properties` when it exists (the workflow writes it from the
  secrets into the runner's temp directory) and otherwise signs release builds with the debug key, so local
  `flutter build apk --release` keeps working. `key.properties` and `*.jks` are ignored by git.
* The build number is the workflow run number (`--build-number=${{ github.run_number }}`), so every published
  APK has a higher `versionCode` than the last. The version name comes from `pubspec.yaml`.
* The release is tagged `build-<run number>` and carries two files: `depress-o-buster.apk` (stable name, what the
  "latest" link serves) and `depress-o-buster-v<version>-build<n>.apk`.
* The signer is checked with `apksigner` before publishing.
* `.github/workflows/ci.yml` runs analyze, test and a debug build for pull requests and other branches.

## If a run fails before any step starts

A run that ends after a few seconds with no logs did not get a runner. The reason is in the job's annotation
(open the run on https://github.com/mihok/depress-o-buster/actions). The one seen on the first run was:

> The job was not started because your account is locked due to a billing issue.

That is GitHub's account billing, nothing in this repository: fix it at https://github.com/settings/billing
(public repositories do not consume paid minutes, but a billing lock still blocks hosted runners), then open the
failed run and tap "Re-run all jobs", or push again.

The runner image is pinned to `ubuntu-24.04` rather than `ubuntu-latest` so the preinstalled Android SDK and
Java do not change under the build when GitHub moves the `latest` label to a new Ubuntu.

## Rolling the key

Only if the key leaks. Generate a new keystore as above, replace both secrets, and tell everyone who has the app
installed that the next update needs an uninstall first. There is no way to avoid that on Android.
