# RxQueryKit

[RxSwift](https://github.com/ReactiveX/RxSwift) extensions for QueryKit.

## Usage

### QuerySet

RxQueryKit extends QueryKit and provides methods to evaluate and execute
operations as observables.

```swift
let queryset = Person.queryset(context).filter(Person.age > 25)
```

```swift
queryset.objects().subscribeNext {
  print($0)
}
```

```swift
queryset.count().subscribeNext {
  print("There are now \($0) people who are more than 25.")
}
```

### Managed Object Context

RxQueryKit provides extensions on managed object context to observe when the
objects in a context change or when a context will or did save.

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
pod 'QueryKit', :git => 'https://github.com/QueryKit/QueryKit', :branch => 'swift-2.0'
pod 'RxQueryKit', :git => 'https://github.com/QueryKit/RxQueryKit'
```

## License


