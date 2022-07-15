GodTools
========

- [Requirements](#requirements)
- [Programming Guide](#programming-guide)

### Requirements

- Xcode 13.4.1
- Bundler
- Cocoapods
- Fastlane

### Programming Guide

- [Architecture](#architecture)

#### Architecture

- [Presentation Layer](#presentation-layer)
- [Domain Layer](#domain-layer)
- [Data Layer](#data-layer)
- [Coordinator](#coordinator)

#### Presentation Layer

The presentation layer makes up the Views and ViewModels.  In the GodTools app Views and ViewModels are organized by Feature in the Features folder.  Below will explain how presentation files are named and organized and conventions for Views and ViewModels.

- [File Naming and Organization](#file-naming-and-organization)
- [Views](#views)
- [ViewModels](#viewmodels)

##### File Naming and Organization

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

##### Views

Views are what a user visually sees and interacts with.

Responsibilities:
- Rendering logic.
- Animation logic.
- Owns a ViewModel.
- Observes ViewModel output.  In SwiftUI this is a combination of @ObservedObject and @Published properties.
- Send inputs to the ViewModel (button tap, entering text input, etc.).

File Naming and Organization:
- All newly created views should be created in SwiftUI.
- Views should have only 1 ViewModel.
- Subviews that are static and help make up a screen (View) can point to the parent screen (View) ViewModel or they can have their own ViewModel.
- Subviews that are dynamic such as views in collections (lists, stacks, etc.) should have there own ViewModel and only 1 ViewModel.

##### ViewModels

ViewModels are considered a view representation.  They're the data backing of a view.

Responsibilities:
- Provides data outputs to the View which the View can observe and react to.
- Each data output connects to a UseCase (Domain Layer) which computes data.  Computing can also happen directly in the ViewModel although UseCases are preferred.

#### Domain Layer

The domain layer is responsible for the business rules of the application and is broken up into Use Cases.  The benefits of the domain layer include:
- It avoids code duplication.
- It improves readability in ViewModels that use domain layer use cases.
- It improves testability of the app.
- It avoids large ViewModels by allowing you to split responsibilities.


##### Use Cases

Use cases make up the domain layer.  Use cases should be responsible for a single task and named to reflect that task.  For example: AuthenticateUserUseCase, GetSpotlightToolsUseCase.

Responsibilities:

- Operates on the data layer classes and other use cases to perform a single task and applies the business rules.

File Naming and Organization:
- Use cases should be stored in Share/Domain/UseCases folder.
- Each UseCase should have it's own folder named the same as the use case.  
- If a UseCase provides a domain model, that model should be included in the same folder as the use case and suffixed with DomainModel.  For example, if the GetAllToolsUseCase were to provide tools, the domain model could be ToolDomainModel.


#### Data Layer
- TODO

#### Coordinator
- TODO


