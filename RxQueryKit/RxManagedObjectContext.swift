import CoreData
import RxSwift


extension NSNotificationCenter {
  func rx_notification(name: String, object: AnyObject?) -> Observable<NSNotification> {
    return Observable.create { observer in
      let nsObserver = self.addObserverForName(name, object: object, queue: nil) { notification in
        observer.on(.Next(notification))
      }

      return AnonymousDisposable {
        self.removeObserver(nsObserver)
      }
    }
  }
}


public class RxManagedObjectContextNotification {
  public let managedObjectContext:NSManagedObjectContext
  public let insertedObjects:Set<NSManagedObject>
  public let updatedObjects:Set<NSManagedObject>
  public let deletedObjects:Set<NSManagedObject>

  init(notification: NSNotification) {
    managedObjectContext = notification.object as! NSManagedObjectContext

    insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
    updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
    deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []
  }
}


/// Extensions to NSManagedObjectContext providing observables for change and save notifications
extension NSManagedObjectContext {
  /// Returns an observable for the NSManagedObjectContextObjectsDidChangeNotification in the current context
  public func qk_objectsDidChange() -> Observable<RxManagedObjectContextNotification> {
    return NSNotificationCenter.defaultCenter().rx_notification(NSManagedObjectContextObjectsDidChangeNotification, object: self).map {
      return RxManagedObjectContextNotification(notification: $0)
    }
  }

  /// Returns an observable for the NSManagedObjectContextWillSaveNotification in the current context
  public func qk_willSave() -> Observable<NSManagedObjectContext> {
    return NSNotificationCenter.defaultCenter().rx_notification(NSManagedObjectContextWillSaveNotification, object: self).map {
      return $0.object as! NSManagedObjectContext
    }
  }

  /// Returns an observable for the NSManagedObjectContextDidSaveNotification in the current context
  public func qk_didSave() -> Observable<RxManagedObjectContextNotification> {
    return NSNotificationCenter.defaultCenter().rx_notification(NSManagedObjectContextDidSaveNotification, object: self).map {
      return RxManagedObjectContextNotification(notification: $0)
    }
  }
}
