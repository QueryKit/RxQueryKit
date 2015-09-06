import CoreData
import RxSwift
import QueryKit


extension QuerySet {
  func objects() throws -> Observable<[ModelType]> {
    return context.qk_objectsDidChange().map { [unowned self] notification in
      return try self.array()
    }.startWith(try self.array())
  }

  func count() throws -> Observable<Int> {
    return context.qk_objectsDidChange().map { [unowned self] notification in
      return try self.count()
    }.startWith(try self.count())
  }
}