# Swift/iOS Code Review Pattern Library

Comprehensive list of **43 patterns** that can be detected automatically (without AI) for fast, accurate code review.

**Currently Implemented: 15 patterns** (in agent-review-v2)

## Why Pattern Matching?

- **Fast**: Patterns check in 3-5 seconds (vs 8+ minutes for AI)
- **Accurate**: grep doesn't hallucinate - it either finds the pattern or doesn't
- **Objective**: No interpretation needed - these are clear violations
- **Efficient**: AI agents can focus on subjective/contextual issues

---

## 1. Code Quality Patterns

### Typos (Common Misspellings)
```bash
langauge|recieve|occured|seperate|definately|maintainence|neccessary|retreive|occassion|wierd|thier|acheive
```
**Why**: Reduces technical debt, improves professionalism
**Severity**: 4/10 (low-medium)

### Debug Statements Left in Code
```bash
print\(|NSLog\(|debugPrint\(|dump\(
```
**Why**: Performance impact, console spam in production
**Severity**: 5/10 (medium)
**Note**: Some projects use print for logging - adjust as needed

### TODOs Without Ticket References
```bash
(TODO|FIXME)(?!.*GT-\d+)
```
**Why**: Un-tracked tech debt, forgotten work items
**Severity**: 3/10 (low)

### Commented-Out Code
```bash
^\s*//\s*(func|class|struct|enum|var|let)\s
```
**Why**: Code clutter, confusion about intent
**Severity**: 4/10 (low-medium)

### Force Unwraps (!)
```bash
\w+!(?!\s*=)  # matches foo! but not foo !=
```
**Why**: Runtime crashes if nil
**Severity**: 7/10 (high) in production code, 2/10 in tests
**Filter**: Exclude tests, exclude known safe patterns

---

## 2. Swift Safety Patterns

### Force Try (try!)
```bash
try!
```
**Why**: Bypasses error handling, crashes on error
**Severity**: 8/10 (high)

### Force Cast (as!)
```bash
as!
```
**Why**: Crashes if cast fails
**Severity**: 8/10 (high)

### fatalError in Production
```bash
fatalError\(
```
**Why**: Intentional crash - should only be in truly impossible conditions
**Severity**: 7/10 (review needed)

### Implicitly Unwrapped Optionals
```bash
var.*:.*!  # var foo: String!
```
**Why**: Same risks as force unwrap
**Severity**: 6/10 (medium-high)
**Note**: Sometimes necessary for @IBOutlet

---

## 3. Architecture Patterns (Swift Clean Architecture)

### Presentation Imports Data Layer
```bash
# In files matching */Presentation/*.swift
import.*Data(?!Model)
```
**Why**: Layer violation - Presentation should only import Domain
**Severity**: 9/10 (critical architecture violation)

### UseCase Depends on Another UseCase
```bash
# In files matching */Domain/UseCases/*.swift
:\s*\w+UseCase
```
**Why**: UseCases should be independent - ViewModel coordinates
**Severity**: 8/10 (high)

### ViewModel Doing Network Calls Directly
```bash
# In files matching */Presentation/*ViewModel.swift
URLSession|URLRequest
```
**Why**: ViewModel should delegate to UseCases/Repositories
**Severity**: 8/10 (high)

### Legacy Data-DomainInterface Usage
```bash
# Check paths
*/Data-DomainInterface/*
```
**Why**: Legacy pattern being phased out per CLAUDE.md
**Severity**: 5/10 (tech debt)

---

## 4. iOS/SwiftUI Patterns

### Hardcoded UI Strings (Missing Localization)
```bash
Text\("[\w\s]+"  # Text("hardcoded") instead of NSLocalizedString
```
**Why**: Not localizable, breaks i18n
**Severity**: 6/10 (medium-high)

### Hardcoded Colors
```bash
Color\(red:|Color\(UIColor|UIColor\(red:
```
**Why**: Doesn't support dark mode, not semantic
**Severity**: 5/10 (medium)
**Note**: Should use Color("SemanticName") from asset catalog

