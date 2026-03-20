---
name: agent-review
description: Fast, accurate multi-agent PR review with pattern matching and streaming for Swift/iOS
approve_tools:
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(date:*)
  - Bash(grep:*)
  - Bash(echo:*)
  - Bash(wc:*)
  - Bash(awk:*)
  - Bash(cat:*)
  - Bash(find:*)
  - Read(**)
  - Glob(**)
  - Grep(**)
  - Task(**)
---

# Multi-Agent Swift/iOS PR Code Review (V2)

AI-powered code review with **pattern-based prescreening**, **streaming output**, and **verified findings** to prevent hallucinations.

**What's New in V2:**
- 🔍 Pattern matching catches 80% of issues in ~5 seconds
- 📡 Streaming output shows results as they're found
- ✅ Verification step prevents AI hallucinations
- ⚡ Quick mode: Single agent, no debates (~30 seconds)

**Usage**:

```bash
/agent-review-v2                       # Interactive mode - prompts for options
/agent-review-v2 quick                 # Quick mode, compare to develop
/agent-review-v2 thorough              # Thorough mode, compare to develop
/agent-review-v2 quick feature/foo     # Quick mode, compare to feature/foo
```

**Arguments (optional):**
- First arg: Review mode — quick, standard, or thorough
- Second arg: Base branch — defaults to develop

**If no arguments provided**, Claude will ask interactively for mode and base branch.

---

## Stage 0 — Interactive Mode Selection (if no arguments)

**IMPORTANT**: If the user provided arguments, skip this stage and go to Stage 0A.

If no arguments were provided, use AskUserQuestion to gather mode and base branch:

**Question 1 - Review Mode:**
```
header: "Mode"
question: "Which review mode would you like to use?"
multiSelect: false
options:
  - label: "Quick"
    description: "1 agent (Architecture+Standards) • 60-90 sec • 4-8k tokens (2-4%)"
  - label: "Standard (Recommended)"
    description: "2-3 core agents • 3-5 min • 12-25k tokens (6-13%) • Verify severity 8+"
  - label: "Thorough"
    description: "All 7 agents • 8-12 min • 25-40k tokens (13-20%) • Verify severity 6+"
```

**Question 2 - Base Branch:**
```
header: "Base Branch"
question: "Which branch should we compare against?"
multiSelect: false
options:
  - label: "develop"
    description: "Main development branch (default)"
  - label: "Custom branch - don't select this!"
    description: "Use 'Other' option below to enter your branch name"
```

For custom branches (e.g., feature/personalized-tools), users should select "Other" and type the branch name in the text field below.

Store the answers and proceed directly to Stage 0A with the selected mode and base branch.

**IMPORTANT**: Skip Stage 0A.5 (confirmation) - the mode selection itself is sufficient confirmation since all details were shown upfront.

---

## Stage 0A — Parse Arguments & Initialize

### Parse Command Arguments

If arguments were provided, parse them in this order:
1. **Review mode** (first non-branch argument): quick, standard, or thorough
2. **Base branch** (looks like a branch name): Any other argument

If no arguments were provided, use the answers from Stage 0 (interactive mode):
- Mode will be one of: "Quick", "Standard (Recommended)", or "Thorough" (normalize to lowercase: quick/standard/thorough)
- Base branch will be either "develop", "main", or a custom branch name from the "Other" input

### Determine Review Mode

Modes:
- **quick**: Pattern scan + 1 agent (Architecture/Standards combined), no debate, model: sonnet
- **standard** (default): Pattern scan + 2-3 core agents, model: sonnet, no debate
- **thorough**: Pattern scan + all 7 agents, no debate, model: sonnet

Print the mode banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[MODE BANNER based on selection]

quick:
  🏃 QUICK REVIEW MODE (V2)
  • Pattern prescreening (15 checks in ~8 seconds)
  • 1 general agent (Architecture + Standards)
  • Model: Sonnet (fast, cost-effective)
  • Streaming results
  • Estimated time: ~60-90 seconds
  • Token cost: ~4,000-8,000 tokens (~2-4% of budget)

