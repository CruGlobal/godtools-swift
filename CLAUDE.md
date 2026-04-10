# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Requirements

- Xcode
- Java 21 SDK (for Kotlin GodToolsToolParser)

**CI/CD only (not required for local development):**
- Bundler (Ruby gem manager)
- Fastlane

## Build & Test Commands

**Run all tests (via Fastlane):**
```bash
bundle exec fastlane cru_shared_lane_run_tests testplan:AllTests output_directory:fastlane_scan_output_directory result_bundle:true reset_simulator:true should_clear_derived_data:true
```

**Run unit tests only:** Use `Tests.xctestplan` instead of `AllTests` in the above command.

**Run UI tests only:** Use `UITests.xctestplan` instead of `AllTests` in the above command.

**Linting:**
```bash
# SwiftLint runs automatically via GitHub Actions (swift-lint.yml)
swiftlint
```

## Architecture

The app uses **Clean Architecture** with three layers plus the **Coordinator (Flow) pattern** for navigation.

```
Presentation (View + ViewModel)
    ↓ depends on
Domain (UseCases + DomainModels)
    ↓ depends on
Data (Repositories + Networking + Persistence)

Coordinator (Flow) — handles navigation decisions and dependency injection
```

### Feature Modules

All feature code lives in `godtools/App/Features/`. Each feature is its own self-contained module:

```
Features/<FeatureName>/
├── Data/                      # Repositories, API clients, caches, protocol interfaces
├── Data-DomainInterface/      # (Legacy - being phased out) Repository implementations bridging data/domain
├── DependencyContainer/       # DI containers (Feature, DataLayer, DomainLayer)
├── Domain/
│   ├── UseCases/
│   └── Entities/              # Domain models
└── Presentation/
    └── <FeatureName>/         # SwiftUI views and ViewModels together
```

**Notes:**
- `Data-DomainInterface/` is legacy and being removed. Repository protocols now live in `Data/` layer.
- `Presentation/` organizes by feature submodules, not separate Views/ViewModels folders.
- Some older features may use `Domain/DomainModels/` instead of `Domain/Entities/` (prefer Entities).

Shared code used across features lives in `godtools/App/Share/`.

### Key Architecture Rules

**UseCases:**
- Single public method named `execute()`
- Inputs must not be Publisher types (ViewModels react to changes and call execute)
- Returns `AnyPublisher<DomainModel, Error>`
- Should not depend on other UseCases; the ViewModel coordinates between them
- Prefer returning DomainModels over Swift primitive types to encapsulate business attributes
- Keep UseCases smaller and focused on a single task
- Private methods are allowed to break up business logic within a UseCase

**ViewModels:**
- Implement `ObservableObject` with `@Published` properties for output
- Communicate with domain via injected UseCases
- Delegate navigation actions to a `FlowDelegate` via `FlowStep` enum

**Flows (Coordinator):**
- Implement the `Flow` protocol
- Handle all navigation decisions in `navigate(step: FlowStep)`
- Instantiate Views/ViewModels and inject dependencies
- Can share a `UINavigationController` stack with a parent flow or have their own (e.g., modal presentation)
- Configure `UIBarButtonItems` here, not in views

**Repositories:**
- Produce a single `DataModel` type
- Encapsulate storage details (remote API, Realm, UserDefaults, file system, etc.)
- Define protocols (e.g., `FooRepositoryInterface`) in the `Data/` layer for dependency injection and test mocking
- Concrete implementations also live in `Data/` layer
- **Tiered Repository Pattern**: Repositories are organized in tiers:
  - **Tier 1 (Core/Shared)**: General-purpose repositories used across the app (e.g., `ResourcesRepository`, `TranslationsRepository`)
  - **Tier 2 (Feature-specific)**: Feature-specific repositories (e.g., `PersonalizedToolsRepository`, `PersonalizedLessonsRepository`)
  - Tier 2 repositories **may depend on** Tier 1 repositories for composition/coordination
  - Tier 1 repositories should remain independent

### Navigation

