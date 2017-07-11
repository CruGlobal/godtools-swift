fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>

# Available Actions
## iOS
### ios run_tests
```
fastlane ios run_tests
```
Runs all the tests

can take skip_install_dependencies and setup_fastfile_path to improve speed if you have the setup Fastfile already checked out.

e.g. `bundle exec fastlane run_tests skip_install_dependencies:true setup_fastfile_path:/path/to/common/Fastfile --env test`

(Note: the Fastfile path must be relative to this project's main Fastfile)
### ios beta
```
fastlane ios beta
```
Creates a beta build

can take skip_tests, skip_install_dependencies and setup_fastfile_path to improve speed if you have the setup Fastfile already checked out.

e.g. `bundle exec fastlane beta skip_tests:true skip_install_dependencies:true setup_fastfile_path:/path/to/common/Fastfile --env beta`

(Note: the Fastfile path must be relative to this project's main Fastfile)
### ios production
```
fastlane ios production
```
Deploy a new version to the App Store

can take skip_tests, skip_install_dependencies and setup_fastfile_path to improve speed if you have the setup Fastfile already checked out.

e.g. `bundle exec fastlane production skip_tests:true skip_install_dependencies:true setup_fastfile_path:/path/to/common/Fastfile --env production`

(path must be relative to this project's main Fastfile)

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