standard:
  ⚡ STANDARD REVIEW MODE (V2 - Recommended)
  • Pattern prescreening (15 checks in ~8 seconds)
  • 2-3 core agents (Architecture + Standards + conditional)
  • Model: Sonnet (fast, cost-effective)
  • Streaming results, no debate
  • Conditional verification (severity 8+ only)
  • Estimated time: ~3-5 minutes
  • Token cost: ~12,000-25,000 tokens (~6-13% of budget)
  • ⚠️  Requires confirmation before proceeding

thorough:
  🔬 THOROUGH REVIEW MODE (V2)
  • Pattern prescreening (15 checks in ~8 seconds)
  • All 7 specialized agents (comprehensive coverage)
  • Model: Sonnet (balanced quality & cost)
  • Streaming results, no debate
  • Full verification (severity 6+)
  • Estimated time: ~8-12 minutes
  • Token cost: ~25,000-40,000 tokens (~13-20% of budget)
  • ⚠️  Requires confirmation before proceeding

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

MODE: REVIEW ONLY. Do NOT modify files or stage/commit.

---

## Stage 0A.5 — User Confirmation (DEPRECATED - SKIP THIS STAGE)

**This stage is no longer used.**

All mode details (time, tokens, agents) are shown upfront in Stage 0 during mode selection, so an additional confirmation is unnecessary. The user's mode selection is sufficient confirmation to proceed.

**Always skip this stage and proceed directly to Stage 0B.**

---

## Stage 0B — Context Gathering

### Determine Base Branch

```bash
CURRENT_BRANCH=$(git branch --show-current)
BASE_BRANCH=${USER_SPECIFIED_BASE:-develop}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 REVIEW CONTEXT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Current Branch: $CURRENT_BRANCH"
echo "Base Branch:    $BASE_BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

### Get Diff Content

```bash
CHANGED_FILES=$(git diff $BASE_BRANCH...HEAD --name-only)
FULL_DIFF=$(git diff $BASE_BRANCH...HEAD)

FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
ADDITIONS=$(git diff $BASE_BRANCH...HEAD --numstat | awk '{add+=$1} END {print add}')
DELETIONS=$(git diff $BASE_BRANCH...HEAD --numstat | awk '{del+=$2} END {print del}')

echo "Files changed: $FILE_COUNT"
echo "Lines: +$ADDITIONS -$DELETIONS"
echo ""
```

---

## Stage 0.5 — Pattern-Based Prescreening ⚡

**CRITICAL: Run this BEFORE launching agents**

Display streaming header:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 PATTERN PRESCREENING (Fast checks before AI analysis)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Run these checks in sequence, displaying results immediately as they complete:

### 1. Common Typos (0.5s)

```bash
echo "Checking: Common typos..."
TYPOS=$(git diff $BASE_BRANCH...HEAD | grep -nE "langauge|recieve|occured|seperate|definately|maintainence|neccessary|retreive|occassion" || true)
if [ -n "$TYPOS" ]; then
  echo "⚠️  Typos found:"
  echo "$TYPOS" | head -5
else
  echo "✓ No common typos"
fi
```

### 2. Realm Observer @MainActor Check (1s)

```bash
echo "Checking: @MainActor on Realm observers..."
# Get new/modified files only
NEW_FILES=$(git diff $BASE_BRANCH...HEAD --name-only --diff-filter=AM | grep "\.swift$")

MAINACTOR_ISSUES=""
for file in $NEW_FILES; do
  # Check if file has observeCollectionChangesPublisher
  if grep -q "observeCollectionChangesPublisher" "$file"; then
    # Check if the method/function has @MainActor
    CONTEXT=$(grep -B5 "observeCollectionChangesPublisher" "$file" | grep -E "func |@MainActor")
    if ! echo "$CONTEXT" | grep -q "@MainActor"; then
      MAINACTOR_ISSUES="$MAINACTOR_ISSUES\n$file: Missing @MainActor on Realm observer"
    fi
  fi
done

