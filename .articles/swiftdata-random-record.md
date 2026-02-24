# The Right Way to Pick a Random Record in SwiftData

A shuffle button crash taught me more about SwiftData's fetch mechanics than any documentation ever did.

---

## The Bug That Started It All

The letscheers app has a shuffle button. Tap it, get a random toast phrase. Simple enough. Then one day, the app crashed with an arithmetic overflow, and the culprit turned out to be this innocuous-looking function:

```swift
// Old code - crashes when toasts array is empty
let cnt = UInt32(toasts.count)
value = toasts[Int(arc4random_uniform(cnt - 1))]
```

When `toasts.count` is zero, `UInt32(0) - 1` wraps around to `4294967295`. That is a spectacular number to pass to `arc4random_uniform`. The crash is immediate and total.

The fix for the overflow itself is straightforward — guard against an empty array. But fixing the crash forced me to look at the broader picture: where should this random fetch even happen? The app had recently migrated to SwiftData, and the old approach of holding a fully-loaded array in memory was ripe for a rethink.

---

## The Approaches I Considered (And Why Most of Them Are Wrong)

### Approach 1: Store all categories in the ViewModel

```swift
// ViewModel
var allToastCategories: [ToastCategory] = []
```

This adds state that exists solely to support one feature: the shuffle button. The ViewModel now carries the cognitive burden of keeping that array in sync with the underlying store. Any time data changes, you have to remember to update it. Unnecessary state is a bug waiting to happen.

### Approach 2: Store all toasts in the ViewModel

```swift
// ViewModel
var allToasts: [Toast] = []
```

Slightly worse. Now you are duplicating what SwiftData already manages for you through its identity map. SwiftData tracks every fetched object and keeps them consistent. Maintaining a parallel array of all toasts means you have two sources of truth. That is never a good place to be.

### Approach 3: Fetch everything on demand

```swift
let toasts = try? modelContext.fetch(FetchDescriptor<Toast>())
let toast = toasts?.randomElement()
```

This is the honest version of approach 2 - at least it does not persist the duplicated data. But it still loads every single `Toast` object into memory every time the user taps shuffle. For a small dataset this is invisible. For a larger one, or a lower-end device, you are doing significant work to retrieve exactly one record.

### Approach 4: Use `@Query` to always load everything

```swift
@Query private var allToasts: [Toast]
```

This is perhaps the most tempting approach if you are already comfortable with `@Query`. The problem is that `@Query` keeps its results live and up to date. On a screen that displays a list, that is exactly what you want. On a screen that only needs one random record when a button is tapped, you are paying for continuous synchronization you never use. Every insert and delete in the store will cause this property to re-evaluate, even when the shuffle button has not been touched.

---

## The Right Approach: `fetchCount` + `fetchOffset` + `fetchLimit`

SwiftData's `ModelContext` exposes `fetchCount(_:)`, which translates directly to a `COUNT(*)` query at the database level. It is O(1) with respect to the number of records. No objects are materialized. No memory is allocated for your data.

Once you have the count, you generate a random index, set it as the `fetchOffset`, and request exactly one record with `fetchLimit: 1`.

```swift
private func showRandomToast() {
    let count = (try? modelContext.fetchCount(FetchDescriptor<Toast>())) ?? 0
    guard count > 0 else { return }

    var descriptor = FetchDescriptor<Toast>()
    descriptor.fetchOffset = Int.random(in: 0..<count)
    descriptor.fetchLimit = 1

    guard let toast = try? modelContext.fetch(descriptor).first else { return }
    // present toast to the user
}
```

Why this works so well:

- `fetchCount` hits the database once for a scalar value. No Swift objects are created.
- `fetchOffset` tells SQLite to skip rows. The database engine does this efficiently; it does not load the skipped records into memory.
- `fetchLimit: 1` means exactly one row is returned and exactly one `Toast` object is materialized.
- The guard on `count > 0` makes the arithmetic overflow impossible by construction.

The total memory cost of this operation is one `Toast` object. The database does the heavy lifting.

---

## What This Taught Me About SwiftData

The instinct when working with SwiftData is to think in terms of arrays and property wrappers. `@Query` is so convenient that it is easy to reach for it by default. But SwiftData sits on top of Core Data, which sits on top of SQLite, and SQLite is extremely good at answering questions like "give me one row starting at offset N."

When you need a single record, fight the urge to fetch all records and pick from them in Swift. Delegate the selection to the database. That is what `fetchOffset` and `fetchLimit` are for.

The shuffle button now works without loading a single unnecessary object. More importantly, it cannot overflow, because the count is always checked before any arithmetic is performed.

---

## Key Takeaways

- Use `modelContext.fetchCount(_:)` when you need a count - it is a scalar query, not a fetch.
- `fetchOffset` and `fetchLimit` together let you retrieve exactly one record by position.
- Avoid holding SwiftData model objects in extra arrays or ViewModel properties - you are fighting the framework's identity map.
- `@Query` is a live subscription; use it only where you need live updates, not for one-time reads.

---

*Tags: Swift, SwiftData, iOS, Mobile Development*
