# BSDataManager

A simple manager for working with Core Data.

**Special consideration**
This is the initial commit. Only basic functionality is available for now.

## Usage

You can use both a singleton instance and a separately initialized instance.
If you intend to use a singleton shared instance you must follow these requirements:

1. Your project must contain a data model file.
> *DataModelFileName*.xcdatamodel

2. To use the default data model, the file must have the same name as the project, words separated by underscores or without any separators.
> Project name: "*My Cool Data Project*"
>
> Model file: "*My_Cool_Data_Project*.xcdatamodel" or "*MyCoolDataProject*.xcdatamodel"

Usage:
```swift
import BSDataManager
let sharedManager = BSDataManager.shared
```

+ If you have a different data model name, then before using the singleton object you need to initialize using the static throwing function `initializeShared(modelName: String? = nil, in bundle: Bundle? = nil)`. ***Otherwise, a fatal error will occur!***

For modelName parameter you should pass data model name without file extension or `nil` to use default name (as mentioned above).

For bundle parameter, if data model is located in other bundle, you should pass that bundle instance object. If data model is in same bundle as your project then simply pass `nil`.
Both parameters default values are `nil`.

After initialization completed you can use shered instance as usual.

```swift
do {
    try BSDataManager.initializeShared(modelName: "MyModelName", in: nil)
    /*
    or simply
    
    try BSDataManager.initializeShared(modelName: "MyModelName")
    */
} catch {
    fatalError("Error: \(error)")
}

let sharedManager = BSDataManager.shared
```

> ***Remember, after the error occurs you can't use the shared instance.***


## Data fetching

Suppose, you have an entity named "Book" and a subclass of `NSManagedObject` for it (either auto-generated or manually created). Suppose, the class name is `Book`, too.

If you want to fetch all `Book` "records" then you can call the following function as shown blow:

```swift
func fetch<T>(
    asFaults: Bool = true,
    where predicate: NSPredicate? = nil,
    sortBy sortDescriptors: [NSSortDescriptor]? = nil
) throws -> [T] where T: NSManagedObject
```

```swift
let dataManager = BSDataManager.shared
let books: [Book] = try! dataManager.fetch()
```

And you can get other types of fetch results as well:

```swift
let bookDictionary: NSDIctionary = try! dataManager.fetch(for: Book.self)
let bookSwiftDictionary: [String : Any] = try! dataManager.fetchDict(for: Book.self)
let numberOfBooks: Int = try! dataManager.count(for: Book.self)
```

These are simplified versions of the basic generic functions such as following:

```swift
func fetch<T, U>(
    for type: T.Type,
    where predicate: NSPredicate? = nil,
    sortBy sortDescriptors: [NSSortDescriptor]? = nil,
    fields: [String]? = nil,
    distinctResults: Bool = false,
    groupBy: [String]? = nil,
    havingPredicate: NSPredicate? = nil
) throws -> [U] where T: NSManagedObject, U: NSDictionary
```

**Remember**, the fuctions can throw an error (`BSDataManagerError`). You should call any fetching function in `do-catch` block and handle the error.

## Object (record) creation and deletion

```swift
var book: Book = dataManager.newRecord()
book.title = "The Mysterious Island"
book.genre = "Novel"
book.author = "Jules Verne"
try! dataManager.saveChanges()
```

or

```swift
let keyedValues: [String : Any] = [
    "title" : "The Mysterious Island",
    "genre" : "Novel",
    "author" : "Jules Verne"
]
var book: Book = dataManager.newRecord(keyedValues: keyedValues)
try! dataManager.saveChanges()
```

To delete existing object:
```swift
dataManager.deleteRecord(book)
try! dataManager.saveChanges()
```
