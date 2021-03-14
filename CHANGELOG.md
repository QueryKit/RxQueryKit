# RxQueryKit

## 0.7.1

### Enhancements

- Compatibility with RxSwift 6.


## 0.7.0

### Breaking Changes

- Support for Swift < 5 has been removed.

### Enhancements

- Support for Swift 5.
- Support for QueryKit 0.14 and RxSwift ~> 5.1

## 0.6.1

- Supports RxSwift 3 stable.

## 0.6.0

### Enhancements

- Adds support for Swift 3.0.

## 0.5.3

### Bug Fixes

- Fixes a bug where `count()` using a predicate may have not counted objects
  that have been modified to come into the predicate.
- QuerySet subscriptions will now correctly handle abstract and sub entities
  for managed objects.

## 0.5.2

### Bug Fixes

- Improves performance of `count()` and `objects()` observables.
- Fixes a bug where `count()` may have incorrectly updated and shown a negative
  value.

## 0.5.1

Adds support for RxSwift 2.0.

## 0.5.0

Adds support for RxSwift 2.0.0-beta.4.
