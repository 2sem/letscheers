# Task Completion Checklist

When a task is completed, follow this checklist to ensure quality and consistency.

## Before Committing Code

### 1. Code Review
- [ ] Code follows the established style guide (see `code_style_and_conventions.md`)
- [ ] Naming conventions are consistent with existing code
- [ ] LC prefix is used for new app-specific classes
- [ ] MARK comments are added for organization
- [ ] No force unwrapping (`!`) unless absolutely necessary

### 2. Tuist Project Management
- [ ] If files were added or removed, run `mise x -- tuist generate`
- [ ] **IMPORTANT**: Do NOT regenerate project if only editing existing files
- [ ] Verify the workspace builds after generation

### 3. Build & Test
- [ ] Project builds successfully in Xcode
  ```bash
  mise x -- tuist build
  ```
- [ ] Test in simulator for target iOS version (13.0+)
- [ ] No compiler warnings introduced
- [ ] Dark mode appearance is maintained (app is dark mode only)

### 4. Dependencies
- [ ] If new dependencies were added to `Package.swift`, run:
  ```bash
  mise x -- tuist install
  ```
- [ ] Verify version constraints are appropriate (using `.upToNextMajor` or `.exact`)

### 5. Interface Builder
- [ ] Storyboard changes are saved
- [ ] IBOutlet connections are valid
- [ ] IBAction connections are valid
- [ ] Auto Layout constraints are properly set

### 6. Resources
- [ ] New assets are added to appropriate `.xcassets` catalog
- [ ] Localization is considered (if applicable)
- [ ] Resources are properly referenced in code

## Code Quality Checks

### Swift Best Practices
- [ ] Optional handling is safe (no forced unwrapping without justification)
- [ ] Memory management is sound (no retain cycles)
- [ ] DisposeBag is properly used for RxSwift bindings
- [ ] Property observers (didSet) update UI correctly

### Architecture
- [ ] MVC pattern is followed
- [ ] Extensions are used for protocol conformance
- [ ] Business logic is in appropriate controllers
- [ ] View controllers focus on view logic

### Performance
- [ ] No unnecessary memory allocations in loops
- [ ] Images are optimized
- [ ] Network calls are asynchronous
- [ ] Core Data operations are efficient

## Before Deployment

### Version Management
- [ ] Update `MARKETING_VERSION` in `debug.xcconfig` and `release.xcconfig` if needed
- [ ] Build number will be auto-incremented by fastlane

### Configuration
- [ ] Debug and Release configurations are both valid
- [ ] Bundle ID is correct: `com.credif.letscheers`
- [ ] App capabilities are properly configured

### Ads Integration
- [ ] Google Mobile Ads work correctly
- [ ] Ad unit IDs are correct
- [ ] Ads display properly on different screen sizes

### Third-Party Services
- [ ] Firebase services are functional (if touched)
- [ ] Kakao sharing works (if modified)
- [ ] App Tracking Transparency is respected

## Git Workflow

### Before Commit
- [ ] Stage only relevant files
  ```bash
  git add <specific-files>
  ```
- [ ] Write descriptive commit message
- [ ] Commit includes co-author tag:
  ```
  Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
  ```

### Branch Management
- [ ] Working on appropriate feature branch
- [ ] Branch name is descriptive
- [ ] Main branch is protected

## CI/CD Considerations

### GitHub Actions
- [ ] Workflow will run on push (`.github/workflows/deploy-ios.yml`)
- [ ] Secrets are properly configured in repository
- [ ] Xcode version matches (16.2)

### Fastlane
- [ ] Changes don't break fastlane deployment
- [ ] Certificate and provisioning profile are valid

## Documentation

### Code Documentation
- [ ] Complex logic has comments explaining "why"
- [ ] Public interfaces are documented
- [ ] TODOs are tracked or removed

### Memory Updates (Serena)
- [ ] Update relevant memory files if project structure changed
- [ ] Update commands if new tools/scripts added
- [ ] Update conventions if new patterns introduced

## Final Checks

### User Experience
- [ ] App launches successfully
- [ ] UI is responsive
- [ ] Navigation flows correctly
- [ ] Error states are handled gracefully

### Compatibility
- [ ] Works on iOS 13.0+ (minimum deployment target)
- [ ] Works on iPhone and iPad
- [ ] Dark mode only (as per design)

### Security
- [ ] No sensitive data in code
- [ ] API keys use environment variables or secure storage
- [ ] Network security exceptions are justified
- [ ] User data is handled securely

## Optional (Context Dependent)

### When Adding Features
- [ ] Feature is complete and functional
- [ ] Edge cases are handled
- [ ] User feedback (errors, success states) is provided

### When Fixing Bugs
- [ ] Root cause is identified and fixed
- [ ] Similar issues elsewhere are checked
- [ ] Prevention strategy is considered

### When Refactoring
- [ ] Functionality remains unchanged
- [ ] No new bugs introduced
- [ ] Code is cleaner and more maintainable

---

## Quick Command Reference

```bash
# Build project
mise x -- tuist build

# Run in Xcode
open letscheers.xcworkspace

# Commit changes
git add <files>
git commit -m "message

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Deploy to TestFlight (via GitHub Actions or manually)
fastlane ios release description:"changes" isReleasing:false
```
