# God Tools
[![Coverage Status](https://coveralls.io/repos/github/CruGlobal/godtools-swift/badge.svg?branch=develop)](https://coveralls.io/github/CruGlobal/godtools-swift?branch=develop)

## Building the project
### Normally
A build server is setup for this project. The build server does the following:

 * Anytime you create a Pull Request the tests will automatically run and be reported on your PR.
 * Anytime you merge a Pull Request into the develop branch beta builds will be delivered to Crashlytics (for your testers) and TestFlight (for your early access users). It will rerun the tests, commit a build number bump and tag the build for you.
 * Anytime you merge a Pull Request into master to will rerun the tests, generate your screenshots, build the app for release, upload all the data in the `fastlane/metadata` folder and upload the build. It does not automatically submit the app for review. You will need to go to iTunes Connect to submit it.

**Note: If you need to change this behavior talk to one of the project admins about updating the Fastlane scripts**

### Locally
Setup:
 * Run `cp fastlane/.env.local.sample fastlane/.env.local`
 * Read the comments in `fastlane/.env.local` and fill out the missing values for your environment.
 * Run `bundle install`. Needs to be rerun after Gemfile changes.

Run Tests:
`bundle exec fastlane run_tests --env local`

Run Beta Distribution:
`bundle exec fastlane beta --env local`

Run AppStore Distribution:
`bundle exec fastlane production --env local`

**Note: If you run these scripts locally on a regular basis read `fastlane/README.md` for tips on how to speed these scripts up.**

