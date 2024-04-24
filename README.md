GodTools
========

- [Requirements](#requirements)
- [Architecture](#architecture)
- [Architecture Responsibilities](#architecture-responsibilities)
- [Fastlane](#fastlane)

### Requirements

- Xcode
- Bundler
- Cocoapods
- Fastlane

### Architecture

![alt text](ReadMeAssets/clean_architecture.png)

The GodTools app architecture consists of 3 layers (Presentation Layer, Domain Layer, and Data Layer), along with a Coordinator Pattern (Navigation decisions and logic).

#### Clean Architecture Pattern:
- Presentation Layer: (View and ViewModel)
- Domain Layer: (Use Cases, Domain Models, and Data Layer Interfaces)
- Data Layer: (Implements domain layer interfaces and consists of Repositories, Networking, Peristence, and other Data Connectivity)
- Data-DomainInterface: (In GodTools we have this additional layer which holds all the business logic.  These classes will implement the domain layer interfaces and operate on the raw data layer classes and apply business rules)

#### Purpose of this Architecture:
- Creates a clear separation of concerns and responsibilities.
- Each layer will have its own responsibilities and the components that make up a layer will have their own responsibilities.
- Enables changes to have isolated impact and allows for the system to be easily extended and maintained.
- Enables us to build a system in the same way that follows best practices without the need for micromanagement.

### Architecture Responsibilities

#### Presentation Layer

- Makes up the visual aspect of the app as well as user interaction (button tap, text input, etc.) 
- Uses the View / ViewModel pattern.
- Knows nothing of the data layer.  Only knows about the Domain Layer.

##### View Responsibilities
- Rendering logic (SwiftUI).
- Animation logic (SwiftUI).
- References a ViewModel using property wrapper @ObservedObject.
- Observes ViewModel output via @Published properties.
- Sends inputs to the ViewModel (button tap, text input, page viewed, etc.).  Purpose here is to drive data.

##### ViewModel Responsibilities
- Considered a View representation or data backing of the View. However, knows nothing of the specific UI elements that structure a View. 
- Defines the inputs, these are typically user initiated inputs.  The view makes calls to these inputs in order to drive the data.
- Communicates to the Domain Layer via UseCases which are injected upon initialization.  
- Provides output to the View via @Published properties to update View state by implementing Combine's ObservableObject protocol.

#### Domain Layer

- Makes up the business aspect of the app  by utilizing Use Cases, Domain Models, and Data Layer Interfaces.
- Use Cases define user related actions in the app.  Implementing Use Cases gives us a high level description of how the app behaves (Screaming Architecture).
- Domain Models will encapsulate business related attributes visually seen and used in the app.
- Interfaces define how UseCases interact with the DataLayer.  The purpose of the interface is to accomplish the dependency inversion principle. 

##### UseCase  Responsibilities
- Defines a business scenario in most cases on behalf of a specific user.  Naming should reflect some type of user action in the app.  This aids in Screaming Architecture.  An example in GodTools could be a user viewing a particular screen, or a user searching for an app language in the app languages list, or a user authenticating.
- Splits the responsibilities of the ViewModel into readable UseCases which reduces ViewModel complexity and also provides better app behaviour readability (Screaming Architecture).
- Should be responsible for a single task and named to reflect that task.
- Operates on the data layer utilizing dependency inversion.  This means UseCases should only point to interfaces. 
- Should define inputs needed to produce the output of the UseCase.  UseCases should typically produce a DomainModel output that encapsulates the business requirements.
- Once a UseCase is defined, it is then composed of 1 or more interfaces (dependency inversion principle) to complete the UseCase DomainModel.
- By using dependency inversion, concrete implementations can isolate the business rules keeping the data layer free from such responsibilities. 

##### Use Cases (Best Practices)

- Should have a single exposed method (public, internal) that takes zero or more inputs and produces a single output that is an AnyPublisher. 
- UseCases can have private methods, however, as we move to dependency inversion I think private methods will become less and less.
- Inputs should not be publisher types. Instead the ViewModel should react to changes which then triggers the UseCase.
- Should not reference or depend on other UseCases.  Should only depend on interfaces.  There may be situations where a UseCase_A requires some data from the result of UseCase_B in order to complete UseCase_A.  In these situations UseCase_A should have already defined the inputs it needs to complete UseCase_A and the ViewModel should reference both UseCase_A and UseCase_B and inject data from UseCase_B into UseCase_A.
- Should depend only on interfaces. Most of the time we depend on some type of Repository Interface where a Repository is simply a data storage and data access.
- Would prefer that UseCases return a non Swift type and instead some type of DomainModel that encapsulates attributes related to the business requirements.

##### Interfaces
- All use cases will be composed of 1 or more interfaces to accomplish dependency inversion.  In most situations these interfaces will be some type of repository interface for fetching data or an interface to perform some sort of service on the data layer.
- Interfaces should define any clear inputs to accomplish the intent and produce a single AnyPublisher output.  In most situations the AnyPublisher should produce a DomainModel.  

##### Domain Models
- These will model app specific data or business specific data.  This is typically data users will visually see and interact with.

#### Data-DomainInterface
- Consists of classes that implement the domain layer interfaces to achieve dependency inversion.  These classes operate on the raw data layer classes and these classes contain all the business formatting, logic, and rules.  The purpose is to isolate the business rules keeping the data layer free from such responsibilities.

#### Data Layer

- Responsible for data retrieval, data storage, and other data connectivity such as sending analytics, communicating to remote databases, web sockets, etc.
- Typical data storage can include a remote database, disk cache (CoreData, Realm, UserDefaults, NSFileManager), app bundle (.json, .txt, .png, .jpg, etc.), and even hardcoded data in a swift file.
- Should know nothing of the Presentation Layer and only knows of the Domain Layer via Domain Layer Interfaces.

##### Repositories

A large number of our classes in the DataLayer will be suffixed by Repository.  Think of a Repository as a simple container for storing data and accessing data.  How that data is stored and accessed is up to the Repository.

A Repository has the following responsibilities:

- Very simple in concept.  Provides data storage and data retrieval.
- Encapsulates data storage types (remote, disk, bundle, hardcoded).
- Should produce a single type suffixed by DataModel that underlying data (persistence, networking) maps to.

#### Coordinator
The coordinator is a pattern used for navigation decisions, navigation logic, and dependency injection.  In GodTools, any class that implements the Flow protocol is a class that implements the coordinator pattern.

- Makes decisions when it comes to navigation.  Actions are sent to the coordinator and it's up to the coordinator to decide where to navigate next based on the action.  The GodTools actions are defined in the FlowStep enum.
- Once navigation is determined, the coordinator will instantiate the view, viewModel, inject any dependencies, and then perform navigation. 

#### Additional Resources:
- Solid principles: 
    - https://www.geeksforgeeks.org/solid-principle-in-programming-understand-with-real-life-examples/
- Coordinator (Flow.swift): 
    - https://khanlou.com/2015/01/the-coordinator/
    - https://twittemb.github.io/posts/2017-11-08-RxFlow-Part1/
    - https://twittemb.github.io/posts/2017-12-09-RxFlow-Part2/

#### Fastlane

Below are some helpful references to GitHub Actions Workflows and Fastlane Files that the GodTools project uses.

- Project Fastlane Fastfile (https://github.com/CruGlobal/godtools-swift/blob/develop/fastlane/Fastfile) points to shared Fastfile (https://github.com/CruGlobal/cru-fastlane-files/blob/master/Fastfile)

- Uses a combination of Fastlane Environment Variables(https://github.com/CruGlobal/godtools-swift/blob/develop/fastlane/.env.default) and GitHub Secrets

- GitHub Actions Build Workflow: https://github.com/CruGlobal/godtools-swift/blob/develop/.github/workflows/build.yml

- GitHub Actions OneSky Workflow: https://github.com/CruGlobal/godtools-swift/blob/develop/.github/workflows/download_onesky_translations.yml

- GitHub Actions OneSky Workflow Dependency Plugin: https://github.com/thekie/fastlane-plugin-onesky

#### Conventions

- [Classes](#classes)
- [Project Folder Structure](#project-folder-structure)

##### Classes

- Class / Struct attributes should always be declared with the type.
- It is also preferred that there is a consistent grouping of Class / Struct attributes.  This way the code we produce has a similar form which can help when quickly reading someone else's code.  Below is a screenshot of the preferred grouping of Class / Struct attributes.  These attributes are broken into 3 high level groupings, static attributes, instance attributes, and special attributes (property wrappers, etc.)  Within those 3 high level groupings, attributes are grouped by access level private, internal, public, and open.  Within the access level grouping, attributes are then grouped by immutable first, then mutable.

For the attribute grouping I don't want to get too nit picky in this area. Just as long as we have some consistency that is close to what is outlined here. The main idea is that code is consistent which can be helpful when multiple developers are contributing to a project.
I also realize there may be cases for attributes that aren't outlined here, example fileprivate and more special attributes such as Binding, State, etc. As long as we hit the 3 main groupings static, instance, special, and from there do the best we can to fill in the inner groupings.
  

![alt text](ReadMeAssets/attribute_grouping.png)

#### Project Folder Structure

There are 3 primary folders to be aware about in the project folder structure.  That is the Features, Flows, and Share folders.

#### Features Folder

The features folder is where most of the app code is going to live.  This is code that implements clean architecture (presentation, domain, data, and data-domain interface) layers.

Each subfolder in the Features folder is named to reflect a feature in the app.

The purpose of adding feature folders in this way is scalability.  It's inevitable that the app will grow in size as product continually comes up with new features they would like to see in the app.  More features means more code and we need to organize code in such a way that it's easy to scale with new features.

Think of a feature folder as its own module.  A feature really should be independent from all other features with some minor overlap where Feature_A might require some data produced by a UseCase in Feature_B.

##### Features Folder Responsibilities

- Should contain subfolders named to reflect a specific feature in the app.
- Each feature folder should contain the following directories to aid in clean architecture. (Data, Data-DomainInterface, DependencyContainer, Domain, and Presentation).  The code in these folders will be specific to the feature and support the implementation of the feature.

##### Features Folder - Data

The Data folder should contain additional directories for the raw data layer classes.  This will typically be repositories and other services for operating on the raw data layer. 

##### Features Folder - Data-DomainInterface

The Data-DomainInterface folder will contain the implementations for the domain layer interfaces.

##### Features Folder - DependencyContainer

The DependencyContainer will consist of a FeatureDiContainer, FeatureDataLayerContainer, and FeatureDomainLayerContainer.  These classes support the Coordinator (Flow) when injecting dependencies into ViewModels.

##### Features Folder - Domain

The Domain folder will consist of the following folders (Entities, Interface, UseCases).  Entities is where DomainModels should live.  Interfaces is where all the UseCase defined interfaces should live for dependency inversion.  UseCases is were all UseCases for the feature should live.

##### Features Folder - Presentation

###### App/Feature/Data Folder

This folder will contain the data layer specific code needed for the feature. 

###### App/Feature/Data-DomainInterface Folder

This folder will contain the domain interface implementation code needed for the feature. 

###### App/Feature/DependencyContainer Folder

This folder will contain the dependency container, data layer container, and domain layer container classes for creating the dependencies (dependency injection) needed for the feature.

###### App/Feature/Domain Folder

This folder will contain the domain layer specific code needed for the feature and will contain subfolders UseCases, Entities (possibly changing to DomainModels), and Interfaces. 

###### App/Feature/Presentation Folder

This folder will contain the presentation layer specific code needed for the feature.

###### App/Flows Folder

This folder will contain specific navigation flows in the app to achieve the coordinator pattern.

###### App/Share Folder

This folder contains code that is shared across features.  One area to highlight is the /Share/Data-DomainInterface/Supporting/ folder which contains more granular business formatting and rules that can be shared across domain interface implementations.
