# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Requirements

- Xcode
- Java 21 SDK (for Kotlin GodToolsToolParser)

**CI/CD only (not required for local development):**
- Bundler (Ruby gem manager)
- Fastlane

## Build & Test Commands

Test plans live in `TestPlans/`: `Tests` (unit + behavior), `UITests`, and `AllTests` (both).

**Only the `GodTools-Production` scheme is configured for the test action.** `GodTools-Staging` and the
other schemes have no test action and will fail with "scheme is not currently configured for the test
action."

### Locally — use `xcodebuild`

```bash
# Unit + behavior tests
xcodebuild test -project godtools.xcodeproj -scheme GodTools-Production -testPlan Tests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# UI tests only
xcodebuild test -project godtools.xcodeproj -scheme GodTools-Production -testPlan UITests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Swap `-testPlan` for `AllTests` to run everything in one pass. List available simulators with
`xcrun simctl list devices available`.

**Reading the results:** the tests use Swift Testing (`@Test`), so the legacy line
`Executed 0 tests, with 0 failures` is **not** the real outcome — it only counts XCTest cases. Look for
`✔ Test run with N tests in M suites passed` instead. If passing `-resultBundlePath`, delete any existing
bundle at that path first; `xcodebuild` errors out rather than overwriting it.

### In CI — Fastlane

GitHub Actions (`run-tests.yml`) runs the `Tests` and `UITests` plans as separate Fastlane invocations and
merges the two `.xcresult` bundles:

```bash
bundle exec fastlane cru_shared_lane_run_tests testplan:Tests output_directory:fastlane_scan_output_directory/tests result_bundle:true reset_simulator:true should_clear_derived_data:true
bundle exec fastlane cru_shared_lane_run_tests testplan:UITests output_directory:fastlane_scan_output_directory/uitests result_bundle:true reset_simulator:true should_clear_derived_data:true
```

These are not expected to work on a stock local machine: `Gemfile.lock` pins a Bundler version that macOS
system Ruby does not ship, so `bundle exec` fails until that exact Bundler is installed. Prefer
`xcodebuild` locally and let the pipeline run Fastlane.

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
- Return type depends on the shape of the work — see [Concurrency](#concurrency-asyncawait-vs-combine)
- Should not depend on other UseCases; the ViewModel coordinates between them
- Prefer returning DomainModels over Swift primitive types to encapsulate business attributes
- Keep UseCases smaller and focused on a single task
- Private methods are allowed to break up business logic within a UseCase

**ViewModels:**
- Implement `ObservableObject` with `@Published` properties for output
- Communicate with domain via injected UseCases
- Call `async` UseCases from inside a `Task { }`, assigning the result to a `@Published` property
- Subscribe to publisher-returning UseCases with `.sink`/`.assign(to:)` and retain the `AnyCancellable`
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

### Concurrency: async/await vs Combine

The codebase is migrating from Combine to Swift Concurrency. The two are **not** interchangeable — choose based on the shape of the work, not on which API is newer.

**One-shot work → `async`/`await`.** A single result (or thrown error), then done: network fetches, cache reads, downloads, authentication, analytics. This is the default for new code.

```swift
func execute(toolId: String, toolLanguageId: String) async throws -> [ShareableDomainModel]
```

**Values over time → Combine `AnyPublisher`.** An open-ended stream with no single return value: observing Realm collection changes, auth-state changes, download progress.

```swift
@MainActor func execute(toolId: String) -> AnyPublisher<ToolIsFavoritedDomainModel, Error>
@MainActor func execute(languageId: String) -> AnyPublisher<Double, Error>  // download progress
```

**Pure synchronous computation → plain return.** No suspension required, e.g. localized string lookups.

```swift
func execute(appLanguage: String) -> ToolDetailsStringsDomainModel
```

**Rules:**
- Do not convert observation or progress UseCases to `async`/`await`. There is no single value to return, so `AnyPublisher` remains correct.
- UseCases that observe Realm collection changes must be `@MainActor` (see Testing → Realm threading requirements).
- Combine is **not** being removed. `ObservableObject` and `@Published` are Combine types, so Combine remains part of the Presentation layer as long as ViewModels use them.
- Prefer `AsyncStream`/`AsyncThrowingStream` over creating new `PassthroughSubject`/`CurrentValueSubject` when bridging non-Combine callbacks into a stream.

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

See [Code Conventions → Comments](#code-conventions). Well-named tests, variables, and clear assertions should be self-documenting.

**Code coverage:**

When writing tests, check the code coverage for the class (or classes) under test. Aim for coverage as close to 100% as possible, ensuring all significant business logic and meaningful code paths are tested.

## Code Conventions

**Attribute grouping order in classes/structs:**
1. Static attributes (private → internal → public → open, immutable before mutable)
2. Instance attributes (same order)
3. Special attributes (`@Published`, `@State`, `@Binding`, etc.)

Always declare attributes with explicit types.

**Comments:**

Code should be self-documenting. Comments are a last resort, not a default.

- Prefer precise names, small focused methods, and named constants over explanatory prose.
- If code needs a comment to be understood, restructure or rename it instead.
- `// TODO:` is acceptable and should reference a ticket (e.g. `// TODO: ... GT-1234`).
- Avoid `// NOTE:` and inline commentary describing what the code does.
- `// MARK:` is fine for organization.

This applies to new and modified code. Existing comments (including `// NOTE: ... ~Name`) are not a cleanup mandate — leave them unless you are already changing that code.

## Localization

Add new strings only to the Base `Localizable.strings` (`godtools/Localizable/en.lproj/Localizable.strings`). GitHub Actions workflows (`crowdin-upload.yml` and `crowdin-download.yml`) manage translations with Crowdin.

## Build Troubleshooting

If you encounter random build errors:

1. Product > Clean Build Folder in Xcode
2. Delete `~/Library/Developer/Xcode/DerivedData/`
3. Verify Command Line Tools: Xcode > Settings > Locations > Ensure Command Line Tools shows latest Xcode version
4. For Swift Package Manager issues: File > Packages > Reset Package Caches
5. For Gradle errors: restart the computer
