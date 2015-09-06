import CoreData
import RxSwift
import QueryKit


/// Extension to QuerySet to provide observables
extension QuerySet {
  /// Performs a query for all objects matching the set predicate ordered by any set sort descriptors.
  /// Emits a value with an array of all objects when the managed object context is changed.
  func objects() throws -> Observable<[ModelType]> {
    return context.qk_objectsDidChange().map { [unowned self] notification in
      return try self.array()
    }.startWith(try self.array())
  }

  /// Performs a query for the count of all objects matching the set predicate.
  /// Emits an Int containing the amount of objects matching the predicate and updates when the managed object context is changed.
  func count() throws -> Observable<Int> {
    return context.qk_objectsDidChange().map { [unowned self] notification in
      return try self.count()
    }.startWith(try self.count())
  }
}