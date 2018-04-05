fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios release
```
fastlane ios release
```
Push a new release build to the App Store
### ios beta
```
fastlane ios beta
```
Push a new (beta) release build to Crashlytics
### ios cru_increment_build_number
```
fastlane ios cru_increment_build_number
```

### ios cru_build_app
```
fastlane ios cru_build_app
```

### ios cru_fetch_certs
```
fastlane ios cru_fetch_certs
```

### ios cru_update_commit
```
fastlane ios cru_update_commit
```

### ios cru_notify_users
```
fastlane ios cru_notify_users
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