`FlowStep` is the central enum defining all navigation actions across the app (`godtools/App/Flows/Flow/FlowStep.swift`). ViewModels reference `FlowDelegate?` (weak) and call `navigate(step:)`. The implementing Flow decides where to go next — steps should not describe a destination, only an action.

### Dependency Injection

The root container is `AppDiContainer`, which composes:
- `AppDataLayerDependencies`
- `AppDomainLayerDependencies`
- `AppFeatureDiContainer` (contains per-feature DI containers)

Flows receive `AppDiContainer` and use it to construct ViewModels with their required dependencies.

## Testing

Tests live in `godtoolsTests/`:
- `BehaviorTests/` — BDD-style tests verifying domain behavior using Swift Testing (`@Test` macro), following Given/When/Then format
- `UnitTests/` — Isolated XCTest unit tests
- `Mock/` — Shared mocks, including `TestsDiContainer`, `TestsAppConfig`, and `TestsInMemorySwiftDatabase`

**Realm threading requirements:**
- **In production code**: Any method that observes Realm collection changes (via `.observe()` or Realm collection publishers) **must** be marked `@MainActor` to avoid a crash (`Can only add notification blocks from within runloops`)
- **In tests**: Tests use an in-memory Realm instance (`TestsInMemorySwiftDatabase`). Any test observing Realm collection changes **must** be marked `@MainActor` for the same reason
- UseCases and Repositories that call `persistence.observeCollectionChangesPublisher()` should be marked `@MainActor`

**Behavior test format (Given/When/Then):**

Behavior tests verify how the app should behave from a user perspective:
- **Given**: Describes the initial state/context before testing begins (preconditions)
- **When**: Describes the action that triggers the behavior being tested
- **Then**: Describes the expected outcome given the initial state and action

Example scenario:
- Given: User is logging in
- When: An invalid email is entered
- Then: Should receive an error message that the email is invalid

```swift
@Test(
    """
    Given: <initial state>
    When: <action>
    Then: <expected outcome>
    """
)
@MainActor func testMethodName() async throws { ... }
```

**Parameterized tests:**

When multiple test scenarios differ only in input values and expected outcomes, use parameterized tests with the `arguments` parameter instead of duplicating similar test methods. This reduces code duplication and makes test intent clearer.

Example:
```swift
struct MyTestArgument {
    let input: String
    let expectedOutput: String
}

@Test(
    """
    Given: <initial state>
    When: <action with different inputs>
    Then: <expected outcome varies by input>
    """,
    arguments: [
        MyTestArgument(input: "value1", expectedOutput: "result1"),
        MyTestArgument(input: "value2", expectedOutput: "result2")
    ]
)
func testBehavior(argument: MyTestArgument) async throws {
    // Test implementation using argument.input and argument.expectedOutput
}
```

**Test code clarity:**

Avoid adding comments in test code unless strictly necessary. Well-named tests, variables, and clear assertions should be self-documenting. Use MARK comments for organizational purposes (e.g., `// MARK: - Test Helpers`), but avoid inline comments that simply describe what the code is doing.

**Code coverage:**

When writing tests, check the code coverage for the class (or classes) under test. Aim for coverage as close to 100% as possible, ensuring all significant business logic and meaningful code paths are tested.

## Code Conventions

**Attribute grouping order in classes/structs:**
1. Static attributes (private → internal → public → open, immutable before mutable)
2. Instance attributes (same order)
3. Special attributes (`@Published`, `@State`, `@Binding`, etc.)

Always declare attributes with explicit types.

## Localization

Add new strings only to the Base `Localizable.strings` (`godtools/Localizable/en.lproj/Localizable.strings`). GitHub Actions workflows (`crowdin-upload.yml` and `crowdin-download.yml`) manage translations with Crowdin.

## Build Troubleshooting

If you encounter random build errors:

1. Product > Clean Build Folder in Xcode
2. Delete `~/Library/Developer/Xcode/DerivedData/`
3. Verify Command Line Tools: Xcode > Settings > Locations > Ensure Command Line Tools shows latest Xcode version
4. For Swift Package Manager issues: File > Packages > Reset Package Caches
5. For Gradle errors: restart the computer