### Missing Accessibility Labels
```bash
Button\(.*\{$  # Button without .accessibilityLabel on next lines
```
**Why**: VoiceOver users can't use app
**Severity**: 7/10 (high for accessibility)

### Heavy .onAppear Side Effects
```bash
\.onAppear.*\n.*\n.*\n.*\n  # onAppear with 4+ lines
```
**Why**: Body can be called multiple times, causes performance issues
**Severity**: 6/10 (medium-high)

---

## 5. Security Patterns

### Hardcoded API Keys
```bash
(api_key|apiKey|API_KEY|x-api-key)\s*=\s*"[\w-]+"
```
**Why**: Security vulnerability - keys should be in secure storage
**Severity**: 10/10 (critical)

### Hardcoded Passwords/Tokens
```bash
(password|pwd|token|secret)\s*=\s*"[^"]+"
```
**Why**: Security vulnerability
**Severity**: 10/10 (critical)

### HTTP URLs (Not HTTPS)
```bash
http://(?!localhost|127\.0\.0\.1)
```
**Why**: Data transmitted in clear text
**Severity**: 9/10 (critical for production endpoints)

### Sensitive Data in UserDefaults
```bash
UserDefaults.*password|UserDefaults.*token|UserDefaults.*apiKey
```
**Why**: UserDefaults not encrypted - use Keychain instead
**Severity**: 9/10 (critical)

### WebView JavaScript Injection
```bash
evaluateJavaScript.*\$|evaluateJavaScript.*\{
```
**Why**: XSS vulnerability if using user input
**Severity**: 9/10 (critical if user input)

---

## 6. Realm/Persistence Patterns

### Missing @MainActor on Realm Observers
```bash
observeCollectionChangesPublisher  # Check if @MainActor in previous 5 lines
```
**Why**: Crash - "Can only add notification blocks from within runloops"
**Severity**: 10/10 (critical - will crash)
**Implementation**:
```bash
# Check if file has observeCollectionChangesPublisher
grep -B5 "observeCollectionChangesPublisher" | grep "@MainActor"
```

### Realm Writes Without Transactions
```bash
realm\.add\(|realm\.delete\(  # Check if inside realm.write block
```
**Why**: Runtime error - writes require transactions
**Severity**: 10/10 (critical - will crash)

### Missing Primary Keys on Realm Objects
```bash
class.*:.*Object.*\{  # Check if primaryKey() method exists in next 20 lines
```
**Why**: Can't update/find objects efficiently
**Severity**: 7/10 (high)

### Realm Objects Accessed Across Threads
```bash
realm\.object\(  # Check if in @MainActor method or DispatchQueue.main
```
**Why**: Crash - Realm objects not thread-safe
**Severity**: 10/10 (critical - will crash)

---

## 7. Testing Patterns

### New Behavior Tests Missing Given/When/Then
```bash
@Test(?!.*Given.*When.*Then)  # In BehaviorTests/ folder
```
**Why**: Project standard per CLAUDE.md
**Severity**: 6/10 (standards violation)

### XCTest in New Behavior Tests
```bash
# In files matching godtoolsTests/BehaviorTests/*.swift (new files only)
XCTest
```
**Why**: Should use Swift Testing (@Test macro) for new behavior tests
**Severity**: 5/10 (tech debt)

### Tests Missing @MainActor for Realm Observers
```bash
# In test files
observeCollectionChangesPublisher  # Check for @MainActor
```
**Why**: Same crash as production code
**Severity**: 10/10 (critical)

---

## 8. Memory Management Patterns

### Potential Retain Cycles in Closures
```bash
\{.*self\.  # Closure capturing self without [weak self]
```
**Why**: Memory leaks
**Severity**: 7/10 (high)
**Note**: High false positive rate - needs AI review for context

### Delegate Not Marked weak
```bash
var.*delegate.*:  # Check if weak keyword present
```
**Why**: Retain cycle between parent/child
**Severity**: 8/10 (high)

