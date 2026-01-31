# Code Style and Conventions

## General Principles
- Follow patterns established by Paul Hudson (Hacking with Swift) and Antoine van der Lee
- Keep code clean, readable, and maintainable
- Use Swift's modern features while maintaining compatibility with iOS 13.0+

## Naming Conventions

### Classes and Structs
- **Prefix**: Use `LC` prefix for app-specific classes
  - Examples: `LCToast`, `LCCategory`, `LCToastTableViewController`, `LCModelController`
- **Suffix**: Use descriptive suffixes
  - ViewControllers: `*ViewController` (e.g., `LCToastTableViewController`)
  - Cells: `*Cell` (e.g., `LCToastTableViewCell`, `GADNativeCollectionViewCell`)
  - Controllers: `*Controller` (e.g., `LCModelController`, `LCExcelController`)

### Properties and Variables
- Use descriptive camelCase names
- Start with lowercase letter
- Examples: `favoriteController`, `currentCategory`, `filteredToasts`

### IBOutlets
- Prefix with `constraint_` for constraint outlets
- Use descriptive names indicating the UI element
- Examples: 
  ```swift
  @IBOutlet var constraint_bottomBanner_Bottom: NSLayoutConstraint!
  @IBOutlet weak var bottomBannerView: GoogleMobileAds.BannerView!
  ```

### Constants
- Use `static let` for constants
- Examples:
  ```swift
  static var appBundleId: String { "com.credif.letscheers" }
  let CellID = "lctoasttableviewcell"
  ```

## Architecture

### MVC Pattern
- **Model**: Data classes in `Sources/Datas/` (e.g., `LCToast`, `LCCategory`)
- **View**: UIViewController subclasses in `Sources/Views/`
- **Controller**: Business logic controllers in `Sources/Controllers/`

### Core Data
- Use `NSFetchedResultsController` for table views
- Implement `NSFetchedResultsControllerDelegate` for automatic updates
- Example pattern:
  ```swift
  extension LCToastTableViewController: NSFetchedResultsControllerDelegate {
      func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, 
                     didChange anObject: Any, 
                     at indexPath: IndexPath?, 
                     for type: NSFetchedResultsChangeType, 
                     newIndexPath: IndexPath?) {
          // Handle changes
      }
  }
  ```

## Code Organization

### MARK Comments
Use MARK comments to organize code sections:
```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - IBActions
// MARK: - Table view data source
// MARK: - UISearchBarDelegate
// MARK: - NSFetchedResultsControllerDelegate
```

### Extensions
- Use extensions for protocol conformance
- Organize related functionality in separate extensions
- Place extensions in `Sources/Extensions/` folder
- Examples:
  - `GADBannerView+.swift`
  - `GADRewardedAd+.swift`
  - `UIApplication+KakaoLink.swift`
  - `UIView+.swift`

### Protocol Extensions
Group by protocol name:
```swift
// MARK: UISearchBarDelegate
extension LCToastTableViewController: UISearchBarDelegate {
    // Implementation
}
```

## Swift Style

### Property Observers
Use `didSet` for UI updates:
```swift
var currentCategory: String? {
    didSet {
        self.updateToasts()
    }
}
```

### Optional Handling
- Use optional chaining when appropriate
- Use `guard let` for early returns
- Use `if let` for conditional unwrapping

### Computed Properties
Use computed properties for derived values:
```swift
var modelController: LCModelController {
    return (UIApplication.shared.delegate as! AppDelegate).modelController
}
```

## Reactive Programming (RxSwift)

### DisposeBag
Always declare a `disposeBag`:
```swift
let disposeBag = DisposeBag()
```

### Binding Pattern
```swift
filteredToasts
    .bind(to: self.tableView.rx.items(cellIdentifier: CellID)) { index, model, cell in
        // Configure cell
    }
    .disposed(by: disposeBag)
```

## UI Development

### Interface Builder + Code
- Use storyboards for view hierarchies
- Use `@IBOutlet` for UI element references
- Use `@IBAction` for event handlers
- Constraints can be managed via IB or programmatically

### Programmatic UI Updates
```swift
self.constraint_bottomBanner_Top.constant = -remainHeight
self.constraint_bottomBanner_Bottom.constant = -remainHeight
```

## Comments

### When to Comment
- Complex business logic
- Non-obvious implementations
- Workarounds or hacks
- TODO items

### Documentation
- Use `//` for single-line comments
- Use `/* */` for multi-line comments
- Keep comments concise and updated

## Error Handling

### Guard Statements
Use guard for early returns:
```swift
guard !keyboardEnabled else {
    return
}
```

### Do-Catch
Use do-catch for error handling when appropriate.

## Type Inference
Let Swift infer types when obvious:
```swift
let toasts = BehaviorSubject<[LCToast]>(value: [])  // Type inferred
```

## Access Control
- Use `private` for internal implementation details
- Use `fileprivate` when needed across extensions in same file
- Use `internal` (default) for app-level access
- Use `public` only when creating frameworks

## Tuist Project Files

### Project.swift Style
- Use `.relativeToRoot()` for path helpers
- Define arrays at top for clarity (e.g., `skAdNetworks`)
- Use string interpolation for paths:
  ```swift
  projects.map { "Projects/\($0)" }
  ```

## Best Practices
1. **Don't regenerate project without file insert/delete** - Only run `tuist generate` when adding/removing files
2. **Follow existing patterns** - Match the style of surrounding code
3. **Keep functions focused** - Single responsibility principle
4. **Avoid force unwrapping** - Use safe unwrapping techniques
5. **Use meaningful names** - Self-documenting code is best
