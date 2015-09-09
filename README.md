<img src="https://github.com/QueryKit/QueryKit/blob/master/QueryKit.png" width=96 height=120 alt="QueryKit Logo" />

# RxQueryKit

[RxSwift](https://github.com/ReactiveX/RxSwift) extensions for QueryKit.

## Usage

### QuerySet

RxQueryKit extends QueryKit and provides methods to evaluate and execute
operations as observables.

```swift
let queryset = Person.queryset(context)
    .filter { $0.age > 25 }
    .orderBy { $0.name.ascending }
```

You can subscribe to any changes to the results of this queryset using the following:

```swift
queryset.objects().subscribeNext {
  print($0)
}
```

You can also subscribe to the number of matching objects:

```swift
queryset.count().subscribeNext {
  print("There are now \($0) people who are more than 25.")
}
```

### Managed Object Context

RxQueryKit provides extensions on managed object context to observe when the
objects in a context change or when a context will or did save.

It provides a type safe structure providing the changes objects.

```swift
context.qk_objectsDidChange().subscribeNext { notification in
  print('Objects did change:')
  print(notification.insertedObjects)
  print(notification.updatedObjects)
  print(notification.deletedObjects)
}

context.qk_willSave().subscribeNext { notification in
  print('Context will save')
}

context.qk_didSave().subscribeNext { notification in
  print('Context did save')
}
```

## Installation

[CocoaPods](http://cocoapods.org) is the recommended way to add RxQueryKit to your project.

```ruby
pod 'RxQueryKit'
```

## License

QueryKit is released under the BSD license. See [LICENSE](LICENSE).
