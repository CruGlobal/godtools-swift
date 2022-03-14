GodTools
=======

Version 5.7.9

- [Requirements](#requirements)
- [Architectural Pattern](#architectural-pattern)

### Requirements

- Xcode 13
- iOS 11+
- Bundler
- Cocoapods
- Fastlane

### Architectural Pattern

MVVM-C

Model - The model layer operates on the data layer. Performs networking, json decoding, and other various data services. 

View - The view layer operates on the presentation layer and is very simple in form as it is a visual display.  It makes up the following responsibilities:
- Rendering.
- Animation logic.
- Observing viewModel output which triggers re-rendering of the view.
- Sending user inputs to the viewModel (button tap, entering text input, etc.).

ViewModel - The viewModel layer operates on the presentation layer and domain layer and is considered a view reprensentation.  It makes up the following responsibilities:
- Applying business rules to data.
- Sends output to the view (via observers) for view changes.
- Recieves input from the view (button tap, entering text input, etc.).
- Interacts with the data layer and various data services.

Coordinator - The Coorindator is a design pattern for handling navigation and dependency injection.  In GodTools this pattern makes up our Flow classes.  The Coordinator is the decision maker when it comes to navigation.  For example, say a user taps a button to login, the coordinater receives a step enumeration (step enumeration describes an action) and determines where to navigate based on that action.  Once navigation is determined, the coordinator will instantiate the view, viewModel, inject any dependencies, and then perform navigation.