if [ -n "$MAINACTOR_ISSUES" ]; then
  echo "⚠️  Missing @MainActor on Realm observers:"
  echo -e "$MAINACTOR_ISSUES"
else
  echo "✓ @MainActor correct on Realm observers"
fi
```

### 3. Force Unwraps in Production Code (0.5s)

```bash
echo "Checking: Force unwraps in production code..."
FORCE_UNWRAPS=$(git diff $BASE_BRANCH...HEAD | grep "^+" | grep -v "Tests" | grep -E "\w+!" | grep -v "!=" | grep -v "!isoRegionCode" || true)

if [ -n "$FORCE_UNWRAPS" ]; then
  COUNT=$(echo "$FORCE_UNWRAPS" | wc -l | tr -d ' ')
  echo "⚠️  Force unwraps found: $COUNT instances"
  echo "$FORCE_UNWRAPS" | head -3
  echo "    (showing first 3)"
else
  echo "✓ No force unwraps in production code"
fi
```

### 4. Debug Statements (0.3s)

```bash
echo "Checking: Debug statements..."
DEBUG=$(git diff $BASE_BRANCH...HEAD | grep "^+" | grep -E "print\(|NSLog\(|debugPrint\(" || true)

if [ -n "$DEBUG" ]; then
  COUNT=$(echo "$DEBUG" | wc -l | tr -d ' ')
  echo "⚠️  Debug statements found: $COUNT print/NSLog calls"
else
  echo "✓ No debug print statements in new code"
fi
```

### 5. TODOs Without Tickets (0.2s)

```bash
echo "Checking: TODOs without ticket references..."
TODOS=$(git diff $BASE_BRANCH...HEAD | grep "^+" | grep -E "TODO|FIXME" | grep -v "GT-[0-9]" || true)

if [ -n "$TODOS" ]; then
  echo "⚠️  TODOs without ticket references:"
  echo "$TODOS" | head -3
else
  echo "✓ All TODOs have ticket references"
fi
```

### 6. Force Try/Cast (0.3s)

```bash
echo "Checking: Force try/cast..."
FORCE_OPS=$(git diff $BASE_BRANCH...HEAD | grep "^+" | grep -v "Tests" | grep -E "try!|as!" || true)

if [ -n "$FORCE_OPS" ]; then
  COUNT=$(echo "$FORCE_OPS" | wc -l | tr -d ' ')
  echo "⚠️  Force try/cast found: $COUNT instances"
else
  echo "✓ No force try/cast in production code"
fi
```

### 7. Hardcoded Strings in UI (0.5s)

```bash
echo "Checking: Hardcoded strings in UI code..."
HARDCODED=$(git diff $BASE_BRANCH...HEAD | grep "Presentation" | grep "^+" | grep -E 'Text\("[\w\s]+"' | grep -v "NSLocalizedString" || true)

if [ -n "$HARDCODED" ]; then
  COUNT=$(echo "$HARDCODED" | wc -l | tr -d ' ')
  echo "⚠️  Potential hardcoded UI strings: $COUNT instances"
  echo "    (may need localization)"
else
  echo "✓ UI strings appear localized"
fi
```

### 8. Legacy Data-DomainInterface Usage (0.2s)

```bash
echo "Checking: Legacy patterns..."
LEGACY=$(git diff $BASE_BRANCH...HEAD --name-only | grep "Data-DomainInterface" || true)

if [ -n "$LEGACY" ]; then
  echo "⚠️  Legacy Data-DomainInterface usage:"
  echo "$LEGACY"
else
  echo "✓ No legacy Data-DomainInterface usage"
fi
```

### 9. Realm Writes Without Transactions (0.5s) — HIGH PRIORITY

```bash
echo "Checking: Realm writes without transactions..."
NEW_FILES=$(git diff $BASE_BRANCH...HEAD --name-only --diff-filter=AM | grep "\.swift$")

