# God Tools

# Note to developers:

The develop branch should be treated as unstable. Two libraries (RealmSwift and SWXMLHash) were updated to newer minor release versions in support of XCode 9 and Swift 4(?). One of these libraries has a bug, or is being used improperly, and the result is that many key user interactions are extremely laggy.

The branch `develop-xcode8` is the branch that has been most recently release as app v5.0.6 . This version has the latest Adobe Analytics code running in a background queue for optimal performance. `develop` also has the commits to do Adobe in the background, but also has the broken libraries.

Any additional hot-fixes should be done off `develop-xcode8` and built with a machine running XCode 8. Developers should research and fix the broken or poorly used library in the main develop branch prior to another full engagement on the project. Direct any questions to @ryancarlson