---

## 9. Project-Specific Patterns

### Domain Models Not in Entities Folder
```bash
# Files matching */Domain/DomainModels/*
```
**Why**: Old pattern - should use Domain/Entities/ per CLAUDE.md
**Severity**: 4/10 (tech debt)

### Missing Explicit Types on Attributes
```bash
(var|let)\s+\w+\s*=  # Check if type annotation present
```
**Why**: Project convention per CLAUDE.md
**Severity**: 3/10 (low)

### Variables Without Explicit Access Control
```bash
^\s*(var|let)\s+\w+.*:  # var or let without private/public/internal
# Exclude lines starting with @ (property wrappers)
```
**Why**: Encourages proper encapsulation, reduces API surface area
**Severity**: 4/10 (low-medium)
**Note**: Should be `private` by default unless intentionally exposing

---

## 10. Performance Patterns

### Synchronous Network Calls
```bash
dataTask.*wait\(|URLSession\.shared\.data\(  # Without async
```
**Why**: Blocks main thread
**Severity**: 9/10 (critical)

### Heavy Computation on Main Thread
```bash
@MainActor.*for.*in  # Large loops in MainActor
```
**Why**: UI freezes
**Severity**: 7/10 (high)
**Note**: Needs AI review - short loops are fine

### Realm Queries Without Background Threads
```bash
realm\.objects\(  # Check if in background queue
```
**Why**: Blocks main thread for large datasets
**Severity**: 6/10 (medium-high)

---

## Pattern Implementation Priority

**✅ Implemented in agent-review-v2 (15 patterns):**
1. ✅ Common typos
2. ✅ Missing @MainActor on Realm observers (crashes)
3. ✅ Force unwraps in production (crashes)
4. ✅ Debug print statements
5. ✅ TODOs without tickets
6. ✅ Force try/cast
7. ✅ Hardcoded UI strings (localization)
8. ✅ Legacy Data-DomainInterface usage
9. ✅ Realm writes without transactions (crashes)
10. ✅ Synchronous network calls (UI freezes)
11. ✅ Hardcoded secrets/API keys (security)
12. ✅ Presentation imports Data layer (architecture)
13. ✅ UseCase depends on UseCase (architecture)
14. ✅ Missing accessibility labels
15. ✅ Variables without access control

**High Priority (Not Yet Implemented):**
- Realm objects accessed across threads (crashes)
- HTTP URLs instead of HTTPS (security)
- Sensitive data in UserDefaults (security)
- WebView JavaScript injection (security)

**Medium Priority (Not Yet Implemented):**
- ViewModel doing network calls directly
- Commented-out code (cleanup)
- Hardcoded colors (design consistency)
- Heavy .onAppear side effects
- Delegates not marked weak (memory leaks)

**Low Priority (Not Yet Implemented):**
- Potential retain cycles in closures
- Heavy computation on main thread
- Implicitly unwrapped optionals

---

## Usage in Code Review

```bash
# Example: Run all high-priority patterns
echo "Running critical pattern checks..."

# 1. Realm observers (crashes)
echo "Checking @MainActor on Realm observers..."
# [implementation from Stage 0.5]

# 2. Force unwraps (crashes)
echo "Checking force unwraps..."
git diff $BASE_BRANCH...HEAD | grep "^+" | grep -v "Tests" | grep -E "\w+!" | grep -v "!="

# 3. Security patterns
echo "Checking for hardcoded secrets..."
git diff $BASE_BRANCH...HEAD | grep -E "(api_key|apiKey|password)\s*=\s*\""

# Total time: ~3 seconds
```

---

## False Positive Handling

Some patterns have high false positive rates and need AI context:

- **weak self**: Sometimes self is intentionally captured strongly
- **Force unwraps**: Sometimes safe after nil checks
- **Hardcoded strings**: Constants and identifiers vs user-facing text

**Solution**: Pattern matching flags potential issues, AI agent reviews context.