REALM_WRITE_ISSUES=""
for file in $NEW_FILES; do
  # Check for realm.add or realm.delete
  if grep -q "realm\.add\(\\|realm\.delete\(" "$file"; then
    # Check if realm.write appears in the same file
    if ! grep -q "realm\.write" "$file"; then
      REALM_WRITE_ISSUES="$REALM_WRITE_ISSUES\n$file: Realm write operation without transaction"
    fi
  fi
done

if [ -n "$REALM_WRITE_ISSUES" ]; then
  echo "🚨 CRITICAL: Realm writes without transactions (will crash):"
  echo -e "$REALM_WRITE_ISSUES"
else
  echo "✓ Realm writes properly wrapped in transactions"
fi
```

### 10. Synchronous Network Calls (0.5s) — HIGH PRIORITY

```bash
echo "Checking: Synchronous network calls..."
SYNC_NETWORK=$(git diff $BASE_BRANCH...HEAD | grep "^+" | grep -v "Tests" | grep -E "\.wait\(\)|URLSession\.shared\.data\(" | grep -v "await" || true)

if [ -n "$SYNC_NETWORK" ]; then
  COUNT=$(echo "$SYNC_NETWORK" | wc -l | tr -d ' ')
  echo "🚨 CRITICAL: Synchronous network calls found: $COUNT instances"
  echo "    (will block main thread and freeze UI)"
  echo "$SYNC_NETWORK" | head -3
else
  echo "✓ No synchronous network calls"
fi
```

### 11. Hardcoded Secrets (0.5s) — HIGH PRIORITY

```bash
echo "Checking: Hardcoded API keys and secrets..."
SECRETS=$(git diff $BASE_BRANCH...HEAD | grep "^+" | grep -E "(api_key|apiKey|API_KEY|x-api-key|password|pwd|secret|token)\s*=\s*\"" | grep -v "UserDefaults" || true)

if [ -n "$SECRETS" ]; then
  echo "🚨 CRITICAL: Hardcoded secrets/API keys found:"
  echo "$SECRETS" | head -3
  echo "    ⚠️  Security vulnerability - use secure storage!"
else
  echo "✓ No hardcoded secrets detected"
fi
```

### 12. Presentation Imports Data Layer (0.5s) — ARCHITECTURE

```bash
echo "Checking: Architecture layer violations..."
PRES_FILES=$(git diff $BASE_BRANCH...HEAD --name-only --diff-filter=AM | grep "Presentation.*\.swift$" || true)

LAYER_VIOLATIONS=""
for file in $PRES_FILES; do
  # Check if Presentation file imports Data layer (but not DataModel)
  if grep -q "^import.*Data" "$file" && ! grep -q "^import.*DataModel" "$file"; then
    LAYER_VIOLATIONS="$LAYER_VIOLATIONS\n$file: Presentation importing Data layer"
  fi
done

if [ -n "$LAYER_VIOLATIONS" ]; then
  echo "⚠️  Architecture violations (Presentation → Data):"
  echo -e "$LAYER_VIOLATIONS"
  echo "    (Presentation should only import Domain)"
else
  echo "✓ Clean architecture layers respected"
fi
```

### 13. UseCase Depends on UseCase (0.5s) — ARCHITECTURE

```bash
echo "Checking: UseCase dependencies..."
USECASE_FILES=$(git diff $BASE_BRANCH...HEAD --name-only --diff-filter=AM | grep "UseCases.*\.swift$" || true)

USECASE_DEPS=""
for file in $USECASE_FILES; do
  # Check if UseCase has dependency on another UseCase (excluding self)
  FILENAME=$(basename "$file" .swift)
  if grep -E ":\s*\w+UseCase" "$file" | grep -v "$FILENAME" | grep -q "UseCase"; then
    USECASE_DEPS="$USECASE_DEPS\n$file: UseCase depends on another UseCase"
  fi
done

if [ -n "$USECASE_DEPS" ]; then
  echo "⚠️  UseCase dependency violations:"
  echo -e "$USECASE_DEPS"
  echo "    (UseCases should be independent - ViewModel coordinates)"
else
  echo "✓ UseCases are independent"
