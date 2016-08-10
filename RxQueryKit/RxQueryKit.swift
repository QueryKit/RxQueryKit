import CoreData
import RxSwift
import QueryKit
import Foundation


private func managedObjectMatchesEntity(entityNames: [String]) -> (NSManagedObject) -> Bool {
  return { object in
    if let name = object.entity.name {
      return entityNames.contains(name)
    }

    return false
  }
}


/// Extension to QuerySet to provide observables
extension QuerySet {
  private var entityNames: [String] {
    if let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) {
      return [entityName] + entity.subentitiesByName.keys
    }

    return [entityName]
  }

  /// Performs a query for all objects matching the set predicate ordered by any set sort descriptors.
  /// Emits a value with an array of all objects when the managed object context is changed.
  public func objects() throws -> Observable<[ModelType]> {
    let initial = try self.array()
    let filter = managedObjectMatchesEntity(entityNames)

    return Observable.create { observer in
      observer.on(.Next(initial))

      return self.context.qk_objectsDidChange().subscribeNext { notification in
        let insertedObjects = notification.insertedObjects.filter(filter)
        let updatedObjects = notification.updatedObjects.filter(filter)
        let deletedObjects = notification.deletedObjects.filter(filter)

        if insertedObjects.isEmpty && updatedObjects.isEmpty && deletedObjects.isEmpty {
          return
        }

        do {
          let objects = try self.array()
          observer.onNext(objects)
        } catch {
          observer.onError(error)
        }
      }
    }
  }

  /// Performs a query for the count of all objects matching the set predicate.
  /// Emits an Int containing the amount of objects matching the predicate and updates when the managed object context is changed.
  public func count() throws -> Observable<Int> {
    var count: Int = try self.count()
    let filter = managedObjectMatchesEntity(entityNames)

    return Observable.create { observer in
      observer.on(.Next(count))

      return self.context.qk_objectsDidChange().subscribeNext { notification in
        let updatedObjects = notification.updatedObjects.filter(filter)

        if !updatedObjects.isEmpty && self.predicate != nil {
          do {
            count = try self.count()
            observer.onNext(count)
          } catch {
            observer.onError(error)
          }
          return
        }

        let insertedObjects = notification.insertedObjects.filter(filter)
        let deletedObjects = notification.deletedObjects.filter(filter)

        var delta = 0

        if let predicate = self.predicate {
          delta += (insertedObjects as NSArray).filteredArrayUsingPredicate(predicate).count
          delta -= (deletedObjects as NSArray).filteredArrayUsingPredicate(predicate).count
        } else {
          delta += insertedObjects.count
          delta -= deletedObjects.count
        }

        if delta != 0 {
          count += delta
          observer.on(.Next(count))
        }
      }
    }
  }
}