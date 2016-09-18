import CoreData
import RxSwift


extension NotificationCenter {
  func qk_notification(_ name: Notification.Name, object: AnyObject?) -> Observable<Notification> {
    return Observable.create { observer in
      let nsObserver = self.addObserver(forName: name, object: object, queue: nil) { notification in
        observer.on(.next(notification))
      }

      return Disposables.create {
        self.removeObserver(nsObserver)
      }
    }
  }
}


open class RxManagedObjectContextNotification {
  open let managedObjectContext: NSManagedObjectContext
  open let insertedObjects: Set<NSManagedObject>
  open let updatedObjects: Set<NSManagedObject>
  open let deletedObjects: Set<NSManagedObject>

  init(notification: Notification) {
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
    return NotificationCenter.default.qk_notification(.NSManagedObjectContextObjectsDidChange, object: self).map {
      return RxManagedObjectContextNotification(notification: $0)
    }
  }

  /// Returns an observable for the NSManagedObjectContextWillSaveNotification in the current context
  public func qk_willSave() -> Observable<NSManagedObjectContext> {
    return NotificationCenter.default.qk_notification(.NSManagedObjectContextWillSave, object: self).map {
      return $0.object as! NSManagedObjectContext
    }
  }

  /// Returns an observable for the NSManagedObjectContextDidSaveNotification in the current context
  public func qk_didSave() -> Observable<RxManagedObjectContextNotification> {
    return NotificationCenter.default.qk_notification(.NSManagedObjectContextDidSave, object: self).map {
      return RxManagedObjectContextNotification(notification: $0)
    }
  }
}