fi
```

### 14. Missing Accessibility Labels (0.5s)

```bash
echo "Checking: Accessibility labels..."
MISSING_A11Y=$(git diff $BASE_BRANCH...HEAD | grep "Presentation" | grep "^+" | grep -E "Button\(|Image\(" | grep -v "accessibilityLabel" || true)

if [ -n "$MISSING_A11Y" ]; then
  COUNT=$(echo "$MISSING_A11Y" | wc -l | tr -d ' ')
  echo "⚠️  Potential missing accessibility labels: $COUNT instances"
  echo "    (check if .accessibilityLabel is on following lines)"
else
  echo "✓ UI elements appear to have accessibility support"
fi
```

### 15. Non-Private Variables (0.5s) — CODE QUALITY

```bash
echo "Checking: Variable privacy..."
NON_PRIVATE_VARS=$(git diff $BASE_BRANCH...HEAD | grep "^+" | grep -v "Tests" | grep -E "^\s*(var|let)\s+\w+.*:" | grep -v "private\|public\|internal\|@" || true)

if [ -n "$NON_PRIVATE_VARS" ]; then
  COUNT=$(echo "$NON_PRIVATE_VARS" | wc -l | tr -d ' ')
  echo "⚠️  Variables without explicit access control: $COUNT instances"
  echo "    (consider marking as private when possible)"
  echo "$NON_PRIVATE_VARS" | head -3
  echo "    (showing first 3)"
else
  echo "✓ All variables have explicit access control"
fi
```

Display prescreening summary:

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Pattern prescreening complete (15 checks in ~8 seconds)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

**Store pattern findings** in variables for inclusion in agent context.

---

## Stage 0C — Risk Assessment

Calculate risk score (same as V1) and display risk assessment.

---

## Stage 0D — Agent Selection

**Quick mode**: 1 combined agent (Architecture/Standards)
**Standard mode**: Maximum 2-3 core agents:
  - Always: Architecture agent
  - Always: Standards agent
  - Conditional (pick ONE if relevant): Security agent (if auth/network changes) OR Performance agent (if Realm/async changes) OR UI agent (if SwiftUI changes)
**Thorough mode**: All 7 agents

Display selection results.

---

## Stage 1 — Launch Agents with Streaming Output

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 AI AGENT ANALYSIS (streaming results...)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Updated Agent Instructions (ALL MODES)

**CRITICAL VERIFICATION REQUIREMENTS:**

Every agent prompt MUST include these rules:

```
**ANTI-HALLUCINATION PROTOCOL:**

1. **Mandatory File Reads**: Before flagging ANY issue with severity 6+, you MUST use the Read tool to view the actual file.

2. **Exact Line References**: Every finding MUST include:
   - Exact file path
   - Exact line number
   - Quoted code snippet (3-5 lines of actual code)

3. **Pattern Findings Already Known**: You have access to pattern prescreening results. DO NOT re-flag these issues unless you have additional architectural context:
   [Include pattern findings from Stage 0.5]

4. **Verification Checklist** before reporting:
   - [ ] I have read the actual file with Read tool
   - [ ] The code I'm citing exists at the line number stated
   - [ ] I have quoted the actual code (not paraphrased)
   - [ ] This isn't already caught by pattern prescreening
   - [ ] I searched for similar patterns in the codebase

5. **If Uncertain**: Mark as "Needs Manual Verification" instead of confidently stating the issue exists.

6. **Known Intentional Patterns (DO NOT flag):**
   - @MainActor on methods that observe Realm collections (REQUIRED for thread safety)
   - Tier 2 repositories depending on Tier 1 repositories (intentional architecture)
   - Repository storing cancellables (check if pattern exists in similar repositories)
