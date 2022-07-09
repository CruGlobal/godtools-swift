GodTools
========

- [Requirements](#requirements)
- [Architectural Pattern](#architectural-pattern)
- [Programming Guide](#programming-guide)

### Requirements

- Xcode 13.3.1+
- Minimum iOS 13
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

### Programming Guide

##### Presentation Layer

The presentation layer makes up the Views and ViewModels.  In the GodTools app Views and ViewModels are organized by Feature in the Features folder.  Below will explain how presentation files are named and organized and conventions for Views and ViewModels.

- [File Naming and Organization](#file-naming-and-organization)
- [Views](#views)
- [ViewModels](#viewmodels)

###### File Naming and Organization

The presentation layer will make up Views and ViewModels and those are stored in the App/Features folder.  The Features folder attempts to group presentation files by feature type. For example:
Features/Lessons
Features/Onboarding
Features/ToolSettings

Where Lessons, Onboarding, and ToolSettings are app features and falling under each feature directory make up the screens (Views) pertaining to that feature.

Under each Feature folder should be the screens (Views) that make up that feature.  Each screen (View) should be placed in a directory name pertaining to that screen.  For example, the Lessons feature has the following screens (Views) associated with it. Lesson, LessonEvaluation, and LessonList.  There would then be a directory for each screen like so.

Feature/Lessons/Lesson
Feature/Lessons/LessonEvaluation
Feature/Lessons/LessonList

Under each screen (View) folder in a feature should be the View and associated ViewModel that make up that screen.  The Lesson screen (View) would then have LessonView and LessonViewModel.

Feature/Lessons/Lesson/LessonView.swift
Feature/Lessons/Lesson/LessonViewModel.swift

Any smaller view components that help in creating the screen (View) should go in a Subviews directory.  From the above example, if we built some smaller subview components that help make up the LessonView.swift, those would go in the following:

Feature/Lessons/Lesson/Subviews

If there are any views or subviews that are shared across screens (Views) or shared across Features.  Those should go in the following:
App/Share/SwiftUI Views

###### Views

- All newly created views should be created in SwiftUI.
- Views should have only 1 ViewModel.
- Subviews that are static and help make up a View can point to the same ViewModel.
- Subviews that are dynamic and help make up a View, such as views in collections (lists, stacks, etc.) should have an associated ViewModel and only 1 ViewModel.

###### ViewModels


##### Domain Layer
- TODO

##### Data Layer
- TODO

##### Coordinator
- TODO

