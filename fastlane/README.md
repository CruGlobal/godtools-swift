fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios release

```sh
[bundle exec] fastlane ios release
```

Push a new release build to the App Store

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Push a new (beta) release build to TestFlight

### ios cru_download_localizations

```sh
[bundle exec] fastlane ios cru_download_localizations
```

Download latest localization files from Onesky

### ios cru_commit_localization_files

```sh
[bundle exec] fastlane ios cru_commit_localization_files
```

Commit downloaded localization files to default branch and push to remote

### ios cru_build_app

```sh
[bundle exec] fastlane ios cru_build_app
```



### ios cru_build_adhoc

```sh
[bundle exec] fastlane ios cru_build_adhoc
```



### ios cru_fetch_certs

```sh
[bundle exec] fastlane ios cru_fetch_certs
```



### ios cru_update_commit

```sh
[bundle exec] fastlane ios cru_update_commit
```



### ios cru_bump_version_number

```sh
[bundle exec] fastlane ios cru_bump_version_number
```



### ios cru_notify_users

```sh
[bundle exec] fastlane ios cru_notify_users
```



### ios cru_push_release_to_github

```sh
[bundle exec] fastlane ios cru_push_release_to_github
```



### ios cru_shared_lane_run_tests

```sh
[bundle exec] fastlane ios cru_shared_lane_run_tests
```



### ios cru_shared_lane_download_and_commit_latest_one_sky_localizations

```sh
[bundle exec] fastlane ios cru_shared_lane_download_and_commit_latest_one_sky_localizations
```



### ios cru_shared_lane_increment_xcode_project_build_number

```sh
[bundle exec] fastlane ios cru_shared_lane_increment_xcode_project_build_number
```



### ios cru_shared_lane_build_and_deploy_for_testflight_release

```sh
[bundle exec] fastlane ios cru_shared_lane_build_and_deploy_for_testflight_release
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