```

### Quick Mode: Single Combined Agent

**Task tool config:**
- description: "Combined architecture and standards review"
- subagent_type: "general-purpose"
- model: "sonnet"

**Prompt** (truncated, but includes):
- All verification requirements above
- Pattern findings from Stage 0.5
- Focus areas: Architecture layers, UseCase design, Standards compliance
- Skip automated fix generation in quick mode
- Time budget: 30 seconds

### Standard Mode: Core Agents (2-3 max)

**Task tool config:**
- description: "Architecture review" / "Standards review" / "[Conditional] review"
- subagent_type: "general-purpose"
- model: "sonnet"

**Key changes for standard mode:**
- Only run 2-3 core agents (Architecture + Standards + 1 conditional)
- Model: sonnet (faster, cheaper than opus)
- Include pattern findings in context
- Mandate file reads before flagging issues
- No debate rounds
- Require exact line numbers and code quotes

### Thorough Mode: All Specialized Agents

**Task tool config:**
- description: "[Agent type] review"
- subagent_type: "general-purpose"
- model: "sonnet"

**Key changes for thorough mode:**
- Run all 7 agents
- Model: sonnet (balanced quality & cost)
- Include pattern findings in context
- Mandate file reads before flagging issues
- No debate rounds (cost optimization)
- Require exact line numbers and code quotes

---

## Stage 2 — Verification Step (Conditional)

**Quick mode**: No verification (too fast to warrant it)
**Standard mode**: Only verify findings with severity 8+ (Critical/High priority blockers)
**Thorough mode**: Verify all findings with severity 6+ (comprehensive verification)

After agents complete, verify high-severity findings:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ VERIFYING HIGH-SEVERITY FINDINGS (severity 8+)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

For each finding meeting the severity threshold:

1. Extract file path and line number
2. Use Read tool to get actual file content
3. Check if the cited code exists at that line
4. If NOT found:
   - Mark finding as "VERIFICATION FAILED - Likely Hallucination"
   - Downgrade severity to 0 (exclude from report)
5. If found:
   - Mark as "✓ Verified"
   - Include in report

Display verification results:
```
Verifying 8 findings...
✓ Finding 1: Verified (PersonalizedToolsRepository.swift:21)
✗ Finding 2: FAILED - Code not found at specified line
✓ Finding 3: Verified (PersonalizedToolsType.swift:16)
...

8 findings checked, 7 verified, 1 hallucination removed
```

---

## Stage 3 — Debate Rounds (DEPRECATED)

**This stage is no longer used in any mode** - removed for cost optimization.
The verification step in Stage 2 provides sufficient quality control without the expense of debate rounds.

---

## Stage 4 — Generate Report

Combine:
1. Pattern findings (from Stage 0.5)
2. Verified agent findings (from Stage 2)

Report format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 CODE REVIEW REPORT (V2)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Mode: [quick/standard/thorough]
Analysis Time: [X] seconds
Verification: [N] findings verified, [M] hallucinations removed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 📊 Pattern Findings (Automated)

List all pattern-detected issues with:
- Severity (most patterns are 4-6/10)
- File:line
- Brief description
- Source: Pattern matching

### 🤖 Agent Findings (AI-Verified)

List verified findings with:
- Severity
- File:line
- Quoted code snippet
- Flagged by: [Agent name]
- ✓ Verified badge

### 🚫 Blockers

Critical + High priority (8-10 severity)

### ⚠️ Important Issues

Severity 6-7

### 💡 Suggestions

Severity 3-5

### 📝 Summary Table

| Source | Critical | High | Important | Suggestions |
|--------|----------|------|-----------|-------------|
| 🔍 Patterns | 0 | 0 | [N] | [N] |
| 🤖 AI Agents | [N] | [N] | [N] | [N] |
| **Total** | **[N]** | **[N]** | **[N]** | **[N]** |

### Verdict

Based on combined findings:
- **BLOCKERS FOUND**: [N] critical + [N] high priority issues
- **APPROVED WITH SUGGESTIONS**: No blockers, [N] improvements recommended
- **CLEAN**: No significant issues found

---

## Stage 5 — Final Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ REVIEW COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Branch:    $CURRENT_BRANCH
Base:      $BASE_BRANCH
Mode:      [quick/standard/thorough]
Time:      [X] seconds
Findings:  [N] total ([X] blockers)
Accuracy:  [N] verified, [M] hallucinations prevented

Next Steps:
[Action items based on findings]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
