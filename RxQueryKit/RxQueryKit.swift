import CoreData
import RxSwift
import QueryKit
import Foundation


/// Extension to QuerySet to provide observables
extension QuerySet {
  /// Performs a query for all objects matching the set predicate ordered by any set sort descriptors.
  /// Emits a value with an array of all objects when the managed object context is changed.
  public func objects() throws -> Observable<[ModelType]> {
    return context.qk_objectsDidChange().map { notification in
      return try self.array()
    }.startWith(try self.array())
  }

  /// Performs a query for the count of all objects matching the set predicate.
  /// Emits an Int containing the amount of objects matching the predicate and updates when the managed object context is changed.
  public func count() throws -> Observable<Int> {
    var count:Int = try self.count()

    return Observable.create { observer in
      observer.on(.Next(count))

      return self.context.qk_objectsDidChange().subscribeNext { notification in
        let insertedObjects = notification.insertedObjects.filter {
          $0.entity.name == self.entityName
        }
        let deletedObjects = notification.deletedObjects.filter {
          $0.entity.name == self.entityName
        }

        if let predicate = self.predicate {
          count += (insertedObjects as NSArray).filteredArrayUsingPredicate(predicate).count
          count -= (deletedObjects as NSArray).filteredArrayUsingPredicate(predicate).count
        } else {
          count += insertedObjects.count
          count -= deletedObjects.count
        }

        observer.on(.Next(count))
      }
    }
  }
}